/** @module workspace */

Menu = require './menu'

MenuAbstract = require './menu-abstract'

/**
 * Settings
 * -------
 * @class Settings
 * @extends MenuAbstract
 */
class Settings extends MenuAbstract

  no-active: ->
    @index-menu.html = @@FIRST-OPTION

  /** @override */
  load-module: (module, evt) ~~>
    @index-menu.html = module._mod-caption
    @trigger (gz.Css \is-active), 'SETTINGS ACTIVO'
    super module, evt

  /** @override */
  _add: (module) ->
    li = super module
      ..on-click @load-module module
      ..html = "<a>#{module._mod-caption}</a>"

  /** @override */
  render: ->
    _r = super!
    ul = App.dom._new \ul
      .._class = gz.Css \dropdown-menu
      ..role = 'menu'

    @index-menu.html = "<i class='#{gz.Css \glyphicon}
                                \ #{gz.Css \glyphicon-cog}'></i>"
    for module in App.SETTINGS
      ul._append @_add module
    @el._append ul
    @@FIRST-OPTION = @index-menu.html
    _r

  /** @public */ index-settings: null

/**
 * Breadcrumb
 * ---------
 * Elemento para crear el title-bar
 * @example
 * another-view._append (new TitleBar).render!.el
 * @class Breadcrumb
 * @extends View
 */
class Breadcrumb extends App.View

  /** @override */
  _tagName: \div

  /** @override */
  _className: gz.Css \breadcrumb-container

  /**
   * Evento del elemento (<LI>).
   */
  on-click: (evt) ~>
    li = evt._target
    @trigger (gz.Css \focus-module), li._index

  /**
   * Carga el `breadcrumb`
   * @param {List<Object>} modules
   * @param {integer} index
   * @see @load-breadcrumb
   */
  load-breadcrumb: (modules, index) ->
    @breadcrumb.html = ''
    for m in modules
      li = App.dom._new \li
        .._index = m.'index'
        if m.'index' is index
          .._class = gz.Css \active
        ..html = m.'caption'
        ..css = 'font-size: 11px;cursor: hand;'
        ..on-click @on-click
      @breadcrumb._append li

  /**
   * Carga los `group-buttons` segun el modulo.
   * @param {Module} module
   * @see @load-module
   */
  load-group-buttons: (module)->
    @group-buttons.html = ''
    g-buttons = module._mod-group-buttons
    if g-buttons? and g-buttons._length
      for buttons in g-buttons
        App.dom._new \button
          .._class = "#{gz.Css \btn} #{gz.Css \btn-default}"
          .._type = 'button'
          ..html = buttons.'name'
          ..on-click buttons.'callback'
          @group-buttons._append ..

  /**
   * Carga todos los elementos del `breadcrumb`
   * @param {Object} obj
   * @see desktop.send-trigger
   */
  load-module: (obj) ~>
    @load-breadcrumb obj.'map', obj.'current'.'index'
    @load-group-buttons obj.'current'.'module'

  /** @override */
  initialize: ->
    @menu = new Menu
    @settings = new Settings
    super!

  /** @override */
  render: ->
    @menu-buttons = App.dom._new \div
      .._class = gz.Css \btn-group
      ..attr 'role', 'group'
      .._append @menu.render!.el
      .._append @settings.render!.el

    @menu.on (gz.Css \is-active), (msg) ~> @settings.no-active!
    @settings.on (gz.Css \is-active), (msg) ~> @menu.no-active!

    @group-buttons = App.dom._new \div
      .._class = "#{gz.Css \btn-group} #{gz.Css \btn-group-sm}"
      ..css = 'margin-left: 15px'
      ..attr 'role', 'group'

    @breadcrumb = App.dom._new \ol
      .._class = gz.Css \breadcrumb


    @el._append @menu-buttons
    @el._append @group-buttons
    @el._append @breadcrumb
    super!

  /** @public */ menu-buttons: null
  /** @public */ breadcrumb: null
  /** @public */ menu: null
  /** @private */ settings: null


module.exports = Breadcrumb

# vim: ts=2:sw=2:sts=2:et
