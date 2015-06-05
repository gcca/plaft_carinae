/** @modules.income */


panelgroup = App.widget.panelgroup
table = App.widget.table
  Table = ..Table

MessageBox = App.widget.message-box

declaration = require './declaration'
DeclarantBody = require './declarant'
DispatchBody = require './dispatch'
StakeholderBody = require './stakeholder'

Module = require '../../workspace/module'


class Dispatch extends App.Model
  /** @oevrride */
  urlRoot: \income


/**
* @Class Dispatches
* @extends Collection
*/
class Dispatches extends App.Collection
  model: Dispatch

/**
* @Class Income
* @extends Module
*/
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
        @_panels._declaration._header.\
          _get declaration.ControlPDF ._show @model.'id'

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
    _declaration = @_panels._declaration._body._json
    _declaration.'customer'.'declarants' = @_panels._declarants._body._json

    _dispatch-dto =
      declaration: _declaration
      stakeholders: @_panels._stakeholders._body._json
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
      _stakeholders: _panel-group.new-panel do
                      _panel-heading: panelgroup.PanelHeading
                      _panel-body: StakeholderBody
      _declaration: _panel-group.new-panel do
                      _panel-heading: declaration.Heading
                      _panel-body: declaration.Body
      _declarants: _panel-group.new-panel do
                     _panel-heading: panelgroup.PanelHeading
                     _panel-body: DeclarantBody

    c-title = panelgroup.ControlTitle
    @_panels
      .._dispatch._header._get c-title ._text = 'Despacho'
      .._declaration._header._get c-title ._text = 'Anexo 5'
      .._declarants._header._get c-title ._text = 'Declarantes'
      .._stakeholders._header._get c-title ._text = 'Vinculados'

    @_panels
      .._dispatch._body._json = _dispatch-dto
      # Stakeholder changes on type
      .._stakeholders._body.set-type .._dispatch._body._get-type!
      .._dispatch._body.on (gz.Css \code-regime), ~>
        .._stakeholders._body.set-type it

    @_panels
      .._declaration._body._json = _dispatch-dto.'declaration'

      # Declaration(-stakeholder) changes on type
      .._declaration._body.set-type .._dispatch._body._get-type!
      .._dispatch._body.on (gz.Css \code-regime), ~>
        .._declaration._body.set-type it

      .._declarants._body._json = _dispatch-dto.'declaration'.'customer'.'declarants'
      .._stakeholders._body._json = _dispatch-dto.'stakeholders'

    if _dispatch-dto.'id'?  # Añadiendo botón PDF(en modo edición).
      @_panels._declaration._header._get declaration.ControlPDF ._show _dispatch-dto.'id'

    # HARDCODE
    _dispatch-ref-el = @_panels._dispatch._body.el.query '[name=reference]'
    _declaration-ref-el = @_panels._declaration._body.el.query '[name=reference]'
    _dispatch-ref-el.on-key-up ->
      _declaration-ref-el._value = _dispatch-ref-el._value
    _declaration-ref-el.on-key-up ->
      _dispatch-ref-el._value = _declaration-ref-el._value



    _panel-group.open-all!
    @el._append _panel-group.render!.el

  _on-dumpy: (_tr) ->
    if _tr._model? and not _tr._model._attributes.'accepted'
      _span = App.dom._new \span
        .._class = "#{gz.Css \glyphicon}
                  \ #{gz.Css \glyphicon-remove}"
        ..css = 'cursor:pointer;font-size:18px'
        ..on-click ~>
          see-button = (_value) ->
            if _value
              _id = _tr._model._id
              App.ajax._delete "/api/dispatch/#{_id}/delete", do
                _success: ->
                  $ _tr ._remove!

          message = MessageBox._new do
            _title: 'Eliminación de despacho.'
            _body: '<h5>¿Desea eliminar el despacho?</h5>'
            _callback: see-button
          message._show!
    else
      App.dom._new \span

  /** @override */
  render: ->
    _labels =
      'Aduana'
      'Orden N&ordm;'
      'Fecha'
      'Régimen'
      'Razón social / Nombre'
      'RUC/DNI'
      ''

    _attributes =
      'jurisdiction.code'
      'order'
      'income_date'
      'regime.code'
      'declaration.customer'
      'declaration.customer.document_number'
      'dumpy'

    _templates =
      'declaration.customer': ->
        "#{if it.'document_type' is \ruc then it.'name'
            else it.'name'+' '+it.'father_name'+' '+ it.'mother_name'}"
      'dumpy': @_on-dumpy

    @el.html = "
      <div>
        <span style='vertical-align:super'>
          Si desea agregar una nueva operación, por favor
        \ ingrese el número de DNI/RUC.
        </span>
        &nbsp;&nbsp;&nbsp;&nbsp;
        <i class='#{gz.Css \glyphicon}
                \ #{gz.Css \glyphicon-hand-up}'
           style='font-size:20pt'></i>
      </div><br/>"

    _column-cell-style =
      'declaration.customer.name': 'text-overflow:ellipsis;
                                    white-space:nowrap;
                                    overflow:hidden;
                                    max-width:27ch'

    App.ajax._get '/api/dispatch/list', do
      _success: (dispatches) ~>
        _pending = new Dispatches dispatches
        _table = new Table  do
          _attributes: _attributes
          _labels: _labels
          _templates: _templates
          _column-cell-style: _column-cell-style
          on-dblclick-row: (evt) ~>
            _dispatch =  evt._target._model._attributes
            @on-search _dispatch.'order', @@_SEARCHENUM.kByOrder

        _table.set-rows _pending

        @el._append _table.render!.el

      _error: ->
        alert 'Error!!! Numeration list'
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
