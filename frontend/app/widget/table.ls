/** @module modules */


/**
 * Table
 * -----
 * Para crear la tabla se necesita enviar dos listas, la de los atributos
 * de los modelos que serán mostrados en las filas y la de los títulos
 * de la cabeceras.
 *
 * Se pueden adicionar filas individuales mediante {@code add-row}.
 *
 *
 * @example
 * >>> labels =  # títulos de la cabecera
 * ...   'label 1'
 * ...   'label 2'
 * ...   ...
 * ...   'label n'
 * >>> attributes =  # atributos que se extraen del DTO para las filas
 * ...   'attribute 1'
 * ...   'attribute 2'
 * ...   ...
 * ...   'attribute n'
 * >>> table = new Table do
 * ...   _attributes : attributes
 * ...   _labels     : labels
 * >>> table.render!
 * >>> table.add-row do  # agrega una única fila
 * ...   'attribute 1': 'value 1'
 * ...   'attribute 2': 'value 2'
 * ...   ...
 * ...   'attribute n': 'value n'
 * >>> dtos =  # lista de $m$ DTO's para agregarlos como filas
 * ...   * 'attribute 1.1': 'value 1.1'
 * ...     'attribute 1.2': 'value 1.2'
 * ...     ...
 * ...     'attribute 1.n': 'value 1.n'
 * ...   * 'attribute 2.1': 'value 2.1'
 * ...     'attribute 2.2': 'value 2.2'
 * ...     ...
 * ...     'attribute 2.n': 'value 2.n'
 * ...   ...
 * ...   * 'attribute m.1': 'value m.1'
 * ...     'attribute m.2': 'value m.2'
 * ...     ...
 * ...     'attribute m.n': 'value m.n'
 * >>> table.add-rows dtos  # agrega múltiples filas
 * >>> # con plantillas
 * >>> table = new Table do
 * ...   _attributes : attributes
 * ...   _labels     : labels
 * ...   _templates  :
 * ...     'attribute 1': (_value) -> "<span>#{_value}</span>"
 * ...     # como {@code 'attribute 2'} no tiene una función asignada,
 * ...     # se imprime tal cual está en {@code attributes} a la celda,
 * ...     # es decir, sin parsear el valor.
 * ...     ...
 * ...     'attribute n': -> "<i>#{it}</i>"
 *
 * >>> # con on-dblclick-row
 * >>> table = new Table do
 * ...   _attributes : attributes
 * ...   _labels     : labels
 * ...   _templates  : {'param1': -> }
 * ...   on-dblclick-row: (evt) ~>
 * ...   # Este evento se lanzara cada vez que se haga doble-click sobre
 * ...   # una fila. El evt es el evento doble-click capturado
 * ...   # Esta funcion esta conectada al metodo __dummy-on-dblclick-row
 *
 * # TODO ###########################################################
 * Modificar el control atributos y templates para la creación de la tabla.
 * ##################################################################
 *
 * @class Table
 * @extends View
 * @export
 */
class Table extends App.View

  /** @override */
  _tagName: \div

  /** @override */
  _className: "#{gz.Css \col-md-12} #{gz.Css \no-padding}"

  /**
   * (Dummy) On double click over row ({@code tr}).
   * @param {Event} evt
   * @see @add-row
   * @private
   */
  __dummy-on-dblclick-row: (evt) ~> @on-dblclick-row ...

  /**
   * Make header table by label list.
   * @param {Array}
   * @see @initialize
   * @private
   */
  make-header: (_labels) ->
    _tr = App.dom._new \tr
    for _label in _labels
      App.dom._new \th
        ..html = _label
        ..css  = 'border-top:none; margin: auto;text-align:center;'
        _tr._append ..
    @t-head._append _tr

  /**
   * Add row by model.
   * @param {Model} _model
   * @return HTMLTableRowElement
   * @see __get-value, @on-dblclick-row
   */
  add-row: (_model) ->
    _tr = App.dom._new \tr
    _tr.css = 'text-align:center'
    _tr._model = _model

    for _attr in @_attributes
      App.dom._new \td
        ..css = @_column-cell-style[_attr]
        $ .. ._append @__get-value _model._attributes, _attr, _tr
        _tr._append ..

    _tr.on-dbl-click @__dummy-on-dblclick-row

    _model.on \change ~>
      _td = _tr._first
      for _attr in @_attributes
        _td.html = @__get-value _model._attributes, _attr
        _td = _td._next

    @t-body._append _tr
    _tr

  /**
   * Maps value from DTO parsing attribute name.
   * Useful for DTO's from models.
   * @param {Object} _dto
   * @param {string} _attr Attribute name.
   * @return Anything
   * @see @add-row, __get-by-attr
   * @private
   */
  __get-value: (_dto, _attr, _tr) -> @_templates[_attr] (__get-by-attr _dto, _attr),
                                                         _dto, _attr, _tr

  /**
   * Get object value by parsed attribute name.
   * @param {Object} _dto
   * @param {string} _attr Attribute name.
   * @see @__get-value
   * @private
   */
  __get-by-attr = (_obj, _attr) ->
    _levels = _attr._split \.
    for _key in _levels
      _obj = _obj[_key]
    _obj

  load-page: (evt) ~>
    @current-page._class._toggle gz.Css \active

    @current-page = evt._target
    cur-page = @current-page._rel
    start-item = cur-page * @row-show
    end-item = start-item + @row-show

    tr-s = @table._last.child-nodes

    for hide-tr in tr-s
      $ hide-tr ._hide!

    for show-tr in ($ tr-s .slice start-item, end-item)
      $ show-tr ._show!

    @current-page._class._toggle gz.Css \active

  load-pagination: (collection) ->
    total-rows = collection._length

    if total-rows <= @row-show
      return

    num-pages = parseInt total-rows/@row-show

    for page from 0 to num-pages
      page-num = page + 1
      App.dom._new \li
        ..html = "<a>#{page-num}</a>"
        .._rel = page
        ..on-click @load-page
        @pagination._append ..

    evt = _target: @pagination._first
    @load-page evt

  /**
   * Build rows from {@code Collection}.
   * @param {Collection} _collection
   */
  set-rows: (_collection) ->
    @t-body.html = ''
    if not _collection._models._length
      _tr = App.dom._new \tr
      App.dom._new \td
        ..html = '<h4>La tabla no contiene datos.</h4>'
        ..css = 'text-align:center'
        ..attr 'colspan', @_labels._length
        _tr._append ..
      @t-body._append _tr

    for _model in _collection._models
      @add-row _model

    @load-pagination _collection._models

  /**
   * Simple template for no user template passed.
   * @see @initialize
   * @private
   */
  simple-template = -> it

  _show: -> @el._class._remove gz.Css \hidden

  _hide: -> @el._class._add gz.Css \hidden

  /** @override */
  initialize: ({@_attributes, \
                @_labels, \
                _templates = {}, \
                @row-show = 12, \
                _column-cell-style = {} \
                @on-dblclick-row = App._void._Function}) ->
    super!

    App.dom._new \nav
      .._class = gz.Css \pull-right
      ..html = "<ul class='#{gz.Css \pagination}
                         \ #{gz.Css \pagination-sm}'
                    style='margin:0'></ul>"
      @pagination = .._first
      @el._append ..

    @table = App.dom._new \table
      .._class = "#{gz.Css \table} #{gz.Css \table-hover}"
      @el._append ..

    # <thead>
    @t-head = App.dom._new \thead
    @make-header @_labels
    @table._append @t-head

    # Evaluating templates and column cell style
    for _attr in @_attributes
      if not _templates[_attr]
        _templates[_attr] = simple-template  # see above of {@initialize}

      if not _column-cell-style[_attr]
        _column-cell-style[_attr] = ''

    @_templates = _templates
    @_column-cell-style = _column-cell-style

    # <tbody>
    @t-body = App.dom._new \tbody
    @table._append @t-body

  /** @private */ _attributes: null
  /** @private */ _templates: null
  /** @private */ _labels: null
  /** @private */ _column-cell-style: null
  /** @private */ t-head: null
  /** @private */ t-body: null
  /** @private */ table: null
  /** @private */ pagination: null
  /** @private */ row-show: null

  /** @private */
  current-page:
    _class: _toggle: App._void._Function

  /**
   * On double click over row ({@code tr}).
   * @see @__dummy-on-dbl-click
   * @private
   */
  on-dblclick-row: null

/**
 * @class SimpleTable
 * @extends View
 * @export
 */
class SimpleTable extends Table
  /**
   * Add row by model.
   * @param {Model} _model
   * @return HTMLTableRowElement
   * @see __get-value, @on-dblclick-row
   */
  add-row: (_model) ->
    _tr = App.dom._new \tr

    for _attr in @_attributes
      App.dom._new \td
        ..html = @__get-value _model, _attr
        ..css = @_column-cell-style[_attr]
        _tr._append ..

    _tr.on-dbl-click @__dummy-on-dblclick-row

    @t-body._append _tr
    _tr

  /**
   * Maps value from DTO parsing attribute name.
   * Useful for DTO's from models.
   * @param {Object} _dto
   * @param {string} _attr Attribute name.
   * @return Anything
   * @see @add-row, __get-by-attr
   * @private
   */
  __get-value: (_dto, _attr) -> @_templates[_attr] _dto[_attr]

  /**
   * Build rows from {@code Collection}.
   * @param {Collection} _collection
   */
  set-rows: (_collection) ->
    @t-body.html = ''
    # Filling list
    if not _collection._length
      _tr = App.dom._new \tr
      App.dom._new \td
        ..html = 'No contiene datos'
        ..css = 'text-align:center'
        ..attr 'colspan', @_labels._length
        _tr._append ..
      @t-body._append _tr

    for _ele in _collection
      e = {}
      for i from 0 to _ele._length-1
        e."#{@_attributes[i]}" = _ele[i]
      @add-row e

/** @export */
exports <<<
  Table: Table
  SimpleTable: SimpleTable

# vim: ts=2:sw=2:sts=2:et
