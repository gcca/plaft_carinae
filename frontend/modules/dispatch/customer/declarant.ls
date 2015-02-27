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

  # /*
  #  *
  #  * TODO
  #  * @private
  #  */
  overload-for-title: ->
    _content-title = @_header._first._first
    _name = @el.query '[name=name]'
    _father_name = @el.query '[name=father_name]'
    _mother_name = @el.query '[name=mother_name]'

    _set-title = ~>
      _content-title.html = _name._value + ' ' \
                             + _father_name._value + ' ' \
                             + _mother_name._value

    _name.on-key-up _set-title
    _father_name.on-key-up _set-title
    _mother_name.on-key-up _set-title

  /**
   *
   * TODO CHANGE HOW TO INSERT FORM
   @override */
  eliminar: ~>  @_free!

  render: ->
    ret = super!
    # console.log ret
    # console.log _form
    # ret._body._append
    @_body.html = "<form></form>"

    App.builder.Form._new @_body._first, _FIELD_DECLARANT
      ..render!
      .._free!
    @_header._first._first.html= "Declarante"
    _span = App.dom._new \span
      .._class = "#{gz.Css \glyphicon}
                \ #{gz.Css \glyphicon-remove}
                \ #{gz.Css \pull-right}
                \ #{gz.Css \toggle}"
      ..css = ' cursor:pointer;
                font-size:18px'
      ..on-click @eliminar

    @_header._first._append _span

    @overload-for-title!
    @_toggle!
    ret

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

    * _name: 'type_document'
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
      _label: 'Descripcion (Otros)'

    * _name: 'ciiu'
      _label: 'Codigo CIIU de la ocupación'
      _type: FieldType.kComboBox
      _options: App.lists.ciiu._display

    * _name: 'position'
      _label : 'Cargo'
      _type: FieldType.kComboBox
      _options: App.lists.office._display

    * _name: 'address'
      _label: 'Nombre y N&ordm; de la via de la direccion'

    * _name: 'ubigeo'
      _label: 'Codigo Ubigeo'

    * _name: 'phone'
      _label: 'Telefono de la persona'

/**
 * Declarants
 * ----------
 * TODO
 *
 * @class Declarants
 * @extends View
 */
class Declarants extends PanelGroup

  /** @override */
  _tagName: \div

  /** @override */
  initialize: ->
    super ConcretPanel: Declarant

  /**
   *
   *
   * TODO: SEARCH FOR FUNCTION REMOVE ATTR
   * @override
   */
  render: ->
    @$el.removeAttr('class')
    @$el.removeAttr('id')

    @el.html = "<div></div>
                <button type='button'
                        class= '#{gz.Css \btn}
                              \ #{gz.Css \btn-default}'>
                  Agregar
                </button>"
    @root-el = @el._first
    @el._last.on-click @new-panel

    super!


/** @export */
module.exports = Declarants


# vim: ts=2:sw=2:sts=2:et
