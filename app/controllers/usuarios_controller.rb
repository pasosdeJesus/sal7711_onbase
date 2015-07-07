# encoding: UTF-8
require 'bcrypt'

class UsuariosController < Sip::UsuariosController
  def new
    super
    @miurl = crea_usuario_url 
  end

  def create
    @usuario.confirmed_at = Date.today
    super
  end

  def edit
    super
    @miurl = actualiza_usuario_url 
  end

  # Lista blanca de paramétros
  def usuario_params
    params.require(:usuario).permit(
      :id, :nusuario, :password, 
      :nombre, :descripcion, :oficina_id,
      :rol, :idioma, :email, :encrypted_password, 
      :fecharenovacion, :diasvigencia,
      :fechacreacion, :fechadeshabilitacion, :reset_password_token, 
      :reset_password_sent_at, :remember_created_at, :sign_in_count, 
      :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, 
      :failed_attempts, :unlock_token, :locked_at,
      :last_sign_in_ip, 
      :confirmation_token, :confirmed_at, 
      :confirmation_sent_at, :uncofirmed_email,
      :etiqueta_ids => []
    )
  end
end
