/** @module workspace */

/**
 * MenuAbstract
 * -------
 * @class MenuAbstract
 * @extends View
 */
class Menu extends App.View

  /** @override */
  _tagName: \span

  /** @override */
  _className: "#{gz.Css \dropdown}"

  /**
   * @param {HTMLLiElement} element
   */
  active-li: (element) ->
    # BUG: Se ejecuta muchas veces
    # Imprimir algo en consola de browser
    # para ver que se imprime varias veces
    element._class._toggle (gz.Css \active)
    if element._parent._constructor is HTMLUListElement
      @active-li element._parent._parent

  /**
   * Se selecciona el menu desde el `desktop`
   * @param {Module} module
   * @param {?Event} evt
   * @protected
   */
  load-module: (module, evt) ~~>
    @active-li @_current
    if not evt?
      evt = _target:
        @el.query ".#{gz.Css \glyphicon}-#{module._mod-icon}"
          ._parent._parent
    @_current = evt._target
    @active-li @_current
    @el._first._first.html = module._mod-caption  # set button title
    @trigger (gz.Css \select-menu), module

  /**
   * Add new module item.
   * @param {Module} module
   * @return {HTMLElement} <LI> element for module.
   * @protected
   */
  _add: (module) ->
    li = App.dom._new \li
      ..css = 'fontsize: 11px'

    if module._constructor is Array
      li.html = "<a>#{module[0]}</a>"
      module = module._slice 1, module._length
      ul = App.dom._new \ul
        .._class = gz.Css \dropdown-menu
      for module then ul._append @_add ..

      li._class = gz.Css \dropdown-submenu

      li._append ul
    else
      li.html = "<a><i class='#{gz.Css \glyphicon}
                        \ #{gz.Css \glyphicon}-#{module._mod-icon}'></i>
                        \&nbsp; #{module._mod-caption}</a>"
      li.on-click @load-module module

    li

  /** @override */
  initialize: ({@MODULES}) -> super!

  /** @override */
  render: ->
    first-module = @MODULES.0
    App.dom._new \span
      .._class = gz.Css \dropdown-toggle
      .._data.'toggle' = 'dropdown'
      ..html = "<span>#{first-module._mod-caption}</span>
                <span class='#{gz.Css \caret}'></span>"
      @el._append ..

    ul = App.dom._new \ul
      .._class = "#{gz.Css \dropdown-menu} #{gz.Css \multi-level}"

    for MODULE in @MODULES
      ul._append @_add MODULE

    @el._append ul

    super!


  /** @private */
  _current:
    _class: _toggle: App._void._Function
    _parent: _constructor: null
  /** @protected */ MODULES: null

module.exports = Menu

# vim: ts=2:sw=2:sts=2:et
