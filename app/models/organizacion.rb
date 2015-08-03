# encoding: UTF-8
class Organizacion < ActiveRecord::Base
  include Sip::Basica

  validates :nombre, presence: true, allow_blank: false
  #validates :diasvigencia, presence: true, allow_blank: false
  #validates :fecharenovacion, presence: true, allow_blank: false
  validates :fechacreacion, presence: true, allow_blank: false
end
