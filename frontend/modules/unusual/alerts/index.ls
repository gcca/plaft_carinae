/**
 * @module modules
 * @author gcca@gcca.tk (cristHian Gz. <gcca>)
 */

Module = require '../../../workspace/module'
Utils = require '../table'
ModalAlert = require './modal'

FieldType = App.builtins.Types.Field
DOCUMENT_TYPE_PAIR = App.lists.document-type._pair


/**
* @class Dispatch
* @extends Model
*/
class Dispatch extends App.Model
  urlRoot: 'dispatch'


/**
* @Class Dispatches
* @extends Collection
*/
class Dispatches extends App.Collection
  urlRoot: 'customs_agency/pending'
#  urlRoot: 'dispatch'
  model: Dispatch


class CustomerAlert extends App.View

  /** @override */
  _tagName: \form

  render-customer: (_FIELD) ->
    App.builder.Form._new @el, _FIELD
      ..render!
      .._free!

  /**
   * Form to JSON.
   * @return {Object}
   * @override
   */
  _toJSON: ->
    _dto = @el._toJSON!
    delete! _dto.'customer_type'
    _dto

  /** @override */
  initialize: (@_customer) -> super!

  /** @override */
  render: ->
    if @_customer.'document_type' is \ruc
      _FIELD = _FIELD_BUSINESS
      _title = "<div class='#{gz.Css \col-md-12}'>
                  <h4>Datos de identificación Persona Jurídica</h4>
                </div>"
      @_customer.'customer_type' = 'Persona Jurídica'
    else
      _title = "<div class='#{gz.Css \col-md-12}'>
                  <h4>Datos de identificación Persona Natural</h4>
                </div>"
      _FIELD = _FIELD_PERSON
      @_customer.'customer_type' = 'Persona Natural'

    App.builder.Form._new @el, _FIELD_HEAD
      ..render!
      .._free!

    @$el._append _title
    @render-customer _FIELD
    @$el._append "<div class='#{gz.Css \col-md-12}'><hr></div>"

    @el._fromJSON @_customer
    super!

  _FIELD_ATTR = App.builder.Form._FIELD_ATTR
  _GRID = App.builder.Form._GRID

  _FIELD_HEAD =
    * _name: 'link_type'
      _label: '6. La persona en cuyo nombre se realiza'

    * _name: 'customer_type'
      _label: '7. Tipo de persona'

  _FIELD_PERSON =
    * _name: 'document_type'
      _label: '8. Tipo documento identidad'
      _type: FieldType.kComboBox
      _options: DOCUMENT_TYPE_PAIR

    * _name: 'document_number'
      _label: '9. No documento de identidad'

    * _name: 'condition'
      _label: '10. Condicion de residencia'

    * _name: 'issuance_country'
      _label: '11. Pais de emision del documento'

    * _name: 'is_pep'
      _label: '12. Person es PEP: (1) SI  o  (2) NO'
      _type: FieldType.kYesNo

    * _name: 'employment'
      _label: '13. Si es PEP indicar el cargo publico '

    * _name: 'father_name'
      _label: '14. Apellido paterno'

    * _name: 'mother_name'
      _label: '15. Apellido materno'

    * _name: 'name'
      _label: '16. Nombres'

    * _name: 'nationality'
      _label: '17. Nacionalidad'

    * _name: 'birthday'
      _label: '18.  Fecha nacimiento (dd/mm/aaaa)'

    * _name: 'activity'
      _label: '19. Ocupacion, oficio o profesion.'

    * _name: 'employer'
      _label: '21. Empleador (en dependiente)'

    * _name: 'average_income'
      _label: '22. Ingresos promedios mensuales'

    * _name: 'address'
      _label: '25. Nombre y numero de la via de la direccion'

    * _name: 'phone'
      _label: '26. Telefono de la persona en cuyo'

    * _name: 'condition_intervene'
      _label: '27. Condicion en la que interviene'
      _type: FieldType.kComboBox
      _options:
        'Involucrado'
        'Vinculado'

    * _name: ''
      _label: '28. Describir la condición en la que interviene en
             \ la operación inusual'
      _grid: _GRID._full
      _type: FieldType.kTextEdit

  _FIELD_BUSINESS =
    * _name: 'name'
      _label: '14. Razon social (persona juridica)'

    * _name: 'social_object'
      _label: '23. Objeto social de la persona juridica'

    * _name: 'activity'
      _label: '24. Cargo (si aplica) datos de la tabla 3'

    * _name: 'address'
      _label: '25. Nombre y numero de la via de la direccion'

    * _name: 'phone'
      _label: '26. Telefono de la persona en cuyo'

    * _name: 'condition_intervene'
      _label: '27. Condicion en la que interviene'
      _type: FieldType.kComboBox
      _options:
        'Involucrado'
        'Vinculado'

    * _name: ''
      _label: '28. Describir la condición en la que interviene en
             \ la operación inusual'
      _grid: _GRID._full
      _type: FieldType.kTextEdit


class StakeholderAlert extends App.View

  _tagName: \div

  _toJSON: -> [.._toJSON! for @_stakeholders]

  initialize: (@_collection-stakeholder) ->
    @_stakeholders = new Array
    super!

  render: ->
    for stk in @_collection-stakeholder
      CustomerAlert._new stk
        @_stakeholders._push ..
        @el._append ..render!.el
    super!

  /** @private */ _stakeholders: null
  /** @private */ _collection-stakeholder: null

/**
* @Class OperationEdit
* @extends Module
*/
class Alerts extends Module

  /** @override */
  on-save: ->
    _dto =
      'stakeholders': @_stakeholders._toJSON!
      'alerts': @transform-to-dto!
      'has_alerts': on
      'declaration':
        'customer': @_income._toJSON!

    App.ajax._post "/api/dispatch/#{@model._id}/alerts", _dto, do
      _success: ~>
        @model._set _dto  # update data for change on (event)
        @_desktop.notifier.notify do
          _message : 'Se actualizó correctamente los datos'
          _type    : @_desktop.notifier.kSuccess
      _bad-request: ~>
        alert 'ERROR: e746ae94-5a3a-11e4-9a1d-88252caeb7e8'

  _is-alert-user: (code) ->
    alerts = window.plaft.'user'.'permissions'.'alerts'
    code in ["#{a.'section'+a.'code'}" for a in alerts]

  transform-to-dto: ->
    _dto-alert = []
    _keys = Object.keys @_alerts

    for k in _keys
      al = @_alerts[k]
      _dto-alert._push do
        'info':
          'code': al.'code'
          'section': al.'section'
          'description': al.'description'
        'comment': al.'comment'
    _dto-alert

  transform-to-alerts: (_dto-alerts) ->
    @_alerts = {}
    for alert in _dto-alerts
      _code = alert.'info'.'code'
      _section = alert.'info'.'section'
      _description = alert.'info'.'description'
      _comment = alert.'comment'
      _name = "#{_section+_code}"
      if @_is-alert-user _name
        @_alerts[_name] =
          'code': _code
          'section': _section
          'description': _description
          'comment': _comment

  load-table: (alerts) ~>
    @_div-table
      $ .._parent ._hide!
      ..html = ''

    _keys = Object.keys alerts

    # Mensajes:
    # - si ha sido visitado,
    # - si NO contiene señales de alerta, y
    # - si contiene señales de alerta.
    $ @_div-table._parent ._hide!
    $ @el._last ._hide!
    $ @_div-message ._show!  # TODO: Mostrar por defecto. (No ocultarlo.)

    if _keys._length  # ¿Tiene alertas?
      @_div-message.html = '<h4>Operación contiene señales de alerta</h4>'
    else
      if not @model._attributes.'alerts_visited'  # ¿No fue visitado?
        @_div-message.html = '<h4>Ingrese al proceso de identificación
                              \ Operaciones Inusuales</h4>'
      else  # No tiene alertas
        @_div-message.html = '<h4>Operación NO contiene
                              \ señales de alerta</h4>'

      return  # Si no contiene, no continuar (para imprimir alertas).

    ## $ @_div-message ._hide!
    # Si hay alertas:
    $ @_div-table._parent ._show!
    $ @el._last ._show!
    _table = App.dom._new \table
      .._class = "#{gz.Css \table}
                \ #{gz.Css \table-bordered}"

    App.dom._new \thead
      ..html = '<tr>
                  <th>Sección</th>
                  <th>Código</th>
                  <th>Descripción</th>
                </tr>'
      _table._append ..

    _tbody = App.dom._new \tbody

    for k in _keys
      al = alerts[k]
      _tr = App.dom._new \tr
        ..attr '_key', k

      App.dom._new \td
        ..html = al.'section'
        _tr._append ..

      App.dom._new \td
        ..html = al.'code'
        _tr._append ..

      App.dom._new \td
        ..html = al.'description'
        _tr._append ..

      _tbody._append _tr

      _tr.on-click (evt) ~>
        @_current-tr._class._remove gz.Css \active
        @_current-tr = evt._target
        @_current-tr._class._add gz.Css \active
        _key = @_current-tr.attr '_key'
        @_current-alert = @_alerts[_key]

        if @_current-alert.'comment'?
          @_txt-area._value = @_current-alert.'comment'
        else
          @_txt-area._value = ''
        $ @_txt-area._parent ._show!

    _table._append _tbody
    @_div-table._append _table

  /** @override */
  render: ->
    _dispatch = @model._attributes
    _table-content = App.utils.uid 'd'
    _area-id = App.utils.uid 'a'
    @el.html = "<h4>Identicación de Operaciones Inusuales</h4>
                <div class='#{gz.Css \form-group}
                          \ #{gz.Css \col-md-3}'
                     style='padding:0px'>
                  <label class='#{gz.Css \col-md-5}'
                         style='text-align:center'>
                    Aduana
                  </label>
                  <label class='#{gz.Css \col-md-2}'
                         style='text-align:center;
                                padding:0px;
                                border-style:solid'>
                    #{_dispatch.'jurisdiction'.'code'}
                  </label>
                  <label class='#{gz.Css \col-md-12}'></label>
                  <label class='#{gz.Css \col-md-5}'
                         style='text-align:center'>
                    Régimen
                  </label>
                  <label class='#{gz.Css \col-md-2}'
                         style='text-align:center;
                                padding:0px;
                                border-style:solid'>
                    #{_dispatch.'regime'.'code'}
                  </label>
                </div>
                <div class='#{gz.Css \form-group}
                          \ #{gz.Css \col-md-8}'>
                  <label class='#{gz.Css \col-md-4}'>
                    No Orden de Despacho
                  </label>
                  <label class='#{gz.Css \col-md-3}'
                         style='text-align:center;
                                border-style:solid'>
                    #{_dispatch.'order'}
                  </label>
                  <label class='#{gz.Css \col-md-12}'></label>
                  <label class='#{gz.Css \col-md-4}'>
                    Razón Social/Nombre
                  </label>
                  <label class='#{gz.Css \col-md-8}'
                         style='text-align:center;
                                border-style:solid'>
                    #{_dispatch.'declaration'.'customer'.'name'}
                  </label>
                </div>
                <div class='#{gz.Css \col-md-12}'>
                  <div class='#{gz.Css \col-md-2}'>
                    <button class='#{gz.Css \btn}
                                 \ #{gz.Css \btn-default}'
                            type='button'
                            style='margin-bottom: 15px'>
                      Señales de Alerta
                    </button>
                  </div>
                  <div class='#{gz.Css \col-md-10}
                            \ #{gz.Css \div-message}'
                       style='display:none;'>
                  </div>
                  <div style='display:none' class='#{gz.Css \col-md-12}'>
                    <div class='#{gz.Css \col-md-6}
                              \ #{gz.Css \form-group}'>
                      <label>Fecha Numeración</label>
                      <input type='text'
                             class='#{gz.Css \form-control}'
                             value='#{_dispatch.'numeration_date'}' disabled/>
                    </div>
                    <div class='#{gz.Css \col-md-6}
                              \ #{gz.Css \form-group}'>
                      <label>Ultimo dia de ROS</label>
                      <input type='text'
                             class='#{gz.Css \form-control}'
                             value='#{_dispatch.'last_date_ros'}' disabled/>
                    </div>
                    <div class='#{gz.Css \col-md-12}'
                         id='#{_table-content}'></div>
                  </div>
                  <div class='#{gz.Css \form-group}
                            \ #{gz.Css \col-md-12}'
                       style='display:none'>
                    <label>Describir la condición en la que interviene en
                         \ la operación inusual</label>
                    <textarea class='#{gz.Css \form-control}'
                              id='#{_area-id}'
                              style='width:70%'></textarea>
                  </div>
                </div>
                <div class='#{gz.Css \col-md-12}' style='display:none;'></div>"

    @transform-to-alerts @model._attributes.'alerts'

    @_div-table = @el.query "##{_table-content}"

    @el.query ".#{gz.Css \btn-default}"
      ..on-click ~>
        modal-test = ModalAlert._new do
            _title: 'SEÑALES DE ALERTA - ' + window.'plaft'.'user'.'role'
            _alerts: @_alerts
            _model: @model
            _callback: @load-table
        modal-test._show ModalAlert.CLASS.large

    @_txt-area = @el.query "##{_area-id}"
    @_txt-area.on-blur ~>
        @_current-tr._class._remove gz.Css \active
        @_current-alert.'comment' = @_txt-area._value
        $ @_txt-area._parent ._hide!

    _customer-dto = _dispatch.'declaration'.'customer'
      ..'link_type' = if _dispatch.'is_out' then 'Exportador' else 'Importador'

    @_income = CustomerAlert._new _customer-dto
      @el._last._append ..render!.el

    @_stakeholders = StakeholderAlert._new _dispatch.'stakeholders'
      @el._last._append ..render!.el

    @_div-message = @el.query ".#{gz.Css \div-message}"

    @load-table @_alerts

    super!

  /** @private */ _alerts: null
  /** @private */ _current-alert: null
  /** @private */ _div-table: null
  /** @private */ _txt-area: null
  /** @private */ _income: null
  /** @private */ _stakeholders: null
  /** @private */ _div-message: null
  /** @private */
  _current-tr:
    _class:
      _remove: ->


/**
* @Class ModuleTest
* @extends Module
*/
class ListAlerts extends Module

  /** @override */
  render: ->
    (new Utils do
      _desktop: @_desktop
      _parent: @
      _child: Alerts)._load-module!

    super!


  /** @protected */ @@_caption = 'IDENTIFICACIÓN DE OI'
  /** @protected */ @@_icon    = gz.Css \envelope
  /** @protected */ @@_hash  = 'auth-hash-alerts'


/** @export */
module.exports = ListAlerts


/* vim: ts=2 sw=2 sts=2 et: */
