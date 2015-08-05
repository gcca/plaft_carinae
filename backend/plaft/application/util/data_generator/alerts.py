# encoding: utf-8

"""
Domain customs signal alerts.

To create Alert models in datastore.
Tuple: (section, code, description)

"""


alerts_1 = (
    ('I', '1',
     'El cliente, para efectos de su identificación,'
     ' presenta información inconsistente o de dificil'
     ' verificación por parte del sujeto obligado.',
     'DJ datos no coincide con Reniec o SUNAT'),
    ('I', '2',
     'El cliente declara o registra la misma dirección'
     ' que la de otras personas con las que no tiene relación'
     ' o vínculo aparente.',
     'DJ dirección errada, DA indica otra dirección'),
    ('I', '3',
     'Existencia de indicios de que el ordenante (propietario'
     '/titular del bien o derecho) ó el beneficiario (adquirente o'
     ' receptor del bien o derecho) no actúa por su cuenta y que'
     ' intenta ocultar la identidad del ordenante o beneficiario real.',
     'DJ sin dato tercero, DA indica un tercero como beneficiario'),
    ('I', '4',
     'El cliente presenta una inusual despreocupación por los'
     ' riesgos que asume o los importes involucrados en el despacho'
     ' aduanero de mercancias o los costos que implica la operación.',
     'Facturación detecta importes y costos altos de operación.'
     ' Sectorista detecta riesgos subpartidas no precisas,'
     ' trata de evadir aforo.'),
    ('I', '5',
     'El cliente realiza operaciones de forma sucesiva y/o reiterada.',
     'Cliente no habitual (nuevo) realiza operaciones de'
     ' forma sucesiva y/o reiterada.'),
    ('I', '6',
     'El cliente realiza constantemente operaciones y de modo inusual'
     ' usa o pretende utilizar dinero en efectivo como único medio'
     ' de pago.',
     'DJ dice dinero en efectivo, DA es pagado en efectivo'
     ' y realiza constantes OI'),
    ('I', '7',
     'El cliente se rehusa a llenar los formularios o proporcionar la'
     ' información requerida por el sujeto obligado, o se niega a realizar'
     ' la operación tan pronto se le solicita.',
     'Cliente se rehúsa llenar o firmar la DJ - Anexo 5'),
    ('I', '8',
     'Las operaciones realizadas por el cliente no corresponden'
     ' a su actividad económica.',
     'DJ indica actividad económica que no corresponde'
     ' actividad económica del cliente'),
    ('I', '9',
     'El cliente está siendo investigado o procesado por el delito'
     ' de lavado de activos, delitos precedentes, el delito de'
     ' financiamiento del terrorismo y sus delitos conexos, y se toma'
     ' conocimiento de ello por los medios de difusión pública u'
     ' otros medios.',
     'Cliente investigado LA/FT, conocimiento por difusión'
     ' periodística, radios, TV u otros'),
    ('I', '10',
     'Clientes entre los cuales no hay ninguna relación de'
     ' parentesco, financiera o comercial, sean personas naturales'
     ' o jurídicas, sin embargo son representados por una misma persona.'
     ' Se debe prestar especial atención cuando dichos clientes tengan'
     ' fijado sus domicilios en el extranjero o en paraísos fiscales.',
     'Clientes NO vinculados, representados por un misma persona,'
     ' en especial clientes con domicilio extranjero o paraísos fiscales'),
    ('I', '11',
     'El cliente realiza frecuentemente operaciones por sumas de'
     ' dinero que no guardan relación con la ocupación que declara tener.',
     'Cliente asume operaciones con sumas dinero que'
     ' no guardan relación con la ocupación que DJ declara'),
    ('I', '12',
     'Solicitud  del cliente de realizar despachos aduaneros de'
     ' mercancias en condiciones o valores que no guardan relación con'
     ' las actividades del dueño o consignatario, o en las condiciones'
     ' habituales del mercado.',
     'Cliente sus operaciones no guarda relación con su'
     ' actividad declara en su DJ o condiciones del mercado'),
    ('I', '13',
     'Solicitud del cliente de dividir los pagos por la prestación'
     ' del servicio, generalmente, en efectivo.',
     'DJ indica pago en efectivo y el cliente solicita dividir los pagos'),
    ('I', '14',
     'Personas naturales o jurídicas, incluyendo sus accionistas,'
     ' socios, asociados, socios fundadores, gerentes y directores,'
     ' que figuren en alguna lista internacional de las Naciones Unidas,'
     ' OFAC o similar.',
     'Se encuentran en lista negativas de Naciones Unidas, OFAC o similar'),
    ('I', '15',
     'El cliente presenta una inusual despreocupación por la'
     ' presentación o estado de su mercancía o carga y/o de'
     ' las comisiones y costos que implica la operación.',
     'Cliente despreocupación no se interesa por estado de su'
     ' mercancía, y costos operación.'),
    ('I', '16',
     'El cliente solicita ser excluido del registro de operaciones.',
     'Cliente expresamente solicita estar excluida RO'),
    ('I', '17',
     'El cliente asume el pago de comisiones, impuestos y cualquier'
     ' otro costo o tributo generado no sólo por la realización de sus'
     ' operaciones, sino la de terceros o a las de otras operaciones'
     ' aparentemente no relacionadas.',
     'Cliente asume los tributos de terceros no relacionados'),
    ('I', '18',
     'El cliente realiza frecuentes o significativas operaciones y'
     ' declara no realizar o no haber realizado actividad económica alguna.',
     'Se detecta negación del cliente no haber realizado operaciones,'
     ' inclusive con otras Agencias')
)


alerts_2 = (
    ('III', '1',
     'Existencia de indicios de exportaciones o importación ficticia'
     ' de bienes y/o uso de documentos presuntamente falsos o inconsistentes'
     ' con los cuales se pretenda acreditar estas operaciones de comercio'
     ' exterior.',
     'Mercancia ficticia con documentos inconsistentes, no se ubica carga,'
     ' se detecta con el vista en el aforo rojo'),
    ('III', '2',
     'Existencia de indicios respecto a que la cantidad'
     ' de mercancía importada es superior a la declarada.',
     'Se solicita aforo anticipado antes numerar por indicios mercancia'
     ' es superior a la declarada'),
    ('III', '3',
     'Existencia de indicios referidos a que la cantidad'
     ' de mercancía exportada es inferior a la declarada.',
     'Embarques con aforo, y se detecta mercancia inferior a la declarada'),
    ('III', '4',
     'Cancelaciones reiteradas de órdenes de embarque.',
     'Embarque no fueron embarcadas sin justificacion alguna'),
    ('III', '5',
     'Importaciones / exportaciones de gran volumen y/o valor,'
     ' realizadas por personas no residentes en el Perú, que no'
     ' tengan relación con su actividad económica.',
     'Verificar la actividad económicadel cliente si tienen personas'
     ' no residentes en el Perú'),
    ('III', '6',
     'Existencia de indicios de sobrevaloración y/o subvaluación'
     ' de mercancías importadas y/o exportadas.',
     'Existencia de indicios de sobrevaloración y/o subvaluación'
     ' de mercancías importadas y/o exportadas.'),
    ('III', '7',
     'Abandono de mercancías importadas.',
     'Mercancía no numerada por fecha llegada mayor 30 días,'
     ' DAM no canceladas, DAM con aforo rojo con observaciones del vista'),
    ('III', '8',
     'Importación de bienes suntuarios (entre otros, obras'
     ' de arte, piedras preciosas, antigüedades, vehículos lujosos)'
     ' que no guardan relación con el giro o actividad del cliente.',
     'No corresponde con el giro o actividad del cliente, verificar'
     ' la actividad comercial.'),
    ('III', '9',
     'Importaciones / exportaciones desde o hacia paraísos fiscales,'
     ' o países considerados no cooperantes por el GAFI o sujetos'
     ' a sanciones OFAC.',
     'Mercancia orientada paraisos fiscales, Lista de GAFI, o OFAC,'
     ' verifcar señales I 10, I 14.'),
    ('III', '10',
     'Importaciones y/o exportaciones realizadas por extranjeros'
     ' sin actividad permanente en el país.',
     'Mercancia por PJ/PN no residente en el pais - Accionistas extranjeros'),
    ('III', '11',
     'Importaciones y/o exportaciones realizadas por personas'
     ' naturales o jurídicas sin trayectoria en la actividad comercial'
     ' del producto importado y/o exportado.',
     'Mercancia de PJ/PN sin trayectoria en su actividad comercial'),
    ('III', '12',
     'Importaciones y/o exportaciones realizadas por personas'
     ' jurídicas que tienen socios jovenes sin experiencia aparente'
     ' en el sector.',
     'PJ con socios jovenes sin experiencia en el sector, verificar DJ'),
    ('III', '13',
     'Importación o almacenamiento de sustancias que se presuma'
     ' puedan ser utilizadas para la producción y/o fabricación'
     ' de estupefacientes.',
     'Mercancias en la produccion y/o fabricacion de estupefacientes'
     ' o drogas, verificar que subpartidas  no se encuentren en la'
     ' lista del D. Leg. N° 1126, DS 024-2013-EF - control IQPF'),
    ('III', '14',
     'Mercancías que ingresan documentalmente al país, pero'
     ' no físicamente sin causa aparente o razonable.',
     'Mercancía no ubicada con volante de despacho, no llego en la nave.'),
    ('III', '15',
     'Despachos realizados para una persona jurídica que tiene'
     ' la misma dirección de otras personas jurídicas, las que están'
     ' vinculadas por contar con el mismo representante, sin ningún'
     ' motivo legal o comercial ó económico aparente.',
     'Clientes PJ vinculadas con la misma direccion y mismo'
     ' representante legal'),
    ('III', '16',
     'Bienes dejados en depósito que totalizan sumas'
     ' importantes y que no corresponden al perfil de la'
     ' actividad del cliente.',
     'Mercancia en deposito, verificar perfil del cliente'),
    ('III', '17',
     'Existen indicios de que el valor de los bienes dejados'
     ' en depsito no corresponde al valor razonable del mercado.',
     'Mercancia con indicios de valor subvaluados, vista de aduana'
     ' lo observa'),
    ('III', '18',
     'Clientes cuyas mercancías presentan constantes abandonos'
     ' legales o diferencias en el valor y/o cantidad de la mercancía,'
     ' en las extracciones de muestras o en otros controles exigidos por'
     ' la regulación vigente.',
     'Clientes con señales alerta constante III 07, III 17,'
     ' extracción muestras'),
    ('III', '19',
     'Importaciones y/o exportaciones realizadas de/a principales'
     ' países consumidores de cocaína.',
     'Analizar paises de destino y/o origen consumidores cocaina'),
    ('III', '20',
     'El instrumento o la orden de pago, giro o remesa que'
     ' cancele la importación figure a favor una persona natural'
     ' o jurídica, distinta al proveedor del exterior, sin que exista'
     ' una justificación aparente, en caso el oficial de cumplimiento'
     ' cuente con esta información.',
     'OC para cumplir con esta señal se debe solicitar al'
     ' cliente el documento financiero de pago a su proveedor'
     ' para su verificación'),
    ('III', '21',
     'El pago de la importación se ha destinado a un país diferente'
     ' al país de origen de la mercancía, sin una justificación aparente.',
     'El pago al proveedor no concuerda con el pais de origen de'
     ' la mercancia, solicitar documento financiero al cliente'
     ' para detectar esta señal'),
    ('III', '22',
     'Existen indicios referidos a que se habrian presentado'
     ' documentos falsos o inconsistentes, con los cuales se pretenda'
     ' acreditar una operación y/o exportación.',
     'OC detecta señal alerta III 01'),
    ('III', '23',
     'El pago de la exportación provenga de persona diferente'
     ' al comprador/cliente en el exterior o que figure como tal la'
     ' persona natural o jurídica que realizó la exportación, sin que'
     ' exista una justificación aparente, en caso el oficial de'
     ' cumplimiento cuente con esta información.',
     'El pago de la exportacion proviene de comprador'
     ' diferente, para cumplir con esta señal alerta debe'
     ' pedir el documento financiero al cliente'),
    ('III', '24',
     'Personas naturales o jurídicas que hayan realizado exportación'
     ' de bienes, sin embargo no solicitan la restitución de derechos'
     ' arancelarios - drawback, aun cuando cumplen los requisitos'
     ' exigidos por la normativa vigente para acogerse a este beneficio.',
     'Cliente expresamente no solicita acogimiento al Drawback'),
    ('III', '25',
     'Solicitud de restitución de derechos arancelarios - drawback,'
     ' por exportaciones de productos cuyos valores, aparentemente y de'
     ' acuerdo a algunos indicios, se encontrarían por encima del precio'
     ' del mercado.',
     'Los productos afectos Drawback con indicios de sobrevaluacion,'
     ' determinar un método de indicios de valoración para cumplir'
     ' con esta señal.'),
    ('III', '26',
     'Envíos habituales de pequeños paquetes de mercancías a nombre'
     ' de una misma persona o diferentes personas con el mismo domicilio.',
     'Revisar exportaciones con el mismo domicilio'),
    ('III', '27',
     'Transferencia de certificados de depósito entre personas naturales'
     ' o jurídicas cuya actividad no guarde relación con los bienes'
     ' representados en dichos instrumentos.',
     'Verificar el endose de certificados depósitos y actividad'
     ' del tercero.'),
    ('III', '28',
     'Solicitud de empleo de almacenes de campo sin justificación'
     ' aparente, dado el tipo de bien sobre el que se pretende realizar'
     ' el depósito.',
     'Ingreso de mercancia a deposito de mercancia que no se justifica'
     ' el tipo de bien.'),
    ('III', '29',
     'El documento de transporte viene a nombre de una persona'
     ' natural o jurídica reconocida y luego es endosado a un tercero'
     ' sin actividad economica o sin trayectoria en el sector.',
     'Verificar endose de documentos de transporte (Conocimiento'
     ' Embarque, Guia Aerea, etc.) PN/PJ a un tercero'
     ' sin actividad economica.'),
    ('III', '30',
     'El importador dificulta o impide el reconocimiento físico'
     ' de la mercancia.',
     'Cliente impide el reconocimiento fisico de mercancia (aforo rojo)'),
    ('III', '31',
     'El cliente realiza operaciones de comercio exterior que'
     ' no guardan relación con el giro del negocio.',
     'Las operacion del cliente no guardan relación con el giro del negocio.'),
    ('III', '32',
     'Existencia de pagos declarados como anticipos de futuras'
     ' importaciones o exportaciones por sumas elevadas, en relacion'
     ' a las operaciones habituales realizadas por el cliente, sin'
     ' embargo existen indicios de que posteriormente no se realizó'
     ' la respectiva importacion o exportacion.',
     'Anticipos de pagos anticipados por operaciones no realizadas,'
     ' para cumplir con esta señal el OC solicita documentacion.'),
    ('III', '33',
     'Importadores o exportadores de bienes inusuales o nuevos'
     ' que de manera súbita o esporádica efectuen operaciones que no'
     ' guarden relacion por su magnitud con la clase del negocio o con'
     ' su nueva actividad comercial, o no tengan la infraestructura'
     ' suficiente para ello.',
     'Operaciones de mercancia nueva sin relacion con la clase'
     ' de negocio o nueva actividad comercial')
)


alerts = alerts_1 + alerts_2


# vim: et:ts=4:sw=4
