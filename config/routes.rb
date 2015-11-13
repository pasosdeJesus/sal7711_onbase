# encoding: UTF-8
Rails.application.routes.draw do
  devise_scope :usuario do
#    get 'usuarios/edit' => 'usuarios#devise_registrations_edit', 
#      :as => 'editar_registro_usuario'    
#    get 'sign_out' => 'devise/sessions#destroy'
    get 'sign_out' => 'sal7711_onbase/sessions#destroy'
    get 'usuarios/sign_in' => 'sal7711_onbase/sessions#new'
    root 'sal7711_onbase/sessions#new'
  end
#  devise_for :usuarios, :skip => [:registrations], module: :devise
  devise_for :usuarios, module: :devise, controllers: { registrations: "registrations" }
  as :usuario do
#          get 'usuarios/edit' => 'usuarios#devise_registrations_edit', 
#            :as => 'editar_registro_usuario'    
          get 'usuarios/edit' => 'devise/registrations#edit', 
            :as => 'editar_registro_usuario'    
          put 'usuarios/:id' => 'devise/registrations#update', 
            :as => 'registro_usuario'           
  end
  resources :usuarios, path_names: { new: 'nuevo', edit: 'edita' } 
  post 'usuarios/crea' => 'usuarios#create', :as => 'crea_usuario'           
  patch 'usuarios/:id/actualiza' => 'usuarios#update', :as => 'actualiza_usuario'           
  get 'usuarios/reconfirma' => 'usuarios#reconfirma'
  get 'bitacora/admin' => 'sal7711_gen/bitacora#admin', as: 'bitacora_admin'
  get 'bitacora/tiempo' => 'sal7711_gen/bitacora#tiempo', as: 'bitacora_tiempo'


#	get 'buscar/:id', to: 'buscar#mostraruno'
#	get 'buscar' => 'buscar#index'
# get 'mundep' => 'buscar#mundep'
# get 'codigo' => 'admin/categoriaprensa#busca'

  resource "contacto", only: [:new, :create]

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
