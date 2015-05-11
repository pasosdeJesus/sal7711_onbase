# encoding: UTF-8
require 'tiny_tds'
require 'sambal'

class BuscarController < ApplicationController
	#before_action :set_caso, only: [:show, :edit, :update, :destroy]

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
  # entradas por página
	@@porpag = 20 

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

	def cruza_tabla_consulta(num, valor)
		numi = num.to_i
		valore = @client.escape(valor)
		@tablas |= ["keyxitem#{numi}", "keytable#{numi}"]
		return " AND keyxitem#{numi}.itemnum=itemdata.itemnum 
				AND keyxitem#{numi}.keywordnum=keytable#{numi}.keywordnum
				AND keytable#{numi}.keyvaluechar='#{valore}'"
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
		if(params[:municipio] && params[:municipio][:nombre] != '')
			w += cruza_tabla_consulta(110, params[:municipio][:nombre])
		end
		if(params[:departamento] && params[:departamento][:nombre] != '')
			w += cruza_tabla_consulta(108, params[:departamento][:nombre])
		end
		if(params[:codigo1] && params[:codigo1][:codigo] != '')
			w += cruza_tabla_consulta(112, params[:codigo1][:codigo])
		end
		if(params[:codigo2] && params[:codigo2][:codigo] != '')
			w += cruza_tabla_consulta(113, params[:codigo2][:codigo])
		end
		if(params[:codigo3] && params[:codigo3][:codigo] != '')
			w += cruza_tabla_consulta(114, params[:codigo3][:codigo])
		end
		if(params[:fuente] && params[:fuente][:nombre] != '')
			w += cruza_tabla_consulta(101, params[:fuente][:nombre])
		end
		if(params[:pagina] && params[:pagina] != '')
			w += cruza_tabla_consulta(104, params[:pagina])
		end
    if (w == '')
      w = " AND 1=2"
    end

		f = "FROM #{@tablas.join(", ")}
		WHERE keyitem103.itemnum=itemdata.itemnum #{w}"
		c = "SELECT count(*) AS cuenta #{f}"
		puts "OJO c=#{c}"
		cuentar = @client.execute(c)
		@numregistros = cuentar.first["cuenta"]
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
	
			c="SELECT itemdata.itemnum, itemdata.itemname #{f} 
				ORDER BY keyitem103.keyvaluedate DESC
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

	def index
		if !current_usuario
			authorize! :buscar, :index
		end
		#byebug
		prepara_pagina
		respond_to do |format|
			format.html { }
			format.json { head :no_content }
			format.js   { render 'resultados' }
		end

	end

	def resultados
	end

	def mostraruno
		if (params[:id] && params[:id].to_i > 0)
			conecta
			id = params[:id]
			c="SELECT filepath FROM itemdatapage WHERE itemnum='#{id}'";
			rutar = @client.execute(c)
			@ruta = rutar.first["filepath"].strip

			smbc = Sambal::Client.new(@@parsmb)
			@rlocal = "/tmp/" + File.basename(@ruta.gsub("\\", "/"))
			g = smbc.get(@ruta, @rlocal)
			m = g.message.to_s.chomp
			is = m.index(" of size ")
			if (is>0)
				fs = m.index(" as /tmp/")
				s=m[is+9..fs].to_i
				respond_to do |format|
					format.html { 
			  	  #img = open @rlocal, "rb"
						#response.headers['Cache-Control'] = "public, max-age=#{12.hours.to_i}"
						#response.headers['Content-Type'] = 'image/tiff'
						#response.headers['Content-Disposition'] = 'inline'
						#render :text => img.read 
					  #send_data img.read, type: 'application/image', disposition: 'inline'
					  send_file @rlocal, disposition: 'inline'
					}
					format.json { head :no_content }
					format.js   { head :no_content }
				end

			end
		end
	end
end
