/** @module modules */

Module = require '../workspace-new/module'


/**
 */
class TestII extends Module

  _tagName: \div


  on-save: ->
    console.log 'asdasdasdasd'

  render: ->
    @el.html = "<h4>TEST MODULE IV</h4>"
    super!

  @text = 'ESTO ESTA CARGADO DESDE EL MODULO'
  @@_mod-caption = 'TEST - MODULE IV'
  @@_mod-icon    = gz.Css \tags
  @@_mod-group-buttons =
    * name: 'GUARDAR'
      callback: ~> console.log @text

    * name: 'MODIFICAR'
      callback: -> console.log 'Modificar'


/** @export */
module.exports = TestII


# vim: ts=2:sw=2:sts=2:et
