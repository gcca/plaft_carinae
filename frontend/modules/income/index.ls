/** @module modules */

Module = require '../../workspace/module'

panelgroup = require '../../app/widgets/panelgroup'
  PanelGroup = ..PanelGroup
  PanelHeading = ..PanelHeading
  PanelBody = ..PanelBody
customer = require './customer'
  Customer = ..Customer
Dispatch = require './dispatch'
Stakeholder = require './stakeholder'
Declarant = require './declarant'

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
 * DispatchModel
 * ----------
 *
 * @class DispatchModel
 * @extends Model
 */
class DispatchModel extends App.Model

  urlRoot: 'dispatch'

  defaults:
    'declaration': []
    'linked': []
    'declarant': []

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
  on-search: (query, filter) ~>
    if not query._length
      @notifier.notify @notifier.kDanger, 'Te olvidaste de escribir algo.'
      return
    if not filter?
      @notifier.notify @notifier.kDanger, 'Debes seleccionar el tipo de
                                         \ búqueda que quieres realizar.'
      return
    # FIND BY ORDER
    if filter is @@_SEARCHENUM.kByOrder
      type-filter = \dispatch
      _dto = 'order' : query

      success = (dto) ~>
        @dispatch-model = new DispatchModel dto.0
        console.log @dispatch-model
        @_customer = @dispatch-model._attributes.'declaration'.'customer'
#        @customer-model = new CustomerModel _ctsm
        console.log @_customer.'shareholders'
        console.log @customer-model
        @render-operation!
        if dto.0.\id
          @customer-heading._change-type \pdf, @dispatch-model\id

      not-found = (e) ~>
        @notifier.notify @notifier.kDanger, e.'responseJSON'.\e

    # FIND BY CUSTOMER
    else if filter is @@_SEARCHENUM.kByCustomer
      type-filter = \customer
      _dto = 'document_number' : query

      success = (dto) ~>
        @customer-model = new CustomerModel dto.0
        @_customer = @customer-model._attributes
        console.log @customer-model
        @dispatch-model = new DispatchModel
        @render-operation!

      not-found = (e) ~>
        if /^\d+$/ is query
          @notifier.notify @notifier.kDanger, 'No existe persona : ' + query
          @load-operation query
        else
         @notifier.notify @notifier.kDanger, e.'responseJSON'.\e

    @render-ajax _dto, type-filter, success, not-found

  /**
   * @param {} _dto
   * @param {String} type-filter
   * @param {Function} success
   * @param {Function} not-found
   */
  render-ajax: (_dto, type-filter, success, not-found) ->
    App.ajax._get "/api/#{type-filter}", _dto, do
      _success: success
      _not-found: not-found


  /** @private */
  load-operation: (_query) ->
    dto =
      \document_number : _query
    @customer-model = new CustomerModel dto
    @dispatch-model = new DispatchModel
    @_customer = @customer-model._attributes
    @render-operation!

  /**
   * On save event.
   * @override
   * @protected
   */
  on-save: ~>
    # JSON to CustomerModel
    form-cto = @customer.el._toJSON!
    if @customer._shareholder?
      _shareholders = @customer._shareholder._view._toJSON!
      console.log _shareholders
      form-cto.\shareholders = @customer._shareholder._view._toJSON!
      console.log form-cto.\shareholders
    console.log form-cto
    # Save to CustomerModel.
    if @customer-model?
      @customer-model._save form-cto
    # JSON to DispatchModel
    console.log form-cto
    form-dto = @dispatch.el._toJSON!
    form-dto.\declaration =
      'third': @customer._third.el._toJSON!
      'customer': form-cto
    form-dto.'declaration'.'customer'.'shareholders' = _shareholders
    form-dto.\declarant = @declarant._toJSON!
    form-dto.\linked = @stakeholder._toJSON!
    console.log form-dto
    # Save to DispatchModel.
    @dispatch-model._save form-dto, do
      _success: (dto) ~>
        console.log dto
        @customer-heading._change-type \pdf, dto.id
        @notifier.notify @notifier.kSuccess, 'Guardado'
      _error: ~>
        @notifier.notify @notifier.kDanger, \
                      'Error: 869171b8-3f8e-11e4-a98f-88252caeb7e8'

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

    @dispatch = Dispatch._new dispatch : @dispatch-model._attributes
    @customer = Customer._new customer : @_customer

    @stakeholder = Stakeholder._new do
      collection : @dispatch-model._attributes\linked
    @declarant = Declarant._new do
      collection : @dispatch-model._attributes\declarant


    pnl-group = new PanelGroup

    pnl-group.new-panel do
      _title: 'Despacho - Operacion'
      _element: (@dispatch).render!.el

    @customer-heading = new PanelHeading _title: 'Declaracion jurada'
    pnl-group.new-panel do
      _panel-heading: @customer-heading
      _element: (@customer).render!.el

    pnl-group.new-panel do
      _title: 'Declarante'
      _element: (@declarant).render!.el

    pnl-group.new-panel do
      _title: 'Vinculado'
      _element: (@stakeholder).render!.el

    pnl-group.open-all!
    @el._append pnl-group.render!el
    @trick-typeahead!

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
    super!

  /**
   * Search options
   */
  @@_SEARCHENUM =
    kByCustomer: 0
    kByOrder: 1

  /** @private */ customer-model: null
  /** @private */ dispatch-model: null
  /** @private */ stakeholder: null
  /** @private */ customer: null
  /** @private */ dispatch: null
  /** @private */ declarant: null

  /** @protected*/ @@_caption = 'OPERACION'
  /** @protected*/ @@_icon    = gz.Css \cloud
  /** @protected*/
  @@_list-filter =
    * _label: 'C'
      _value: @@_SEARCHENUM.kByCustomer
      _name: 'Customer'

    * _label: 'O'
      _value: @@_SEARCHENUM.kByOrder
      _name: 'Order'

/** @export */
module.exports = Operation


# vim: ts=2:sw=2:sts=2:et
