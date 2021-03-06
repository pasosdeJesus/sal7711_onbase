# encoding: UTF-8
Rails.application.routes.draw do
  devise_scope :usuario do
    get 'sign_out' => 'sessions#destroy'
    get 'usuarios/sign_in' => 'sessions#new'
    get 'usuarios/sign_up' => 'registrations#new'

    # El siguiente para superar mala generación del action en el formulario
    # cuando se autentica mal (genera 
    # /puntomontaje/puntomontaje/usuarios/sign_in )
    if (Rails.configuration.relative_url_root != '/') 
      ruta = File.join(Rails.configuration.relative_url_root, 
                       'usuarios/sign_in')
      post ruta, to: 'devise/sessions#create'
    end
    root 'sessions#new'
  end
  devise_for :usuarios, module: :devise, controllers: { registrations: "registrations" }
  as :usuario do
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

  get 'sincroniza' => 'sal7711_gen/buscar#sincroniza', as: 'buscar_sincroniza'

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
