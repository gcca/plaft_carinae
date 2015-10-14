/** @module workspace */


MODULES = App.MODULES

MenuAbstract = require './menu-abstract'

/**
 * Menu
 * -------
 * @class Menu
 * @extends MenuAbstract
 */
class Menu extends MenuAbstract

  no-active: ->
    @index-menu.html = @@FIRST-OPTION

  /**
   * @override
   */
  load-module: (module, evt) ~~>
    @index-menu.html = "<i class='#{gz.Css \glyphicon}
                                \ #{gz.Css \glyphicon}-#{module._mod-icon}'></i>"
    @trigger (gz.Css \is-active), 'MENU ACTIVO'
    super module, evt

  /**
   * Add new module item.
   * @param {Module} module
   * @return {HTMLElement} <LI> element for module.
   * @override
   */
  _add: (module) ->
    li = super module
      ..html = "<a><i class='#{gz.Css \glyphicon}
                        \ #{gz.Css \glyphicon}-#{module._mod-icon}'></i>
                \&nbsp; #{module._mod-caption}</a>"

  /** @override */
  render: ->
    _r = super!
    @index-menu.html = "<i class='#{gz.Css \glyphicon}
                                \ #{gz.Css \glyphicon-align-justify}'></i>"
    ul = App.dom._new \ul
      .._class = gz.Css \dropdown-menu
      ..role = 'menu'
    for module in App.MODULES
      ul._append @_add module
    @el._append ul
    _r


  /** @protected */ _current: _class: _toggle: App._void._Function
  /** @protected */ @@FIRST-OPTION = "<i class='#{gz.Css \glyphicon}
                                    \ #{gz.Css \glyphicon-align-justify}'></i>"

/** @exports */
module.exports = Menu

# vim: ts=2:sw=2:sts=2:et
