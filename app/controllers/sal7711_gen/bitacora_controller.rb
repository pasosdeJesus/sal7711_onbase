# encoding: UTF-8

require 'sal7711_gen/concerns/controllers/bitacora_controller'

module Sal7711Gen
  class BitacoraController < ApplicationController
 
    include Sal7711Gen::Concerns::Controllers::BitacoraController

    def admin
      @usuarioscons = Sal7711Gen::Bitacora.connection.select_rows(
        "SELECT nusuario, count(*) FROM sal7711_gen_bitacora 
          JOIN usuario ON usuario_id=usuario.id WHERE
          operacion = 'index' GROUP BY 1"
      )
      @totconsultas = Sal7711Gen::Bitacora.where(operacion: 'index').all.count
    end
  
  end
end
