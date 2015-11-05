/** @module workspace.desktop */

Notifier = require './notifier'

/**
 * Desktop
 * -------
 * @class Desktop
 * @extends View
 */
class Desktop extends App.View

  /** @overide */
  _tagName: \div

  /** @override */
  _className: "#{gz.Css \row} #{gz.Css \container}"

  /**
   * On search event to module.
   * @param {string} query
   * @param {string} filter
   * @private
   */
  on-search: (query, filter) ~>
    @current-module.on-search query, filter

  /**
   * On save event to module.
   * @private
   */
  on-save: ~>
    @current-module.on-save!

  #####################################################
  # MODULOS
  #####################################################
  /**
   * Limpia la lista de los modulos segun el indice que se pase.
   * @param {integer} index
   */
  clean-cache: (index = 0) ->
    c = @cache-modules[index]
    while c
      c._free!
      c = @cache-modules[++index]

  /**
   * Limpia el modulo actual y carga el modulo del indice.
   * @param {integer} i
   */
  load-module: (i) ~>
    last-module = @current-module
    @current-index = i
    @el._remove last-module.el
    @el._append @current-module.el
    @_search.clean-input!
    if @current-index isnt @@FIRST-MODULE then @back._show! else @back._hide!
    @send-trigger!

  /**
   * Envia Object en trigger con elementos
   * 'map': lista de los modulos (nombre e indice de lista)
   * 'current': modulo cargado en desktop
   */
  send-trigger: ->
    @trigger (gz.Css \change-module), do
      'map': [{'caption': k._constructor._mod-caption, \
               'index': j} for k, j in @cache-modules]
      'current': {
        'module': @current-module,
        'index': @current-index}

  /**
   * Deprecate
   * Cambiar el nombre en los otros modulos.
   */
  load-next-page: (sub-module, _options) ->
    @load-sub-module sub-module, _options
  /**
   * Carga el modulo inicial
   */
  start-module: (module) ~>
    @back._hide!  ## ocultar el botón REGRESAR
    @clean-cache!
    @cache-modules._length = 0
    mod = @_new module
    @_search.clean-input!
    @el._append mod.el
    @current-index = @@FIRST-MODULE
    @send-trigger!

  /**
   * Carga el submodulo correspondiente
   */
  load-sub-module: (sub-module, _options) ->
    if @cache-modules[@current-index + 1]?
      @clean-cache @current-index + 1
      @cache-modules = @cache-modules._slice 0, @current-index + 1
    @_new sub-module, _options
    @load-module @current-index + 1

  /**
   * Cierra la ultima pagina
   */
  close-last-page: ~>
    @load-module @current-index - 1

  /**
   * Crea un nuevo modulo y guarda modulo en @cache-modules
   */
  _new: (Module, _options = App._void._Object) ->
    Module._new _options
      .._desktop = @
      ..render!
      @_search._menu .._constructor._mod-search-menu
      @cache-modules._push ..

  /** @overide */
  initialize: ({title-bar})->
    @_search = title-bar.search
    @save = title-bar.save
    @back = title-bar.back
    App._debug._assert @_search
    @_search.on (gz.Css \search), @on-search
    @save.on (gz.Css \save), @on-save
    @back.on (gz.Css \back), @close-last-page
    @cache-modules = new Array
    @notifier = new Notifier
    super!


  /** @private */
  current-module:~
    -> @cache-modules[@current-index]

  /** @private */ last-module: null

  /** @private */ _search: null

  /** @private */ save: null

  /** @private */ back: null

  /** @private */ cache-modules: null

  /** @private */ current-index: null

  /** @static */ @@FIRST-MODULE = 0

  _lock: -> @_is-locked = true

  _unlock: -> @_is-locked = false

  _spinner-start: -> document.body._append @_spinner

  _spinner-stop: -> document.body._remove @_spinner if @_spinner._parent?


  ## ACTIONS IN BUTTON SAVE
  _show-save: -> @save._show!

  _hide-save: -> @save._hide!

  /**
   * Avoid re-render. Useful when use tables on main module.
   * @type {boolean}
   * @private
   */
  _is-locked: null

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

/** @exports */
module.exports = Desktop


# vim: ts=2:sw=2:sts=2:et
