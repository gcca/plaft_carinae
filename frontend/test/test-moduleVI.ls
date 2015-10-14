/** @module modules */

Module = require '../workspace-new/module'


/**
 */
class TestVI extends Module

  _tagName: \div


  on-save: ->
    console.log 'asdasdasdasd'

  render: ->
    @el.html = "<h4>TEST MODULE VI</h4>"
    super!

  @@_mod-caption = 'TEST - MODULE VI'
  @@_mod-icon    = gz.Css \tags
  _mod-group-buttons:
    * caption: 'GUARDAR-I'
      callback: ->
        console.log 'Test II'
        console.log 'REGISTRAR'
        console.log @text

    * caption: 'MODIFICAR-II'
      callback: ->
        console.log 'Test II'
        console.log 'MODIFICAR'
        console.log @


/** @export */
module.exports = TestVI


# vim: ts=2:sw=2:sts=2:et
