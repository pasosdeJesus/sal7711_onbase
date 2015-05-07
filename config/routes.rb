# encoding: UTF-8
Rails.application.routes.draw do
  devise_scope :usuario do
    get 'sign_out' => 'devise/sessions#destroy'
  end
#  devise_for :usuarios, :skip => [:registrations], module: :devise
  devise_for :usuarios, module: :devise, controllers: { registrations: "registrations" }
  as :usuario do
          get 'usuarios/edit' => 'devise/registrations#edit', 
            :as => 'editar_registro_usuario'    
          put 'usuarios/:id' => 'devise/registrations#update', 
            :as => 'registro_usuario'            
  end
  resources :usuarios, path_names: { new: 'nuevo', edit: 'edita' } 

	get 'buscar/:id', to: 'buscar#mostraruno'
	get 'buscar' => 'buscar#index'
	get 'resultados' => 'buscar#resultados'

  resource "contacto", only: [:new, :create]

  root 'sip/hogar#index'
  mount Sip::Engine => "/", as: 'sip'

end
