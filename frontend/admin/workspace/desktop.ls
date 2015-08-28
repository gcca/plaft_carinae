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
 */


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
    @_hide-save! # Hide button save in module.
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
  initialize: ({@_save}) ->
    @_save.on (gz.Css \save), @on-save

    # TODO: Improve "Regresar" button
    _btn = $ "<div id='#{gz.Css \id-back}'
    class='#{gz.Css \navbar-right} #{gz.Css \navbar-form} #{gz.Css \hidden}'>
            <button type='button' class='#{gz.Css \btn} #{gz.Css \btn-info}'>&laquo; Regresar</button>
          </div>"

    @_return-div = _btn.0
      .._first.on-click @close-last-page

    $ "##{gz.Css \id-navbar-collapse}" ._append  _btn


  /** @override */
  render: ->
    @$el.html "
      <ol class='#{gz.Css \breadcrumb}'>
        <li class='#{gz.Css \active}'>
          <i class='#{gz.Css \glyphicon} #{gz.Css \glyphicon-home}'></i>
          &nbsp;
        </li>
      </ol>"
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
   * Save view.
   * @type {View}
   * @private
   */
  _save: null


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
