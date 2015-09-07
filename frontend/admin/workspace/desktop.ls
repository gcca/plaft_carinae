/** @module workspace.desktop
 *  - - - - - - - - - -
 * |_ _ _ _ _ _ _ _ _ _|
 * |      |            |
 * | Menu |  Desktop   |
 * |      |            |
 * |      |            |
 * |______|____________|
 *
 * This module manages the desktop zone.
 * Connect events between views: menu, desktop, search, breadcrumbs.
 *
 */

DesktopParent = require '../../workspace/desktop'

/**
 * Desktop
 * -------
 * @class DesktopParent
 * @extends View
 */
class Desktop extends DesktopParent

  /** @override */
  initialize: ({@_save}) ->
    super do
      _save: @_save
      _search: @_search

  /** TODO */
  _search:
    clean-input: ->
    _menu: ->
    on: ->

/** @export */
module.exports = Desktop


# vim: ts=2:sw=2:sts=2:et
