/** @module modules */

Module = require '../../workspace/module'
Officer = require './user'
/**
 * NewOfficer
 * --------
 *
 * @class NewOfficer
 * @extends Module
 */
class NewOfficer extends Module

  /** @override */
  render: ->
    @_desktop._spinner-start!

    App.ajax._get '/api/customs_agency/officers', true, do
      _success: (dto) ~>
        @_officer = Officer._new!
        @el._append @_officer.render!.el
        @_officer._fromJSON dto
        @_desktop._spinner-stop!

    super!

  /** @private */ _officer: null
  /** @protected */ @@_caption = 'REGISTRAR USUARIO'
  /** @protected */ @@_icon    = gz.Css \user
  /** @protected */ @@_hash    = 'NEWUSER-HASH'

/** @export */
module.exports = NewOfficer

# vim: ts=2:sw=2:sts=2:et
