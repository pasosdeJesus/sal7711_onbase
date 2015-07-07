# encoding: UTF-8

class ApplicationController < Sip::ApplicationController
  protect_from_forgery with: :exception
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to Rails.application.routes.url_helpers.root_path, 
      :alert => exception.message
  end
end

