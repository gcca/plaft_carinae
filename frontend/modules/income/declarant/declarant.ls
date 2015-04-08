/** @module modules */

widget = App.widget.codename
  InputName = ..InputName
  CodeNameField = ..CodeNameField

panelgroup = require '../../../app/widgets/panelgroup'
  PanelBody = ..PanelBody

FieldType = App.builtins.Types.Field
DOCUMENT_TYPE_PAIR = App.lists.document-type._pair


/**
 * Declarant
 * ----------
 *
 * @class Declarant
 * @extends View
 */
class Declarant extends PanelBody

  /**
   * Carga el formulario segun el dto.
   */
  read-dto: (dto) ->
    @_body._first._fromJSON @_options.dto

  /** @override */
  render: ->
    ret = super!
    @_body = @el.query '.panel-body'
    $ @_body ._append "<form></form>"
    App.builder.Form._new @_body._first, _FIELD_DECLARANT
        ..render!
        .._free!
    @_body._first._fromJSON @_options.dto
    ret

  /** Local variable for settings. */
  _GRID = App.builder.Form._GRID
  _FIELD_ATTR = App.builder.Form._FIELD_ATTR

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
      _type: FieldType.kComboBox
      _options:
        'Residente'
        'No residente'

    * _name: 'document_type'
      _label: 'Tipo de Documento'
      _type: FieldType.kComboBox
      _options: DOCUMENT_TYPE_PAIR

    * _name: 'document_number'
      _label: 'Numero de Documento'

    * _name: 'issuance_country'
      _label: 'Pais emision del documento'

    * _name: 'father_name'
      _label: 'Apellido Paterno'

    * _name: 'mother_name'
      _label: 'Apellido Materno'

    * _name: 'name'
      _label: 'Nombre'

    * _name: 'nationality'
      _label: 'Nacionalidad'

    * _name: 'activity'
      _label: 'Ocupación, profesión'
      _type: FieldType.kView
      _options : new InputName do
                   _name : App.lists.activity._display
                   _field : 'activity'

    * _name: 'ciiu'
      _label: 'Codigo CIIU de la ocupación'
      _type: FieldType.kView
      _options : new CodeNameField do
                   _code : App.lists.ciiu._code
                   _name : App.lists.ciiu._display
                   _field : 'ciiu'

    * _name: 'position'
      _label : 'Cargo'
      _type: FieldType.kView
      _options : new InputName do
                   _name : App.lists.office._display
                   _field : 'position'


    * _name: 'address'
      _label: 'Nombre y N&ordm; de la via de la direccion'

    * _name: 'ubigeo'
      _label: 'Codigo Ubigeo'
      _grid: _GRID._full
      _type: FieldType.kView
      _options : new CodeNameField do
                   _code: App.lists.ubigeo._pool._code
                   _name: App.lists.ubigeo._pool._display
                   _max-length: 15
                   _field: 'ubigeo'

    * _name: 'phone'
      _label: 'Telefono de la persona'

/** @export */
module.exports = Declarant


# vim: ts=2:sw=2:sts=2:et
