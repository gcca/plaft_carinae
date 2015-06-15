/**
 * @module settings
 * @author gcca@gcca.tk (cristHian Gz. <gcca>)
 */

panelgroup = App.widget.panelgroup

FieldType = App.builtins.Types.Field

class Employee extends App.Model

  urlRoot: \user

  /** @override */
#  urlRoot: "officer/#{window.'plaft'.'cu'.\id}/employee"

MODULES = App.MODULES

class EmployeeItem extends panelgroup.FormBody

  _json-setter: (_dto) ->
    super _dto
    @employee = new Employee _dto
    @_save.html = "Modificar"
    _cmodules = @el._elements.'permissions[modules]'
    _csignals = @el._elements.'permissions[signals]'

    for m, i in _cmodules
      if _cmodules.options[i].value in _dto.'permissions'.'modules'
        _cmodules.options[i].selected = true

    for m, i in _csignals
      if _csignals.options[i].value in _dto.'permissions'.'signals'
        _csignals.options[i].selected = true

  _json-getter: ->
    _dto = super!
    @el._elements.'permissions[modules]'
      _permission = $ .. .find 'option:selected'

    @el._elements.'permissions[signals]'
      _anexo = $ .. .find 'option:selected'

    _dto.'permissions' =
      'modules': [per.value for per in _permission]
      'signals': [ax.value for ax in _anexo]
    _dto

  on-save: ->
    if not @employee?
      @employee = new Employee
    @employee._save @_json, do
      _success:     ~>
        @_save.html = "Modificar"
        console.log 'Registrado correctamente.'
      _bad-request: ~>
        alert 'ERROR: e746ae94-5a3a-11e4-9a1d-88252caeb7e8'

  /** @override */
  render: ->
    ret = super!
    @el.html = "<div class='#{gz.Css \form-group}
                          \ #{gz.Css \col-md-4}'>
                  <label>Nombre de Empleado</label>
                  <input type='text'
                         name='name'
                         class='#{gz.Css \form-control}' />
                </div>
                <div class='#{gz.Css \form-group}
                          \ #{gz.Css \col-md-4}'>
                  <label>Username</label>
                  <input type='text'
                         name='username'
                         class='#{gz.Css \form-control}' />
                </div>
                <div class='#{gz.Css \form-group}
                          \ #{gz.Css \col-md-4}'>
                  <label>Password</label>
                  <input type='text'
                         name='password'
                         class='#{gz.Css \form-control}' />
                </div>
                <div class='#{gz.Css \form-group}
                          \ #{gz.Css \col-md-6}'>
                  <label>Permisos módulos:</label>
                  <select multiple class='#{gz.Css \form-control}'
                                   name='permissions[modules]'>
                    #{for m in MODULES then '<option value='+m._hash+'>'+
                            m._caption +
                            '</option>'}
                  </select>
                </div>
                <div class='#{gz.Css \form-group}
                          \ #{gz.Css \col-md-6}'>
                  <label>Permisos señales:</label>
                  <select multiple class='#{gz.Css \form-control}'
                                   name='permissions[signals]'>
                    #{for m in MODULES then '<option value='+m._hash+'>'+
                            m._caption +
                            '</option>'}
                  </select>
                </div>
                <div class='#{gz.Css \form-group}
                          \ #{gz.Css \col-md-6}'>
                  <button type='button' class='#{gz.Css \btn}
                \ #{gz.Css \btn-default}'> Registrar</button>
                </div>"
    @_save = @el.query 'button'
    @_save.on-click ~> @on-save!
    ret

  /** @private */ employee: null
  /** @private */ _save: null

class EmployeeHeading extends panelgroup.PanelHeading

  _controls: [panelgroup.ControlTitle,
              panelgroup.ControlClose]

class EmployeeList extends panelgroup.PanelGroup

  /** @override */
  _tagName: \div

  _toJSON: -> for @_panels then .._body._json


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

class Settings extends App.View

  /** @override */
  _tagName: \div

  on-save: ->
    App.ajax._post "/api/employee/register", @_employeeList._toJSON!, do
      _success:     ~>
        @_desktop.notifier.notify do
          _message : 'Se actualizó correctamente los datos'
          _type    : @_desktop.notifier.kSuccess
      _bad-request: ~>
        alert 'ERROR: b4f555cc-0bcd-11e5-810c-904ce5010430'


  /** @override */
  render: ->
    @el.html = ''
    @_employeeList = new EmployeeList
    @el._append (@_employeeList).render!.el
    super!

  _employeeList: null

/** @export */
module.exports = Settings


# vim: ts=2:sw=2:sts=2:et
