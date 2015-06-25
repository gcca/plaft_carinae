/** @module modules */

Module = require '../../workspace/module'
Officer = require './user'

class NewOfficer extends Module

  render: ->
    @_desktop._spinner-start!

    App.ajax._get '/api/customs_agency/officers', do
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
