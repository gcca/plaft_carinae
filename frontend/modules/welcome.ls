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

  on-save: ->
    dto = @el.query 'form' ._toJSON!

    App.ajax._post '/update_data', dto, do
      _success: ~>
        @_desktop.notifier.notify 'Guardado'

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
      </span>
      <hr>
      <form class='#{gz.Css \col-md-6}'>
        <div class='#{gz.Css \form-group}'>
          <label>Agencia de aduana</label>
          <input type='text' class='#{gz.Css \form-control}'
                 name='agency'
                 value='#{window.'plaft'.'user'.'customs_agency'.'name'}'/>
        </div>
        <div class='#{gz.Css \form-group}'>
          <label>Usuario</label>
          <input type='text' class='#{gz.Css \form-control}'
                 name='user'
                 value='#{window.'plaft'.'user'.'username'}'/>
        </div>
        <div class='#{gz.Css \form-group}'>
          <label>Contraseña</label>
          <input type='text' class='#{gz.Css \form-control}'
                 name='password'/>
        </div>
      </form>
      "
    super!


  /** @protected */ @@_caption = 'INICIO'
  /** @protected */ @@_icon    = gz.Css \certificate
  /** @protected */ @@_hash  = 'WEL-HASH'


/** @export */
module.exports = Welcome


# vim: ts=2:sw=2:sts=2:et
