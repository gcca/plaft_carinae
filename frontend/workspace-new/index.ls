/** @module workspace */

/**
 *
 * To easy adding components on topbar.
 * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 */

TitleBar = require './title-bar'
Desktop = require './desktop'
Breadcrumb = require './breadcrumb'

/**
 * Workspace
 * ---------
 * @class Workspace
 * @extends View
   --------------------------------------------------
  | /-TITLE-/      TITLE BAR      /-SEARCH-//-SAVE-/ |
   --------------------------------------------------
  |  |   -----------------------------               |
  |  |  /               breadcrumb              /    |
  |  |   -----------------------------          |    |
  |  |  ------------------------------          |    |
  |  |                                          |    |
  |  |                                          |    |
  |  |                   DESKTOP                |    |
  |  |                                          |    |
  |  |                                          |    |
  |  |                                          |    |
  |  |                                          |    |
  |  -------------------------------------------     |
  |                                                  |
   --------------------------------------------------
 *
 */
class Workspace extends App.View

  /** @override */
  _tagName: \div

  /**
   * Carga modulo
   */
  load-module: ~>
    @_menu.load-module it, null

  initialize: ({@MENUS})-> super!

  /** @override */
  render: ->
    # add title
    title-bar = new TitleBar
      @el._append ..render!.el

    # add breadcrumb
    @_breadcrumb = new Breadcrumb MENUS: @MENUS

    # add menu
    @_menu = @MENUS[0]

    # addd desktop
    @_desktop = new Desktop do
              title-bar: title-bar

    work-place = App.dom._new \div
      .._class = "#{gz.Css \container} #{gz.Css \app-container}"

    App.dom._new \div
      .._class = gz.Css \col-md-12
      .._append @_breadcrumb.render!.el
      .._append @_desktop.render!.el  # DESKTOP
      work-place._append ..

    ## Listener: Menu seleccionado
    for menu in @MENUS
      menu.on (gz.Css \select-menu), @_desktop.start-module

    ## Listener: Cambio de modulo
    @_desktop.on (gz.Css \change-module), @_breadcrumb.load-module

    ## Listener: Modulo seleccionado en el breadcrumb
    @_breadcrumb.on (gz.Css \focus-module), @_desktop.load-module

    ## Titulo seleccionado
    title-bar.title.on (gz.Css \title), @load-module

    @el._append work-place

    ## Carga el primer modulo
    @load-module App.FIRST-MODULE

    super!

  /** @private */ _menu: null
  /** @private */ _desktop: null
  /** @private */ _breadcrumb: null
  MENUS: null

/** @export */
module.exports = Workspace


# vim: ts=2:sw=2:sts=2:et
