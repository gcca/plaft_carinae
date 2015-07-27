/**
 * @module app.lists
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
alertTest = require './alerts-test' #TODO
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
  _._object @_sbs
    @gen-sbs-pair = -> ..


/** @export */
exports <<<
  document-type:  # Table 1
    _display:
      'DOCUMENTO NACIONAL DE IDENTIDAD'
      'CARNÉ DE EXTRANJERIA'
      'CARNÉ DE IDENTIDAD'
      'CÉDULA DE CIUDADANIA'
      'CÉDULA DIPLOMATICA DE IDENTIDAD'
      'PASAPORTE'
      'REGISTRO ÚNICO DE CONTRIBUYENTE'
      'OTRO'

    _code: #(gen-seq 7) ++ ['01']
      'dni'
      'ce'
      'ci'
      'cc'
      'cdi'
      'pa'
      'ruc'
      'otro'

    _short:
      'DNI'
      'CE'
      'CI'
      'CC'
      'CDI'
      'PA'
      'RUC'
      'OTRO'

    _sbs:
      (gen-seq 6) ++ ['01']

  jurisdiction: require './jurisdiction'

  regime: require './regime'

  activity: require './activity'

  activity-business: require './activity-business'

  office: require './office'

  ciiu: require './ciiu'

  ubigeo: require './ubigeo'

  alerts: require './alerts'

  alerts-test: alertTest

  country-sbs: require './country-sbs'

  anexo2: require './anexo2'

  anexo6: require './anexo6'

  money-source: require './money-source'

  alerts_user: ->
    sections = []
    sections_user = window.plaft.'user'.'permissions'.'sections'
    for section in sections_user
      if section is 'I'
        sections = sections.concat alertTest._alert-one
      else if section is 'III'
        sections = sections.concat alertTest._alert-three
    sections

# Generate {@code _pair} attribute
for , _obj of exports
  Object._properties _obj, do
    _pair: get: -> @gen-pair!
    _sbs-pair: get: -> @gen-sbs-pair!

  _obj <<<
    gen-pair: gen-pair
    gen-sbs-pair: gen-sbs-pair


# vim: ts=2:sw=2:sts=2:et
