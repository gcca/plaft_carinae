/** @module modules */

/**
 * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 * Module Operation
 *
 *  - - - - - - - - - - - - - - - - -  <- PanelGroup
 * |     Dispatch [PanelHeading]    |
 * |_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ |
 * |                                |
 * |        [PanelBody]             |
 * |                                |
 * |_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ |
 * |   Customer [PanelHeadingPDF]   |
 * |_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ |
 * |                                |
 * |        [PanelBody]             |
 * |                                |
 * |_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ |
 * |    Stakeholder [PanelHeading]  |
 * |_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ |
 * |                                |
 * |        [PanelBody]             |
 * |                                |
 * |_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ |
 * |    Declarant [PanelHeading]    |
 * |_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ |
 * |                                |
 * |        [PanelBody]             |
 * |                                |
 * |_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ |
 *
 * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 */

Module = require '../../workspace/module'

panelgroup = require '../../app/widgets/panelgroup'
panel-heading = require './heading'

customer = require './customer'
  CustomerBody = ..Customer

DispatchBody = require './dispatch'
#Stakeholder = r equire './stakeholder'
#Declarant = r equire './declarant'


/**
 * CustomerModel
 * ----------
 *
 * @class CustomerModel
 * @extends Model
 */
class CustomerModel extends App.Model
  urlRoot: 'customer'

/**
 * IncomeModel
 * ----------
 *
 * @class IncomeModel
 * @extends Model
 */
class IncomeModel extends App.Model
  urlRoot: 'income/create'

  defaults:
    'declaration': []
    'stakeholders': []
    'declarants': []


/**
 * Operation
 * ----------
 *
 * @class Operation
 * @extends Module
 */
class Operation extends Module

  /**
   * On search event.
   * @param {string} query
   * @param {string} type
   * @override
   * @protected
   */
  on-search: (query, filter) ->
    if not query._length
      @_desktop.notifier.notify do
        _message: 'Te olvidaste de escribir algo.'
        _type: @_desktop.notifier.kDanger
      return
    if not filter?
      @_desktop.notifier.notify do
        _message: 'Debes seleccionar el tipo de
                   \ búqueda que quieres realizar.'
        _type: @_desktop.notifier.kDanger
      return
    # FIND BY ORDER
    if filter is @@_SEARCHENUM.kByOrder
      type-filter = \dispatch
      _dto = 'order' : query

      success = (dto) ~>
        @income-model = new IncomeModel dto.0

        @_customer-dto = @income-model._attributes.'declaration'

        customer-dto = @income-model._attributes.'customer'

        @customer-model = new CustomerModel customer-dto

        @render-operation!
#        if dto.0.\id
#          @customer-head._show do
#            _href: "/declaration/pdf/#{@income-model\id}"

      not-found = (e) ~>
        @_desktop.notifier.notify do
          _message: e.'responseJSON'.\e
          _type: @_desktop.notifier.kDanger

    # FIND BY CUSTOMER
    else if filter is @@_SEARCHENUM.kByCustomer
      type-filter = \customer
      _dto = 'document_number' : query

      success = (dto) ~>
        @customer-model = new CustomerModel dto.0
        @_customer-dto = @customer-model._attributes
        @income-model = new IncomeModel
        @render-operation!

      not-found = (e) ~>
        if /^\d+$/ is query
          @_desktop.notifier.notify do
            _message: 'No existe persona : ' + query
            _type: @_desktop.notifier.kDanger

          @load-operation query
        else
          @_desktop.notifier.notify do
            _message: e.'responseJSON'.\e
            _type: @_desktop.notifier.kDanger

    @render-ajax _dto, type-filter, success, not-found

  /**
   * @param {Object} _dto
   * @param {String} type-filter
   * @param {Function} success
   * @param {Function} not-found
   */
  render-ajax: (_dto, type-filter, success, not-found) ->
    App.ajax._get "/api/#{type-filter}", _dto, do
      _success: success
      _not-found: not-found

  /**
   * Carga el formulario segun el query.
   * @param {String} _query
   * @private
   */
  load-operation: (_query) ->
    dto =
      \document_number : _query
    @customer-model = new CustomerModel dto
    @income-model = new IncomeModel
    @_customer-dto = @customer-model._attributes
    @_third = null
    @render-operation!

  /**
   * On save event.
   * @override
   * @protected
   */
  on-save: ~>
    customer-dto = @customer._toJSON!

    stk = @stakeholder._toJSON!
    for s in stk
      delete s.'customer_type'


    dispatch-dto = @dispatch.el._toJSON!
      ..'customer' = @customer-model._id
      ..'declaration' =
        'third': @customer._third.el._toJSON!
        'customer': customer-dto
      ..'declarants' = @declarant._toJSON!
      ..'stakeholders' = stk

    # Save to IncomeModel.
    @income-model._save dispatch-dto, do
      _success: (dto) ~>
#        @customer-head._show do
#          _href:  "/declaration/pdf/#{@income-model\id}"

        @_desktop.notifier.notify do
          _message: 'Guardado'
          _type: @_desktop.notifier.kSuccess
      _error: ~>
        @_desktop.notifier.notify do
          _message: 'Error: 869171b8-3f8e-11e4-a98f-88252caeb7e8'
          _type: @_desktop.notifier.kDanger

  /**
   * Sync typeahead completion with panel overflow.
   * @private
   */
  trick-typeahead: ->
    @$ ".#{gz.Css \tt-input}"  # Hack to panel and typeahead
      ..on \focus (evt) ->
        $ evt._target .parents ".#{gz.Css \panel-default}"
          .css \overflow \visible
      ..on \blur (evt) ->
        $ evt._target .parents ".#{gz.Css \panel-default}"
          .css \overflow \hidden

  /** @private */
  render-operation: ->
    @clean!

#    @dispatch = Dispatch._new dispatch : @income-model._attributes
#    @customer = Customer._new do
#      customer-dto : @_customer
#      third-dto: @_third

#    @stakeholder = Stakeholder._new do
#      collection : @income-model._attributes\stakeholders

#    @declarant = Declarant._new do
#      collection : @income-model._attributes\declarants

#    pnl-group = new PanelGroup

    pnl-group = new panelgroup.PanelGroup

    @dispatch =  pnl-group.new-panel do
      _panel-heading: panelgroup.PanelHeading
      _panel-body: DispatchBody
    @dispatch._header._get panelgroup.ControlTitle ._text = 'Despacho-Operacion'
    @dispatch._body._json = @income-model._attributes

    @customer = pnl-group.new-panel do
      _panel-heading: panel-heading.HeadingPDF
      _panel-body: CustomerBody
    @customer._header._get panelgroup.ControlTitle ._text = 'Declaración Jurada'
    @customer._body._json = @_customer-dto


    @el._append pnl-group.render!.el

#    pnl-group.new-panel do
#      _title: 'Despacho - Operacion'
#      _element: (@dispatch).render!.el

##    @customer-head = new panel-heading.Pdf _title: 'Declaracion jurada'
##    pnl-group.new-panel do
##      _panel-heading: @customer-head
##      _element: (@customer).render!.el

#    pnl-group.new-panel do
#      _title: 'Declarante'
#      _element: (@declarant).render!.el

#    pnl-group.new-panel do
#      _title: 'Vinculado'
#      _element: (@stakeholder).render!.el

#    @dispatch.on (gz.Css \code-regime), ~>
#      @stakeholder.load-stakeholder it

#    pnl-group.open-all!
#    @el._append pnl-group.render!el
#    @trick-typeahead!

  /** @override */
  render: ->
    @el.html = "
      <span>
        <span style='vertical-align:super'>
          Ingrese el DNI o el Orden de Despacho.</span>
         \ &nbsp;&nbsp;&nbsp;&nbsp;
        <i class='#{gz.Css \glyphicon} #{gz.Css \glyphicon-hand-up}'
            style='font-size:20pt'></i>
      </span>"
    @_desktop._search._focus 'DNI o número de orden'
    super!

  /**
   * Search options
   */
  @@_SEARCHENUM =
    kByCustomer: 0
    kByOrder: 1

  /** @private */ customer-model: null
  /** @private */ income-model: null
  /** @private */ stakeholder: null
  /** @private */ customer: null
  /** @private */ dispatch: null
  /** @private */ declarant: null

  /** @protected*/ @@_caption = 'OPERACION'
  /** @protected*/ @@_icon    = gz.Css \cloud
  /** @protected*/
  @@_search-menu =
    * _caption: 'C'
      _label: 'DNI/RUC'
      _value: @@_SEARCHENUM.kByCustomer

    * _caption: 'O'
      _label: 'Número de Orden'
      _value: @@_SEARCHENUM.kByOrder


/** @export */
module.exports = Operation


# vim: ts=2:sw=2:sts=2:et
