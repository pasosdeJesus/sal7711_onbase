# Sal7711
[![Estado Construcción](https://api.travis-ci.org/pasosdeJesus/sal7711.svg?branch=master)](https://travis-ci.org/pasosdeJesus/sal7711) [![Clima del Código](https://codeclimate.com/github/pasosdeJesus/sal7711/badges/gpa.svg)](https://codeclimate.com/github/pasosdeJesus/sal7711) [![Cobertura de Pruebas](https://codeclimate.com/github/pasosdeJesus/sal7711/badges/coverage.svg)](https://codeclimate.com/github/pasosdeJesus/sal7711) [![security](https://hakiri.io/github/pasosdeJesus/sal7711/master.svg)](https://hakiri.io/github/pasosdeJesus/sal7711/master) [![Dependencias](https://gemnasium.com/pasosdeJesus/sal7711.svg)](https://gemnasium.com/pasosdeJesus/sal7711) 


Archivo de Prensa


### Requerimientos
* Ruby version >= 2.1
* PostgreSQL >= 9.3 con extensión unaccent disponible
* Recomendado sobre adJ 5.5p2 (que incluye todos los componentes mencionados).  
  Las siguientes instrucciones suponen que opera en este ambiente.

Puede consultar como instalar estos componentes en: http://dhobsd.pasosdejesus.org/index.php?id=Ruby+on+Rails+en+OpenBSD


### Arquitectura

Es una aplicación que emplea el motor genérico para sistemas de información
estilo Pasos de Jesús ```sip```
Ver https://github.com/pasosdeJesus/sip


### Configuración y uso de servidor de desarrollo
* Ubique fuentes por ejemplo en ```/var/www/htdocs/sal7711/```
* Instale gemas requeridas (como Rails 4.2) con:
```sh
  NOKOGIRI_USE_SYSTEM_LIBRARIES=1 MAKE=gmake make=gmake QMAKE=qmake4 bundle install
```
o emplee el script ```bin/gc.sh```, que además ejecutará pruebas de regresión, con:
```sh
SINAC=1 bin/gc.sh
```
* Copie y modifique las plantillas:
```sh
  cp app/views/hogar/_local.html.erb.plantilla app/views/hogar/_local.html.erb
  cp config/database.yml.plantilla config/database.yml
  vim app/views/hogar/_local.html.erb config/database.yml
```
* Establezca una ruta para anexos en ```config/initializers/sip.rb```.  
  Debe existir y poder ser escrita por el dueño del proceso con el que corra 
  el servidor de desarrollo.
* Cree un superusuario para PostgreSQL, configure datos para este en 
  ```config/database.yml``` e inicialice:
```sh
  $ sudo su - _postgresql
  $ createuser -h/var/www/tmp -Upostgres -s sal7711des
  $ psql -h/var/www/tmp -Upostgres
psql (9.3.6)
Type "help" for help.

postgres=# ALTER USER sal7711des WITH password 'miclave';
ALTER ROLE
postgres=# \q
  exit
  $ vim config/database.yml
  $ rake db:setup
  $ rake sal7711:indices
```
* Lance la aplicación en modo de desarrollo con:
```sh
  rails s
```
* Examine con un navegador el puerto 3000: ```http://127.0.0.1:3000```
* Cuando requiera detener basta que presione Control-C o bien que busque el
  proceso con ruby que corre en el puerto 3000 y lo elimine con ```kill```:
```sh
ps ax | grep "ruby.*3000"
kill 323122
```
* En este modo es recomendable borrar recursos precompilados 
```sh
rm -rf public/assets/*
```

### Pruebas

Dado que se hacen pruebas a modelos, rutas, controladores y vistas en 
```sip```, en ```sal7711``` sólo se implementan algunas pruebas 
de regresión con capybara-webkit.  Ejecutelas con:

```sh
RAILS_ENV=test rake db:reset
RAILS_ENV=test rake sip:indices
rspec
```

### Despliegue de prueba en Heroku

[![heroku](https://www.herokucdn.com/deploy/button.svg)](http://sal7711.herokuapp.com) http://sal7711.herokuapp.com

Para tener menos de 10000 registros en base de datos se han eliminado ciudades de Colombia y Venezuela. Podrá ver departamentos/estados y municipios.

Los anexos son volatiles pues tuvieron que ubicarse en ```/tmp/``` (que se 
borra con periodicidad).

En tiempo de ejecución el uso de heroku se detecta en 
```config/initializers/sip``` usando una variable de entorno 
--que cambia de un despliegue a otro y que debe examinarse con 
```sh
	heroku config
```
Para que heroku solo instale las gemas de producción:
```sh
	heroku config:set BUNDLE_WITHOUT="development:test"
```

Otras labores tipicas son:
* Para iniciar interfaz Postgresql: ```heroku pg:psql```
* Para ejecutar migraciones faltantes: ```heroku run rake db:migrate```
* Para examinar configuración ```heroku config``` que entre otras mostrará URL y nombre de la base de datos.
* Heroku usa base de datos de manera diferente, para volver a inicializar base de datos (cuyo nombre se ve con ```heroku config```):  ```heroku pg:reset nombrebase```

### Medición de tiempos

En el archivo TIEMPO.md se han consignado algunas mediciones de tiempo de respuesta medidos con el inspector del navegador Chrome (una vez en la página de ingreso, botón derecho Inspeccionar Elemento, pestaña Network). En ese archivo se ha consignado el tiempo de cada prueba junto con el servidor y el cliente usado.


### Despliegue en sitio de producción con unicorn:
* Se recomienda que deje fuentes en ```/var/www/htdocs/sal7711```
* Siga los mismos pasos para configurar un servidor de desarrollo --excepto
  lanzar
* Configure base de datos en `config/databases.yml` y ejecute
```sh
  RAILS_ENV=production rake db:setup
  RAILS_ENV=production rake sip:indices
```
* Como servidor web recomendamos nginx, en la sección http agregue:
```
  upstream unicorns2 {
	  server 127.0.0.1:2009 fail_timeout=0;
  }
```
* Y agregue también un dominio virtual (digamos `sal7711.pasosdeJesus.org`) con:
```
  server {
    listen 443;
    ssl on;
    ssl_certificate /etc/ssl/server.crt;
    ssl_certificate_key /etc/ssl/private/server.key;
    ssl_session_timeout  5m;
    ssl_protocols  SSLv3 TLSv1;
    ssl_ciphers  HIGH:!aNULL:!MD5;
    root /var/www/htdocs/sal7711/;
    server_name sal7711.pasosdeJesus.org
    error_log logs/s2error.log;

    location ^~ /assets/ {
        gzip_static on;
        expires max;
        add_header Cache-Control public;
        root /var/www/htdocs/sal7711/public/;
    }

    try_files $uri/index.html $uri @unicorn;
    location @unicorn {
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header Host $http_host;
            proxy_redirect off;
            proxy_pass http://unicorn;
            error_page 500 502 503 504 /500.html;
            client_max_body_size 4G;
            keepalive_timeout 10;
    }

  }
```
* Precompile los recursos 
```sh 
rake assets:precompile
```
* Tras reiniciar nginx, inicie unicorn desde directorio con fuentes con:
```sh 
./bin/u.sh
```
* Para iniciar en cada arranque, por ejemplo en adJ cree /etc/rc.d/sal7711
```sh
servicio="/var/www/htdocs/sal7711/bin/u.sh"

. /etc/rc.d/rc.subr

rc_cmd $1
```
  E incluya ```sal7711``` en la variable ```pkg_scripts``` de ```/etc/rc.conf.local```

### Actualización de servidor de desarrollo

* Detenga el servidor de desarrollo (teclas Control-C)
* Actualice fuentes: ```git pull```
* Instale nuevas versiones de gemas requeridas: 
``` sh
  bundle install
```
* Aplique cambios a base de datos: ```rake db:migrate```
* Actualice tablas básicas: ```rake sip:actbasicas```
* Actualice índices: ```rake sip:indices```
* Lance nuevamente el servidor de desarrollo: ```rails s```

### Actualización de servidor de producción

Son practicamente los mismos pasos que emplea para actualizar servidor 
de desarrollo, excepto que unicorn se detiene con pkill y se inica
como se describió en Despliegue y que debe preceder cada rake con 
	RAILS_ENV=production

### Respaldos

En el sitio de producción se recomienda agregar una tarea cron con:

``` sh
cd /var/www/htdocs/sal7711/; RAILS_ENV=production bin/rake sal7711:vuelca 
```

### Convenciones

Las mismas de ```sip```.  Ver https://github.com/pasosdeJesus/sip
