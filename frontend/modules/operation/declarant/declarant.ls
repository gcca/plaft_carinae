/** @module modules */

panelgroup = require '../../../app/widgets/panelgroup'
  Panel = ..Panel
  PanelGroup = ..PanelGroup

FieldType = App.builtins.Types.Field
DOCUMENT_TYPE_PAIR = App.lists.document-type._pair

/**
 * Declarant
 * ----------
 * TODO
 *
 * @class Declarant
 * @extends View
 */


class Declarant extends Panel

  render: ->
    ret = super!

    @_panel-body._get-el!.html = "<form></form>"

    App.builder.Form._new @_panel-body._get-form!, _FIELD_DECLARANT
        _nationality = .._elements'nationality'._element
        _description = .._elements'activity_description'._element
        _dposition = .._elements'description_position'._element
        _number = .._elements'number_document'._element

        .._elements.'document_type'._element.on-change (evt) ~>
            if evt._target._value is \005
              _number.attr('placeholder','Numero de DNI')
              _nationality._value='Peruana'
              _nationality._disabled = on
            else
              _nationality._value=''
              _nationality._disabled = off

        .._elements.'activity'._element .on-change (evt)~>
            if evt._target._value is \OTROS
              _description._parent.css= ""
            else
              _description._parent.css= "display:none"

        .._elements.'position'._element .on-change (evt)~>
            if evt._target._value is 'OTRO (señalar)'
              _dposition._parent.css= ""
            else
              _dposition._parent.css= "display:none"

        ..render!
        .._free!

    @_panel-heading.set-title-heading 'Declarante'

    @_panel-heading.overload-for-title!
    @_toggle!
    ret

  /** Local variable for settings. */
  _GRID = App.builder.Form._GRID
  _FIELD_ATTR = App.builder.Form._FIELD_ATTR

  # FIELDS
  _FIELD_DECLARANT =
    * _name: 'represent_PSOFRO'
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

    * _name: 'number_document'
      _label: 'Numero de Documento'

    * _name: 'country_document'
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
      _type: FieldType.kComboBox
      _options: App.lists.activity._display

    * _name: 'activity_description'
      _label: 'Descripcion (Otros) - Ocupación'
      _hide: on

    * _name: 'ciiu'
      _label: 'Codigo CIIU de la ocupación'
      _type: FieldType.kComboBox
      _options: App.lists.ciiu._display

    * _name: 'position'
      _label : 'Cargo'
      _type: FieldType.kComboBox
      _options: App.lists.office._display

    * _name: 'description_position'
      _label: 'Descripcion (Otros) - Cargo'
      _hide: on

    * _name: 'address'
      _label: 'Nombre y N&ordm; de la via de la direccion'

    * _name: 'ubigeo'
      _label: 'Codigo Ubigeo'
      _grid: _GRID._complete

    * _name: 'phone'
      _label: 'Telefono de la persona'

/** @export */
module.exports = Declarant


# vim: ts=2:sw=2:sts=2:et
