# encoding: UTF-8

class Usuario < Sal7711Gen::Usuario
  devise :registerable, :confirmable

  validates_length_of :nusuario, maximum: 255

  @autenticado_por_ip = false
  attr_accessor :autenticado_por_ip

end
