
modal = App.widget.message-box

class ModalAlert extends modal.Modal

  _is-alert-user: (code) ->
    alerts = window.plaft.'user'.'permissions'.'alerts'
    code in ["#{a.'section'+a.'code'}" for a in alerts]

  delete-alert: (_checkbox) ->
    if not _checkbox._checked
      _dto =
        'code_section': _checkbox._name
      App.ajax._post "/api/dispatch/#{@_model._id}/delete_alert", _dto, do
        _success: ~>
          console.log 'ELIMINADO'

  template-table: ->
    _table = App.dom._new \table
      .._class = "#{gz.Css \table}"
    App.dom._new \thead
      ..html = '<tr>
                  <th>Sección</th>
                  <th>Código</th>
                  <th>Descripción</th>
                  <th>Aplica</th>
                </tr>'
      _table._append ..
    alerts = App.lists.alerts_user!
    _tbody = App.dom._new \tbody

    for alert in alerts
      _tr = App.dom._new \tr
      App.dom._new \td
        ..html = alert[0]
        _tr._append ..
      App.dom._new \td
        ..html = alert[1]
        _tr._append ..
      App.dom._new \td
        ..html = alert[2]
        _tr._append ..
      App.dom._new \td
        _name = "#{alert[0]+alert[1]}"
        if @_is-alert-user _name
          _tr._class._add gz.Css \success
        _checkbox = App.dom._new \input
          .._type = 'checkbox'
          .._name = "#{alert[0]}|#{+alert[1]}"
          if @_alerts[_name]
            ..attr 'checked', on
          ..on-change (evt) ~> @delete-alert evt._target

        .._append _checkbox
        _tr._append ..
      _tbody._append _tr

    _table._append _tbody
    _table

  get-data: ~>
    _tbody = (@el.query 'table').query 'tbody'
    for tr in _tbody.rows
      _checkbox = tr.cells[3]._first
      _description = tr.cells[2].html
      _code = tr.cells[1].html
      _section = tr.cells[0].html
      _name = "#{_section+_code}"
      if _checkbox._checked
        if @_alerts[_name]?
          @_alerts[_name].'section' = _section
          @_alerts[_name].'code' = _code
          @_alerts[_name].'description' = _description
        else
          @_alerts[_name] =
            'section': _section
            'code': _code
            'description': _description
      else
        delete @_alerts[_name]
    @_callback @_alerts
    @_hide!


  /** @override */
  initialize: ({_title= '', \
                @_alerts={}, \
                @_model, \
                @_callback}) ->

    _r = super do
      _title: _title
      _body: @template-table!
    _accept = App.dom._new \button
      .._type = 'button'
      .._class = "#{gz.Css \btn}
                \ #{gz.Css \btn-primary}"
      ..on-click @get-data
      ..html = 'Aceptar'

    @_footer._append _accept

    _r

  /** @private */ _alerts: null
  /** @private */ _callback: null
  /** @private */ _model: null

/** @export */
module.exports = ModalAlert


/* vim: ts=2 sw=2 sts=2 et: */
