/** @module modules */

Module = require '../workspace-new/module'


/**
 */
class Declarations extends Module

  _tagName: \div

  render: ->
    @el.html = "<h4>Declarations</h4>"
    super!

  @@_mod-caption = 'DECLARACIONES JURADAS'
  @@_mod-icon    = gz.Css \tags


/** @export */
module.exports = Declarations


# vim: ts=2:sw=2:sts=2:et
