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
 * TODO(...): Breadcrumb for module on desktop.
 */

Notifier = require './notifier'


class Treeview extends App.View

  /** @override */
  _tagName: \ul

  /**
   * Collapse list.
   */
  _toggle: !-> @$el._toggle!

  __UL_TYPES =
      gz.Css \circle
      gz.Css \square

  /**
   * Generate tree from data.
   * @param {Array<String|Array<...>>} _tree
   */
  render: (_tree = new Array, _global, _level = 0) ->  # HARDCODE: level
    _global = @ if not _global  # TODO: Remove this!!
    @el.html = null
    if _tree and _tree._constructor is Array
      for _node in _tree
        App.dom._new \li
          ..css.'cursor' = 'pointer'
          ..html = _node.0
          @el._append ..

          if _node.1  # Is there something?
            if _node.1._constructor is Array  # subtree
              tv = new Treeview
              # HARDCODE: level
              @el._append (tv.render _node.1, _global, (_level + 1)).el

              # TODO: On toggle method for treeview.
              ((tv) -> ..on-click ~> tv._toggle!) tv

              # HARDCODE: level
              ..css.'list-style-type' = __UL_TYPES[_level % 2]

            if _node.1._constructor is Number  # leaf
              ((_node) -> ..on-click ~>
                _global.trigger (gz.Css \leaf-click), _node.1) _node

              # HARDCODE: level
              ..css.'list-style-type' = gz.Css \disc


    # ------------------------
    # What if `_tree` is null?
    # ------------------------
    super!


class Documents extends App.View

  _tagName: \div

  maximize-viewer: ~>
    if @_viewer.class-name is gz.Css \col-md-12
      $ @treeview-container ._show!
      @_viewer.class-name = gz.Css \col-md-8
    else
      $ @treeview-container ._hide!
      @_viewer.class-name = gz.Css \col-md-12

  __func = (_body, _level, _id, _callback) ->
    App.ajax._get "/api/document/#_id", null, do
      _success: (_list) ->
        _select = App.dom._new \select
          .._class = "#{gz.Css \form-control}
                    \ #{gz.Css \col-md-12}"
          ..css = "float:none;
                   padding-left:#{_level}em"
          ..html = '<option value="0"></option>'

          ..on-change (evt) ->
            _target = evt._target

            _tmp = new Array
            _iter = _target._next
            while _iter
              _tmp._push _iter
              _iter = _iter._next

            for _el in _tmp
              _body._remove _el

            _id = _target._value
            if _id isnt '0'
              __func _body, (_level + 1), _id, ->  # _body._append _select

        for _pair in _list
          App.dom._new \option
            .._value = _pair.1
            ..html = _pair.0
            _select._append ..

        _body._append _select  # see callback

        _callback!
      _error: -> alert 'Loop'

  /** @override */
  render: ->
    App.ajax._get '/api/document/list', null, do
      _success: (_tree) ~>
        # treeview
        @treeview-container = App.dom._new \div
          .._class = gz.Css \col-md-4

          @treeview = new Treeview
            ..on (gz.Css \leaf-click), (hdr-id) ~>
              @_current-node = null
              App.ajax._get "/api/document/#{hdr-id}/getbody", null, do
                _success: (_body) ~>
                  @_viewer.html = _body
                  # TODO: Remove HARCODE for tables
                  for t in @_viewer.query-all \table
                    t.style.'width' = '100%'
                    t.style.'margin' = '0'
                  @_current-node = hdr-id
                _error: -> alert '95c4c788-5b2c-11e5-be89-001d7d7379f5'
          .._append (@treeview.render _tree .el)

          @el._append ..

        # viewer
        @_viewer = App.dom._new \div
          .._class = gz.Css \col-md-8
          ..css = 'background-color:#fffecd'
          @el._append ..


      _error: -> alert '2553a338-575e-11e5-a88b-001d7d7379f5'
    super!


  /** @private */ treeview: null
  /** @private */ treeview-container: null
  /** @private */ _viewer: null
  /** @private */ _current-node: null


/**
 * Desktop
 * -------
 * To manage and show modules. Add interaction with {@code UiSearch}.
 * Sub-modules working module stacking collection.
 * TODO(...): Pop methods maybe don't need implementation. They are write only
 *   for naming convention.
 * @class Desktop
 * @extends View
 */
class Desktop extends App.View

  /** @override */
  _tagName: \div

  /** @override */
  _className: gz.Css \row

  /**
   * Set current module. Can be used like an event.
   * @param {Object} Module Base module class.
   * @public
   */
  load-module: (@Module) ~>
    if @_is-locked
      # TODO: Check if @Module is the same last module. Otherwise
      #       set lock to false and continue.
      return
    #---------------------
    # Sub-module extension
    #---------------------
    @close-last-page! if @_sub-module?

    #-------
    # Module
    #-------
    @clean-current!
    @_search.clean-input!
    @_hide-save! # Hide button save in module.
    @_search._menu @Module._search-menu
    @el._append (@_new Module).render!.el

  /**
   * Clean current module and sub-modules.
   * @see @change
   * @private
   */
  clean-current: ->
    @module.el.css._display = ''
    @module._free!

  /**
   * Reload current module.
   * @protected
   */
  _reload: -> @load-module @Module

  /**
   * On search event to module.
   * @param {string} query
   * @param {string} filter
   * @private
   */
  on-search: (query, filter) ~>
    @module.on-search query, filter

  /**
   * On save event to module.
   * @private
   */
  on-save: ~>
    @module.on-save!

  /**
   * Add customized properties to constructed module.
   * @param {Object} Module Class.
   * @return {Object} Module Object.
   * @private
   */
  _new: (Module) ->
    @module = Module._new!
      .._desktop = @

  #------------------
  # Next page methods
  #------------------

  /**
   */
  load-next-page: (sub-module, _options) ->
    ################################################################
    # TODO: Verificar uso del desktop en la función `render` de los
    # sub-módulos para mostrar el botón 'Guardar'.
    ################################################################
    @_show-save!
    @module.$el._hide!
    mod = sub-module._new _options
    @el._append mod.render!.el
    @_sub-module = mod
    @_return-div._class._remove gz.Css \hidden

    @_aux-module = @module
    mod._parent = @module
    @module = mod

    ########################################################################
    # TODO: Integrar submodulos (rehacer).
    ########################################################################
    mod._desktop = @

  close-last-page: ~>
    if @_sub-module?
      @module = @_aux-module

      @_sub-module._free!
      @_sub-module = null
      @_hide-save!
      @module.$el._show!
      @_return-div._class._add gz.Css \hidden

  _sub-module: null

  _aux-module: null

  _return-div: null

  _lock: -> @_is-locked = true

  _unlock: -> @_is-locked = false

  _spinner-start: -> document.body._append @_spinner

  _spinner-stop: -> document.body._remove @_spinner if @_spinner._parent?

  _show-save: -> @_save.$el._show!

  _hide-save: -> @_save.$el._hide!

  #-----
  # View
  #-----

  /** @override */
  initialize: ({@_search, @_save}) ->
    App._debug._assert @_search
    @_search.on (gz.Css \search), @on-search
    @_save.on (gz.Css \save), @on-save

    # TODO: Improve "Regresar" button
    _btn = $ "<div id='#{gz.Css \id-back}'
    class='#{gz.Css \navbar-right} #{gz.Css \navbar-form} #{gz.Css \hidden}'>
            <button type='button' class='#{gz.Css \btn} #{gz.Css \btn-info}'>&laquo; Regresar</button>
          </div>"

    @_return-div = _btn.0
      .._first.on-click @close-last-page

    $ "##{gz.Css \id-navbar-collapse}" ._append  _btn

    # Notifier
    @notifier = new Notifier

  /** @override */
  render: ->
    ###########################################
    # TODO: !!! Remove treeview. No hardcode. #
    ###########################################
    @$el.html "
      <ol class='#{gz.Css \breadcrumb}'>
        <li class='#{gz.Css \active}'>
          <i class='#{gz.Css \glyphicon} #{gz.Css \glyphicon-home}'></i>
          &nbsp;
        </li>
        <li class='#{gz.Css \pull-right}'>
          <button type='button'
                  class='#{gz.Css \btn}
                       \ #{gz.Css \btn-default}
                       \ #{gz.Css \btn-xs}'>
            Legislación
          </button>
        </li>
      </ol>"

    # Show modal treeview
    @el._first._last._first.on-click ->
      _modal = new App.widget.message-box.Modal do
        _title: 'Legislación'
        _body: (new Documents).render!.el
      _modal._body.style.'padding' = '0'
      _modal._footer.style.'display' = 'inline'
      _modal._show App.widget.message-box.Modal.CLASS.large

    @$el._append "<div class='#{gz.Css \hidden}'></div>"
    super!


  /**
   * Current module.
   *
   * Nothing function.
   * To doesn't write validation for "null" module.
   * Pseudo-module with {@code free} void function. To match with
   * module interface and avoid {@code if} structure when change
   * current module on desktop.
   *
   * @type {Object}
   * @private
   */
  module:
   _free: App._void._Function
   on-search: App._void._Function
   el:
     _next: null
     css: _display : 'none'

  /**
   * Current Module class.
   * Used when need to reload the current module.
   * @see _reload
   * @type {Object?}
   * @private
   */
  Module: null

  /**
   * Search view.
   * @type {View}
   * @private
   */
  _search: null

  /**
   * Save view.
   * @type {View}
   * @private
   */
  _save: null

  /**
   * Notifier view.
   * @type {View}
   * @public
   */
  notifier: null

  /**
   * Avoid re-render. Useful when use tables on main module.
   * @type {boolean}
   * @private
   */
  _is-locked: null

  /**
   * Avoid re-render. Useful when use tables on main module.
   * @type {boolean}
   * @private
   */
  _spinner: (App.dom._new \div
    .._id = gz.Css \loader-wrapper
    ..html = "<div id='#{gz.Css \loader}'></div>")


/** @export */
module.exports = Desktop


# vim: ts=2:sw=2:sts=2:et
