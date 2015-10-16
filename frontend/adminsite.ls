/**
 * Admin module manage.
 * @module admin
 */


App = require './app'


MODULES =
  Profile  = require './admin/modules/profile'
  User     = require './admin/modules/new-user'
  Billing  = require './admin/modules/billing'


Menu = require './workspace-new/menu'

MENUS-MODULES = [
  new Menu MODULES: MODULES
  ]

Workspace = require './workspace-new'

/**
 * Admin
 * -----
 * @class Admin
 * @extends View
 */
class Admin extends App.View

  /** @override */
  el: $ \body

  /** @override */
  render: ->
    @el._append (new Workspace MENUS: MENUS-MODULES).render!.el
    super!

(new Admin).render!
