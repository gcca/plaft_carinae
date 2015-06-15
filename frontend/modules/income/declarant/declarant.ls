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
    _ratio =  @ratio._calculate _r
    @_panel._header._get panelgroup.ControlBar ._set-bar _ratio
    _r

  _json-setter: (_dto) ->
    super _dto
    # Progress Bar
    @ratio = new FormRatio do
      fields: _FIELD_DECLARANT
    _ratio =  @ratio._calculate _dto
    if _ratio isnt 0
      @_panel._header._get panelgroup.ControlBar ._set-bar _ratio

  read-dto: (dto) ->
    @_body._first._fromJSON @_options.dto

  /** @override */
  render: ->
    ret = super!
    App.builder.Form._new @el, _FIELD_DECLARANT
        .._elements.'document_type'._element._value = \dni
        ..render!
        .._free!

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
      _label: 'Actua en representacion'
      _type: FieldType.kComboBox
      _options:
        'Ordenante'
        'Beneficiario'

    * _name: 'residence_status'
      _label: 'Condición de residencia'
      _tip: 'Condición de residencia de la persona que solicita o físicamente
           \ realiza la operación.'
      _type: FieldType.kComboBox
      _options:
        'Residente'
        'No residente'

    * _name: 'document_type'
      _label: 'Tipo de Documento'
      _tip: 'Tipo de documento de la persona que solicita o físicamente realiza
           \ la operación.'
      _type: FieldType.kComboBox
      _options: DOCUMENT_TYPE_PAIR

    * _name: 'document_number'
      _label: 'Número de Documento'
      _tip: 'Número de documento de la persona que solicita o físicamente realiza
           \ la operación.'

    * _name: 'issuance_country'
      _label: 'País emisión del documento'
      _tip: 'País de emisión del documento de la persona que solicita o físicamente
           \ realiza la operación, en caso sea un documento emitido en el extranjero.'

    * _name: 'father_name'
      _label: 'Apellido Paterno'

    * _name: 'mother_name'
      _label: 'Apellido Materno'

    * _name: 'name'
      _label: 'Nombre'

    * _name: 'nationality'
      _label: 'Nacionalidad'
      _tip: 'Nacionalidad de la persona que solicita o físicamente realiza la operación.'

    * _name: 'activity'
      _label: 'Ocupación, profesión'
      _tip: 'Ocupación, oficio o profesión de la persona que solicita o físicamente
           \ realiza la operación.'
      _type: FieldType.kView
      _options : new InputName do
                   _name : App.lists.activity._display
                   _field : 'activity'

    * _name: 'ciiu'
      _label: 'Código CIIU de la ocupación'
      _tip: 'Código CIIU de la ocupación de la persona que solicita o físicamente
           \ realiza la operación.'
      _type: FieldType.kView
      _options : new CodeNameField do
                   _code : App.lists.ciiu._code
                   _name : App.lists.ciiu._display
                   _field : 'ciiu'

    * _name: 'position'
      _label : 'Cargo'
      _tip: 'Cargo de la persona que solicita de la persona que solicita o
           \ físicamente realiza la operación.'
      _type: FieldType.kView
      _options : new InputName do
                   _name : App.lists.office._display
                   _field : 'position'


    * _name: 'address'
      _label: 'Nombre y N&ordm; de la via de la direccion'
      _tip: 'Nombre y número de la vía de la dirección de la persona
           \ que solicita o físicamente realiza la operación.'

    * _name: 'ubigeo'
      _label: 'Código ubigeo'
      _grid: _GRID._full
      _tip: 'Código ubigoe del departamento, provincia y distrito de la dirección
           \ de la persona que solicita o físicamente realiza la operación: de
           \ acuerdo a la codificación vigente y publicada por el INEI.'
      _type: FieldType.kView
      _options : new CodeNameField do
                   _code: App.lists.ubigeo._pool._code
                   _name: App.lists.ubigeo._pool._display
                   _max-length: 15
                   _field: 'ubigeo'

    * _name: 'phone'
      _label: 'Teléfono de la persona'
      _tip: 'Teléfono de la persona que solicita o físicamente realiza la operación.'

/** @export */
module.exports = Declarant


# vim: ts=2:sw=2:sts=2:et
