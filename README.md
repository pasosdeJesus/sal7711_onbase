# Sal7711
[![Clima del Código](https://codeclimate.com/github/pasosdeJesus/sal7711_onbase/badges/gpa.svg)](https://codeclimate.com/github/pasosdeJesus/sal7711_onbase) [![security](https://hakiri.io/github/pasosdeJesus/sal7711_onbase/master.svg)](https://hakiri.io/github/pasosdeJesus/sal7711_onbase/master) [![Dependencias](https://gemnasium.com/pasosdeJesus/sal7711_onbase.svg)](https://gemnasium.com/pasosdeJesus/sal7711_onbase) 

Archivo de Prensa


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

Y la gema tiny_tds en su versión 0.6.3, en el momento de este escrito esa
versión no ha sido publicada, pero la rama master de sus fuentes en github
sirven (las versiones 0.6.2 y anteriores presentan problemas para conexiones 
como las que se hacen).

Se deben clonar el repositorio, generar la gema e instalarla.


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


