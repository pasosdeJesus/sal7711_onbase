class ContactosController < ApplicationController
  def new
    @contacto = Contacto.new
  end

  def create
    @contacto = Contacto.new(params[:contacto])
    @contacto.request = request
    if @contacto.deliver
      flash.now[:notice] = 'Gracias por su mensaje. ' +
        '¡Pronto lo contactaremos!'
    else
      flash.now[:error] = 'No se pudo enviar mensaje.'
      render :new
    end
  end
end
