# encoding: UTF-8

require 'sip/concerns/models/usuario'

class Usuario < ActiveRecord::Base
  include Sip::Concerns::Models::Usuario

  devise :registerable

  validates_format_of :nusuario, :with  => /\A[a-zA-Z_0-9]+\z/
  validates_length_of :nusuario, maximum: 255

end
