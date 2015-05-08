# encoding: UTF-8

require 'sip/concerns/models/usuario'

class Usuario < ActiveRecord::Base
  devise :registerable, :confirmable

  include Sip::Concerns::Models::Usuario
  validates_length_of :nusuario, maximum: 255

end
