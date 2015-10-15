/** @module workspace */

Menu = require './menu'

MenuAbstract = require './menu-abstract'
FieldType = App.builtins.Types.Field

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
 *
 * group =
 * -- Check-box
 *  * caption: 'name-checkbox'
 *    options:  <[V1 V2]>
 *    type: kCheckBox
 *    callback: function ((element) ->)
 *
 * -- Radio
 *  * caption: 'name-radio'
 *    options:  <[V1 V2]>
 *    type: kRadioGroup
 *    callback: function ((element) ->)
 *
 * -- Combo-box
 *  * options:
 *      * name: 'description-function'
 *        callback: function ((element) ->)
 *      * name: 'description-function'
 *        callback: function ((element) ->)
 *      * name: 'description-function'
 *        callback: function ((element) ->)
 *    type: kComboBox
 *    caption: 'description combo box'
 *
 * -- Button
 *  * caption: 'description button'
 *    type: kButton
 *    callback: function ((element) ->)
 *
 *
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
    if li._class is gz.Css \active then return
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


  add-by-type: (element)->
    | element.'type' is FieldType.kComboBox =>
      _div = App.dom._new \div
        .._class = "#{gz.Css \btn-group}
                  \ #{gz.Css \btn-group-sm}"
        ..attr 'role', 'group'
        ..html = "<button type='button'
                    class='#{gz.Css \btn}
                         \ #{gz.Css \btn-default}
                         \ #{gz.Css \dropdown-toggle}'
                    data-toggle='dropdown' aria-haspopup='true'
                    aria-expanded='false'>
                      #{element.'caption'}
                   <span class='#{gz.Css \caret}'></span></button>"

      ul = App.dom._new \ul
        .._class = gz.Css \dropdown-menu

      for option in element.'options'
        li = App.dom._new \li
          ..html = "<a>#{option.'caption'}</a>"
          ..callback = option.'callback'
          ..on-click ~>
            callback = it._target.callback
              ..apply @current-module, [it._target]
          ul._append ..

      _div._append ul
      _div

    | element.'type' is FieldType.kButton =>
      App.dom._new \button
        .._class = "#{gz.Css \btn} #{gz.Css \btn-default}"
        .._type = 'button'
        ..html = element.'caption'
        ..on-click ~>
          (element.'callback').apply @current-module, [it.target]

    | element.'type' is FieldType.kRadioGroup =>
      div = App.dom._new \div
        .._class = "#{gz.Css \btn-group} #{gz.Css \btn-group-sm}"
        .._data.'toggle' = 'buttons'
        ..css = 'margin-left: 15px'

      for option in element.'options'
        label = App.dom._new \label
          .._class = "#{gz.Css \btn} #{gz.Css \btn-info}"

        App.dom._new \input
          .._type = 'radio'
          .._name = element.'caption'
          .._value = option
          ..attr 'autocomplete', off
          ..on-change ~>
            (element.'callback').apply @current-module, [it.target]
          label._append ..

        $ label ._append option

        div._append label

      div

    | element.'type' is FieldType.kCheckBox =>
      div = App.dom._new \div
        .._class = "#{gz.Css \btn-group} #{gz.Css \btn-group-sm}"
        .._data.'toggle' = 'buttons'
        ..css = 'margin-left: 15px'

      for option in element.'options'
        label = App.dom._new \label
          .._class = "#{gz.Css \btn} #{gz.Css \btn-warning}"

        App.dom._new \input
          .._type = 'checkbox'
          ..attr 'autocomplete', off
          ..on-change ~>
            (element.'callback').apply @current-module, [it.target]
          label._append ..

        $ label ._append option

        div._append label

      div

  /**
   * Carga los `group-buttons` segun el modulo.
   * @param {Module} module
   * @see @load-module
   */
  load-group-buttons: ->
    @group-buttons.html = ''
    elements = @current-module._mod-group-buttons
    if elements? and elements._length
      for element in elements
        if not element.'type'? then element.'type' = FieldType.kButton
        @add-by-type element
          @group-buttons._append ..

  /**
   * Carga todos los elementos del `breadcrumb`
   * @param {Object} obj
   * @see desktop.send-trigger
   */
  load-module: (obj) ~>
    @current-module = obj.'current'.'module'
    @load-breadcrumb obj.'map', obj.'current'.'index'
    @load-group-buttons!


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

    label-css = 'color:rgb(153,153,153);
                 display: inline-block;
                 width: 95px;
                 text-overflow:ellipsis;
                 white-space:nowrap;
                 overflow:hidden'
    @menu.el._first.css = label-css
    @settings.el._first.css = label-css

    @menu.on (gz.Css \is-active), (msg) ~> @settings.no-active!
    @settings.on (gz.Css \is-active), (msg) ~> @menu.no-active!

    @group-buttons = App.dom._new \div
      .._class = "#{gz.Css \btn-group} #{gz.Css \btn-group-sm}"
      ..css = 'margin-left: 15px'
      ..attr 'role', 'group'

    @breadcrumb = App.dom._new \ol
      .._class = "#{gz.Css \breadcrumb} #{gz.Css \pull-right}"


    @el._append @menu-buttons
    @el._append @group-buttons
    @el._append @breadcrumb
    super!

  /** @public */ menu-buttons: null
  /** @public */ breadcrumb: null
  /** @public */ menu: null
  /** @private */ settings: null
  /** @private */ current-module: null


module.exports = Breadcrumb

# vim: ts=2:sw=2:sts=2:et
