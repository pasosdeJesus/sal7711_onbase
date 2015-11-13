# encoding: UTF-8

require 'devise/sessions_controller'

class Sal7711Onbase::SessionsController < Devise::SessionsController
  #http://stackoverflow.com/questions/8570077/about-overriding-devise-or-clearance-controllers
  skip_before_filter :require_no_authentication

  def destroy
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    set_flash_message :notice, :signed_out if signed_out && is_flashing_format?
    flash[:error] = Ability::ultimo_error_aut if Ability::ultimo_error_aut
    yield if block_given?
    respond_to_on_destroy
    #super
  end

  def new
    if current_usuario
      if current_usuario.autenticado_por_ip
        sign_out(current_usuario)
      else
        return
      end
    end
    super
    if current_usuario
      puts "OJO no autentico por IP";
      current_usuario.autenticado_por_ip = false
      current_usuario.save!
    end
  end
end
