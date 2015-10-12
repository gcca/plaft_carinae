/** @module workspace.desktop */

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
  _className: gz.Css \row


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
        'module': @current-module._constructor,
        'index': @current-index}

  /**
   * Carga el modulo inicial
   */
  start-module: (module) ~>
    @back._hide!  ## ocultar el botón REGRESAR
    @clean-cache!
    @cache-modules._length = 0
    mod = @_new module
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
    @send-trigger!

  /**
   * Crea un nuevo modulo y guarda modulo en @cache-modules
   */
  _new: (Module, _options = App._void._Object) ->
    module = Module._new _options
      .._desktop = @
      ..render!
      @cache-modules._push ..

  /** @overide */
  initialize: ({title-bar})->
    @search = title-bar.search
    @save = title-bar.save
    @back = title-bar.back
    @search.on (gz.Css \search), @on-search
    @save.on (gz.Css \save), @on-save
    @back.on (gz.Css \back), @close-last-page
    @cache-modules = new Array
    super!


  /** @private */
  current-module:~
    -> @cache-modules[@current-index]

  /** @private */ last-module: null

  /** @private */ search: null

  /** @private */ save: null

  /** @private */ back: null

  /** @private */ cache-modules: null

  /** @private */ current-index: null

  /** @static */ @@FIRST-MODULE = 0

/** @exports */
module.exports = Desktop


# vim: ts=2:sw=2:sts=2:et