/** @module workspace */

/**
 *
 * To easy adding components on topbar.
 * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 */

TitleBar = require './title-bar'
Menu = require './menu'
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
  el: $ \body

  /**
   * Carga modulo
   */
  load-module: ~>
    @_menu.load-module it, null

  /** @override */
  render: ->
    # add title
    title-bar = new TitleBar
      @el._append ..render!.el

    # add breadcrumb
    @_breadcrumb = new Breadcrumb

    # add menu
    @_menu = @_breadcrumb.menu

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
    @_menu.on (gz.Css \select-menu), @_desktop.start-module

    ## Listener: Cambio de modulo
    @_desktop.on (gz.Css \change-module), @_breadcrumb.load-module

    ## Listener: Modulo seleccionado en el breadcrumb
    @_breadcrumb.on (gz.Css \focus-module), @_desktop.load-module

    ## Titulo seleccionado
    title-bar.title.on (gz.Css \title), @load-module

    @el._append work-place

    ## Carga el primer modulo de la lista de modulos
    @load-module App.MODULES[0]

    super!

  /** @private */ _menu: null
  /** @private */ _desktop: null
  /** @private */ _breadcrumb: null

/** @export */
module.exports = Workspace


# vim: ts=2:sw=2:sts=2:et
