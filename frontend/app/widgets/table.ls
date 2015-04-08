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
 * @class Table
 * @extends View
 * @export
 */
class exports.Table extends App.View

  /** @override */
  _tagName: \table

  /** @override */
  _className: "#{gz.Css \table} #{gz.Css \table-hover}"

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
        ..css  = 'border-top:none; margin: auto;'
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

    for _attr in @_attributes
      App.dom._new \td
        ..html = @__get-value _model._attributes, _attr
        _tr._append ..

    _tr._model = _model
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
  __get-value: (_dto, _attr) -> @_templates[_attr] __get-by-attr _dto, _attr

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

  /**
   * Build rows from {@code Collection}.
   * @param {Collection} _collection
   */
  set-rows: (_collection) ->
    @t-body.html = ''
    for _model in _collection._models
      @add-row _model

  /**
   * Simple template for no user template passed.
   * @see @initialize
   * @private
   */
  simple-template = -> it

  /** @override */
  initialize: ({@_attributes, \
                _labels, \
                _templates = {}, \
                @on-dblclick-row = App._void._Function}) ->
    super!
    # <thead>
    @t-head = App.dom._new \thead
    @make-header _labels
    @el._append @t-head

    # Evaluating templates
    @_templates = _templates
    for _attr in @_attributes
      if not @_templates[_attr]
        @_templates[_attr] = simple-template  # see above of {@initialize}

    # <tbody>
    @t-body = App.dom._new \tbody
    @el._append @t-body

  /** @private */ _attributes: null
  /** @private */ _templates: null
  /** @private */ t-head: null
  /** @private */ t-body: null
  /**
   * On double click over row ({@code tr}).
   * @see @__dummy-on-dbl-click
   * @private
   */
  on-dblclick-row: null


# vim: ts=2:sw=2:sts=2:et
