/** @module modules */

Module = require '../workspace-new/module'


/**
* @Class Profile
* @extends Module
*/
class Profile extends Module

  /** @override */
  _tagName: \div

  /** @override */
  on-save: ->
     dto = @el.query 'form' ._toJSON!

     App.ajax._post '/update_data', dto, do
       _success: ~>
         @_desktop.notifier.notify 'Guardado'

  /** @override */
  render: ->
    @_desktop._show-save!
    window.'plaft'.'user'
      name = ..'name'
      customs_agency = ..'customs_agency'.'name'
      username = ..'username'
    @el.html = "
      <span> Bienvenido #{if name? then '-'+ name else '' }</span>
      <hr>
      <form class='#{gz.Css \col-md-6}'>
         <div class='#{gz.Css \form-group}'>
           <label>Agencia de aduana</label>
           <input type='text' class='#{gz.Css \form-control}'
                  name='agency'
                  value='#{customs_agency}'/>
         </div>
         <div class='#{gz.Css \form-group}'>
           <label>Usuario</label>
           <input type='text' class='#{gz.Css \form-control}'
                  name='user'
                  value='#{username}'/>
         </div>
         <div class='#{gz.Css \form-group}'>
           <label>Contraseña</label>
           <input type='text' class='#{gz.Css \form-control}'
                  name='password'/>
         </div>
       </form>"
    super!

  /** @protected */ @@_mod-caption = 'EDITAR PERFIL'
  /** @protected */ @@_mod-icon    = gz.Css \user
  /** @protected */ @@_mod-hash    = 'auth-hash-profile'


/** @export */
module.exports = Profile


# vim: ts=2:sw=2:sts=2:et
