/** @module modules */


/**
* @class TableModel
* @extends Model
*/
class TableModel extends App.Model
  urlRoot: ''

/**
 * @Class CollectionTable
 * @extends Collection
 */
class CollectionTable extends App.Collection
  model: TableModel

/**
 * Table
 * -----
 * Para crear la tabla se necesita enviar dos listas, la de los atributos
 * de los modelos que serán mostrados en las filas y la de los títulos
 * de la cabeceras.
 *
 * @class Table
 * @extends View
 * @export
 */
class TableJSON extends App.View

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
        ..css  = 'border-top:none; margin: auto;text-align:center;'
        _tr._append ..
    @t-head._append _tr

  /**
   * Add row by model.
   * @param {Object} _attribute
   * @return HTMLTableRowElement
   * @see __get-value, @on-dblclick-row
   */
  add-row: (_attribute) ->
    row = App.dom._new \tr

    for _attr in @_attributes
      App.dom._new \td
        ..css = @_column-cell-style[_attr]
        $ .. ._append @__get-value _attribute, _attr, row
        row._append ..
    row.on-dbl-click @__dummy-on-dblclick-row

    @t-body._append row
    row

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

  is-empty: (attributes) -> not attributes._length

  empty-table: (attributes) ->
    @t-body.html = "<tr>
                      <td colspan='#{@_attributes._length}'
                          style='text-align:center'>
                        <h4>La tabla no contiene datos.</h4>
                      </td>
                    </tr>"

  /**
   * Build rows from {@code Array}.
   * @param {Array} _attributes
   */
  set-rows: (_attributes) ->
    for _attribute in _attributes
      @add-row _attribute

    if @is-empty _attributes then @empty-table _attributes

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
                _column-cell-style = {} \
                @on-dblclick-row = App._void._Function}) ->
    super!
    @t-head = App.dom._new \thead
    @make-header _labels
    @el._append @t-head

    for _attr in @_attributes
      if not _templates[_attr]
        _templates[_attr] = simple-template

      if not _column-cell-style[_attr]
        _column-cell-style[_attr] = ''

    @_templates = _templates
    @_column-cell-style = _column-cell-style

    @t-body = App.dom._new \tbody
    @el._append @t-body

  /** @private */ _attributes: null
  /** @private */ _templates: null
  /** @private */ _column-cell-style: null
  /** @private */ t-head: null
  /** @private */ t-body: null
  /**
   * On double click over row ({@code tr}).
   * @see @__dummy-on-dbl-click
   * @private
   */
  on-dblclick-row: null

class TableCollection extends TableJSON

  add-row: (_model) ->
    row = super _model._attributes
    row._model = _model
    _model.on \change ~>
      _td = row._first
      for _attr in @_attributes
        _td.html = @__get-value _model._attributes, _attr
        _td = _td._next
    row

  set-rows: (_collection) ->
    table-collection = new CollectionTable _collection

    for _model in table-collection._models
      @add-row _model



/** @export */
exports <<<
  TableJSON: TableJSON
  TableCollection: TableCollection

# vim: ts=2:sw=2:sts=2:et
