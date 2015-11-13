# encoding: UTF-8
require_dependency "sal7711_gen/concerns/controllers/buscar_controller"

require 'tiny_tds'
require 'sambal'

module Sal7711Gen
  class BuscarController < ApplicationController
    #skip_before_action :verify_authenticity_token, if: :autenticado_por_ip?
    # Necesario para EZ-Proxy, por lo mismo se requiere authorize en otros métodos

    def autenticado_por_ip?
      if current_usuario
        c = ::Organizacion.where('usuarioip_id = ?', current_usuario.id).count('*')
        return c > 0
      end
      return false
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
      if current_usuario
        return true
      end
      # Funciona Rails.configuration.action_mailer.default_url_options[:host] = 'http://archivoprensa.loco.cinep.org.co:11443/'
      nips = ::IpOrganizacion.where('? <<= ip', request.ip).
        count('organizacion_id', distinct: true)
      #byebug
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
        org = ::Organizacion.joins(:ip_organizacion).where('?<<=ip', request.ip).take
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
 
    def verifica_departamentos
      ds = Sip::Departamento.all.where(id_pais: 170)
      ds.each do |d|
        puts d.nombre
        c="SELECT COUNT(*) AS cuenta FROM keytable108 WHERE keyvaluechar='#{d.nombre}';"
        cuentar = @client.execute(c)
        @numregistros = cuentar.first["cuenta"]
        if @numregistros != 1
          puts "OJO #{d.nombre} aparece #{@numregistros} veces"
        end
      end
    end 

    def verifica_municipios
      dm = Sip::Municipio.joins(:departamento).where(
        "sip_departamento.id_pais='170'")
      puts "MUNICIPIOS CON PROBLEMAS:"
      puts "*************************"
      dm.each do |m|
        c="SELECT COUNT(*) AS cuenta FROM keytable110 WHERE keyvaluechar='#{m.nombre}';"
        cuentar = @client.execute(c)
        @numregistros = cuentar.first["cuenta"]
        if @numregistros == 0
          puts "#{m.nombre}"
        end
      end
      puts "*************************"
    end 

    def prepara_pagina
      authorize! :read, Sal7711Gen::Articulo
      conecta
      #verifica_departamentos
      #verifica_municipios
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
        titulo = fila["itemname"].strip
        rlocal = rutacache + "/" + File.basename(ruta.gsub("\\", "/"))
        if (!File.exists? rlocal)
          smbc = Sambal::Client.new(@@parsmb)
          g = smbc.get(ruta, rlocal)
          smbc.close
          m = g.message.to_s.chomp
          puts "m=#{m}"
          is = m.index(" of size ")
          if (is <= 0)
            return
          end
          fs = m.index(" as #{rlocal}")
          s=m[is+9..fs].to_i
          puts "s=#{s}"
        end
        return [titulo, rlocal]
    end

  end
end
