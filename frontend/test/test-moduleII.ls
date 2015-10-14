/** @module modules */

Module = require '../workspace-new/module'


/**
 */
class TestII extends Module

  _tagName: \div


  on-save: ->
    console.log 'asdasdasdasd'

  render: ->
    @el.html = "<h4>TEST MODULE II</h4>"
    super!

  @text = 'ESTO ESTA CARGADO DESDE EL MODULO'
  @@_mod-caption = 'TEST - MODULE II'
  @@_mod-icon    = gz.Css \tags
  _mod-group-buttons:
    * caption: 'GUARDAR-I'
      callback: ->
        console.log 'Test I'
        console.log 'REGISTRAR'
        console.log @text

    * caption: 'MODIFICAR-II'
      callback: ->
        console.log 'Test I'
        console.log 'MODIFICAR'
        console.log @


/** @export */
module.exports = TestII


# vim: ts=2:sw=2:sts=2:et
