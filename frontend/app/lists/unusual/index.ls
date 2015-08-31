/** @module app.lists */


/** @export */
exports <<<

  person: require './person'

  operation: require './operation'

  alerts: require './alerts'

gen-code-display = ->
  _.zip @_code, @_display

/**
 * Template.
 * @return Array
 * @private
 */
gen-template = ->
  _.zip @_code, @_display, @_method

# Generate {@code _pair} attribute
for , _obj of exports
  Object._properties _obj, do
    _template: get: -> @gen-template!
    _code-display: get: -> @gen-code-display!

  _obj <<<
    gen-template: gen-template
    gen-code-display: gen-code-display

# vim: ts=2:sw=2:sts=2:et
