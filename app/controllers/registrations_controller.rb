class RegistrationsController < Devise::RegistrationsController 
  def new
    build_resource({})
    respond_with self.resource
  end

  def create
    params[:usuario][:nusuario] = params[:usuario][:email].gsub(/[@.]/,"_")
    params[:usuario][:fechacreacion] = Date.today
    super
    #byebug
  end

  private

  def sign_up_params
    allow = [:email, :nusuario, :password, :password_confirmation, 
             :fechacreacion]
    params.require(resource_name).permit(allow)
  end

end
