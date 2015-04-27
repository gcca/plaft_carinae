/** @module modules */

class exports.SearchByDto extends App.View

  /** @override */
  _tagName: \div

  /** @override */
  _className: gz.Css \input-group

  /**
   * (Event) On change value from number.
   * @private
   */
  changeValue: ~>
    @_value = @_items[@_input._value]
    @_search-dto!

  _search-dto: ~>
    App.ajax._get ("/api/#{@_url}/" + @_value), null, do
      _success: @_callback

  initialize: ({@_url, @_items, @_callback}) !->


  /** @override */
  render: ->
    @el.html = ''
    @_input = App.dom._new \input
      .._type = \text
      .._name = \search
      .._class = gz.Css \form-control

    @el._append @_input
    (new App.widget.Typeahead do
      el: @_input
      _source:
        _display: App.widget.Typeahead.Source.kDisplay
        _tokens: App.widget.Typeahead.Source.kTokens
      _limit: 3
      _collection: [{
        _name: n, \
        _code: '<span style="color:#555;font-size:9px">...</span>', \
        _id: @_items[n], \
        _display: n, \
        _tokens: n} \
        for n of @_items]
      _template: (p) -> "
        <p style='float:right;font-style:italic;margin-left:1em'>
          #{p._code}</p>
        <p style='font-size:14px;text-align:justify'>#{p._name}</p>")
      ..on-closed @changeValue
      ..render!

    _button = App.dom._new \button
      .._class = "#{gz.Css \btn} #{gz.Css \btn-default}"
      ..html = "&nbsp;<i class='#{gz.Css \glyphicon}
                              \ #{gz.Css \glyphicon-search}'></i>&nbsp;"
      ..on-click @_search-dto

    _span = App.dom._new \span
        .._class = gz.Css \input-group-btn
        .._append _button

    @el._append _span
    super!

  /** @private */ _field   : null
  /** @private */ _name    : null
  /** @private */ _callback : null
  /** @private */ _input   : null
  /** @private */ _value  : null


# vim: ts=2:sw=2:sts=2:et
