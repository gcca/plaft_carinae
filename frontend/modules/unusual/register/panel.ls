/** @module modules */


panelgroup = App.widget.panelgroup
FieldType = App.builtins.Types.Field
DOCUMENT_TYPE_PAIR = App.lists.document-type._pair

/**
 * PanelAlert
 * --------
 *
 * @class PanelAlert
 * @extends FormBody
 */
class PanelAlert extends panelgroup.FormBody

  /** @override */
  _json-getter: ->
    super!
      code-alert = ..'code_alert'
      ..'info'.'section' = code-alert._substring 0, code-alert._length-1
      ..'info'.'code' = code-alert.substr -1
      delete ..'code_alert'

  /** @override */
  _json-setter: (_dto) ->
    super _dto
    @on-change-source!

  on-change-source: ~>
    switch @_source._value
      | 'Otras Fuentes' =>
        @_other-source._disabled = off
      | otherwise =>
        @_other-source._disabled = on
        @_other-source._value = ''

  /** @override */
  render: ->
    _r = super!
    App.builder.Form._new @el, _FIELD_SIGNAL
      @_other-source = .._elements.'description_source'._element
      @_source = .._elements.'source'._element
        ..on-change @on-change-source
      ..render!
      .._free!
    _r

  _GRID = App.builder.Form._GRID

  /** _FIELDS */
  _FIELD_SIGNAL =
    * _name: 'code_alert'
      _label: '44. Codigo de las señal de alerta'

    * _name: 'info[description]'
      _label: '45. Descripción de la señal de alerta'

    * _name: 'comment'
      _label: 'Comentario'
      _type: FieldType.kHidden

    * _name: 'source'
      _label: '46. Fuenta de la señal de la alerta'
      _type: FieldType.kComboBox
      _options:
        'Sistema de Monitoreo'
        'Área Comercial'
        'Análisis del SO'
        'Medio Periodistico'
        'Otras Fuentes'

    * _name: 'description_source'
      _label: '47. Si se ha consignado la opcion (5) describir la fuente'

/**
 * CurrentAlerts
 * --------
 *
 * @class CurrentAlerts
 * @extends PanelGroup
 */
class CurrentAlerts extends panelgroup.PanelGroup

  /** @override */
  _tagName: \div

  _toJSON: -> for @_panels then .._body._json

  /** @override */
  new-panel: ->
    super do
      _panel-heading: panelgroup.PanelHeading
      _panel-body: PanelAlert

  _fromJSON: (_alerts) ->
    for alert in _alerts
      alert.'code_alert' = alert.'info'.'section' + alert.'info'.'code'
      @new-panel!
        .._body._json = alert
        .._header._get panelgroup.ControlTitle ._text = alert.'code_alert'


/** @export */
module.exports = CurrentAlerts


# vim: ts=2:sw=2:sts=2:et
