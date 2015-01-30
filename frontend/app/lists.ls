/**
 * @module app
 *
 * Keep naming style:
 * >>> list-name:
 * ...   _display    : {...}  # show in app
 * ...   _code       : {...}  # show in app
 * ...   _sbs-display: {...}  # to send
 * ...   _sbs-code   : {...}  # to send
 * ... ...
 *
 * When list have no {@code _sbs} and {@code _sbs-code} use {@code display}
 * and {@code _code} to show an send.
 * {@code _pair} attribute is optional. It's a object with _display
 * as attributes and _code as values.
 *
 * @author gcca@gcca.tk (cristHian Gz. <gcca>)
 */


/**
 * Generate sequence.
 * @param {number} n Elements number to list.
 * @param {number?} max-length
 * @return Array.<string>
 * @private
 */
gen-seq = (n, max-length = 3) ->
  # TODO(): Improve by ten^n step
  _zeros = '0' * --max-length
  _level = 10
  for i from 1 to n
    unless i % _level
      _zeros = '0' * --max-length
      _level *= 10
    _zeros ++ i


/**
 * Pair generator.
 * @return Object
 * @private
 */
gen-pair = ->
  _._object @_code, @_display
    @gen-pair = -> ..


/**
 * SBS pair generator.
 * @return Object
 * @private
 */
gen-sbs-pair = ->
  _._object @_sbs-code, @_sbs-display
    @gen-sbs-pair = -> ..


/** @export */
exports <<<
  document-type:  # Table 1
    _display:
      'CARNÉ DE EXTRANJERIA'
      'CARNÉ DE IDENTIDAD'
      'CÉDULA DE CIUDADANIA'
      'CÉDULA DIPLOMATICA DE IDENTIDAD'
      'DOCUMENTO NACIONAL DE IDENTIDAD'
      'PASAPORTE'
      'OTRO'
      'REGISTRO ÚNICO DE CONTRIBUYENTE'

    _code: (gen-seq 7) ++ ['01']

  jurisdiction:
    _display:
      'A NIVEL NACIONAL'
      'AÉREA DEL CALLAO'
      'AEROPUERTO DE TACNA'
      'ALMACÉN SANTA ANITA'
      'AREQUIPA'
      'CETICOS - TACNA'
      'CHICLAYO'
      'CHIMBOTE'
      'COMPLEJO FRONTERIZO SANTA ROSA - TACNA'
      'CUSCO'
      'DEPENDENCIA FERROVIARIA TACNA'
      'DEPENDENCIA POSTAL DE AREQUIPA'
      'DEPENDENCIA POSTAL DE SALAVERRY'
      'DEPENDENCIA POSTAL TACNA'
      'DESAGUADERO'
      'ILO'
      'INTENDENCIA DE PREVENCIÓN Y CONTROL FRONTERIZO'
      'INTENDENCIA NACIONAL DE FISCALIZACIÓN ADUANERA (INFA)'
      'IQUITOS'
      'LA TINA'
      'LIMA METROPOLITANA'
      'MARÍTIMA DEL CALLAO'
      'MOLLENDO - MATARANI'
      'OFICINA POSTAL DE LINCE'
      'PAITA'
      'PISCO'
      'POSTAL DE LIMA'
      'PUCALLPA'
      'PUERTO MALDONADO'
      'PUNO'
      'SALAVERRY'
      'SEDE CENTRAL - CHUCUITO'
      'TACNA'
      'TALARA'
      'TARAPOTO'
      'TERMINAL TERRESTRE TACNA'
      'TUMBES'
      'VUCE ADUANAS'

    _code:
      '983'
      '235'
      '947'
      '974'
      '154'
      '956'
      '055'
      '091'
      '929'
      '190'
      '884'
      '910'
      '965'
      '893'
      '262'
      '163'
      '316'
      '307'
      '226'
      '299'
      '992'
      '118'
      '145'
      '901'
      '046'
      '127'
      '244'
      '217'
      '280'
      '181'
      '082'
      '000'
      '172'
      '028'
      '271'
      '928'
      '019'
      '848'

  regime:
    _display:
      'Importacion para el Consumo'
      'Reimportacion en el mismo Estado'
      'Exportacion Definitiva'
      'Exportacion Temporal para Reimportacion en el mismo Estado'
      'Exportacion Temporal para Perfeccionamiento Pasivo'
      'Admision temporal para Perfeccionamiento Activo'
      'Admision temporal para Reexportacion en el mismo Estado'
      'Drawback'
      'Reposicion de Mercancias con Franquicia Arancelaria'
      'Deposito Aduanero'
      'Reembarque'
      'Transito Aduanero'
      'Importacion Simplificada'
      'Exportacion Simplificada'
      'Material de Uso Aeronautico'
      'Destino Especial de Tienda Libre (DUTY FREE)'
      'Rancho de naves'
      'Material de Guerra'
      'Vehiculos para Turismo'
      'Material uso Aeronautico'
      'Ferias o Exposiciones Internacionales'
      ''
    _code:
      '10'
      '36'
      '40'
      '51'
      '52'
      '21'
      '20'
      '41'
      '41'
      '70'
      '89'
      '80'
      '18'
      '48'
      '71'
      '72'
      ''
      ''
      ''
      ''
      '20'
      ''

  activity:  # Table 7
    _display:
      'ABOGADO'
      'ACTOR, ACTRIZ, ARTISTA, DIRECTOR DE ESPECTÁCULOS, COREÓGRAFO, MODELO,
       \ MÚSICO, ESCENÓGRAFO Y BAILARINES'
      'ACTUARIO'
      'ADMINISTRADOR'
      'ADUANERO/AGENTE DE ADUANAS/INSPECTORES DE FRONTERA'
      'AEROMOZO/ AZAFATA'
      'AGENTE / INTERMEDIARIO / CORREDOR INMOBILIARIO'
      'AGENTE DE BOLSA'
      'AGENTE DE INMIGRACIÓN/MIGRACIÓN'
      'AGENTE DE TURISMO/VIAJES'
      'AGENTE/INTERMEDIARIO/CORREDOR DE SEGUROS'
      'AGRICULTOR, AGRÓNOMO, AGRÓLOGO, ARBORICULTOR, AGRIMENSOR, TOPOGRAFO,
       \ GEOGRAFO'
      'ALBAÑIL, OBRERO DE CONSTRUCCIÓN'
      'AMA DE CASA'
      'ANALISTAS DE SISTEMA Y COMPUTACIÓN'
      'ANTROPÓLOGO, ARQUEÓLOGO Y ETNÓLOGO'
      'ARCHIVERO'
      'ARMADOR DE BARCO'
      'ARQUITECTO'
      'ARTESANO'
      'ASISTENTE SOCIAL'
      'AUTOR LITERARIO, ESCRITOR Y CRÍTICO'
      'AVICULTOR'
      'BACTERIÓLOGO, FARMACÓLOGO, BIÓLOGO, CIENTÍFICO'
      'BASURERO / BARRENDERO'
      'CAJERO'
      'CAMARERO / BARMAN / MESERO/ COCINERO / CHEF'
      'CAMBISTA, COMPRA/VENTA DE MONEDA'
      'CAMPESINO'
      'CAPATAZ'
      'CARGADOR'
      'CARPINTERO'
      'CARTERO'
      'CERRAJERO'
      'COBRADOR'
      'COMERCIANTE / VENDEDOR'
      'CONDUCTOR, CHOFER / TAXISTA'
      'CONSERJE / PORTERO/ GUARDIAN/ VIGILANTE'
      'CONSTRUCTOR'
      'CONTADOR'
      'CONTRATISTA'
      'CORTE Y CONFECCIÓN DE ROPA/ FABRICANTE DE PRENDAS'
      'COSMETÓLOGO, PELUQUERO Y BARBERO'
      'DECORADOR, DIBUJANTE, PUBLICISTA, DISEÑADOR DE PUBLICIDAD'
      'DENTISTA / ODONTÓLOGO'
      'DEPORTISTA PROFESIONAL, ATLETA, ARBITRO, ENTRENADOR DEPORTIVO'
      'DISTRIBUIDOR'
      'DOCENTE'
      'ECONOMISTA'
      'ELECTRICISTA'
      'EMPLEADA (O) DEL HOGAR / NANA'
      'EMPRESARIO EXPORTADOR/ EMPRESARIO IMPORTADOR'
      'ENFERMERO'
      'ENSAMBLADOR'
      'ESCULTOR'
      'ESTUDIANTE'
      'FOTÓGRAFO / OPERADORES CÁMARA, CINE Y TV, LOCUTOR DE RADIO Y TV, GUIONISTA'
      'GANADERO'
      'GASFITERO'
      'HISTORIADOR'
      'INGENIERO'
      'INTÉRPRETE, TRADUCTOR'
      'JARDINERO'
      'JOCKEY'
      'JOYERO Y/O PLATERO / ORFEBRE'
      'JUBILADO / PENSIONISTA'
      'LABORATORISTA (TÉCNICO)'
      'LIQUIDADOR, RECLAMACIONES/SEGUROS'
      'MAQUINISTA / OPERADOR DE MAQUINARIA'
      'MARTILLERO / SUBASTADOR'
      'MAYORISTA, COMERCIO AL POR MAYOR'
      'MECÁNICO'
      'MÉDICO / CIRUJANO'
      'METALURGISTA'
      'MIEMBRO DE LAS FUERZAS ARMADAS'
      'NUTRICIONISTA'
      'OBRERO / OPERADOR'
      'OBSTETRIZ'
      'ORGANIZADOR DE EVENTOS'
      'PANADERO / PASTELERO'
      'PARAMÉDICO'
      'PERIODISTA'
      'PERITO'
      'PESCADOR'
      'PILOTO'
      'PINTOR'
      'POLICIA MUNICIPAL'
      'POLICIA PNP'
      'PRODUCTOR DE CINE / RADIO / TELEVISIÓN / TEATRO'
      'PRODUCTOR, CULTIVOS EXTENSIVOS'
      'PROGRAMADOR'
      'PSICÓLOGO/ TERAPEUTA'
      'QUIROPRÁCTICO/ KINESITERAPEUTA (KINESIÓLOGOS)'
      'RELACIONISTA PÚBLICO E INDUSTRIAL'
      'RELOJERO'
      'REPARACIÓN DE AUTOMÓVILES,PINTOR RETOCADOR'
      'REPARADOR DE APARATOS ELECTRODOMÉSTICOS'
      'REPARTIDOR'
      'SACERDOTE / MONJA'
      'SECRETARIA, RECEPCIONISTA, TELEFONISTA'
      'SEGURIDAD / GUARDAESPALDA / GUARDIA DE SEGURIDAD'
      'SERVICIO DE ALMACENAMIENTO/ALMACENERO'
      'SERVICIO DE ALQUILER DE VEHÍCULOS'
      'SERVICIO DE ALQUILER DE VIDEOS, EQUIPOS DE SONIDO'
      'SOCIÓLOGO'
      'TASADOR'
      'TÉCNICO'
      'TORERO'
      'TRAMITADOR'
      'TRANSPORTE DE CARGA Y/O MUDANZA'
      'TRANSPORTISTA'
      'VENDEDOR AMBULANTE'
      'VETERINARIO, ZOOLOGO, ZOOTÉCNICO'
      'VISITADOR MÉDICO'
      'ZAPATERO'
      'OTROS'
      'NO DECLARA'

    _code: App._void._Array

  activity-business:
    _display:
      "Agrícola"
      "Pecuario"
      "Silvicultura (extracción de madera)"
      "Pesca"
      "Minería"
      "Hidrocarburos y/o similares"
      "Conservas y Productos de Pescado"
      "Refinación de Petróleo "
      "Productos Cárnicos "
      "Azúcar"
      "Arroz"
      "Otras Industrias Primarias"
      "Alimentos, Bebidas y Tabaco"
      "Textil, Cuero y Calzado"
      "Transformación de la Madera"
      "Industrias del Papel, Imprenta y Reproducción de Grabaciones"
      "Productos Químicos, Caucho y Plástico"
      "Minerales no Metálicos"
      "Productos Metálicos, Maquinaria e Equipo"
      "Industria del Hierro y Acero"
      "Reciclaje"
      "Otras Industrias"
      "Generación de Energía Eléctrica y Agua"
      "Restaurantes"
      "Hoteles, Hostales y Alojamientos"
      "Casinos, Tragamonedas, Loterías, Juegos de Azar y/o similares"
      "Transportes"
      "Almacenamiento"
      "Telecomunicaciones y  Correos"
      "Intermediación Financiera"
      "Compra y Venta de divisas"
      "Administración Pública, Defensa y Seguridad Social (PEPS)"
      "Enseñanza"
      "Salud"
      "Informática"
      "Asesoramiento, Consultoría e Investigación y Desarrollo"
      "Otros Servicios"
      "Construcción"
      "Inmobiliaria"
      "Alquiler de Maquinaria"
      "Comercio Automotriz"
      "Comercio de Arroz"
      "Comercio al por mayor"
      "Comercio al por menor"
      "Otros Comercios"
      "Actividades de Asociaciones"
      "ONG"
      "Organizaciones y Organos Extraterritoriales"
      "No identificado"



  money_source:
    _display:
      'Efectivo'
      'Ahorros'
      'Herencia'
      'Prestamo bancario'
      'Venta Inmueble'
      'Recursos de la empresa'
      'Financiado por el Banco'
      'Ahorros'
      'Herencia'
      'Prestamo bancario'
      'Venta Inmueble'
      'Venta de terrenos'

    to-payment:
      'EFECTIVO'
      'EFECTIVO'
      'EFECTIVO'
      'EFECTIVO'
      'EFECTIVO'
      'NO EFECTIVO'
      'NO EFECTIVO'
      'NO EFECTIVO'
      'NO EFECTIVO'
      'NO EFECTIVO'
      'NO EFECTIVO'
      'NO EFECTIVO'


  ciiu: require './list/ciiu'

  ubigeo: require './list/ubigeo'


# Generate {@code _pair} attribute
for , _obj of exports
  Object._properties _obj, do
    _pair: get: -> @gen-pair!
    _sbs-pair: get: -> @gen-sbs-pair!

  _obj <<<
    gen-pair: gen-pair
    gen-sbs-pair: gen-sbs-pair


# vim: ts=2:sw=2:sts=2:et
