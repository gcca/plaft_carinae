/** @module workspace */


/**
 * Main module list.
 * To register new main modules.
 */
MODULES = App.MODULES


/**
 * Modules
 * -------
 * @class Modules
 * @extends View
 */
class Modules extends App.View

  /** @override */
  _tagName: \ul

  /** @override */
  _className: "#{gz.Css \nav} #{gz.Css \nav-pills} #{gz.Css \nav-stacked}"

  /**
   * Load module. Also, on module click to load on desktop.
   * @param {Module} module
   * @param {?Event} evt
   * @private
   */
  load-module: (module, evt) ~~>
    @_current._class._toggle (gz.Css \active)
    if not evt?
      evt = _target:
        @el.query ".#{gz.Css \glyphicon}-#{gz.Css module._icon}"
          ._parent._parent

    @_current = evt._target
    @_current._class._toggle (gz.Css \active)
    @trigger (gz.Css \select), module

  /**
   * Add new module item.
   * @param {Module} module
   * @return {HTMLElement} <LI> element for module.
   * @private
   */
  _add: (module) ->
    a = App.dom._new \a
      ..html = "<i class='#{gz.Css \glyphicon}
                        \ #{gz.Css \glyphicon}-#{module._icon}'></i>
                \&nbsp; #{module._caption}"

    li = App.dom._new \li
      ..on-click @load-module module
      .._append a

  /** @override */
  render: ->
    for module in MODULES
      @el._append @_add module
    super!


  /** @private */ _current: _class: _toggle: App._void._Function


/**
  * Menu
  * ----
  * @class Menu
  * @extends View
 */
class Menu extends App.View

  /** @override */
  _tagName: \div

  /** @override */
  _className: "#{gz.Css \hidden-print} #{gz.Css \affix-top}"

  /**
   * Trigger change item from menu.
   * @private
   */
  notify-change: ~>
    @trigger (gz.Css \select), it

  /**
   * Load module. Select current menu item.
   * @param {Module} _module
   */
  load-module: (_module) ->
    @_modules.load-module _module

  /** @override */
  initialize: ->
    @el.attr 'role' 'complementary'

  /** @override */
  render: ->
    App.dom._write ~> @el.css._font-size = '11px'
    @_modules = new Modules
      ..on (gz.Css \select), @notify-change
      @el._append ..render!.el
    super!


  /** @private */ _modules: null


/** @export */
module.exports = Menu


# vim: ts=2:sw=2:sts=2:et
