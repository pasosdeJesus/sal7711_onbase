
* Disminuir tamaño del logo de los andes y poner el del CINEP a 
* Prefieren http para consulta publica (se habilitó basada en IP sobre 3777) (quedó tanto para estudiantes como para egresados).

* De forma similar a JSTOR y EBSCO se dejo funcionando medianamente registro y autenticacion de usuarios con correo @unidandes.edu.co sobre https (para mantener historial de búsqueda personalizado ---a futuro como hacen otras bases para permitir referencias RIS), pero falta:

  1. Que al presionar Ingresar capture la URL de la que viene para usarla cuando presione salir. (Que al presionar botón salir desde IP de los Andes un estudiante vuelva a http://p3777-archivoprensa-cinep-org-co.ezproxy.uniandes.edu.co:8080/buscar cuando viene https://archivoprensa-cinep-org-co.ezproxy.uniandes.edu.co:8443 y un egresado a http://p3777-archivoprensa-cinep-org-co.ezproxyegre.uniandes.edu.co:8888/buscar  https://archivoprensa-cinep-org-co.ezproxyegre.uniandes.edu.co:8843 )
  2. El enlace que va al correo debe ser con el mismo dominio desde el cual se solicitó (estilo https://archivoprensa-cinep-org-co.ezproxy.uniandes.edu.co:8443 o estio https://archivoprensa-cinep-org-co.ezproxyegre.uniandes.edu.co:8843 )
  3. Desactivar búsqueda sobre https cuando consulta venga de una IP que no sea de los Andes ---pues prefieren las estadísticas consolidadas que el Ez-Proxy les da.
  4. Enlace para recuperar contrasea olvidada en pagina de autenticaciòn.
  5. Recuperar Ingresar e InscribiR

EBSCO permite a cada persona:

Crear carpetas (vienen unas predeterminadas),

Al encontrar un artículo es posible hacer click en un enlace para 
enviar a una de las carpetas creadas.

Los que tienen una carpeta deja:

* Exportar referencias bibliograficas en formato RIS
* Enviar correo con referencia (y opcional PDF). APA, Chicago MLA y Harard ---debe haber un sitio que explique como generar estos a partir del RIS



* Probar desde https://biblioteca.uniandes.edu.co/index.php?lang=es  se dio acceso a Alejandro

* Que https reconozca la IP remotea y/o que solo vaya a HTTPS para suscribir o autenticacion y sigue basado en aut. institucional.
  Dicen que no estan dispuestos a asumir compra y renovacion de certificado https.   Probarán agregando dominio https al
  balanceador (les sirve para jstor y otros que muestra problema de certificado).
* Varias paginas en TIFF a varias paginas en PDF ejemplo 492260
* Que menus administrar y salir salgan solo cuando haya autenticación.

* Administracion permite poner logo de institucion que paga
* No hay 

* Al autenticar por IP permite hacer busquedas, pero ademas permite suscribir usuarios e inscribir para guardar cosas personalizadas como: historial de bùsquedas, fuentes predeterminadas para búsquedas-



