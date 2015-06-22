/** @module modules */


Modal = modal.Modal

class exports.CodeNameField extends App.View

  _tagName: \div

  /** @override */
  _className: "#{gz.Css \input-group} #{gz.Css \field-codename}"

  /**
   * (Event) On change input value.
   * @param {Object} evt
   * @private
   */
  changeCode: (evt) ~> @_span.html = @_hidden._value

  /**
   * (Event) On change cursor for name.
   * @param {Event} _
   * @param {Object} _data Same data from collection.
   * @private
   */
  changeName: (_, _data) ~>
    @_span.html = _data._code
    @_hidden._value = _data._code

  /**
   * (Event) On change value from number.
   * @private
   */
  changeValue: ~>
    _value = @_input._value
    if _value isnt ''
      if _value._match /\d+/
        i = @_code._index _value
        if i is -1
          @_input._value = 'Código inválido'
          @_span.html = '000'
          @_hidden._value = '000'
        else
          @_input._value = @_name[i]
          @_span.html = _value
          @_hidden._value = _value
      else
        _code = @_code[@_name._index _value]
        @_input._value = _value
        @_span.html = _code
        @_hidden._value = _code

  /**
   * @param {Object.<Array.<string>, Array.<string>, string>}
   * @override
   */
  initialize: ({@_code, @_name, @_field, @_max-length = 10}) !->

  /** @private */ _field  : null
  /** @private */ _code   : null
  /** @private */ _name   : null
  /** @private */ _input  : null
  /** @private */ _span   : null
  /** @private */ _hidden : null
  /** @private */ _max-length : null
  /** @private */ _typeahead : null

  /** @override */
  render: ->
    @el.html = ''
    @_input = App.dom._new \input
      .._type = \text
      .._name = "#{@_field}[name]"
      .._class = gz.Css \form-control

    @_span = App.dom._new \span
      .._class = gz.Css \input-group-addon
      ..html = '000'

    @_hidden = App.dom._new \input
      .._type = \hidden
      .._name = "#{@_field}[code]"

    # Hack
    Object._properties @_hidden, do
      _value:
        get: -> @value
        set: (a) ->  @value = a ; $ @ .trigger \change

    @el._append @_hidden
    @el._append @_input
    @el._append @_span
    @_typeahead = (new App.widget.Typeahead do
      el          : @_input
      full-args: [@_code, @_name]
      full-headers: <[Código Descripción]>
      _source     :
        _display : App.widget.Typeahead.Source.kDisplay
        _tokens  : App.widget.Typeahead.Source.kTokens
      _limit      : @_max-length
      _collection : [{
        _name    : n, \
        _code    : c, \
        _display : n, \
        _tokens  : n + ' ' + c } \
        for [n, c] in _.zip @_name, @_code]
      _template   : (p) -> "
        <p style='float:right;font-style:italic;margin-left:1em'>#{p._code}</p>
        <p style='font-size:14px;text-align:justify'>#{p._name}</p>")
      ..onCursorChanged @changeName
      ..onClosed @changeValue
      ..render!
    @_hidden.onChange @changeCode

    super!
/**
 * NameInput
 * ----------
 *
 * @class NameInput
 * @extends View
 * @export
 */
class exports.InputName extends App.View

  /** @override */
  _tagName: \div

  /** @override */
  initialize: ({@_name, @_field}) !->

  changeValue: ~>
    _value = @_input._value
    @_input._value = _value

  /** @override */
  render: ->
    @el.html = ''
    @_input = App.dom._new \input
      .._type = \text
      .._name = "#{@_field}"
      .._class = gz.Css \form-control

    @el._append @_input
    (new App.widget.Typeahead do
      el: @_input
      full-args: [@_name]
      full-headers: <[Descripción]>
      _source:
        _display: App.widget.Typeahead.Source.kDisplay
        _tokens: App.widget.Typeahead.Source.kTokens
      _limit: 3
      _collection: [{
        _name: n, \
        _display: n, \
        _tokens: n} \
        for n in @_name]
      _template: (p) -> "
        <p style='font-size:14px;text-align:justify'>#{p._name}</p>")
      ..onCursorChanged @changeName
      ..render!

    super!

  /** @private */ _field  : null
  /** @private */ _name   : null
  /** @private */ _input  : null


class exports.DisplaySelect extends App.View

  /** @override */
  _tagName: \div

  /** @override */
  _className: gz.Css \input-group

  _on-change-value: (evt) ~>
    @_change-value evt._target._item

  _change-value: (i) ->
    @_menu-short.html = @_list._short[i]
    @_hidden._value = @_list._code[i]

  /** @override */
  initialize: ({@_list, @_name, @_value}) -> super!

  /** @override */
  render: ->
    @el.html = ''

    @_hidden = App.dom._new \input
      .._type = \hidden
      .._name = @_name
      # .._value = @_value  # Se obvia porque es asignado al invocar
      #                     # el metodo {@code _fromJSON}.

    _select-btn = App.dom._new \button
      .._type = \button
      .._class = "#{gz.Css \btn}
                \ #{gz.Css \btn-default}
                \ #{gz.Css \dropdown-toggle}"
      .._data.'toggle' = 'dropdown'
      ..html = "<span></span>
                &nbsp;&nbsp;
                <span class='#{gz.Css \caret}'></span>"

      @_menu-short = .._first

    _dropdown = App.dom._new \ul
      .._class = "#{gz.Css \dropdown-menu}"

    _current-index = @_list._code._index @_value

    if @_value?
      if _current-index isnt -1
        @_change-value _current-index
      else
        # Data corrupta de la base de datos, o
        # brutalidad.
        throw 'c214cd1e-ed23-11e4-a9e7-0014a48224a1'

    for _display in @_list._display
      _a = App.dom._new \a
        ..html = _display

      _li = App.dom._new \li
        .._item = @_list._display._index _display
        ..on-click @_on-change-value
        .._append _a

      _dropdown._append _li

    @el._append @_hidden
    @el._append _select-btn
    @el._append _dropdown
    super!


  /** @private */ _list: null
  /** @private */ _display: null
  /** @private */ _code: null
  /** @private */ _short: null
  /** @private */ _menu-short: null

# vim: ts=2:sw=2:sts=2:et
