# encoding: UTF-8
require 'spec_helper'

describe "Control de acceso " do
  before { 
    @usuario = FactoryGirl.create(:usuario, rol: Ability::ROLANALI)
                                  visit new_usuario_session_path 
                                  fill_in "Correo Electrónico", with: @usuario.email
                                  fill_in "Clave", with: @usuario.password
                                  click_button "Iniciar Sesión"
                                  expect(page).to have_content("Administrar")
  }

  describe "investigador" do
    it "puede buscar" do
      skip
      visit "/buscar"
		  expect(page).to have_content("Municipio") 
    end

  end

end
