/** @module modules */

panelgroup = App.widget.panelgroup

FieldType = App.builtins.Types.Field

modal = App.widget.message-box
MessageBox = modal.MessageBox

class Officer extends App.Model

  urlRoot: \officer

class OfficerItem extends panelgroup.FormBody

  on-save: ->
    if not @model?
      @model = new Officer
    _dto = @_json

    if (not _dto.'password') or (_dto.'password' is '')
      delete _dto.'password'

    @model._save _dto, do
      _success: ->
        @_desktop.notifier.notify do
          _message: 'Guardado'
          _type: @_desktop.notifier.kSuccess
        (@el.query 'button').html = 'Modificar'

  _json-setter: (_dto) ->
    @model = new Officer _dto
    (@el.query 'button').html = 'Modificar'
    super _dto
    @_panel._header._get panelgroup.ControlTitle ._text = _dto.'agency'

  /** @override */
  render: ->
    _r = super!
    App.builder.Form._new @el, _FIELD_USER
      ..render!
      .._free!
    @$el._append "<div class='#{gz.Css \form-group}
                          \ #{gz.Css \col-md-6}'>
                  <button type='button' class='#{gz.Css \btn}
                \ #{gz.Css \btn-default}'> Registrar</button>
                </div>"
    (@el.query 'button').on-click ~> @on-save!

    _control-close = @_panel._header._get panelgroup.ControlClose
    _control-close.el._first.on-click ~>
      see-button = (_value) ->
        if _value
          console.log 'Si'
          App.ajax._delete "/api/officer/#{@model.id}", do
            _success: ->
              console.log 'Eliminado'
          _control-close.on-close!

      message = MessageBox._new do
        _title: 'Eliminación de la Agencia de Aduana.'
        _body: '<h5>¿Desea eliminar la Agencia de Aduana?</h5>'
        _callback: see-button
      message._show MessageBox.CLASS.small


    _r

  /** @private */ model: null
  _FIELD_USER =
    * _name: 'agency'
      _label: 'Nombre de Agencia'
      _tip: 'Nombre de la agencia de aduana.'

    * _name: 'name'
      _label: 'Nombre de oficial'
      _tip: 'Nombre de oficial de cumplimiento'

    * _name: 'username'
      _label: 'Usuario de oficial'
      _tip: 'Correo de oficial de cumplimiento'

    * _name: 'password'
      _label: 'Contraseña'

class OfficerHeading extends panelgroup.PanelHeading

  _controls: [panelgroup.ControlTitle,
              panelgroup.ControlClose]

class OfficerList extends panelgroup.PanelGroup

  /** @override */
  _tagName: \div

  _toJSON: -> for @_panels then .._body._json

  _fromJSON: (_officers) ->
    for _officer in _officers
      @new-panel!
        .._body._json = _officer

  new-panel: ->
    _officer = super do
      _panel-heading: OfficerHeading
      _panel-body: OfficerItem
    _officer._header._get panelgroup.ControlTitle ._text = 'Oficial Cumplimiento'
    _officer

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

    super!

/** @export */
module.exports = OfficerList

# vim: ts=2:sw=2:sts=2:et