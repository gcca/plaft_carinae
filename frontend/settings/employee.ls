/**
 * @module settings
 * @author gcca@gcca.tk (cristHian Gz. <gcca>)
 */
Module = require '../workspace-new/module'
panelgroup = App.widget.panelgroup
modal = App.widget.message-box
widget = require './widget'

FieldType = App.builtins.Types.Field

MODULES = App.MODULES

/**
 * @Class Employee
 * @extends App.Model
 */
class Employee extends App.Model
  /** @override */
  urlRoot: \user

/**
 * EmployeeItem
 * ------------
 * @Class EmployeeItem
 * @extends FormBody
 */
class EmployeeItem extends panelgroup.FormBody

  /** @override */
  _json-setter: (_dto) ->
    super _dto
    @_panel._header._get panelgroup.ControlTitle ._text = "#{_dto.'name'} -
                                                         \ #{_dto.'role'}"
    @employee = new Employee _dto
    @_save.html = "Modificar"

    if not _dto.'permissions'
      _dto.'permissions' =
        'modules': []
        'alerts': []

    @table-module._fromJSON _dto.'permissions'.'modules'

    @table-alert._fromJSON  ["#{alert.'section'}-#{alert.'code'}" \
                            for alert in _dto.'permissions'.'alerts']

  /** @override */
  _json-getter: ->
    super!
      ..'permissions' =
        'modules': @table-module._toJSON!
        'alerts': @table-alert._toJSON!

  on-save: ->
    _dto = @_json
    if not @employee?
      @employee = new Employee
      _dto.'permissions'.'id' = null
      _method = App.ajax._post
      _url = '/api/user'
    else
      _dto.'permissions'.'id' = @employee._attributes.'permissions'.'id'
      _method = App.ajax._put
      _url = "/api/user/#{@employee._id}"

    if (not _dto.'password') or (_dto.'password' is '')
      delete _dto.'password'

    _method _url, _dto, do
      _success:     ~>
        @_save.html = "Modificar"
        @_panel._header._get panelgroup.ControlTitle ._text = "#{_dto.'name'} -
                                                             \ #{_dto.'role'}"
        App.GLOBALS.update_employees!
        console.log 'Registrado correctamente.'
      _bad-request: ~>
        alert 'ERROR: e746ae94-5a3a-11e4-9a1d-88252caeb7e8'

  /** @override */
  render: ->
    ret = super!

    App.builder.Form._new @el, _FIELD
      ..render!
      .._free!

    @$el._append "<div class='#{gz.Css \form-group}
                          \ #{gz.Css \col-md-6}'>
                    <label>Permisos módulos:</label>
                  </div>"

    # MODULES
    @table-module = new widget.ListGroup do
          _items-group: [{'value': m._mod-hash, 'name': m._mod-caption} \
                         for m in MODULES]

    @el._last._append @table-module.render!.el


    @$el._append "<div class='#{gz.Css \form-group}
                            \ #{gz.Css \col-md-12}'>
                    <label>Alertas :</label>
                  </div>"

    # ALERTS
    alert-one = window.plaft.'lists'.'alert_s1'
    alert-three = window.plaft.'lists'.'alert_s3'
    _columns =
      * 'first-column': 'I'
        'checks': [{'value':"#{a[0]}-#{a[1]}",'tip': a[2]} for a in alert-one]

      * 'first-column': 'II'
        'checks': [{'value':"#{a[0]}-#{a[1]}",'tip': a[2]} for a in alert-three]

    @table-alert = new widget.CheckBoxTable do
        _headers: [a[1] for a in alert-three]
        _columns: _columns

    @el._last._append @table-alert.render!.el

    @$el._append "<div class='#{gz.Css \form-group}
                            \ #{gz.Css \col-md-6}'>
                    <button type='button' class='#{gz.Css \btn}
                  \ #{gz.Css \btn-primary}'> Registrar</button>
                  </div>"

    @_save = @el.query 'button'

    @_save.on-click ~> @on-save!

    _control-close = @_panel._header._get panelgroup.ControlClose

    _control-close.el._first.on-click ~>
      see-button = (_value) ~>
        if _value
          App.ajax._delete "/api/user/#{@employee._id}", do
            _success: ->
              console.log 'Eliminado'
              App.GLOBALS.update_employees!
          _control-close.on-close!

      if not @employee?
          _control-close.on-close!
      else
        message = modal.MessageBox._new do
          _title: 'Eliminación del Empleado.'
          _body: '<h5>¿Desea eliminar al empleado?</h5>'
          _callback: see-button
        message._show modal.MessageBox.CLASS.small
    ret

  /** @private */ employee: null
  /** @private */ _save: null
  /** @private */ table-alert: null
  /** @private */ table-module: null

  /** Local variable for settings. */
  _GRID = App.builder.Form._GRID

  _FIELD =
    * _name: 'name'
      _label: 'Nombre de Empleado :'

    * _name: 'username'
      _label: 'Usuario :'

    * _name: 'password'
      _label: 'Password :'

    * _name: 'role'
      _label: 'Rol :'
      _type: FieldType.kComboBox
      _options: window.plaft.'lists'.'employees_roles'

/**
 * EmployeeHeading
 * ------------
 * @Class EmployeeHeading
 * @extends PanelHeading
 */
class EmployeeHeading extends panelgroup.PanelHeading

  _controls: [panelgroup.ControlTitle,
              panelgroup.ControlClose]

/**
 * EmployeeList
 * ------------
 * @Class EmployeeList
 * @extends PanelGroup
 */
class EmployeeList extends panelgroup.PanelGroup

  /** @override */
  _tagName: \div

  _toJSON: -> for @_panels then .._body._json

  /** @override */
  new-panel: ->
    _declarant = super do
      _panel-heading: EmployeeHeading
      _panel-body: EmployeeItem
    _declarant._header._get panelgroup.ControlTitle ._text = 'Empleado'
    _declarant

  /** @override */
  render: ->
    @el.html = "<div></div>
                <button type='button'
                        class= '#{gz.Css \btn}
                              \ #{gz.Css \btn-default}'>
                  Agregar </button>
                <div> <hr/> </div>"
    @_container = @el._first
    (@el.query 'button').on-click ~>
      @new-panel!

    for dto in window.'plaft'.\us
      @new-panel!
        .._body._json = dto

    super!

/**
 * Settings
 * ------------
 * @Class Settings
 * @extends View
 */
class EmployeeModule extends Module

  /** @override */
  _tagName: \div

  /** @override */
  render: ->
    @clean!
    @el._append (new EmployeeList).render!.el
    super!

  /** @protected */ @@_mod-caption     = 'EMPLEADOS'
  /** @protected */ @@_mod-icon        = gz.Css \user
  /** @protected */ @@_mod-hash        = 'auth-hash-employee'
/** @export */
module.exports = EmployeeModule


# vim: ts=2:sw=2:sts=2:et
