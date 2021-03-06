/** @module modules */

Module = require '../../workspace-new/module'


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
    name = window.'plaft'.'user'.'name'
    @el.html = "
      <h2> Bienvenido #{if name? then '- '+ name else '' }</h2>"
    super!

  /** @protected */ @@_mod-caption = 'BIENVENIDO'
  /** @protected */ @@_mod-icon    = gz.Css \user
  /** @protected */ @@_mod-hash    = 'auth-hash-profile'


/** @export */
module.exports = Profile


# vim: ts=2:sw=2:sts=2:et
