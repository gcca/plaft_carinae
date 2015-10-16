/** @module modules */

Module = require '../workspace-new/module'


/**
 */
class TestIV extends Module

  _tagName: \div


  on-save: ->
    console.log 'asdasdasdasd'

  render: ->
    @el.html = "<h4>TEST MODULE IV</h4>"
    super!

  @text = 'ESTO ESTA CARGADO DESDE EL MODULO'
  @@_mod-caption = 'TEST - MODULE IV'
  @@_mod-icon    = gz.Css \pencil
  _mod-group-buttons:
    * caption: 'GUARDAR-I'
      callback: ->
        console.log 'Test IV'
        console.log 'REGISTRAR'
        console.log @text

    * caption: 'MODIFICAR-II'
      callback: ->
        console.log 'Test IV'
        console.log 'MODIFICAR'
        console.log @


/** @export */
module.exports = TestIV


# vim: ts=2:sw=2:sts=2:et
