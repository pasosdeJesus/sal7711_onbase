# encoding: UTF-8
module Admin
	class OrganizacionesController < BasicasController
		before_action :set_organizacion, 
			only: [:show, :edit, :update, :destroy]
		load_and_authorize_resource  class: Organizacion

		def clase 
			"Organizacion"
		end

		def set_organizacion
			@basica = Organizacion.find(params[:id])
		end

		def atributos_index
			["id", "nombre", "observaciones", "fechacreacion", "fechadeshabilitacion"]
		end

		def organizacion_params
			params.require(:organizacion).permit( *(atributos_index - ["id"]))
		end

	end
end
