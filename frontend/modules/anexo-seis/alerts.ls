/** @module modules */


panelgroup = App.widget.panelgroup
FieldType = App.builtins.Types.Field
DOCUMENT_TYPE_PAIR = App.lists.document-type._pair

/**
 * SignalAlert
 * --------
 *
 * @example
 * @class SignalAlert
 * @extends View
 */

class HeadAlert extends panelgroup.PanelHeading

  _controls: [panelgroup.ControlTitle, panelgroup.ControlClose]

class PanelAlert extends panelgroup.FormBody

  render: ->
    _r = super!
    App.builder.Form._new @el, _FIELD_SIGNAL
      ..render!
      .._free!
    _r

  _GRID = App.builder.Form._GRID

  /** _FIELDS */
  _FIELD_SIGNAL =
    * _name: 'comment'
      _label: 'Comentario'
      _tip: 'Ingrese el comentario.'
      _grid: _GRID._full
      _type: FieldType.kTextEdit

    * _name: 'source'
      _label: 'Fuenta de la señal de la alerta'
      _type: FieldType.kComboBox
      _options:
        'Sistema de Monitoreo'
        'Área Comercial'
        'Análisis del SO'
        'Medio Periodistico'
        'Otras Fuentes'

    * _name: 'description_source'
      _label: 'Descripción de otros.'


class CurrentAlerts extends panelgroup.PanelGroup

  /** @override */
  _tagName: \div

  new-panel: ->
    super do
      _panel-heading: HeadAlert
      _panel-body: PanelAlert

  _fromJSON: (_alerts) ->
    for alert in _alerts
      @new-panel!
        .._header._get panelgroup.ControlTitle ._text = alert


/** @export */
module.exports = CurrentAlerts


# vim: ts=2:sw=2:sts=2:et
