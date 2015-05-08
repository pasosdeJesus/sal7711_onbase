# encoding: UTF-8
require 'rails_helper'

RSpec.describe Organizacion, :type => :model do

	it "valido" do
		organizacion = FactoryGirl.build(:organizacion)
		expect(organizacion).to be_valid
		organizacion.destroy
	end

	it "no valido" do
		organizacion = 
			FactoryGirl.build(:organizacion, nombre: '')
		expect(organizacion).not_to be_valid
		organizacion.destroy
	end

	it "existente" do
		organizacion = Organizacion.where(id: 1).take
		expect(organizacion.nombre).to eq("CINEP")
	end

end
