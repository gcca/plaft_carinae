/**
 * @module modules
 * @author gcca@gcca.tk (cristHian Gz. <gcca>)
 */

Module = require '../../workspace-new/module'
Treeview = require './treeview'


class Documents extends Module

  /** @override */
  render: ->
    @el._append (new Treeview).render!.el
    super!


  /** @protected */ @@_mod-caption = 'LEGISLACIÓN'
  /** @protected */ @@_mod-icon    = gz.Css \print
  /** @protected */ @@_mod-hash    = 'auth-hash-documents'


/** @export */
module.exports = Documents


/* vim: ts=2 sw=2 sts=2 et: */
