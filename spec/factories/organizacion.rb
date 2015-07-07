# encoding: UTF-8

FactoryGirl.define do
  factory :organizacion, class: 'Organizacion' do
		id 1000 # Buscamos que no interfiera con existentes
    nombre "Organizacion"
    fechacreacion "2015-03-27"
    fecharenovacion "2015-03-27"
    diasvigencia "1000000"
    created_at "2015-03-27"
  end
end
