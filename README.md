# ATENCIÓN: ESTA APLICACIÓN NO SE ESTÁ ACTUALIZANDO, SE MANTIENE COMO EJEMPLO DE COMO EMPLEAR UNA BASE DE DATOS USADA POR ONBASE

Archivo de Prensa usando ONBASE


### Requerimientos
* Ruby version >= 2.2
* PostgreSQL >= 9.4 con extensión unaccent disponible
* Recomendado sobre adJ 5.6 (que incluye todos los componentes mencionados).  
  Las siguientes instrucciones suponen que opera en este ambiente.

Puede consultar como instalar estos componentes en: http://dhobsd.pasosdejesus.org/index.php?id=Ruby+on+Rails+en+OpenBSD

Se requiere además freetds:
```
sudo pkg_add freetds
```

### Arquitectura

Es una aplicación que emplea el motor genérico para sistemas de información
estilo Pasos de Jesús ```sip``` (ver https://github.com/pasosdeJesus/sip ) y
un motor genérico para archivos de prensa ```sal7711_gen``` 


### Configuración y uso de servidor de desarrollo
Puede ver instrucciones por ejemplo de sivel2
	https://github.com/pasosdeJesus/sivel2

Tenga en cuenta que para poder emplear servidor de desarrollo o producción
debe especificar algunas variables de ambiente, por ejemplo el servidor
de desarrollo lo inicia con algo como:

```
USUARIO_HBASE=usariomssql CLAVE_HBASE=clavemssql IP_HBASE=192.168.10.40 DOMINIO=MIDOMINIO CARPETA=OnBaseData1\$ USUARIO_DOMINIO=miusuario CLAVE_DOMINIO=miclave rails s -b 192.168.10.8
```


