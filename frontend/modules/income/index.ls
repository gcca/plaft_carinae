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

#  is-business:~
#    -> @_attributes.'class_'[*-1] is 'Business'

#  is-person:~
#    -> @_attributes.'class_'[*-1] is 'Person'


#  if model.is-person
#    cargue la persona

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
        @dispatch-model = new DispatchModel dto.0
        @_customer = @dispatch-model._attributes.'declaration'.'customer'
        @_third = @dispatch-model._attributes.'declaration'.'third'
        customer-dto = @dispatch-model._attributes.'customer'
        @customer-model = new CustomerModel customer-dto

        @render-operation!
        if dto.0.\id
          @customer-head._change-type do
            _type: @customer-head.kPDF
            _href: @dispatch-model\id

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
        @_customer = @customer-model._attributes
        @dispatch-model = new DispatchModel
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
   * @param {} _dto
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
    @dispatch-model = new DispatchModel
    @_customer = @customer-model._attributes
    @render-operation!

  /**
   * On save event.
   * @override
   * @protected
   */
  on-save: ~>
    customer-dto = @customer._toJSON!
    # Save to CustomerModel.
    @customer-model._save customer-dto

    dispatch-dto = @dispatch.el._toJSON!
      ..'customer' = @customer-model._id
      ..'declaration' =
        'third': @customer._third.el._toJSON!
        'customer': customer-dto
      ..'declarant' = @declarant._toJSON!
      ..'linked' = @stakeholder._toJSON!

    # Save to DispatchModel.
    @dispatch-model._save dispatch-dto, do
      _success: (dto) ~>
        @customer-head._change-type do
          _type: @customer-head.kPDF
          _href: @dispatch-model\id
        @_desktop.notifier.notify 'Guardado' @_desktop.notifier.kSuccess
      _error: ~>
        @_desktop.notifier.notify(
          'Error: 869171b8-3f8e-11e4-a98f-88252caeb7e8',
          @_desktop.notifier.kDanger)

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
    @customer = Customer._new do
      customer-dto : @_customer
      third-dto: @_third

    @stakeholder = Stakeholder._new do
      collection : @dispatch-model._attributes\linked
    @declarant = Declarant._new do
      collection : @dispatch-model._attributes\declarant

    pnl-group = new PanelGroup

    pnl-group.new-panel do
      _title: 'Despacho - Operacion'
      _element: (@dispatch).render!.el

    @customer-head = new PanelHeading _title: 'Declaracion jurada'
    pnl-group.new-panel do
      _panel-heading: @customer-head
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
    @_desktop._search._focus 'DNI o número de orden'
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
  @@_search-menu =
    * _caption: 'C'
      _label: 'Customer'
      _value: @@_SEARCHENUM.kByCustomer

    * _caption: 'O'
      _label: 'Order'
      _value: @@_SEARCHENUM.kByOrder


/** @export */
module.exports = Operation


# vim: ts=2:sw=2:sts=2:et
