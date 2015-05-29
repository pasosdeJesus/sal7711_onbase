#!/bin/sh
# Inicia produccion
if (test "${SECRET_KEY_BASE}" = "") then {
	echo "Definir variable de ambiente SECRET_KEY_BASE"
	exit 1;
} fi;
if (test "${USUARIO_AP}" = "") then {
	echo "Definir usuario con el que se ejecuta en USUARIO_AP"
	exit 1;
} fi;
if (test "${IP_HBASE}" = "") then {
	echo "Definir IP de servidor donde correo MS-SQL y donde estan archivos de OnBase en IP_HBASE"
	exit 1;
} fi;
if (test "${USUARIO_HBASE}" = "") then {
	echo "Definir usuario en MS-SQL en USUARIO_HBASE"
	exit 1;
} fi;
if (test "${CLAVE_HBASE}" = "") then {
	echo "Definir clave en MS-SQL en CLAVE_HBASE"
	exit 1;
} fi;
if (test "${DOMINIO}" = "") then {
	echo "Definir dominio en DOMINIO"
	exit 1;
} fi;
if (test "${CARPETA}" = "") then {
	echo "Definir carpeta donde estan archivos de OnBase en CARPETA"
	exit 1;
} fi;
if (test "${USUARIO_DOMINIO}" = "") then {
	echo "Definir usuario en dominio en USUARIO_DOMINIO"
	exit 1;
} fi;
if (test "${CLAVE_DOMINIO}" = "") then {
	echo "Definir clave en dominio en CLAVE_DOMINIO"
	exit 1;
} fi;
if (test "${CLAVE_DOMINIO}" = "") then {
	echo "Definir clave en dominio en CLAVE_DOMINIO"
	exit 1;
} fi;
if (test "${SAL7711_ONBASE_SERV}" = "") then {
	echo "Definir clave en dominio en SAL7711_ONBASE_SERV"
	exit 1;
} fi;

sudo su ${USUARIO_AP} -c "cd /var/www/htdocs/sal7711_onbase; echo \"Iniciando unicorn...\"; SAL7711_ONBASE_SERV=${SAL7711_ONBASE_SERV} USUARIO_HBASE=${USUARIO_HBASE} CLAVE_HBASE=${CLAVE_HBASE} IP_HBASE=${IP_HBASE} DOMINIO=${DOMINIO} CARPETA='${CARPETA}' USUARIO_DOMINIO=${USUARIO_DOMINIO} CLAVE_DOMINIO=${CLAVE_DOMINIO} SECRET_KEY_BASE=${SECRET_KEY_BASE} bundle exec unicorn_rails -c ../sal7711_onbase/config/unicorn.conf.minimal.rb  -E production -D"
#sudo su ${USUARIO_AP} -c "cd /var/www/htdocs/sal7711_onbase; rake assets:precompile; echo \"Iniciando unicorn...\"; SAL7711_ONBASE_SERV=${SAL7711_ONBASE_SERV} USUARIO_HBASE=${USUARIO_HBASE} CLAVE_HBASE=${CLAVE_HBASE} IP_HBASE=${IP_HBASE} DOMINIO=${DOMINIO} CARPETA='${CARPETA}' USUARIO_DOMINIO=${USUARIO_DOMINIO} CLAVE_DOMINIO=${CLAVE_DOMINIO} SECRET_KEY_BASE=${SECRET_KEY_BASE} bundle exec unicorn_rails -c ../sal7711_onbase/config/unicorn.conf.minimal.rb  -E production -D"


  

