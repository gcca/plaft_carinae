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


  jurisdiction: require './jurisdiction'

  regime: require './regime'

  activity: require './activity'

  activity-business: require './activity-business'

  money-source: require './money-source'

  office: require './office'

  ciiu: require './ciiu'

  ubigeo: require './ubigeo'


# Generate {@code _pair} attribute
for , _obj of exports
  Object._properties _obj, do
    _pair: get: -> @gen-pair!
    _sbs-pair: get: -> @gen-sbs-pair!

  _obj <<<
    gen-pair: gen-pair
    gen-sbs-pair: gen-sbs-pair


# vim: ts=2:sw=2:sts=2:et
