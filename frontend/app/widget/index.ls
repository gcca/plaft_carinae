/** @module app */

modal = require './modal'

class exports.Typeahead extends App.View

  /**
   * DOM element.
   * @type {string}
   * @private
   */
  _tagName: \input

  /**
   * (Event) On cursor changed.
   * @param {Function} _callback
   */
  on-cursor-changed: (_callback)-> @$el.on 'typeahead:cursorchanged', _callback

  /**
   * (Event) On closed choices.
   * @param {Function} _callback
   */
  on-closed: (_callback)-> @$el.on 'typeahead:closed', _callback

  /**
   * (Event) On selected from dropdown.
   * @param {Function} _callback
   */
  on-selected: (_callback)-> @$el.on 'typeahead:selected', _callback

  Bh = Bloodhound

  /** @override */
  initialize: (@options) !->
    ## next = @$el.next!
    ## isNext = next.get 0
    ## next.remove! if isNext
    ##
    ## @$el.after next if isNext

  /**
   * Enable typeahead over {@code HTMLElement}.
   * @override
   */
  render: ->
    options = @options
    _.invert options._source
      _tokens  = ..[@@Source.kTokens]
      _display = ..[@@Source.kDisplay]

    bloodhound = new Bh do
      \datumTokenizer : Bh.'tokenizers'.'obj'.'whitespace' _tokens
      \queryTokenizer : Bh.'tokenizers'.'whitespace',
      \local : options._collection
    bloodhound.'initialize'!

    @$el.typeahead (
        \hint : true
        \highlight : true
        \minLength : 0), (
        \name       : 'c-gz'
        \displayKey : _display
        \source     : bloodhound.'ttAdapter'!
        \templates  :
          \empty      : "
            <div class='#{gz.Css \empty-message}'>
              &nbsp;&nbsp; No se encontraron coincidencias.
            </div>"
          \suggestion : options._template)

    @el.on-key-up (evt) ~>
      if evt.key-code is 77 and evt.ctrl-key   # [ctrl+M]
        mdl = modal.Modal._new do
            _title: 'Tabla completa'
            _body: @template-table @options.full-args
        mdl._show!

  template-table: ->
    if not @options.full-template?
      @options.full-template = -> ["<td>#{..}</td>" for &]._join ''
    t-body = App.dom._new \tbody
    for i from 0 to @options.full-args.0._length - 1
      args = [_list[i] for _list in @options.full-args]
      _tr = App.dom._new \tr
        ..html = @options.full-template.apply @, args
      t-body._append _tr
    tb = App.dom._new \table
    tb._class = "#{gz.Css \table}
               \ #{gz.Css \table-hover}"
    tb.html = "<thead>
                <tr>
                 #{["<th>#{..}</th>" for @options.full-headers]._join ''}
                </tr>
              </thead>"
    tb._append t-body
    tb

  /**
   * Flag to data source.
   */
  @@Source =
    kTokens  : 1
    kDisplay : 2

  /**
   * Bloodhound for source.
   */
  @@Bloudhound = Bloodhound


/** @export */
exports.panelgroup = require './panelgroup'
exports.codename = require './codename'
exports.table = require './table'
exports.message-box = modal
exports.newtable = require './newtable'

# vim: ts=2:sw=2:sts=2:et
