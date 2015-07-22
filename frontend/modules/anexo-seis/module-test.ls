/**
 * @module modules
 * @author gcca@gcca.tk (cristHian Gz. <gcca>)
 */

Module = require '../../workspace/module'
SignalAlerts = require './alerts'
Utils = require './utils-anexo6'
ModalAlert = require './modal-alert'

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
class Test extends Module

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
        @_desktop.notifier.notify do
          _message : 'Se actualizó correctamente los datos'
          _type    : @_desktop.notifier.kSuccess
      _bad-request: ~>
        alert 'ERROR: e746ae94-5a3a-11e4-9a1d-88252caeb7e8'

  transform-to-dto: ->
    _dto-alert = []
    _keys = Object.keys @_alerts

    for k in _keys
      al = @_alerts[k]
      dct-alert =
        'code': al.'code'
        'section': al.'section'
        'description': al.'description'
        'comment': al.'comment'
      _dto-alert._push dct-alert
    _dto-alert

  transform-to-alerts: (_dto-alerts) ->
    @_alerts = {}
    for alert in _dto-alerts
      _code = alert.'code'
      _section = alert.'section'
      _description = alert.'description'
      _comment = alert.'comment'
      _name = "#{_section+_code}"
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

    if not _keys._length
      $ @_div-table._parent ._hide!
      $ @el._last ._hide!
      return

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
          @_txt-area.value = @_current-alert.'comment'
        else
          @_txt-area.value = ''
        $ @_txt-area._parent ._show!

    _table._append _tbody
    @_div-table._append _table

  /** @override */
  render: ->
    _dispatch = @model._attributes
    _table-content = App.utils.uid 'd'
    _area-id = App.utils.uid 'a'
    @el.html = "<div class='#{gz.Css \form-group}
                          \ #{gz.Css \col-md-5}'
                     style='padding:0px'>
                  <label class='#{gz.Css \col-md-4}'
                         style='text-align:center'>
                    Aduana
                  </label>
                  <label class='#{gz.Css \col-md-5}'
                         style='text-align:center;
                                padding:0px;
                                border-style:solid'>
                    #{_dispatch.'jurisdiction'.'code'}
                  </label>
                  <label class='#{gz.Css \col-md-4}'
                         style='text-align:center'>
                    Régimen
                  </label>
                  <label class='#{gz.Css \col-md-5}'
                         style='text-align:center;
                                padding:0px;
                                border-style:solid'>
                    #{_dispatch.'regime'.'code'}
                  </label>
                </div>
                <div class='#{gz.Css \form-group}
                          \ #{gz.Css \col-md-5}'>
                  <label class='#{gz.Css \col-md-6}'>
                    No Orden de Despacho
                  </label>
                  <label class='#{gz.Css \col-md-6}'
                         style='text-align:center;
                                border-style:solid'>
                    #{_dispatch.'order'}
                  </label>
                  <label class='#{gz.Css \col-md-6}'>
                    Razón Social/Nombre
                  </label>
                  <label class='#{gz.Css \col-md-6}'
                         style='text-align:center;
                                border-style:solid'>
                    #{_dispatch.'declaration'.'customer'.'name'}
                  </label>
                </div>
                <div class='#{gz.Css \col-md-12}'>
                  <button class='#{gz.Css \btn}
                               \ #{gz.Css \btn-default}'
                          type='button'
                          style='margin-bottom: 15px'>
                    Señales
                  </button>
                  <div style='display:none'>
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
                             value='#{_dispatch.'last_day_ros'}' disabled/>
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
            _title: 'SEÑALES DE ALERTA'
            _alerts: @_alerts
            _callback: @load-table
        modal-test._show ModalAlert.CLASS.large

    @_txt-area = @el.query "##{_area-id}"
    @_txt-area.on-blur ~>
        @_current-alert.'comment' = @_txt-area.value

    @load-table @_alerts

    @_income = CustomerAlert._new @model._attributes.'declaration'.'customer'
      @el._last._append ..render!.el

    @_stakeholders = StakeholderAlert._new @model._attributes.'stakeholders'
      @el._last._append ..render!.el

    super!

  /** @private */ _alerts: null
  /** @private */ _current-alert: null
  /** @private */ _div-table: null
  /** @private */ _txt-area: null
  /** @private */ _income: null
  /** @private */ _stakeholders: null
  /** @private */
  _current-tr:
    _class:
      _remove: ->


/**
* @Class ModuleTest
* @extends Module
*/
class ModuleTest extends Module

  /** @override */
  render: ->
    (new Utils do
      _desktop: @_desktop
      _parent: @
      _child: Test)._load-module!

    super!


  /** @protected */ @@_caption = 'MODULO DE ALERTAS'
  /** @protected */ @@_icon    = gz.Css \envelope
  /** @protected */ @@_hash    = 'ANX6-HASH'


/** @export */
module.exports = ModuleTest


/* vim: ts=2 sw=2 sts=2 et: */
