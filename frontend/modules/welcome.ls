/** @module modules */

Module = require '../workspace/module'


/**
 * Welcome
 * -------
 * Welcome page for dashboard.
 * @class Welcome
 * @extends Module
 */
class Welcome extends Module

  /** @override */
  render: ->
    @el.html = "
      <span>
        &nbsp;&nbsp;&nbsp;&nbsp;
        <i class='#{gz.Css \glyphicon} #{gz.Css \glyphicon-hand-left}'
            style='font-size:20pt'></i>
        \ &nbsp;&nbsp;
        <span style='vertical-align:super'>
          Dar clic en alguno de los módulos de la izquierda.</span>
      </span>"
    super!


  /** @protected */ @@_caption = 'INICIO'
  /** @protected */ @@_icon    = gz.Css \certificate
  /** @protected */ @@_hash  = 'WEL-HASH'


/** @export */
module.exports = Welcome


# vim: ts=2:sw=2:sts=2:et
