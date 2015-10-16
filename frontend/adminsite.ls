/**
 * Admin module manage.
 * @module admin
 */


App = require './app'

## Name in title
App.DISPLAY-NAME = window.'plaft'.'user'.'name'

## Modules
MODULES =
  Profile  = require './admin/modules/profile'
  User     = require './admin/modules/new-user'
  Billing  = require './admin/modules/billing'

## Menu
Menu = require './workspace-new/menu'

## List menus
MENUS-MODULES = [
  new Menu MODULES: MODULES
  ]

## Workspace
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
