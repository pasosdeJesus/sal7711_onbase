# encoding: UTF-8
require_dependency "sal7711_gen/concerns/controllers/buscar_controller"

require 'tiny_tds'
require 'sambal'

module Sal7711Gen
  class BuscarController < ApplicationController
    #skip_before_action :verify_authenticity_token, if: :autenticado_por_ip?
    # Necesario para EZ-Proxy, por lo mismo se requiere authorize en otros métodos

    def autenticado_por_ip?
      current_usuario && current_usuario.autenticado_por_ip
    end

    include Sal7711Gen::Concerns::Controllers::BuscarController
  
    include ActionView::Helpers::AssetUrlHelper
    
    #helper Rails.application.routes.url_helpers

    # Conexión a base de datos
    @@hbase = {:username => ENV["USUARIO_HBASE"],
               :password => ENV["CLAVE_HBASE"],
               :host => ENV["IP_HBASE"], 
               :timeout => 30
    }
    # Conexión a directorio compartido con archivos
    @@parsmb = {
      domain: ENV['DOMINIO'],
      host: ENV['IP_HBASE'],
      share: ENV['CARPETA'],
      user: ENV['USUARIO_DOMINIO'],
      password: ENV['CLAVE_DOMINIO'],
      port: 445
    }

    def autentica_especial
      puts "OJO ipx, request=", request.inspect;
      org = ::Organizacion.joins(:ip_organizacion)
        .where('?<<=ip', request.remote_ip).take
      if !current_usuario
        nips = ::IpOrganizacion.where('? <<= ip', request.remote_ip).
          count('organizacion_id', distinct: true)
        if nips === 0
          if (current_usuario && ::Organizacion.
              where('usuarioip_id=?', current_usuario.id).
              count('*') > 0)
            # Si la organización ya no se autentica por IP se termina
            # sesión de usuario
            sign_out(current_usuario)
          end
          return false
        elsif nips > 1
          ::Ability::ultimo_error_aut = 'IP coincide con varias organizaciones'
          puts "** Error: ", ::Ability::ultimo_error_aut 
          return false
        else
          if !org.usuarioip_id
            ::Ability.ultimo_error_aut = 'Organización sin Usuario IP'
            puts "** Error: ", ::Ability::ultimo_error_aut 
            return false
          end
          us = ::Usuario.find(org.usuarioip_id)
          sign_in(us) #, bypass: true#, store: false
          #byebug
          current_usuario.autenticado_por_ip = true
          current_usuario.save!
          return true;
        end
      end
      if current_usuario && current_usuario.autenticado_por_ip
        if org.opciones_url_nombre_cif
          Rails.configuration.action_mailer.default_url_options[:host] = 
            org.opciones_url_nombre_cif
        end
        if org.opciones_url_puerto_cif
          Rails.configuration.action_mailer.default_url_options[:port] = 
            org.opciones_url_puerto_cif
        end
        if org.opciones_url_nombre_nocif
          Rails.configuration.x.serv_nocif[:host] = 
            org.opciones_url_nombre_nocif
        end
        if org.opciones_url_puerto_nocif
          Rails.configuration.x.serv_nocif[:port] = 
            org.opciones_url_puerto_nocif
        end
        puts "Rails.configuration.action_mailer.default_url_options=",
          Rails.configuration.action_mailer.default_url_options
        puts "Rails.configuration.x.serv_nocif=",
          Rails.configuration.x.serv_nocif
      end
    end

    def conecta
      if !@client || @client.dead? || !@client.active?
        @client = TinyTds::Client.new(@@hbase)
        @client.execute("USE OnBase").do;
      end
      if @client.dead?
        puts "dead"
        byebug
      end
      if !@client.active?
        puts "no active";
        byebug
      end
    end
  
    def cruza_tabla_consulta(num, valor, op = ' = ')
      numi = num.to_i
      valore = @client.escape(valor)
      @tablas |= ["keyxitem#{numi}", "keytable#{numi}"]
      return " AND keyxitem#{numi}.itemnum=itemdata.itemnum 
          AND keyxitem#{numi}.keywordnum=keytable#{numi}.keywordnum
      AND keytable#{numi}.keyvaluechar #{op} '#{valore}'"
    end
 
    def verifica_fechas
      cprob = ''
      c="SELECT itemnum, itemname FROM itemdata 
      WHERE itemname LIKE 'Prensa Cinep%' 
      AND itemnum NOT IN (SELECT itemnum FROM keyitem103);"
      r = @client.execute(c)
      r.try(:each) do |fila|
          cprob += "<br>Falta fecha en artículo #{fila['itemnum']}: #{fila['itemname']}"
      end
      r.do
      c="SELECT itemdata.itemnum, itemdata.itemname FROM itemdata 
      JOIN keyitem103 ON itemdata.itemnum=keyitem103.itemnum 
      WHERE keyitem103.keyvaluedate<'1960-01-01';"
      r = @client.execute(c)
      r.try(:each) do |fila|
          cprob += "<br>Fecha muy antigua en artículo #{fila['itemnum']}: #{fila['itemname']}"
      end
      r.do
      c="SELECT itemdata.itemnum, itemdata.itemname FROM itemdata 
      JOIN keyitem103 ON itemdata.itemnum=keyitem103.itemnum 
      WHERE keyitem103.keyvaluedate>'#{Time.now.strftime("%Y/%m/%d")}';"
      r = @client.execute(c)
      r.try(:each) do |fila|
          cprob += "<br>Fecha en el futuro en artículo #{fila['itemnum']}: #{fila['itemname']}"
      end
      r.do

      return cprob 
    end
 
    def verifica_fuenteprensa
      cprob = ''
      c="SELECT itemnum, itemname FROM itemdata 
      WHERE itemname LIKE 'Prensa Cinep%' 
      AND itemnum NOT IN (SELECT itemnum FROM keyxitem101);"
      r = @client.execute(c)
      r.try(:each) do |fila|
          cprob += "<br>Falta fuente en artículo #{fila['itemnum']}: #{fila['itemname']}"
      end
      r.do

      c="SELECT DISTINCT keyvaluechar FROM keytable101;"
      r = @client.execute(c)
      r.try(:each) do |fila|
        if fila['keyvaluechar'] && fila['keyvaluechar'].strip != ''
          nf = fila["keyvaluechar"].strip
          if Sip::Fuenteprensa.
            where("SUBSTRING(nombre FROM 1 FOR 45) = '#{nf}'").count == 0
            cprob += "<br>Fuente #{nf} de SQL Server no aparece en PostgreSQL"
          end
        end
      end


      return cprob
    end

    def verifica_paginas
      cprob = ''
      c="SELECT itemnum, itemname FROM itemdata 
      WHERE itemname LIKE 'Prensa Cinep%' 
      AND itemnum NOT IN (SELECT itemnum FROM keyxitem104);"
      r = @client.execute(c)
      r.try(:each) do |fila|
          cprob += "<br>Falta página en artículo #{fila['itemnum']}: #{fila['itemname']}"
      end
      r.do

      return cprob
    end

    def verifica_categorias
      cprob = ''
      c="SELECT itemnum, itemname FROM itemdata 
      WHERE itemname LIKE 'Prensa Cinep%' 
      AND itemnum NOT IN (SELECT itemnum FROM keyxitem112);"
      r = @client.execute(c)
      r.try(:each) do |fila|
          cprob += "<br>Falta primera categoria en artículo #{fila['itemnum']}: #{fila['itemname']}"
      end
      r.do

      c="SELECT DISTINCT keyvaluechar FROM keytable112;"
      r = @client.execute(c)
      r.try(:each) do |fila|
        if fila['keyvaluechar'] && fila['keyvaluechar'].strip != ''
          nc = fila["keyvaluechar"].strip
          if Sip::Fuenteprensa.
            where("SUBSTRING(nombre FROM 1 FOR 45) = '#{nc}'").count == 0
            cprob += "<br>Categoria 1 #{nc} de SQL Server no aparece en PostgreSQL"
          end
        end
      end

      c="SELECT DISTINCT keyvaluechar FROM keytable113;"
      r = @client.execute(c)
      r.try(:each) do |fila|
        if fila['keyvaluechar'] && fila['keyvaluechar'].strip != ''
          nc = fila["keyvaluechar"].strip
          if Sip::Fuenteprensa.
            where("SUBSTRING(nombre FROM 1 FOR 45) = '#{nc}'").count == 0
            cprob += "<br>Categoria 2 #{nc} de SQL Server no aparece en PostgreSQL"
          end
        end
      end

      c="SELECT DISTINCT keyvaluechar FROM keytable114;"
      r = @client.execute(c)
      r.try(:each) do |fila|
        if fila['keyvaluechar'] && fila['keyvaluechar'].strip != ''
          nc = fila["keyvaluechar"].strip
          if Sip::Fuenteprensa.
            where("SUBSTRING(nombre FROM 1 FOR 45) = '#{nc}'").count == 0
            cprob += "<br>Categoria 3 #{nc} de SQL Server no aparece en PostgreSQL"
          end
        end
      end

      return cprob
    end

    def verifica_departamentos
      cprob = ''
      ds = Sip::Departamento.all.where(id_pais: 170).
        where("nombre != 'EXTERIOR'")
      ds.each do |d|
        puts d.nombre[0..44]
        c="SELECT COUNT(*) AS cuenta FROM keytable108 WHERE keyvaluechar='#{d.nombre[0..44]}';"
        cuentar = @client.execute(c)
        @numregistros = cuentar.first["cuenta"]
        if @numregistros != 1
          cprob += "<br>Departamento #{d.nombre} aparece #{@numregistros} veces"
        end
      end
      c="SELECT keyvaluechar FROM keytable108;"
      r = @client.execute(c)
      r.try(:each) do |fila|
        if fila['keyvaluechar'] && fila['keyvaluechar'].strip != ''
          nd = fila["keyvaluechar"].strip
          if Sip::Departamento.
            where("SUBSTRING(nombre FROM 1 FOR 45) = '#{nd}'").count == 0
            cprob += "<br>Departamento #{nd} de SQL Server no aparece en PostgreSQL"
          end
        end
      end

      return cprob
    end 

    def verifica_municipios
      cprob = ''
      c="SELECT keyvaluechar FROM keytable110;"
      r = @client.execute(c)
      r.try(:each) do |fila|
        if fila['keyvaluechar'] && fila['keyvaluechar'].strip != ''
          nd = fila["keyvaluechar"].strip
          if Sip::Municipio.
            where("SUBSTRING(nombre FROM 1 FOR 45) = '#{nd}'").count == 0
            cprob += "<br>Municipio #{nd} de SQL Server no aparece en PostgreSQL"
          end
        end
      end

      return cprob
    end 

    def prepara_pagina
      authorize! :read, Sal7711Gen::Articulo
      conecta
      #verifica_departamentos
      #erifica_municipios
      @tablas = ["keyitem103", "itemdata"]
      w = ""
      if (params[:buscar] && params[:buscar][:fechaini] && 
          params[:buscar][:fechaini] != '')
        pfi = @client.escape(params[:buscar][:fechaini])
        pfid = Date.strptime(pfi, '%d-%m-%Y')
        w = " AND keyvaluedate>='#{pfid.strftime('%Y-%m-%d')}'"
      end
      if(params[:buscar] && params[:buscar][:fechafin] && 
         params[:buscar][:fechafin] != '')
        pff = @client.escape(params[:buscar][:fechafin])
        pffd = Date.strptime(pff, '%d-%m-%Y')
        w += " AND keyvaluedate<='#{pffd.strftime('%Y-%m-%d')}'"
      end
      if (params[:buscar] && params[:buscar][:mundep] && 
          params[:buscar][:mundep] != '')
        pmd = params[:buscar][:mundep].split(" / ")
        
        if pmd.length == 1 # solo departamento
          w += cruza_tabla_consulta(108, pmd[0].slice(0,45))
        else # departamento y municipio
          w += cruza_tabla_consulta(108, pmd[1].slice(0, 45))
          w += cruza_tabla_consulta(110, pmd[0].slice(0, 45))
        end
      end
  
      if(params[:buscar] && params[:buscar][:fuente] &&
         params[:buscar][:fuente] != '')
        fu = Sip::Fuenteprensa.all.find(params[:buscar][:fuente])
        if fu
          w += cruza_tabla_consulta(101, fu.nombre)
        else
          w += cruza_tabla_consulta(101, 'loco')
        end
      end

      if(params[:buscar] && params[:buscar][:pagina] && 
         params[:buscar][:pagina] != '')
        w += cruza_tabla_consulta(104, params[:buscar][:pagina])
      end
      if (w == '' && (!params[:buscar] || !params[:buscar][:categoria] || 
                      params[:buscar][:categoria] == ''))
        w = " AND 1=2"
      end
      if(params[:buscar] && params[:buscar][:categoria] && 
         params[:buscar][:categoria] != '')
        ccat = params[:buscar][:categoria].upcase.split(' ')[0]
        if ccat.ends_with? "*"
          op = ' LIKE '
          cod = "#{ccat.split('*')[0]}%"
        else 
          cat = Sal7711Gen::Categoriaprensa.where('codigo=?', ccat).take;
          if cat && cat.supracategoria
            op = ' LIKE '
            cod = "#{cat.codigo}%"
          elsif cat
            op = ' = '
            cod = cat.codigo.to_s
          else
            op = ' = '
            cod = 'loco' 
          end
        end
        tablaspre = @tablas
        w1 = w + cruza_tabla_consulta(112, cod, op)
        f = "FROM (SELECT itemdata.*, keyitem103.keyvaluedate, 1 as prio FROM #{@tablas.join(", ")} " +
          "WHERE keyitem103.itemnum=itemdata.itemnum #{w1}"
        @tablas = tablaspre
        w2 = w + cruza_tabla_consulta(113, cod, op)
        f += " UNION SELECT itemdata.*, keyitem103.keyvaluedate, 2 as prio FROM #{@tablas.join(", ")} " +
          "WHERE keyitem103.itemnum=itemdata.itemnum #{w2}"
        @tablas = tablaspre
        w3 = w + cruza_tabla_consulta(114, cod, op)
        f += " UNION SELECT itemdata.*, keyitem103.keyvaluedate, 3 as prio FROM #{@tablas.join(", ")} " +
          "WHERE keyitem103.itemnum=itemdata.itemnum #{w3}"
        f += ") AS sub"
      else
        f = "FROM (SELECT itemdata.itemnum AS itemnum, itemdata.itemname AS itemname," +
          "keyitem103.keyvaluedate AS keyvaluedate, 1 as prio FROM #{@tablas.join(", ")} " +
          "WHERE keyitem103.itemnum=itemdata.itemnum #{w}) AS sub"
      end
  
      c = "SELECT count(*) AS cuenta #{f}"
      puts "OJO c=#{c}"
      #byebug
      cuentar = @client.execute(c)
      @numregistros = cuentar.first["cuenta"]
      @coltexto = "itemname"
      @colid = "itemnum"
      pag = 1
      if (params[:pag])
        pag = params[:pag].to_i
      end
      @entradas = WillPaginate::Collection.create(
        pag, @@porpag, @numregistros
      ) do |paginador|
        # Solucion hasta MS-SQL 2008 de acuerdo a 
        # http://stackoverflow.com/questions/2135418/equivalent-of-limit-and-offset-for-sql-server
        #c = ";WITH Results_CTE AS
        #(
        #	    SELECT itemdata.itemname, 
        #			row_number() over (order by itemdata.itemname) as rownum 
        #			#{f}
        #)
        #SELECT *
        #	FROM Results_CTE
        #WHERE RowNum >= #{paginador.offset}
        #AND RowNum < #{paginador.offset + paginador.per_page}"
 
        c="SELECT itemnum, itemname #{f} 
          ORDER BY prio, keyvaluedate 
          OFFSET #{paginador.offset} ROWS
        FETCH NEXT #{paginador.per_page} ROWS ONLY"
        puts "OJO q=#{c}"
        if !@client.active?
          conecta
        end
        result = @client.execute(c)
        puts result
        arr = []
        result.try(:each) do |fila|
          puts fila["itemname"]
          arr.push(fila)
          #"<a href='articulo/#{fila["itemnum"]}'>" +
          #				 CGI.escapeHTML(fila["itemname"].to_s) +
          #					 "</a>"
          #				)
        end
        paginador.replace(arr)
        unless paginador.total_entries
          paginador.total_entries = @numresultados
        end
      end
    end
 
    def descarga(id, rutacache)
      authorize! :read, Sal7711Gen::Articulo
      conecta
      c="SELECT filepath, itemdata.itemname 
        FROM itemdata INNER JOIN itemdatapage 
          ON itemdata.itemnum=itemdatapage.itemnum 
        WHERE itemdata.itemnum='#{id.to_s}'";
        rutar = @client.execute(c)
        fila = rutar.first
        ruta = fila["filepath"].strip
        rutaconv = ruta.gsub("\\", "/")
        titulo = fila["itemname"].strip
        rlocal = rutacache + "/" + File.basename(rutaconv)
        puts "ruta=#{ruta}, rlocal=#{rlocal}"
        if (!File.exists? rlocal)
          cmd="smbget -o #{rlocal} -p '#{ENV['CLAVE_DOMINIO']}' -w #{ENV['DOMINIO']} -u #{ENV['USUARIO_DOMINIO']} -v smb://#{ENV['IP_HBASE']}/#{ENV['CARPETA']}/#{rutaconv}"
          puts cmd
          r=`#{cmd}`
#          smbc = Sambal::Client.new(@@parsmb)
#          g = smbc.get(ruta, rlocal)
#          smbc.close
#          m = g.message.to_s.chomp
#          puts "m=#{m}"
#          is = m.index(" of size ")
#          if (is <= 0)
#            return
#          end
#          fs = m.index(" as #{rlocal}")
#          s=m[is+9..fs].to_i
#          puts "s=#{s}"
        end
        return [titulo, rlocal]
    end

    def sincroniza
      @examinados = 0
      @procesados = 0
      @sinc = []
      @cprob = ''
      conecta
      if !@client.active?
        conecta
      end
      @cprob += verifica_fechas
      @cprob += verifica_departamentos
      @cprob += verifica_municipios
      @cprob += verifica_fuenteprensa
      @cprob += verifica_paginas
      @cprob += verifica_categorias
      return
      #return if @cprob != ''
      minitemnum = Sal7711Gen::Articulo.maximum(:onbase_itemnum) || 0
      maxitemnum = 870
      c="SELECT itemdata.itemnum AS itemnum, itemdata.itemname AS itemname,
          keyitem103.keyvaluedate AS fecha,
          keytable101.keyvaluechar AS fuenteprensa,
          keytable104.keyvaluechar AS pagina,
          keytable108.keyvaluechar AS departamento,
          keytable110.keyvaluechar AS municipio,
          keytable112.keyvaluechar AS cat1,
          keytable113.keyvaluechar AS cat2,
          keytable114.keyvaluechar AS cat3
          FROM itemdata 
          JOIN keyitem103 ON keyitem103.itemnum=itemdata.itemnum  
          JOIN keyxitem101 ON keyxitem101.itemnum = itemdata.itemnum
          JOIN keytable101 ON keyxitem101.keywordnum = keytable101.keywordnum 
          JOIN keyxitem104 ON keyxitem104.itemnum = itemdata.itemnum
          JOIN keytable104 ON keyxitem104.keywordnum = keytable104.keywordnum 
          JOIN keyxitem112 ON keyxitem112.itemnum = itemdata.itemnum
          JOIN keytable112 ON keyxitem112.keywordnum = keytable112.keywordnum 
          LEFT JOIN keyxitem108 ON keyxitem108.itemnum = itemdata.itemnum
          LEFT JOIN keytable108 ON keyxitem108.keywordnum = keytable108.keywordnum 
          LEFT JOIN keyxitem110 ON keyxitem110.itemnum = itemdata.itemnum
          LEFT JOIN keytable110 ON keyxitem110.keywordnum = keytable110.keywordnum 
          LEFT JOIN keyxitem113 ON keyxitem113.itemnum = itemdata.itemnum
          LEFT JOIN keytable113 ON keyxitem113.keywordnum = keytable113.keywordnum 
          LEFT JOIN keyxitem114 ON keyxitem114.itemnum = itemdata.itemnum
          LEFT JOIN keytable114 ON keyxitem114.keywordnum = keytable114.keywordnum 
          WHERE itemdata.itemnum < #{maxitemnum}
          AND itemname LIKE 'Prensa Cinep%' 
          AND keyitem103.keyvaluedate >= '1960-01-01'
          AND keyitem103.keyvaluedate <= '#{Time.now.strftime("%Y/%m/%d")}'
          ORDER BY itemnum"
      puts "OJO q=#{c}"
      result = @client.execute(c)
      puts "result.count=" + result.count.to_s
#      result.try(:each) do |fila|
#        itemnum = fila['itemnum']
#        if Sal7711Gen::Articulo.where(onbase_itemnum: itemnum).count == 0
#          itemname = it['itemname']
#          puts "itemname #{itemname}"
#          nart = Sal7711Gen::Articulo.new
#          nart.onbase_itemnum = itemnum
#          nart.adjunto_descripcion = itemname
#          nart.fecha = fila['fecha']
#          # Departamento
#          #byebug
#          dep = fila["departamento"]
#          if dep && dep.strip != ''
#            nart.departamento = Sip::Departamento.where("SUBSTRING(nombre FROM 1 FOR 45) = '#{dep.strip}'").first
#              # Municipio
#              mun=fila["municipio"]
#              nart.municipio = Sip::Municipio.where(
#                  id_departamento: nart.departamento_id).
#                  where("SUBSTRING(nombre FROM 1 FOR 45) = '#{mun.strip}'").first
#              end
#            end
#          end
#          
#
#          # Fuente
#          c2 = "SELECT keyvaluechar FROM keyxitem101, keytable101 WHERE
#          keyxitem101.keywordnum = keytable101.keywordnum AND
#          keyxitem101.itemnum = '#{itemnum}'"
#          r2 = @client.execute(c2)
#          if r2.count > 0
#            v2 = r2.first["keyvaluechar"]
#            r2.do
#            if v2 && v2.strip != ''
#              nart.fuenteprensa = Sip::Fuenteprensa.where("SUBSTRING(nombre FROM 1 FOR 45) = '#{v2.strip}'").first
#            end
#          else
#            @cprob += "<br>Elemento #{itemnum} no tiene Fuente"
#            r2.do
#          end
#
#          # Pagina
#          c2 = "SELECT keyvaluechar FROM keyxitem104, keytable104 WHERE
#          keyxitem104.keywordnum = keytable104.keywordnum AND
#          keyxitem104.itemnum = '#{itemnum}'"
#          r2 = @client.execute(c2)
#          if r2.count > 0
#            v2 = r2.first["keyvaluechar"]
#            r2.do
#            if v2 && v2.strip != ''
#              nart.pagina = v2.strip
#            end
#          else
#            @cprob += "<br>Elemento #{itemnum} no tiene Página"
#            r2.do
#          end
#          # Categorias, falta prio y antes cambiar tabla articulo_categoria para que tenga id
#          # Archivo descargar, reubicar y procesar
#          @sinc << itemname
#          @procesados += 1
#        end
#        @examinados += 1
#      end
#      #byebug
    end
  end
end
