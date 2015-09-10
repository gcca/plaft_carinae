/**
 * @author Javier Huaman
 */

modal = App.widget.message-box

/**
 * ModalAlert
 * --------
 *
 * @Class ModalAlert
 * @extends Modal
 */
class ModalAlert extends modal.Modal

  alerts_user: ->
    sections = []
    sections_user = App.permissions.sections
    alert-section-one = window.plaft.'lists'.'alert_s1'
    alert-section-three = window.plaft.'lists'.'alert_s3'

    for section in sections_user
      if section is 'I'
        sections = sections ++ alert-section-one
      else if section is 'III'
        _ALERT = if @_model._attributes.'is_out' then _ALERT-OUT else _ALERT-IN
        alerts = [a for a in alert-section-three when a[1] in _ALERT]
        sections = sections ++ alerts
    sections

  _is-alert-user: (code) ->
    alerts = App.permissions.alerts
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
                  <th>Sec</th>
                  <th>Cod</th>
                  <th>Descripción</th>
                  <th>Criterio de ayuda</th>
                  <th>Aplica</th>
                </tr>'
      _table._append ..

    _tbody = App.dom._new \tbody

    for alert in @alerts_user!
      _tr = App.dom._new \tr
      # SECTION
      App.dom._new \td
        ..html = alert[0]
        _tr._append ..
      # CODE
      App.dom._new \td
        ..html = alert[1]
        _tr._append ..
      # DESCRIPTION
      App.dom._new \td
        ..html = alert[2]
        _tr._append ..
      #HELP
      App.dom._new \td
        ..html = alert[3]
        _tr._append ..
      #CHECKBOX
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

  _hide: ->
    _id-user = window.'plaft'.'user'.'id'
    _dto =
      'user-visited': _id-user
    App.ajax._post "/api/dispatch/#{@_model._id}/alerts_visited", _dto, do
      _success: ~>
        @_module._parent._unusual-alerts._reload-module!
    super!

  get-data: ~>
    _tbody = (@el.query 'table').query 'tbody'
    for tr in _tbody.rows
      _checkbox = tr.cells[4]._first
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
                @_module, \
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

  _ALERT-OUT = ['1', '3', '4', '5', '6', '9', '10', '11',
                '12', '15', '19', '22', '23', '24', '25',
                '26', '27', '28', '30', '31', '32']

  _ALERT-IN = ['1', '2', '5', '6', '7', '8', '9', '10',
               '11', '12', '13', '14', '15', '16', '17',
               '18', '19', '20', '21', '22', '27', '28',
               '29', '30', '31', '32', '33']


  /** @private */ _alerts: null
  /** @private */ _callback: null
  /** @private */ _model: null
  /** @private */ _module: null

/** @export */
module.exports = ModalAlert


/* vim: ts=2 sw=2 sts=2 et: */
