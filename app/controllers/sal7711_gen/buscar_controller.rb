# encoding: UTF-8
require_dependency "sal7711_gen/concerns/controllers/buscar_controller"

require 'tiny_tds'
require 'sambal'

module Sal7711Gen
  class BuscarController < ApplicationController

    include Sal7711Gen::Concerns::Controllers::BuscarController
  
    include ActionView::Helpers::AssetUrlHelper

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
  
    def conecta
      if !@client || @client.dead? || !@client.active?
        @client = TinyTds::Client.new(@@hbase)
        r = @client.execute("USE OnBase").do;
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
  
    def prepara_pagina
      conecta
      @tablas = ["keyitem103", "itemdata"]
      w = ""
      if (params[:fechaini] && params[:fechaini] != '')
        pfi = @client.escape(params[:fechaini])
        pfid = Date.strptime(pfi, '%d-%m-%Y')
        w = " AND keyvaluedate>='#{pfid.strftime('%Y-%m-%d')}'"
      end
      if(params[:fechafin] && params[:fechafin] != '')
        pff = @client.escape(params[:fechafin])
        pffd = Date.strptime(pff, '%d-%m-%Y')
        w += " AND keyvaluedate<='#{pffd.strftime('%Y-%m-%d')}'"
      end
      if (params[:mundep] && params[:mundep] != '')
        pmd = params[:mundep].split(" / ")
        
        if pmd.length == 1 # solo departamento
          w += cruza_tabla_consulta(108, pmd[0])
        else # departamento y municipio
          w += cruza_tabla_consulta(108, pmd[1])
          w += cruza_tabla_consulta(110, pmd[0])
        end
      end
  
      if(params[:fuente] && params[:fuente][:nombre] != '')
        w += cruza_tabla_consulta(101, params[:fuente][:nombre])
      end
      if(params[:pagina] && params[:pagina] != '')
        w += cruza_tabla_consulta(104, params[:pagina])
      end
      if (w == '' && (!params[:categoria_id] || params[:categoria_id] == ''))
        w = " AND 1=2"
      end
  
      if(params[:categoria_id] && params[:categoria_id] != '')
        cat = Sal7711Gen::Categoriaprensa.find(params[:categoria_id]);
        if cat.supracategoria
          op = ' LIKE ';
          cod = "#{cat.codigo}%"
        else
          op = ' = ';
          cod = cat.codigo.to_s
        end
        tablaspre = @tablas
        w1 = w + cruza_tabla_consulta(112, cod, op)
        f = "FROM (SELECT itemdata.*, keyitem103.keyvaluedate FROM #{@tablas.join(", ")} " +
          "WHERE keyitem103.itemnum=itemdata.itemnum #{w1}"
        @tablas = tablaspre
        w2 = w + cruza_tabla_consulta(113, cod, op)
        f += " UNION SELECT itemdata.*, keyitem103.keyvaluedate FROM #{@tablas.join(", ")} " +
          "WHERE keyitem103.itemnum=itemdata.itemnum #{w2}"
        @tablas = tablaspre
        w3 = w + cruza_tabla_consulta(114, cod, op)
        f += " UNION SELECT itemdata.*, keyitem103.keyvaluedate FROM #{@tablas.join(", ")} " +
          "WHERE keyitem103.itemnum=itemdata.itemnum #{w3}"
        f += ") AS sub"
      else
        f = "FROM (SELECT itemdata.itemnum AS itemnum, itemdata.itemname AS itemname," +
          "keyitem103.keyvaluedate AS keyvaluedate FROM #{@tablas.join(", ")} " +
          "WHERE keyitem103.itemnum=itemdata.itemnum #{w}) AS sub"
      end
  
      c = "SELECT count(*) AS cuenta #{f}"
      puts "OJO c=#{c}"
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
          ORDER BY keyvaluedate DESC
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
  
    def mostraruno
      if (params[:id] && params[:id].to_i > 0)
        conecta
        id = params[:id].to_i
        c="SELECT filepath, itemdata.itemname 
        FROM itemdata INNER JOIN itemdatapage 
          ON itemdata.itemnum=itemdatapage.itemnum 
        WHERE itemdata.itemnum='#{id.to_s}'";
        rutar = @client.execute(c)
        fila = rutar.first
        ruta = fila["filepath"].strip
        @titulo = titulo = fila["itemname"].strip
        smbc = Sambal::Client.new(@@parsmb)
        dirl = Rails.root.join('public').to_s
        FileUtils.mkdir_p(dirl + "/assets/images/cache-articulos/")
        @rutadescarga = "/assets/images/cache-articulos/" + 
          File.basename(ruta.gsub("\\", "/"))
        rlocal = dirl + image_path(@rutadescarga)
        puts "OJO rlocal=#{rlocal}"
        g = smbc.get(ruta, rlocal)
        smbc.close
        m = g.message.to_s.chomp
        puts "m=#{m}"
        is = m.index(" of size ")
        if (is <= 0)
          return
        end
        fs = m.index(" as #{dirl}")
        s=m[is+9..fs].to_i
        arr = []
        #byebug
        system("convert #{rlocal} #{rlocal}.jpg")
        if !File.exists?("#{rlocal}.jpg")
          return
        end
        # Genera PDF
        Prawn::Document.generate("#{rlocal}.pdf") do
          w = 550
          h = 700
          text titulo
          bounding_box([0, cursor], :width => w, :height => h) do
            image "#{rlocal}.jpg", :fit => [w, h]
            stroke_bounds
          end
        end
  
        #img = Magick::Image.read(rlocal).first
        #img.write ""
        # Image.read falla para algunas imagenes con  Null count for "Tag 34026" (type 1, writecount │-3, passcount 1). `_TIFFVSetField' @ error/tiff.c/TIFFErrors/508):
        respond_to do |format|
          format.html { head :no_content }
          format.json { head :no_content }
          format.js   { render action: :mostraruno }
        end
      end
    end

  end
end
