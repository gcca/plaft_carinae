/** @module modules.income */

panelgroup = App.widget.panelgroup

Business = require './business'
Person = require './person'
Stakeholder = require './stakeholder'
Declarant = require './declarant'

# HEADING

class ControlPDF extends App.View

  @@__hash__ = 'pdf'

  _tagName: \span

  _className: gz.Css \pull-right

  _show: (_href) ->
    @_pdf.attr \href "declaration/pdfv2/#{_href}"
    @el.css.'display' = ''

  initialize: ({_heading}) ->
    @el.css = 'flex:1;margin-right:5px;display:none;'
    _icon = App.dom._new \i
      .._class = "#{gz.Css \glyphicon}
                  \ #{gz.Css \glyphicon-bookmark}"

    @_pdf = App.dom._new \a
      .._class = "#{gz.Css \btn}
                \ #{gz.Css \btn-info}
                \ #{gz.Css \btn-sm}
                \ #{gz.Css \pull-right}"
      ..target = '_blank'
      ..html = 'PDF '
      .._append _icon
    @el._append @_pdf

  _pdf: null


class DeclarationHeading extends panelgroup.PanelHeading

  _controls: [panelgroup.ControlTitle, panelgroup.ControlBar, ControlPDF]


# BODY

class DeclarationBody extends panelgroup.JSONBody

  /**
   * @override
   * @protected
   */
  _json-getter: ->
    declarant-dto =
      'proxy': @_declarant._json
    'customer': @_customer._json <<<< @_stakeholder._json <<<< declarant-dto


  /**
   * Toggle a field by operation type (in or out).
   * @see Stakeholder.display-legal
   */
  set-type: -> @_stakeholder.display-legal it

  /**
   * Get customer data and build the form by customer type Business
   * or Person.
   * @param {Object} _customer-dto JSON with customer data.
   * @override
   * @protected
   */
  _json-setter: (_declaration-dto) ->
    @el.html = null  # clean

    _customer-dto = _declaration-dto.'customer'

    try
      _customer-class = __class-by _customer-dto
    catch
      alert e.'message'
      return

    # adding customer
    @_customer = new _customer-class
    @_customer._panel = @_panel
    @_customer.on (gz.Css \change), @on-customer-type-change
    @el._append @_customer.render!.el
    @_customer._json = _customer-dto

    # adding declarant
    @_declarant = new Declarant
    @el._append @_declarant.render!.el
    @_declarant._json = _customer-dto.'proxy'

    # adding stakeholder data
    @_stakeholder = new Stakeholder
    App.dom._new \div
      .._class = gz.Css \col-md-12
      $ .. ._append '<h4>Datos identificación adicionales para el Anexo 2</h4>'
      .._append App.dom._new \hr
      @el._append ..
    @el._append @_stakeholder.render!.el
    @_stakeholder._json = _customer-dto

  on-customer-type-change: ~>
    _customer-class = if it is 'j' then Business else Person

    @_customer = new _customer-class
    @_customer.on (gz.Css \change), @on-customer-type-change
    @_customer.set-type it

    @el.html = null
    @el._append @_customer.render!.el

    # adding declarant
    @_declarant = new Declarant
    @el._append @_declarant.render!.el

    @_stakeholder = new Stakeholder
    App.dom._new \div
      .._class = gz.Css \col-md-12
      $ .. ._append '<h4>Datos identificación adicionales para el Anexo 2</h4>'
      .._append App.dom._new \hr
      @el._append ..
    @el._append @_stakeholder.render!.el

  /**
   * Get customer class ({@code Business} or {@code Person}) by customer dto.\
   * @param {Object} _customer-dto JSON with customer data.
   * @return Customer (Business|Person)
   * @private
   */
  __class-by = (_customer-dto) ->
    return Business if not _customer-dto?  # By default

    # (-o-) TODO: Add to model a method to evaluate customer type.
    doc-type = _customer-dto.'document_type'
    if doc-type is 'ruc'
      Business
    else if doc-type?  # not equal to 'ruc' but there is data.
      Person
    else  # check by number when type doesn't exists.
      doc-number = _customer-dto.'document_number'
      if doc-number? and doc-number._constructor is String
        if doc-number._length is 11  # is RUC
          Business
        else  # is DNI, PA, CE, etc.
          Person
      else  # programming error when it doesn't exist or it is not a string.
        throw 'ERROR: 047bc8c2-f997-11e4-a5be-001d7d7379f5'

  /**
   * Customer view.
   * @type App.View
   */
  _customer: null

  /**
   * Third view.
   * @type App.View
   */
  _declarant: null

  /**
   * Third view.
   * @type App.View
   */
  _stakeholder: null


/** @export */
exports <<<
  Body: DeclarationBody
  Heading: DeclarationHeading
  ControlPDF: ControlPDF

# vim: ts=2:sw=2:sts=2:et
