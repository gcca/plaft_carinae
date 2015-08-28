/** @module workspace */

/**
 * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 * TODO: Workspace should be:
 *
 *  - - - - - - - - - - - - - -
 * |          top-bar   search |
 * |_ _ _ _ _ _ _ _ _ _ _ _ _ _|
 * |                           |
 * |                           |
 * |         workspace         |
 * |                           |
 * |                           |
 * |_ _ _ _ _ _ _ _ _ _ _ _ _ _|
 * |_ _ _ bottom (footer) _ _ _|
 *
 * To easy adding components on topbar.
 * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 */

Menu = require './menu'
Desktop = require './desktop'


class Save extends App.View

  /** @override */
  _tagName: \button

  /** @override */
  _className: "#{gz.Css \btn} #{gz.Css \btn-primary}"

  /** @override */
  _events:
    on-click: -> @trigger gz.Css \save

  /** @override */
  initialize: ->
    @el._type = 'button'

  /** @override */
  render: ->
    @el.html = 'Guardar'
    super!


/**
 * Workspace
 * ---------
 * TODO(...): Default search place.
 * @class Workspace
 * @extends View
 */
class Workspace extends App.View

  /** @override */
  _tagName: \div

  /** @override */
  _className: gz.Css \row

  /**
   * @override
   * Set search container to render search widget.
   * @param {Object.<HTMLElement, HTMLElement>} arg$
   */
  initialize: ({@save-place}) ->

  /**
   * Load module.
   * @param {Module} _module
   */
  load-module: (_module) ->
    @_menu._modules.load-module _module, null
    @_desktop.load-module _module

  /** @override */
  render: ->
    _save = new Save
    menu = new Menu
    desktop = new Desktop do
      _save: _save

    @save-place._append _save.render!.el

    App.dom._new \div
      .._class = "#{gz.Css \col-sm-3}
                \ #{gz.Css \col-md-2}
                \ #{gz.Css \sidebar}"
      .._append menu.render!.el
      @el._append ..

    App.dom._new \div
      .._class = "#{gz.Css \col-sm-9}
                \ #{gz.Css \col-sm-offset-3}
                \ #{gz.Css \col-md-10}
                \ #{gz.Css \col-md-offset-2}
                \ #{gz.Css \main}"
      .._append desktop.render!.el
      @el._append ..
    menu.on (gz.Css \select), desktop.load-module

    @_menu = menu
    @_desktop = desktop

    super!


  /** @private */ search-place: null
  /** @private */ save-place: null
  /** @private */ _menu: null
  /** @private */ _desktop: null


/** @export */
module.exports = Workspace


# vim: ts=2:sw=2:sts=2:et
