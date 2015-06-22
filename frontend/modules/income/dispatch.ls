/** @module modules */

widget = App.widget.codename
  CodeNameField = ..CodeNameField

FormRatio = App.form-ratio

FieldType = App.builtins.Types.Field
DOCUMENT_TYPE_PAIR = App.lists.document-type._pair

panelgroup = App.widget.panelgroup



class DispatchHeading extends panelgroup.PanelHeading

  _controls: [panelgroup.ControlTitle, panelgroup.ControlBar]

/**
 * Dispatch
 * ----------
 *
 * @class Dispatch
 * @extends View
 */
class DispatchBody extends panelgroup.FormBody

  _json-getter: ->
    _r = super!
    if not @ratio?
      @ratio = new FormRatio do
        fields: _FIELD_DISPATCH
    _ratio =  @ratio._calculate _r
    if _ratio isnt 0
      @_panel._header._get panelgroup.ControlBar ._set-bar _ratio
    _r

  _json-setter: (_dto) ->
    if _dto.'regime'?
      @_display = _dto.'regime'.'name'
    super _dto
    if not @ratio?
      @ratio = new FormRatio do
        fields: _FIELD_DISPATCH
    _ratio =  @ratio._calculate _dto
    if _ratio isnt 0
      @_panel._header._get panelgroup.ControlBar ._set-bar _ratio

  _get-type: ->
    if @_display?
      _k = App.lists.regime._display._index @_display
      return App.lists.regime._sbs[_k]


  /** @override */
  render: ->
    App.builder.Form._new @el, _FIELD_DISPATCH
      ..render!
      @_typeahead = .._elements.'regime'._view._typeahead
      .._free!

    @_typeahead.on-selected (_, _obj) ~>
      _display = _obj.'_display'
      _k = App.lists.regime._display._index _display
      @trigger (gz.Css \code-regime), App.lists.regime._sbs[_k]

    super!

  _FIELD_DISPATCH=
      * _name: 'reference'
        _label: 'Ref. cliente'

      * _name: 'jurisdiction'
        _label: 'Aduana despacho/ Juridiccion'
        _tip: '([ctrl+M] para ver la tabla completa)'
        _type: FieldType.kView
        _options : new CodeNameField do
                     _code : App.lists.jurisdiction._code
                     _name : App.lists.jurisdiction._display
                     _field : 'jurisdiction'

      * _name: 'order'
        _label: 'N&ordm; Orden despacho'

      * _name: 'income_date'
        _label: 'Fecha ingreso orden de despacho'
        _placeholder: 'dd/mm/YYYY'

      * _name: 'regime'
        _label: 'Regimen Aduanero'
        _tip: '([ctrl+M] para ver la tabla completa)'
        _type: FieldType.kView
        _options : new CodeNameField do
                     _code : App.lists.regime._code
                     _name : App.lists.regime._display
                     _field : 'regime'

      * _name: 'description'
        _label: 'Descripcion mercancia'

  _display: null
  ratio: null

/** @export */
exports <<<
  DispatchBody: DispatchBody
  DispatchHeading: DispatchHeading


# vim: ts=2:sw=2:sts=2:et
