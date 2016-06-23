#!/bin/sh

if (test -f .env) then {
	. .env
} fi;

if (test $PUERTODES = "") then {
	echo "Falta variable PUERTODES con puerto para lanzar servidor de desarrollo (e.g 4000)"
} fi;
if (test $IPDES = "") then {
	echo "Falta variable IPDES con IP en la que lanza servidor de desarrollo (e.g 192.168.1.1)"
} fi;
if (test "$SININD" != "1") then {
	PATH=$PATH:/usr/local/bin ./bin/rake sip:indices
} fi;
SAL7711_ONBASE_SERV=${SAL7711_ONBASE_SERV} USUARIO_HBASE=${USUARIO_HBASE} CLAVE_HBASE=${CLAVE_HBASE} IP_HBASE=${IP_HBASE} DOMINIO=${DOMINIO} CARPETA=${CARPETA} USUARIO_DOMINIO=${USUARIO_DOMINIO} CLAVE_DOMINIO=${CLAVE_DOMINIO} PATH=$PATH:/usr/local/bin ./bin/rails s -b $IPDES -p $PUERTODES







