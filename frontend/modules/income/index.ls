/** @modules.income */


panelgroup = App.widget.panelgroup
table = App.widget.table
  Table = ..Table

modal = App.widget.message-box
MessageBox = modal.MessageBox
declaration = require './declaration'
declarationv2 = require './declarationv2'
DeclarantBody = require './declarant'
dispatch = require './dispatch'
StakeholderBody = require './stakeholder'

Module = require '../../workspace-new/module'


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

      if _query._length > 11
        @_desktop.notifier.notify do
          _message: 'No debe superar la cantidad de digitos'
          _type: @_desktop.notifier.kWarning
        @_desktop._search.clean-input!
        @_desktop._search._focus 'DNI o número de orden'
        return

      App.ajax._get '/api/customer', true, ('document_number': _query), do
        _success: ([_customer-dto]) ~>  # income with registered customer
          if _customer-dto?
            _dispatch_dto =
              'declaration':
                'customer': _customer-dto
          else
            _dispatch_dto =
              'declaration':
                'customer': 'document_number': _query
            # TODO: Esto corrige un error al crear un nuevo despacho.
            #       Al parecer el código que crea el formulario de cliente
            #       (Customer) para persona jurídica (Business) exige que
            #       la lista de acciones exista.
            #       Se debe validar porque es posible que sea `null`.
            if _query._length is 11  # is Business
              _dispatch_dto.'declaration'.'customer'.'shareholders' = new Array
          @render-panels _dispatch_dto

    # Find by order number (dispatch)
    else if _filter is @@_SEARCHENUM.kByOrder
      # TODO: valid order number.
      App.ajax._get '/api/dispatch', true, ('order': _query), do
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
    @_desktop._spinner-start!

    @model._save @panels2dispatchDTO!, do
      _success: ~>
        @model._set @panels2dispatchDTO!
        App.model.Dispatches.add-new @model
        @_desktop.notifier.notify do
          _message: 'Guardado'
          _type: @_desktop.notifier.kSuccess
        @_panels
          .._declaration._header.\
          _get declaration.ControlPDF ._show @model.'id'
          .._declarationv2._header.\
          _get declarationv2.ControlPDF ._show @model.'id'
        App.GLOBALS.update_autocompleter!
        @_panels._stakeholders._body._update-autocompleter App.GLOBALS._stakeholders
        @_panels._declarants._body._update-autocompleter App.GLOBALS._declarants
        @_desktop._spinner-stop!
        @_panel-group.close-all!

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
    _declaration = if @is-new-version then \
                   @_panels._declarationv2._body._json \
                   else @_panels._declaration._body._json
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
    @_desktop._show-save!
    @clean!

    @model = new App.model.Dispatch _dispatch-dto  # Model for storing data

    @_panel-group = new panelgroup.PanelGroup

    @_panels =  # To build dispatch DTO.
      _dispatch:  @_panel-group.new-panel do
                    _panel-heading: dispatch.DispatchHeading
                    _panel-body: dispatch.DispatchBody
      _stakeholders: @_panel-group.new-panel do
                      _panel-heading: panelgroup.PanelHeading
                      _panel-body: StakeholderBody
      _declaration: @_panel-group.new-panel do
                      _panel-heading: declaration.Heading
                      _panel-body: declaration.Body
      _declarationv2: @_panel-group.new-panel do
                      _panel-heading: declarationv2.Heading
                      _panel-body: declarationv2.Body
      _declarants: @_panel-group.new-panel do
                     _panel-heading: panelgroup.PanelHeading
                     _panel-body: DeclarantBody

    c-title = panelgroup.ControlTitle
    @_panels
      .._dispatch._header._get c-title ._text = 'N&ordm; Orden despacho'
      .._declaration._header._get c-title ._text = 'Anexo 5 - Declaración
                                            \ Jurada de Conocimiento del
                                            \ Cliente'
      .._declarationv2._header._get c-title ._text = 'Anexo 5 - Declaración
                                            \ Jurada de Conocimiento del
                                            \ Cliente v.2'
      .._declarants._header._get c-title ._text = 'Declarantes'
      .._stakeholders._header._get c-title ._text = 'Vinculado o involucrado
                                                  \ en la operación.'

    @_panels
      .._dispatch._body._json = _dispatch-dto
      # Stakeholder changes on type
      .._stakeholders._body.set-type .._dispatch._body._get-type!
      .._dispatch._body.on (gz.Css \code-regime), ~>
        .._stakeholders._body.set-type it

    @_panels
      .._declaration._body._json = _dispatch-dto.'declaration'
      .._declarationv2._body._json = _dispatch-dto.'declaration'

      # Declaration(-stakeholder) changes on type
      .._declaration._body.set-type .._dispatch._body._get-type!
      .._declarationv2._body.set-type .._dispatch._body._get-type!
      .._dispatch._body.on (gz.Css \code-regime), ~>
        .._declaration._body.set-type it

      .._declarants._body._json = _dispatch-dto.'declaration'.'customer'.'declarants'
      .._stakeholders._body._json = _dispatch-dto.'stakeholders'

    if _dispatch-dto.'id'?  # Añadiendo botón PDF(en modo edición).
      @_panels
        .._declaration._header.\
        _get declaration.ControlPDF ._show _dispatch-dto.'id'
        .._declarationv2._header.\
        _get declarationv2.ControlPDF ._show _dispatch-dto.'id'

    # HARDCODE
    _dispatch-ref-el = @_panels._dispatch._body.el.query '[name=reference]'
    @_panels._declaration._body.el
      _declaration-ref-el = ..query '[name=reference]'
      _declaration-address-el = ..query '[name=address]'

    _dispatch-ref-el.on-key-up ->
      _declaration-ref-el._value = _dispatch-ref-el._value

    _declaration-ref-el.on-key-up ->
      _dispatch-ref-el._value = _declaration-ref-el._value

    _declaration-address-el.on-blur ~>
      @_panels._declarants._body._dcl-address-el _declaration-address-el._value


    @_panel-group.open-all!

    # CHANGE VERSION
    @_panels._declarationv2._hide!
    @is-new-version = off

    __change-version = ~>
      if it._target._value is \v1
        @is-new-version = off
        @_panels._declaration._show!
        @_panels._declarationv2._hide!
      else
        @is-new-version = on
        @_panels._declaration._hide!
        @_panels._declarationv2._show!

    label-v1 = App.dom._new \label
      .._class = gz.Css \radio-inline
    App.dom._new \input
      .._type = 'radio'
      .._name = 'version'
      .._value = 'v1'
      .._checked = on
      ..on-change __change-version
      label-v1._append ..
    $ label-v1 ._append 'Versión 1'

    label-v2 = App.dom._new \label
      .._class = gz.Css \radio-inline
    App.dom._new \input
      .._type = 'radio'
      .._name = 'version'
      .._value = 'v2'
      ..on-change __change-version
      label-v2._append ..
    $ label-v2 ._append 'Versión 2'

    App.dom._new \div
      ..css = 'margin: 0 0 15 10'
      ..html = '<label style="margin-right: 15px">
                  Cambiar versión
                </label>'
      .._append label-v1
      .._append label-v2
      @el._append ..

    @el._append @_panel-group.render!.el

  on-dummy: (_value, _dto, _attr, _tr) ->
    if not _dto.'operation'
      _span = App.dom._new \span
        .._class = "#{gz.Css \glyphicon}
                  \ #{gz.Css \glyphicon-remove}"
        ..css = 'cursor:pointer;font-size:18px'
        ..on-click ~>
          see-button = (_value) ->
            if _value
              App.ajax._delete "/api/dispatch/#{_dto.'id'}", do
                _success: ->
                  App.model.Dispatches._remove _tr._model
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
    @_desktop._lock!
    @_desktop._spinner-start!

    _labels =
      'Aduana'
      'N&ordm; Orden'
      'Rég.'
      'Razón social / Nombre'
      'Fecha'
      'RUC/DNI'
      ''

    _attributes =
      'jurisdiction.code'
      'order'
      'regime.code'
      'declaration.customer'
      'income_date'
      'declaration.customer.document_number'
      'dummy'

    _templates =
      'declaration.customer': ->
        "#{if it.'document_type' is \ruc then it.'name'
            else it.'name'+' '+it.'father_name'+' '+ it.'mother_name'}"
      'dummy': @on-dummy

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
      'declaration.customer': 'text-overflow:ellipsis;
                               white-space:nowrap;
                               overflow:hidden;
                               max-width:27ch;
                               text-align:left'

    App.model.Dispatches._all (dispatches) ~>
    # '/api/dispatch/list'
      _pending = dispatches
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
      @_desktop._unlock!
      @_desktop._spinner-stop!

    @_desktop._search._focus 'DNI o número de orden'
    super!

  ## Attributes
  /**
   * @type Boolean
   * @private
   */
  is-new-version: null

  /**
   * To generate the JSON dispatch from views.
   * @see render-panels, on-save
   * @type {Object}
   * @private
   */
  _panels: null

  /** @private */ _panel-group: null

  /** Search options */
  @@_SEARCHENUM =
    kByDocumentNumber: 0
    kByOrder: 1

  /** @protected*/ @@_mod-caption = 'INGRESO DE OPERACIONES'
  /** @protected*/ @@_mod-icon    = gz.Css \cloud
  /** @protected*/ @@_mod-hash   = 'auth-hash-income'
  /** @protected*/
  @@_mod-search-menu =
    * _caption: 'C'
      _label: 'DNI/RUC'
      _value: @@_SEARCHENUM.kByDocumentNumber

    * _caption: 'O'
      _label: 'Número de Orden'
      _value: @@_SEARCHENUM.kByOrder


/** @export */
module.exports = Income


# vim: ts=2:sw=2:sts=2:et
