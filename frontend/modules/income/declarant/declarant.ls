/** @module modules */

widget = App.widget.codename
  InputName = ..InputName
  CodeNameField = ..CodeNameField

panelgroup = App.widget.panelgroup

FieldType = App.builtins.Types.Field
DOCUMENT_TYPE_PAIR = App.lists.document-type._pair

FormRatio = App.form-ratio

/**
 * Declarant
 * ----------
 *
 * @class Declarant
 * @extends View
 */
class Declarant extends panelgroup.FormBody

  _json-getter: ->
    _r = super!
    if not @ratio?
      @ratio = new FormRatio do
        fields: _FIELD_DECLARANT
        el: @el
    _ratio =  @ratio._calculate _r
    @_panel._header._get panelgroup.ControlBar ._set-bar _ratio
    _r

  _json-setter: (_dto) ->
    super _dto
    # Progress Bar
    @ratio = new FormRatio do
      fields: _FIELD_DECLARANT
      el: @el
    _ratio =  @ratio._calculate _dto

    if _ratio isnt 0
      @_panel._header._get panelgroup.ControlBar ._set-bar _ratio

  change-document: ->
    _document-type = @el.query '[name=document_type]'
    switch _document-type._selected-index
        | 0 =>
          (@el.query '[name=issuance_country]')._value = 'Perú'
        | otherwise =>
          (@el.query '[name=issuance_country]')._value = ''

  /** @override */
  render: ->
    ret = super!
    App.builder.Form._new @el, _FIELD_DECLARANT
      .._elements.'document_type'._element._value = \dni
      ..render!
      .._free!
    _document-type = @el.query '[name=document_type]'
    @change-document!
    _document-type.on-change ~> @change-document!
    @_panel.on (gz.Css \load-body), (_dto) ~>
      @_json = _dto
    ret

  /** Local variable for settings. */
  _GRID = App.builder.Form._GRID
  _FIELD_ATTR = App.builder.Form._FIELD_ATTR

  ratio: null

  # FIELDS
  _FIELD_DECLARANT =
    * _name: 'represents_to'
      _label: '9. Actua en representacion'
      _type: FieldType.kComboBox
      _tip: 'La persona que solicita o fisicamente realiza la operación
           \ actúa en representación del: (1)Ordenante o (2)Beneficiario.'
      _options:
        'Ordenante'
        'Beneficiario'

    * _name: 'residence_status'
      _label: '10. Condición de residencia'
      _tip: 'Condición de residencia de la persona que solicita o físicamente
           \ realiza la operación: (1)Residente o (2)No residente.'
      _type: FieldType.kComboBox
      _options:
        'Residente'
        'No residente'

    * _name: 'document_type'
      _label: '11. Tipo de Documento'
      _tip: 'Tipo de documento de la persona que solicita o físicamente realiza
           \ la operación.'
      _type: FieldType.kComboBox
      _options: DOCUMENT_TYPE_PAIR

    * _name: 'document_number'
      _label: '12. Número de Documento'
      _tip: 'Número de documento de la persona que solicita o físicamente realiza
           \ la operación.'

    * _name: 'issuance_country'
      _label: '13. País emisión del documento'
      _tip: 'País de emisión del documento de la persona que solicita o físicamente
           \ realiza la operación, en caso sea un documento emitido en el extranjero.'

    * _name: 'father_name'
      _label: '14. Apellido Paterno'
      _tip: 'Apellido Paterno de la persona que solicita o fisicamente la operación.'

    * _name: 'mother_name'
      _label: '15. Apellido Materno'
      _tip: 'Apellido Materno de la persona que solicita o fisicamente la operación.'

    * _name: 'name'
      _label: '16. Nombre'
      _tip: 'Nombre de la persona que solicita o fisicamente la operación.'

    * _name: 'nationality'
      _label: '17. Nacionalidad'
      _tip: 'Nacionalidad de la persona que solicita o físicamente realiza la operación.'

    * _name: 'activity'
      _label: '18. Ocupación, profesión'
      _tip: 'Ocupación, oficio o profesión de la persona que solicita o físicamente
           \ realiza la operación.([ctrl+M] para ver la tabla completa)'
      _type: FieldType.kView
      _options : new InputName do
                   _name : App.lists.activity._display
                   _field : 'activity'

    * _name: 'ciiu'
      _label: '20. Código CIIU de la ocupación'
      _tip: 'Código CIIU de la ocupación de la persona que solicita o físicamente
           \ realiza la operación.([ctrl+M] para ver la tabla completa)'
      _type: FieldType.kView
      _options : new CodeNameField do
                   _code : App.lists.ciiu._code
                   _name : App.lists.ciiu._display
                   _field : 'ciiu'

    * _name: 'position'
      _label : '21. Cargo'
      _tip: 'Cargo de la persona que solicita de la persona que solicita o
           \ físicamente realiza la operación (si aplica).
           \ ([ctrl+M] para ver la tabla No 3 completa)'
      _type: FieldType.kView
      _options : new InputName do
                   _name : App.lists.office._display
                   _field : 'position'


    * _name: 'address'
      _label: '22. Nombre y N&ordm; de la via de la direccion'
      _tip: 'Nombre y número de la vía de la dirección de la persona
           \ que solicita o físicamente realiza la operación.'

    * _name: 'ubigeo'
      _label: '23. Código ubigeo'
      _grid: _GRID._full
      _tip: 'Código ubigoe del departamento, provincia y distrito de la dirección
           \ de la persona que solicita o físicamente realiza la operación: de
           \ acuerdo a la codificación vigente y publicada por el INEI.([ctrl+M]
           \ para ver la tabla completa)'
      _type: FieldType.kView
      _options : new CodeNameField do
                   _code: App.lists.ubigeo._pool._code
                   _name: App.lists.ubigeo._pool._display
                   _max-length: 15
                   _field: 'ubigeo'

    * _name: 'phone'
      _label: '24. Teléfono de la persona'
      _tip: 'Teléfono de la persona que solicita o físicamente realiza la operación.'

/** @export */
module.exports = Declarant


# vim: ts=2:sw=2:sts=2:et
