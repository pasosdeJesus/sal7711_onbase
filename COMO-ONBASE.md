
Suponemos que tiene una base base manejada por OnBase, para
poder emplearla para consultarla con sal7711_onbase debe analizarla 
para determinar las tablas usadas y para formular las consultas que 
requiere.

Esta labor puede considerarse ingeniería reversa a una base
de datos legada, es necesaria para poder extraer la información y
migrarla a otra base de datos o usarla.

Hasta donde sabemos no hay restricciones legales para hacerlo y de 
hecho Hyland (la empresa que desarrolla OnBase) promueve hacer ingenieria 
reversa a otras bases de datos legadas y tiene ofertas laborales 
justamente para ese fin como a 19.Mar.2015 dice en 
http://www.onbase.com/en/about/careers/apply/?apply=0&jobid=560#.VQqhf-Aci-8:

"Database Migration Engineer- SQL Developer
...
The position requires a broad understanding of database technologies, 
ETL development, and SSIS. This is a perfect opportunity for a database 
professional to work in a fast paced environment, which allows them to 
reverse engineer legacy systems,  while having the opportunity to 
work across industries.
...
"

A continuación damos algunas ideas de como analizar la base legada de OnBase.


# Sacar la estructura

Para sacar estructura con MS-SQL Manager

* Boton derecho sobre base.
* Tareas
* Script
* Seguir wizard eligiendo scrpit con tablas.

# Usar base MS-SQL-Server desde Unix

Recomendamos que instale sqsh (sudo pkg_add sqsh en adJ)

Una vez instalado, si por ejemplo la IP del servidor MS-SQL es 192.168.10.2
y el usuario de la base empleada por OnBase es hsi:

sqsh -S 192.168.10.2 -U hsi 

Como se explica en 
http://stackoverflow.com/questions/428458/counting-rows-for-all-tables-at-once
Para ver tablas y numero de registros de cada una:


SELECT [TableName] = so.name, [RowCount] = MAX(si.rows) FROM sysobjects so, sysindexes si WHERE so.xtype = 'U' AND si.id = OBJECT_ID(so.name) GROUP BY so.name ORDER BY 2 DESC

Entre otras notará que:
* OnBase maneja tablas como archivos que crea de acuerdo a campos que se requieran.
* Hay algunas tablas que parecen de aplicaciones particulares (medicas)
que estan parcialmente llenas, pero la mayoría vacías.
* Por ejemplo en una instalación en la que se basan las búsquedas implementadas en sal7711_onbase se observó que de 2632 tablas se usan las siguientes 257:

** transactionxlog,3708768. Registra vistas de documentos
** itemdatapage,546699	Registra donde esta cada item
** itemdata,532376	Items
**keyxitem104,525316	Cruza items y keytable104 (pagina)
** keyxitem101,525293	Cruza items y keytable101 (fuente --incluye errores como ELSIGLO, ELIEMPO)
** keyitem103,525174	Referencia items y fechas
** keyxitem112,495168	Cruza items con keytable112 (categoria 1)
** keyxitem113,233668	Cruza items con keytable113 (categoria 2)
** keyxitem108,209609	Cruza items con keytable108 (departamento --incluye errores como CUCRE, CUUCA)
** keyxitem110,165098	Cruza items con keytable110 (municipios --incluye errores)
** keyxitem109,146006	Cruza items con keytable109 (cod. departamento)
** keyxitem111,145889	Cruza items con keytable111 (cod. municipio)
** pltrmgmtlog,93325	Bitacora de platos (e.g errores).
** securitylog,57744	Bitacora de seguridad (conexiones, ingresos errados)
** keyxitem114,55345	Cruza items con keytable114 (categoria 3)
** scanninglog,32057	Bitacora de escaneos
** eventlog,26754		Bitacora de fallas
** archivedqueue,8654	Bitacora de archivados hasta 20.Ago.210
** processinglog,7896	Lotes hasta 2009
** keytable104,2844	Paginas diferentes
** userenvscreen,2661	Parecen detalles de escanner usado
** envelopexitem,2368	Cruza items con sobres (com etiquetas) de la tabla envelopes
** keysetdata104,2180	Ciudades
** keyxitem1,1690	Cruza items con keytable1 (archivo)
** keytable110,1342	Municipio?
** usergfiletype,1301	Cruza tipos de archivo con grupos de usuario
** hl7segmentfield,1141	Campos posibles (para otras bases)
** keysetdata103,1091	Relaciona ks111, ks110, ks109 departamentos, municipios
** keytable111,1017	Codigos de municipio?
** maxnumkeys,937	Máximos para algunos tipos de campos (folder:100, datos item: 554386, etc.)
** mailxitem,933	Cruza correos e items (?)
** adminlog,822		Bitacora admin de 17.May.2006 a la fecha
** chtlistcolconfig,686	Configuracion de columnas ?
** productsold,674	Productos 
** hl7msgxsegment,491	Relaciona mensajes con segmentos en hl7
** registeredusers,482	Usuarios registrados
** chtsearchfieldcfg,422	relaciona campos con contextos en interfaz y pos. busq?
** wkstmonitor,419	Monitor de estaciones que se conectan
** mailtable,394	Correos
** keytable1,365	Archivos definidos en AP
** regusersproducts,356	Parece bitacora de actualizaciones
** physicalplatter,345	Relaciona numeros de plato fisico y logico con unidades
** configlog,338	Bitacora de dialogos especiales (advertencias, licencias)
** keytable112,326	Categoria 1
** keytable113,324	Categoria 2
** rrjob,319		Bitacoras de tareas hasta 24.Feb.2009
** usergroupconfig,310	Relaciona grupos con tipos de documenots
** usermail,272		Relaciona emisor, receptor y mensaje en correos
** passwordhistory,251	Bitacora de claves anteriores mantenidas con fecha	 de cambio y condensado de clave 
** pagereference,238	Cruza items con referencia (num. pag, linea inicial)
** keytable114,226	Categoria 3
** edifieldxpath,225	
** ediparsefields,186
** doccheckout,168
** chartmetadata,168	
** useraccount,168		Cuentas de usuario incluye clave (condensado?)
** docmaintf389,160
** docmaint389,158
** keysetdata101,153
** keytable101,143		Fuente
** physicalplatterTMP,119	
** logicalplatter,118	Cruza plato lógico con grupo de discos
** rmkey,100		
** keytable108,89		Deptos.
** useritemtypegrp,89	Cruza grupo de usuario con grupo de tipos de item
** userxusergroup,82	Cruza usuarios con grupos
** keytypetable,76		Nombres de los tipos de llaves. e.g 101 Fuente, 102 Id Noticia, 103 Fecha fuente, 104 Pagina fuente, 106 Fecha suceso, 108 Departamento, 109 Codigo Departamento, 110 Municipio, 111 cod. municipio, 112 Cod. ppal, 113, codigo secundario 1, 114 cod sec. 2, 115 marco conceptual, 116 fecha ficha, 117 redactor, 118 interlocutor ficha,  119 asociado de la ficha, 120 palabras clave de la ficha, 124 XX, 125 XNo. Documento 1, 126 Comprobante Egreso, 127 XNo. Documento 2, 128 No. Comprob. Egreso, 129 IS Batch #
** usergroupkeyset,68	Cruza grupos de usuario con tablas de keysets
** itemtypexkeyword,66  Cruza tipos de item con palabras reservadas, e.g relaciona el tipo de item 101 (Prensa) con las palabras reservadas 109, 112, 113, 111, 114, 110, 103, 104, 108, 106 y 101
** envelope,65
** statetable,59
** keytable109,57  Codigos de departamento (?)
** keyitem106,56	Fechas?
** doctype,54	Similar a itemtype
** filetype,53	Tipos de archivo (pdf, con tipos mime)
** usergprintqueue,53
** medpopcolconfig,49
** doctyperevision,48
** doctypeext,47
** scanprocess,47
** hl7segment,45
** hl7v3appconfig,44
** itemtype,44  	Tipos de items. 101 Prensa, 102 Marco Conceptual, 103 Ficha de seguimiento. Define el formato para el titulo usando varialbes como %K00112.1 que indica palabra clave 112 (categoria 1)
** hl7message,42
** dbsection,39
** usercheckout,38
** usergnotetype,34 	
** systemlog,29 	Actualizaciones
** usergroup,26	Grupos de usuarios
** keyxitem2,24
** notetype,23
** medpopfilterconfig,21
** queryproperty,19
** systemsettings,18 Detalles interfaz
** pswdrule,17
** keysetxkeytype,17
** usergxproductsold,16
** vendornarchiveparam,16
** wvmappingtable,15
** volqryproperty,15
** hl7codedentry,15
** usergcustomquery,14
** sapconfig,13
** m2wsitemapnode,13
** exitxkey,12
** docmaint479,11
** docmaintf479,11
** keyitem70,10
** ordermetadata,10
** sapbarcodeconfig,10
** requesttable,9
** physicalplattertmpl,9
** empcalendar,9
** keytable2,8
** customkeytype,8
** sapkeys,8
** scheduledday,8
** usergscanqueue,8
** licensedproduct,7	Cruza licencia con productos
** printformat,6
** qpdependency,6
** docmaint228,6
** docmaintf228,6
** hl7v3actionprocessor,6
** itemtypegroup,6
** impparseflds,6
** docmaintf231,5
** keytable115,5
** docmaint231,5
** scheduledprocess,5
** printqueue,5
** parsefiledesc,4
** rmsystemproperties,4
** userxcustomquery,4
** docmaint102,4
** keytable117,4
** keytable118,4
** keytable120,4
** keytable126,4
** keywordset,4
** keytable125,3
** keytable119,3
** keyitem56,3
** itemredaction,3
** keysetprocess,3
** itxrefkeytype,3
** doctyperedaction,3
** hl7codedentrymap,3
** fontstructure,3
** doctypeinfo,3
** diskgroup,3
** batchprocesslog,3
** cblog,3
** chartfcytype,3
** trashcan,3
** scheduletemplate,3
** pswdpolicy,3
** sparakpostingsettings,3
** parsedfilename,3
** parsedqueue,3
** liccertificate,3
** vendornarchive,3
** loggeduser,2
** parsefilexitmtyp,2
** rimevents,2
** scanqueue,2
** scanqueuexit,2
** docmaint575,2
** docmaintf575,2
** foldertype,2
** eulaevents,2
** institutions,2
** itemtypexref,2
** keyitem116,2
** keytable10,2
** keytable11,2
** keytable12,2
** keytable127,2
** keytable129,2
** keytable13,2
** keytable122,2
** keytable123,2
** keytable124,2
** keytable23,2
** keytable24,2
** keytable25,2
** keytable26,2
** keytable27,2
** keytable3,2
** keytable4,2
** keytable5,2
** keytable6,2
** keytable7,2
** keytable74,2
** keytable75,2
** keytable76,2
** keytable8,2
** keytable9,2
** keyxitem117,2
** keyxitem118,2
** keyxitem120,2
** keyxitem122,2
** keyxitem123,2
** keyxitem126,2
** keyxitem119,1
** keyxitem115,1
** keyitem68,1
** keyitem51,1
** incompletecommit,1
** holdreason,1
** customit,1
** doctypeoverlay,1
** exindexcfg,1
** exindexxit,1
** fileformatsetup,1
** foldnotetempl,1
** folder,1
** faxconfig,1
** doctypekeyset,1
** docmaint156,1
** distprocess,1
** delinquencylevel,1
** dganalysisjob,1
** coreaccesstokenconfig,1
** cscprocreportopts,1
** codingflowxqueue,1
** dbcontactinfo,1
** ddssettings,1
** dynfoldtemplate,1
** dynfoldtmpl,1
** customquery,1
** codingqueue,1
** businessprocxbpmnproc,1
** codingflow,1
** cadscope,1
** bpmnprocessversion,1
** scanfiledesc,1
** scanformat,1
** systemtable,1
** systemtableex,1
** stmtserveropts,1
** terminalprefs,1
** roiprivs,1
** procparsefields,1
** scannersetup,1
** systemlockout,1
** usergparentfolder,1
** usermaxnumkeys,1
** xmldataport,1
** parsefiledescextdip,1
** meddepartment,1
** parentxfolder,1
** keyxitem125,1
** locktable,1
** licensedproductcontrol,1
** licensetable,1
** lbitemview,1


Los artículos se referencian en itemdatapage cuya estructura es:
```
CREATE TABLE [hsi].[itemdatapage](
	[filetypenum] [int] NULL,
	[docrevnum] [int] NULL,
	[itempagenum] [int] NULL,
	[itemnum] [int] NULL,
	[batchnum] [int] NULL,
	[diskgroupnum] [int] NULL,
	[logicalplatternum] [int] NULL,
	[filepath] [char](26) NULL,
	[filesize] [int] NULL,
	[compressfile] [int] NULL,
	[numbernotes] [int] NULL,
	[numberpages] [int] NULL,
	[physicalpagenum] [int] NULL,
	[numberlines] [int] NULL,
	[offset] [int] NULL,
	[deleteusernum] [int] NULL,
	[imagetype] [int] NULL,
	[imageoffsettype] [int] NULL,
	[numexceptions] [int] NULL,
	[xdpi] [int] NULL,
	[ydpi] [int] NULL,
	[textencoding] [int] NULL,
	[imageheight] [int] NULL,
	[imagewidth] [int] NULL
) ON [PRIMARY]
```

Puede extraer la información de una tabla asi:

OnBase.1> select * from keyxitem108 
OnBase.2> \go > /tmp/keyxitem108

La información extraida puede convertirse a SQL para insertar en otra base asi:

CREATE TABLE tmp_onbase_keytable108 (
        keywordnum      INTEGER PRIMARY KEY,
        keyvaluechar  VARCHAR(100)
);


grep "^ *[0-9][0-9]* .*" keytable108 | sed -e  "s/^ *\([0-9]*\) \(.*[^ ]\) *$/INSERT INTO tmp_onbase_keytable108 VALUES ('\1', '\2');/g" > inserta.sql
recode latin1..utf8 inserta.sql

CREATE TABLE tmp_onbase_keyxitem108 (
	itemnum	INTEGER,
	keywordnum INTEGER,
	keysetnum  INTEGER
);

grep "^ *[0-9][0-9]* .*" keyxitem108 | sed -e  "s/^ *\([0-9]*\) \([0-9]*\) \([0-9]*\) *$/INSERT INTO tmp_onbase_keyxitem108 VALUES ('\1', '\2', '\3');/g" > inserta.sql
recode latin1..utf8 inserta.sql

Para el ejemplo de las tablas antes mostrada se debería repetir con:
- Pagina 104
- Fuente 101
- Cat 1  112
- Cat 2  113
- Cat 3  114
- Depto  108
- Mcpio  110
- Fecha  103

# Usar base MS-SQL-Server desde Ruby

Emplear la gema tiny_tds

Ver detalles de su instalación en README.md


