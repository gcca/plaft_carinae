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

    if not _dto.'permissions'
      _dto.'permissions' =
        'modules': []
        'alerts': []

    for m, i in _cmodules
      if _cmodules.options[i].value in _dto.'permissions'.'modules'
        _cmodules.options[i].selected = true

    for alert in _dto.'permissions'.'alerts'
      _name = "#{alert.'section'}-#{alert.'code'}"
      ($ @table-alert ).find "##_name"
        ..[0]._checked = on

  _json-getter: ->
    _dto = super!
    @el._elements.'permissions[modules]'
      _permission = $ .. .find 'option:selected'

    alerts = $ @table-alert .find 'input[type="checkbox"]:checked'

    _dto.'permissions' =
      'modules': [per.value for per in _permission]
      'alerts': [a._id for a in alerts]
    _dto

  on-save: ->
    if not @employee?
      @employee = new Employee
    _dto = @_json

    if (not _dto.'password') or (_dto.'password' is '')
      delete _dto.'password'

    _id = @employee._id

    # TODO: check on creation
    _dto.'permissions'.'id' = @employee._attributes.'permissions'.'id'

    App.ajax._put "/api/user/#{_id}", _dto, do
      _success:     ~>
        @_save.html = "Modificar"
        console.log 'Registrado correctamente.'
      _bad-request: ~>
        alert 'ERROR: e746ae94-5a3a-11e4-9a1d-88252caeb7e8'

  /** @override */
  render: ->
    ret = super!
    table-id = App.utils.uid 'l'
    roles = window.plaft.'lists'.'employees_roles'
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
                  <label>Rol:</label>
                  <select class='#{gz.Css \form-control}'
                          name='role'>
                    #{for r in roles then '<option>'+r+'</option>' }
                  </select>
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
                          \ #{gz.Css \col-md-12}' id='#{table-id}'>
                </div>
                <div class='#{gz.Css \form-group}
                          \ #{gz.Css \col-md-6}'>
                  <button type='button' class='#{gz.Css \btn}
                \ #{gz.Css \btn-default}'> Registrar</button>
                </div>"
    @_save = @el.query 'button'
    # TABLE
    @table-alert = App.dom._new \table
      .._class = gz.Css \table
    t-head = App.dom._new \thead
    t-body = App.dom._new \tbody

    tr-header = App.dom._new \tr
      .._append App.dom._new \th

    alert-one = App.lists.alerts-test._alert-one
    alert-three = App.lists.alerts-test._alert-three

    for i from 1 to alert-three._length
      App.dom._new \th
        ..html = i
        tr-header._append ..

    # ALERT SECTION I
    App.dom._new \tr
      ..html = "<td>I</td>"
      for one in alert-one
        _td = App.dom._new \td
        _input = App.dom._new \input
          .._id = "#{one[0]}-#{one[1]}"
          .._type = 'checkbox'
          ..title = one[2]
          $ .. ._tooltip do
            'template': "<div class='#{gz.Css \tooltip}' role='tooltip'
                              style='min-width:175px'>
                           <div class='#{gz.Css \tooltip-arrow}'></div>
                           <div class='#{gz.Css \tooltip-inner}'></div>
                         </div>"
        _td._append _input
        .._append _td
      t-body._append ..

    # ALERT SECTION III
    App.dom._new \tr
      ..html = "<td>III</td>"
      for three in alert-three
        _td = App.dom._new \td
        _input = App.dom._new \input
          .._id = "#{three[0]}-#{three[1]}"
          .._type = 'checkbox'
          ..title = three[2]
          $ .. ._tooltip do
            'template': "<div class='#{gz.Css \tooltip}' role='tooltip'
                              style='min-width:175px'>
                           <div class='#{gz.Css \tooltip-arrow}'></div>
                           <div class='#{gz.Css \tooltip-inner}'></div>
                         </div>"
        _td._append _input
        .._append _td
      t-body._append ..

    t-head._append tr-header
    @table-alert._append t-head
    @table-alert._append t-body

    _container-table = @el.query "##{table-id}"
      $ .. ._append '<label>Alertas :</label>'
      .._append @table-alert
    @_save.on-click ~> @on-save!
    ret

  /** @private */ employee: null
  /** @private */ _save: null
  /** @private */ table-alert: null

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
