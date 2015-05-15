/** @modules.income */


panelgroup = App.widget.panelgroup

DeclarationBody = require './declaration'
DeclarantBody = require './declarant'
DispatchBody = require './dispatch'
StakeholderBody = require './stakeholder'

Module = require '../../workspace/module'


class Dispatch extends App.Model

  /** @oevrride */
  urlRoot: \income


class Income extends Module

  /**
   * Search by a number (order or document) and filtering
   * by type of that number: valid document number when filter is customer
   * and valid order number when filter is disptach.
   * @param {string} _query Document number.
   * @param {string} _filter Order or customer search enum.
   * @override
   * @protected
   */
  on-search: (_query, _filter) ->
    if _query is ''
      @_desktop.notifier.notify do
        _message: 'Olvidó de escribir el número de documento
                  \ o el número de orden.'
        _type: @_desktop.notifier.kWarning
      return

    # Find by customer document number
    if _filter is @@_SEARCHENUM.kByDocumentNumber
      if not __valid-document-number _query
        @_desktop.notifier.notify do
          _message: 'Número de documento inválido: ' + _query
          _type: @_desktop.notifier.kWarning
        return

      App.ajax._get '/api/customer', ('document_number': _query), do
        _success: ([_customer-dto]) ~>  # income with registered customer
          _dispatch_dto =
            'declaration':
              'customer': _customer-dto
          @render-panels _dispatch_dto
        _not-found: ~>  # income with new customer
          _dispatch_dto =
            'declaration':
              'customer': 'document_number': _query
          @render-panels _dispatch_dto

    # Find by order number (dispatch)
    else if _filter is @@_SEARCHENUM.kByOrder
      # TODO: valid order number.
      App.ajax._get '/api/dispatch', ('order': _query), do
        _success: ([_dispatch-dto]) ~>
          @render-panels _dispatch-dto
        _not-found: ~>
          @_desktop.notifier.notify do
            _message: 'Número de orden inválido: ' + _query
            _type: @_desktop.notifier.kWarning

    # Programming error: brutality
    else
      alert 'ERROR: 774165be-f989-11e4-a5be-001d7d7379f5'

  # Utils (@see on-search)
  __valid-document-number = (q) -> /\d+/ is q

  /**
   * Save income data to dispatch.
   * @override
   * @protected
   */
  on-save: ->
    @model._save @panels2dispatchDTO!, do
      _success: ~>
        @_desktop.notifier.notify do
          _message: 'Guardado'
          _type: @_desktop.notifier.kSuccess

      _error: ~>
        @_desktop.notifier.notify do
          _message: 'Error: 869171b8-3f8e-11e4-a98f-88252caeb7e8'
          _type: @_desktop.notifier.kDanger

  /**
   * Convert form-data from panels to JSON dispatch DTO.
   * @return Object
   * @private
   */
  panels2dispatchDTO: ->
    _dispatch-dto =
      declaration: @_panels._declaration._body._json
      declarants: @_panels._declarants._body._json
    _dispatch-dto <<<< @_panels._stakeholders._body._json
    _dispatch-dto <<<< @_panels._dispatch._body._json

  /**
   * Render dispatch, declaration, declarants and stakeholders panels.
   * The model is initialized here to it don't lose the 'id' attribute.
   * @param {Object} _dispatch-dto
   * @private
   */
  render-panels: (_dispatch-dto) ->
    @clean!

    @model = new Dispatch _dispatch-dto  # Model for storing data

    _panel-group = new panelgroup.PanelGroup


    @_panels =  # To build dispatch DTO.
      _dispatch:  _panel-group.new-panel do
                    _panel-heading: panelgroup.PanelHeading
                    _panel-body: DispatchBody
      _declaration: _panel-group.new-panel do
                      _panel-heading: panelgroup.PanelHeading
                      _panel-body: DeclarationBody
      _declarants: _panel-group.new-panel do
                     _panel-heading: panelgroup.PanelHeading
                     _panel-body: DeclarantBody
      _stakeholders:_panel-group.new-panel do
                      _panel-heading: panelgroup.PanelHeading
                      _panel-body: StakeholderBody

    c-title = panelgroup.ControlTitle
    @_panels
      .._dispatch._header._get c-title ._text = 'Despacho'
      .._declaration._header._get c-title ._text = 'Anexo 5'
      .._declarants._header._get c-title ._text = 'Declarantes'
      .._stakeholders._header._get c-title ._text = 'Vinculados'

    @_panels
      .._dispatch._body._json = _dispatch-dto
      .._stakeholders._body.set-type .._dispatch._body._get-type!
      .._dispatch._body.on (gz.Css \code-regime), ~>
        .._stakeholders._body.set-type it

    @_panels
      .._declaration._body._json = _dispatch-dto.'declaration'
      .._declarants._body._json = _dispatch-dto.'declarants'
      .._stakeholders._body._json =
        'sender_stakeholders': _dispatch-dto.'sender_stakeholders'
        'reciever_stakeholders': _dispatch-dto.'reciever_stakeholders'

    _panel-group.open-all!
    @el._append _panel-group.render!.el

  /** @override */
  render: ->
    @el.html = "
      <span>
        <span style='vertical-align:super'>
          Ingrese el DNI o el Orden de Despacho.
        </span>
        &nbsp;&nbsp;&nbsp;&nbsp;
        <i class='#{gz.Css \glyphicon}
                \ #{gz.Css \glyphicon-hand-up}'
           style='font-size:20pt'></i>
      </span>"
    @_desktop._search._focus 'DNI o número de orden'
    super!

  ## Attributes

  /**
   * To generate the JSON dispatch from views.
   * @see render-panels, on-save
   * @type {Object}
   * @private
   */
  _panels: null

  /** Search options */
  @@_SEARCHENUM =
    kByDocumentNumber: 0
    kByOrder: 1

  /** @protected*/ @@_caption = 'OPERACION'
  /** @protected*/ @@_icon    = gz.Css \cloud
  /** @protected*/
  @@_search-menu =
    * _caption: 'C'
      _label: 'DNI/RUC'
      _value: @@_SEARCHENUM.kByDocumentNumber

    * _caption: 'O'
      _label: 'Número de Orden'
      _value: @@_SEARCHENUM.kByOrder


/** @export */
module.exports = Income


# vim: ts=2:sw=2:sts=2:et
