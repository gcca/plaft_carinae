/** @module workspace */

/**
 * MenuAbstract
 * -------
 * @class MenuAbstract
 * @extends View
 */
class MenuAbstract extends App.View

  /** @override */
  _tagName: \div

  /** @override */
  _className: "#{gz.Css \btn-group}"

  /**
   * Se selecciona el menu desde el `desktop`
   * @param {Module} module
   * @param {?Event} evt
   * @protected
   */
  load-module: (module, evt) ~~>
    @trigger (gz.Css \select-menu), module

  /**
   * Add new module item.
   * @param {Module} module
   * @return {HTMLElement} <LI> element for module.
   * @protected
   */
  _add: (module) ->
    App.dom._new \li
      ..css = 'fontsize: 11px'
      ..on-click @load-module module

  /** @override */
  render: ->
    @el.css = 'margin-right: 10px'
    App.dom._new \a
      .._class = gz.Css \dropdown-toggle
      ..css = 'color: #999'
      .._data.'toggle' = 'dropdown'
      ..html = "<span></span>
                <span class='#{gz.Css \caret}'></span>"
      @index-menu = .._first
      @el._append ..
    super!

  /** @protected */ index-menu: null

  /** @protected */ @@FIRST-OPTION = ""

module.exports = MenuAbstract

# vim: ts=2:sw=2:sts=2:et
