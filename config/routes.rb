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

#	get 'buscar/:id', to: 'buscar#mostraruno'
#	get 'buscar' => 'buscar#index'
# get 'mundep' => 'buscar#mundep'
# get 'codigo' => 'admin/categoriaprensa#busca'

  resource "contacto", only: [:new, :create]

  root 'sip/hogar#index'
  mount Sal7711Gen::Engine => "/", as: 'sal7711_gen'
  mount Sip::Engine => "/", as: 'sip'

  namespace :admin do
    Ability.tablasbasicas.each do |t|
      #puts "OJO config/routes.rb, t=" + t.to_s
      if (t[0] == "") 
        c = t[1].pluralize
        resources c.to_sym, 
          path_names: { new: 'nueva', edit: 'edita' }
      end
    end
  end


end
