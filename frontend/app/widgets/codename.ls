/** @module modules */

class CodeNameField extends App.View

#class
#    (new App.widget.Typeahead do
#      el: @el.query '[name=jurisdiction]'
#      _source:
#        _display: App.widget.Typeahead.Source.kDisplay
#        _tokens: App.widget.Typeahead.Source.kTokens
#      _limit: 9
#      _collection: [{
#        _name: _n, \
#        _code: "<span style='color:#555;font-size:10pt'>#_c</span>", \
#        _id: _c, \
#        _display: _n, \
#        _tokens: _n} \
#        for _c, _n of JURISDICTION_PAIR]
#      _template: (p) -> "
#        <p style='float:right;font-style:italic;margin-left:1em'>
#          #{p._code}</p>
#        <p style='font-size:14px;text-align:justify'>#{p._name}</p>")
#      ..render!
  /** @override */

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
  initialize: ({@_code, @_name, @_field}) !->

  /** @private */ _field  : null
  /** @private */ _code   : null
  /** @private */ _name   : null
  /** @private */ _input  : null
  /** @private */ _span   : null
  /** @private */ _hidden : null

  /** @override */
  render: ->
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

    (new App.widget.Typeahead do
      el          : @_input
      _source     :
        _display : App.widget.Typeahead.Source.kDisplay
        _tokens  : App.widget.Typeahead.Source.kTokens
      _limit      : 10
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


/** @export */
module.exports = CodeNameField


# vim: ts=2:sw=2:sts=2:et
