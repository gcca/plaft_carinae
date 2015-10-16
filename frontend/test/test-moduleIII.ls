/** @module modules */

Module = require '../workspace-new/module'


/**
 */
class TestIII extends Module

  _tagName: \div


  on-save: ->
    console.log 'asdasdasdasd'

  render: ->
    @el.html = "<h4>TEST MODULE III</h4>"
    super!

  @text = 'ESTO ESTA CARGADO DESDE EL MODULO'
  @@_mod-caption = 'TEST - MODULE III'
  @@_mod-icon    = gz.Css \remove
  _mod-group-buttons:
    * caption: 'GUARDAR-I'
      callback: ->
        console.log 'Test III'
        console.log 'REGISTRAR'
        console.log @text

    * caption: 'MODIFICAR-II'
      callback: ->
        console.log 'Test III'
        console.log 'MODIFICAR'
        console.log @


/** @export */
module.exports = TestIII


# vim: ts=2:sw=2:sts=2:et
