# encoding: UTF-8

require 'devise/sessions_controller'

class Sal7711Onbase::SessionsController < Devise::SessionsController
  def destroy
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    set_flash_message :notice, :signed_out if signed_out && is_flashing_format?
    flash[:error] = Ability::ultimo_error_aut if Ability::ultimo_error_aut
    yield if block_given?
    respond_to_on_destroy
    #super
  end
end
