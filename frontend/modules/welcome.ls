/** @module modules */

Module = require '../workspace-new/module'


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
        <i class='#{gz.Css \glyphicon} #{gz.Css \glyphicon-hand-up}'
            style='font-size:20pt'></i>
        \ &nbsp;&nbsp;
        <span style='vertical-align:super'>
          Seleccione algun modulo de la parte superior</span>
      </span>"
    super!


  /** @protected */ @@_mod-caption = 'INICIO'
  /** @protected */ @@_mod-icon    = gz.Css \certificate
  /** @protected */ @@_mod-hash  = 'auth-hash-welcome'


/** @export */
module.exports = Welcome


# vim: ts=2:sw=2:sts=2:et
