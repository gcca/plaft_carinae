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
     ' verificación por parte del sujeto obligado.'),
    ('I', '2',
     'El cliente declara o registra la misma dirección'
     ' que la de otras personas con las que no tiene relación'
     ' o vínculo aparente.'),
    ('I', '3',
     'Existencia de indicios de que el ordenante (propietario'
     '/titular del bien o derecho) ó el beneficiario (adquirente o'
     ' receptor del bien o derecho) no actúa por su cuenta y que'
     ' intenta ocultar la identidad del ordenante o beneficiario real.'),
    ('I', '4',
     'El cliente presenta una inusual despreocupación por los'
     ' riesgos que asume o los importes involucrados en el despacho'
     ' aduanero de mercancias o los costos que implica la operación.'),
    ('I', '5',
     'El cliente realiza operaciones de forma sucesiva y/o reiterada.'),
    ('I', '6',
     'El cliente realiza constantemente operaciones y de modo inusual'
     ' usa o pretende utilizar dinero en efectivo como único medio'
     ' de pago.'),
    ('I', '7',
     'El cliente se rehusa a llenar los formularios o proporcionar la'
     ' información requerida por el sujeto obligado, o se niega a realizar'
     ' la operación tan pronto se le solicita.'),
    ('I', '8',
     'Las operaciones realizadas por el cliente no corresponden'
     ' a su actividad económica.'),
    ('I', '9',
     'El cliente está siendo investigado o procesado por el delito'
     ' de lavado de activos, delitos precedentes, el delito de'
     ' financiamiento del terrorismo y sus delitos conexos, y se toma'
     ' conocimiento de ello por los medios de difusión pública u'
     ' otros medios.'),
    ('I', '10',
     'Clientes entre los cuales no hay ninguna relación de'
     ' parentesco, financiera o comercial, sean personas naturales'
     ' o jurídicas, sin embargo son representados por una misma persona.'
     ' Se debe prestar especial atención cuando dichos clientes tengan'
     ' fijado sus domicilios en el extranjero o en paraísos fiscales.'),
    ('I', '11',
     'El cliente realiza frecuentemente operaciones por sumas de'
     ' dinero que no guardan relación con la ocupación que declara tener.'),
    ('I', '12',
     'Solicitud  del cliente de realizar despachos aduaneros de'
     ' mercancias en condiciones o valores que no guardan relación con'
     ' las actividades del dueño o consignatario, o en las condiciones'
     ' habituales del mercado.'),
    ('I', '13',
     'Solicitud del cliente de dividir los pagos por la prestación'
     ' del servicio, generalmente, en efectivo.'),
    ('I', '14',
     'Personas naturales o jurídicas, incluyendo sus accionistas,'
     ' socios, asociados, socios fundadores, gerentes y directores,'
     ' que figuren en alguna lista internacional de las Naciones Unidas,'
     ' OFAC o similar.'),
    ('I', '15',
     'El cliente presenta una inusual despreocupación por la'
     ' presentación o estado de su mercancía o carga y/o de'
     ' las comisiones y costos que implica la operación.'),
    ('I', '16',
     'El cliente solicita ser excluido del registro de operaciones.'),
    ('I', '17',
     'El cliente asume el pago de comisiones, impuestos y cualquier'
     ' otro costo o tributo generado no sólo por la realización de sus'
     ' operaciones, sino la de terceros o a las de otras operaciones'
     ' aparentemente no relacionadas.'),
    ('I', '18',
     'El cliente realiza frecuentes o significativas operaciones y'
     ' declara no realizar o no haber realizado actividad económica alguna.')
)


alerts_2 = (
    ('III', '1',
     'Existencia de indicios de exportaciones o importación ficticia'
     ' de bienes y/o uso de documentos presuntamente falsos o inconsistentes'
     ' con los cuales se pretenda acreditar estas operaciones de comercio'
     ' exterior.'),
    ('III', '2',
     'Existencia de indicios respecto a que la cantidad'
     ' de mercancía importada es superior a la declarada.'),
    ('III', '3',
     'Existencia de indicios referidos a que la cantidad'
     ' de mercancía exportada es inferior a la declarada.'),
    ('III', '4',
     'Cancelaciones reiteradas de órdenes de embarque.'),
    ('III', '5',
     'Importaciones / exportaciones de gran volumen y/o valor,'
     ' realizadas por personas no residentes en el Perú, que no'
     ' tengan relación con su actividad económica.'),
    ('III', '6',
     'Existencia de indicios de sobrevaloración y/o subvaluación'
     ' de mercancías importadas y/o exportadas.'),
    ('III', '7',
     'Abandono de mercancías importadas.'),
    ('III', '8',
     'Importación de bienes suntuarios (entre otros, obras'
     ' de arte, piedras preciosas, antigüedades, vehículos lujosos)'
     ' que no guardan relación con el giro o actividad del cliente.'),
    ('III', '9',
     'Importaciones / exportaciones desde o hacia paraísos fiscales,'
     ' o países considerados no cooperantes por el GAFI o sujetos'
     ' a sanciones OFAC.'),
    ('III', '10',
     'Importaciones y/o exportaciones realizadas por extranjeros'
     ' sin actividad permanente en el país.'),
    ('III', '11',
     'Importaciones y/o exportaciones realizadas por personas'
     ' naturales o jurídicas sin trayectoria en la actividad comercial'
     ' del producto importado y/o exportado.'),
    ('III', '12',
     'Importaciones y/o exportaciones realizadas por personas'
     ' jurídicas que tienen socios jovenes sin experiencia aparente'
     ' en el sector.'),
    ('III', '13',
     'Importación o almacenamiento de sustancias que se presuma'
     ' puedan ser utilizadas para la producción y/o fabricación'
     ' de estupefacientes.'),
    ('III', '14',
     'Mercancías que ingresan documentalmente al país, pero'
     ' no físicamente sin causa aparente o razonable.'),
    ('III', '15',
     'Despachos realizados para una persona jurídica que tiene'
     ' la misma dirección de otras personas jurídicas, las que están'
     ' vinculadas por contar con el mismo representante, sin ningún'
     ' motivo legal o comercial ó económico aparente.'),
    ('III', '16',
     'Bienes dejados en depósito que totalizan sumas'
     ' importantes y que no corresponden al perfil de la'
     ' actividad del cliente.'),
    ('III', '17',
     'Existen indicios de que el valor de los bienes dejados'
     ' en depsito no corresponde al valor razonable del mercado.'),
    ('III', '18',
     'Clientes cuyas mercancías presentan constantes abandonos'
     ' legales o diferencias en el valor y/o cantidad de la mercancía,'
     ' en las extracciones de muestras o en otros controles exigidos por'
     ' la regulación vigente.'),
    ('III', '19',
     'Importaciones y/o exportaciones realizadas de/a principales'
     ' países consumidores de cocaína.'),
    ('III', '20',
     'El instrumento o la orden de pago, giro o remesa que'
     ' cancele la importación figure a favor una persona natural'
     ' o jurídica, distinta al proveedor del exterior, sin que exista'
     ' una justificación aparente, en caso el oficial de cumplimiento'
     ' cuente con esta información.'),
    ('III', '21',
     'El pago de la importación se ha destinado a un país diferente'
     ' al país de origen de la mercancía, sin una justificación aparente.'),
    ('III', '22',
     'Existen indicios referidos a que se habrian presentado'
     ' documentos falsos o inconsistentes, con los cuales se pretenda'
     ' acreditar una operación y/o exportación.'),
    ('III', '23',
     'El pago de la exportación provenga de persona diferente'
     ' al comprador/cliente en el exterior o que figure como tal la'
     ' persona natural o jurídica que realizó la exportación, sin que'
     ' exista una justificación aparente, en caso el oficial de'
     ' cumplimiento cuente con esta información.'),
    ('III', '24',
     'Personas naturales o jurídicas que hayan realizado exportación'
     ' de bienes, sin embargo no solicitan la restitución de derechos'
     ' arancelarios - drawback, aun cuando cumplen los requisitos'
     ' exigidos por la normativa vigente para acogerse a este beneficio.'),
    ('III', '25',
     'Solicitud de restitución de derechos arancelarios - drawback,'
     ' por exportaciones de productos cuyos valores, aparentemente y de'
     ' acuerdo a algunos indicios, se encontrarían por encima del precio'
     ' del mercado.'),
    ('III', '26',
     'Envíos habituales de pequeños paquetes de mercancías a nombre'
     ' de una misma persona o diferentes personas con el mismo domicilio.'),
    ('III', '27',
     'Transferencia de certificados de depósito entre personas naturales'
     ' o jurídicas cuya actividad no guarde relación con los bienes'
     ' representados en dichos instrumentos.'),
    ('III', '28',
     'Solicitud de empleo de almacenes de campo sin justificación'
     ' aparente, dado el tipo de bien sobre el que se pretende realizar'
     ' el depósito.'),
    ('III', '29',
     'El documento de transporte viene a nombre de una persona'
     ' natural o jurídica reconocida y luego es endosado a un tercero'
     ' sin actividad economica o sin trayectoria en el sector.'),
    ('III', '30',
     'El importador dificulta o impide el reconocimiento físico'
     ' de la mercancia.'),
    ('III', '31',
     'El cliente realiza operaciones de comercio exterior que'
     ' no guardan relación con el giro del negocio.'),
    ('III', '32',
     'Existencia de pagos declarados como anticipos de futuras'
     ' importaciones o exportaciones por sumas elevadas, en relacion'
     ' a las operaciones habituales realizadas por el cliente, sin'
     ' embargo existen indicios de que posteriormente no se realizó'
     ' la respectiva importacion o exportacion.'),
    ('III', '33',
     'Importadores o exportadores de bienes inusuales o nuevos'
     ' que de manera súbita o esporádica efectuen operaciones que no'
     ' guarden relacion por su magnitud con la clase del negocio o con'
     ' su nueva actividad comercial, o no tengan la infraestructura'
     ' suficiente para ello.')
)


# vim: et:ts=4:sw=4
