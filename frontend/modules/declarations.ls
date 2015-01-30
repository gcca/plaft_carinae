/** @module modules */

Module = require '../workspace/module'


/**
 */
class Declarations extends Module

  _tagName: \div

  render: ->
    @el.html = "<h4>Declarations</h4>"
    super!

  @@_caption = 'DECLARACIONES JURADAS'
  @@_icon    = gz.Css \tags


/** @export */
module.exports = Declarations


# vim: ts=2:sw=2:sts=2:et
