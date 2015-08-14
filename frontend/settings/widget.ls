/**
 * @module settings
 * @author Javier Huaman
 *
 * CheckBoxTable
 * -----
 * Crea un tabla con checkbox de acuerdo a una lista personalizada, es decir
 * se envia como paramétro una lista con la cantidad de filas que se desea
 * mostrar.
 *
 * Para crear la dicho widget se debe enviar dos listas:  `_headers` para
 * las cabeceras  y `_columns` para las columnas.
 *
 * @example
 * >>> _headers = [1, 2, 3, 4, 5, 6, 7]
 * >>> _columns =
 *    * 'first-column': 'I'
 *      'checks': [{'value':"#{a[0]}-#{a[1]}",'tip': a[2]} for a in alert-one]
 *
 *    * 'first-column': 'II'
 *      'checks': [{'value':"#{a[0]}-#{a[1]}",'tip': a[2]} for a in alert-three]
 *
 *     ....
 *
 *    * 'first-column': 'II'
 *      'checks': [{'value':"#{a[0]}-#{a[1]}",'tip': a[2]} for a in alert-three]
 *
 * >>> Para el atributo `checks` en `_columns` recibe una lista de Objects{json}
 *     con la siguiente estructura:
 *     'checks': [{'value': a.value, 'tip': a.tip} for a in attributes]
 *
 * >>> `value` = es el valor que se asigna a los respectivos checkboxs.
 * >>> `tip` = es el mensaje no obligatorio para los diferentes checkboxs.
 *
 * checks = new CheckButtonTable do
 * ...  _headers: _headers
 * ...  _columns: _columns
 *
 * checks.render!
 *
 * @class CheckBoxTable
 * @extends View
 * @export
 */
class CheckBoxTable extends App.View

  /** @override */
  _tagName: \table

  /** @override */
  _className: gz.Css \table

  _toJSON: -> [v.'value' for v in @$el.find 'input[type="checkbox"]:checked']

  _fromJSON: (values) ->
    for values then (@$el.find ":checkbox[value=#{..}]").attr 'checked', on

  /**
   * Se agrega cabecera.
   * @param {Array}
   * @see @initialize
   */
  add-header: (_headers) ->
    _tr = App.dom._new \tr
      ..html = '<td></td>'

    for _header in _headers
      App.dom._new \th
        ..html = _header
        _tr._append ..

    @t-head._append _tr

  /**
   * Se agrega las filas con checkboxs.
   * @param {Array} _columns
   * @see @initialize
   */
  add-checkbox: (_columns) ->
    for _column in _columns
      _tr = App.dom._new \tr
        ..html = "<td>#{_column.'first-column'}</td>"

      for check in _column.'checks'
        _td = App.dom._new \td
        _td.css = 'text-align:center'
        App.dom._new \input
          .._type = 'checkbox'
          .._value = check.'value'
          if check.'tip'?
            ..title = check.'tip'
            $ .. ._tooltip do
              'template': "<div class='#{gz.Css \tooltip}' role='tooltip'
                                style='min-width:175px'>
                             <div class='#{gz.Css \tooltip-arrow}'></div>
                             <div class='#{gz.Css \tooltip-inner}'></div>
                           </div>"
          _td._append ..
        _tr._append _td
      @t-body._append _tr

  /** @override */
  initialize: ({_headers, _columns}) ->
    super!
    #t-head
    @t-head = App.dom._new \thead
    @add-header _headers
    @el._append @t-head

    #t-body
    @t-body = App.dom._new \tbody
    @add-checkbox _columns
    @el._append @t-body

  /** @private */ t-head: null
  /** @private */ t-body: null
  /** @private */ _name: null

/*
 * ListGroup
 * -----
 * Crea una lista con nombre y su respectivo check.
 *
 * Para crear la dicho widget se debe enviar dos listas:  `_items-group` para
 * proceder a crear el widget.
 *
 * @example
 * >>> _items-group= [{'value': a.value, 'name': m.name} for a in attributes]
 *
 * >>> `value` = es el valor que se asigna a los respectivos checkboxs.
 * >>> `name` = es el nombre que aparece al costado de los checkboxs.
 *
 * group = new ListGroup do
 * ...  _items-group: _items-group
 *
 * group.render!
 *
 * @class ListGroup
 * @extends View
 * @export
 */
class ListGroup extends App.View

  /** @override */
  _tagName: \ul

  /** @override */
  _className: gz.Css \list-group

  _toJSON: -> [i._value for i in @_items when i._checked]

  _fromJSON: (_items) ->
    for i in @_items
      if i._value in _items then i._checked = on

  /**
   * Se añade items en la lista.
   * @param {Array}
   * @see @initialize
   */
  add-item: (_items-group) ->
    for _item in _items-group
      _li = App.dom._new \li
        .._class = gz.Css \list-group-item
        ..html = _item.'name'

      App.dom._new \input
        .._type = 'checkbox'
        .._value = _item.'value'
        .._class = gz.Css \pull-right
        _li._append ..
        @_items._push ..

      @el._append _li

  /** @override */
  initialize: ({_items-group}) ->
    @_items = new Array
    super!
    @el.css = "max-height: 150px;overflow-y: scroll;"
    @add-item _items-group


  /** @private */ _values: null
  /** @private */ _items: null

/** @export */
exports <<<
  CheckBoxTable: CheckBoxTable
  ListGroup: ListGroup

# vim: ts=2:sw=2:sts=2:et
