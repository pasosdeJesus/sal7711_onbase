# encoding: UTF-8

class ApplicationController < Sip::ApplicationController
  protect_from_forgery with: :exception
  rescue_from CanCan::AccessDenied do |exception|
    render :file => "#{Rails.root}/public/403.html", 
      :status => 403, :layout => true
  end
end

