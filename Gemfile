source 'https://rubygems.org'



# Rails (internacionalización)
gem "rails", '~> 4.2.3.rc1'
gem "rails-i18n"

# Color en terminal
gem 'colorize'

# Postgresql
gem "pg"

# Formulario contacto
gem 'mail_form'

# Para generar CSS
gem 'sass'
gem "sass-rails"#, '~> 4.0.0.rc1'
gem "compass-rails"

# Cuadros de selección para búsquedas
gem 'chosen-rails'

# Dialogo modal
gem 'lazybox'

# Tiny_TDS para MS-SQL usado por OnBase
#gem "tiny_tds", '~> 0.6.3'
gem 'tiny_tds', '~> 0.6.3.rc1' #, path: '../tiny_tds', ver README.md

# sambal para extraer archivos en directorio Windows usado por OnBase
# gem "sambal"
gem "sambal"
#gem "sambal", github: "vtamara/sambal"
#gem 'sambal', path: '../sambal'

# Para convertir de tiff a jpg
#gem "rmagick"

# Para generar PDF
gem "prawn"

# Maneja variables de ambiente (como claves y secretos) en .env
gem "foreman"

# API JSON facil. Ver: https://github.com/rails/jbuilder
gem "jbuilder"


# Uglifier comprime recursos Javascript
gem "uglifier", '>= 1.3.0'

# CoffeeScript para recuersos .js.coffee y vistas
gem "coffee-rails", '~> 4.1.0'

# jquery como librería JavaScript
gem "jquery-rails"
# Problema al actualiza a 4.0.0, al lanzar servidor reporta que jquery no existe

gem "jquery-ui-rails"
gem "jquery-ui-bootstrap-rails", git: "https://github.com/kristianmandrup/jquery-ui-bootstrap-rails"

# Seguir enlaces más rápido. Ver: https://github.com/rails/turbolinks
gem "turbolinks"

# Ambiente de CSS
gem "twitter-bootstrap-rails"
gem "bootstrap-datepicker-rails"
gem "bootstrap-sass"

# Formularios simples 
gem "simple_form"

# Formularios anidados (algunos con ajax)
#gem "cocoon", github: "vtamara/cocoon"

# Autenticación y roles
gem "devise"
gem "devise-i18n"
gem "cancancan"
gem "bcrypt"

# Listados en páginas
gem "will_paginate"

# ICU con CLDR
gem 'twitter_cldr'

# Maneja adjuntos
gem "paperclip", "~> 4.1"

# Zonas horarias
gem "tzinfo"
gem "tzinfo-data"

# Motor de sistemas de información estilo Pasos de Jesús
gem 'sip', github: 'pasosdeJesus/sip'
#gem 'sip', path: '../sip'

gem 'sal7711_gen', github: 'pasosdeJesus/sal7711_gen'
#gem 'sal7711_gen', path: '../sal7711_gen'

group :doc do
    # Genera documentación en doc/api con bundle exec rake doc:rails
    gem "sdoc", require: false
end

# Los siguientes son para desarrollo o para pruebas con generadores
group :development, :test do
  # Acelera ejecutando en fondo.  https://github.com/jonleighton/spring
  gem "spring"

  # Pruebas con rspec
  gem 'spring-commands-rspec'
  gem 'rspec-rails'

  # Maneja datos de prueba
  gem "factory_girl_rails", "~> 4.0", group: [:development, :test]

  # https://www.relishapp.com/womply/rails-style-guide/docs/developing-rails-applications/bundler
  # Lanza programas para examinar resultados
  gem "launchy"

  # Depurar
  #gem 'byebug'

  # Consola irb en páginas con excepciones o usando <%= console %> en vistas
  gem 'web-console'

  # Para examinar errores, usar "rescue rspec" en lugar de "rspec"
  gem 'pry-rescue'
  gem 'pry-stack_explorer'

end

# Los siguientes son para pruebas y no tiene generadores requeridos en desarrollo
group :test do
  # Pruebas de regresión que no requieren javascript
  gem "capybara"
  
  # Pruebas de regresión que requieren javascript
  gem "capybara-webkit", '1.4.1'

  # Envia resultados de pruebas desde travis a codeclimate
  gem "codeclimate-test-reporter", require: nil
end


group :production do
  # Para despliegue
  gem "unicorn"

  # Requerido por heroku para usar stdout como bitacora
  gem "rails_12factor"
end


