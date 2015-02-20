/** @module modules */

PanelGroup = require '../../../app/widgets/panelgroup'

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
class Declarant extends App.View

  /** @override*/
  _tagName: \form

  /** @override */
  _className: gz.Css \col-md-12

  /*
   *
   * TODO
   * @private
   */
  overload-for-title: ->
    _name = @el.query '[name=name]'
    _father_name = @el.query '[name=father_name]'
    _mother_name = @el.query '[name=mother_name]'

    _set-title = ~>
      @_content-title.html = _name._value + ' ' \
                             + _father_name._value + ' ' \
                             + _mother_name._value

    _name.on-key-up _set-title
    _father_name.on-key-up _set-title
    _mother_name.on-key-up _set-title

  /** @override */
  initialize: ({@_content-title}) -> super!

  /** @override */
  render: ->
    App.builder.Form._new @el, _FIELD_DECLARANT
      ..render!
      .._free!
    @overload-for-title!
    super!

  /** @private */ _content-title:null

  /** FIELDS */
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
class Declarants extends App.View

  /** @override */
  _tagName: \div

  /*
   *
   * TODO
   * @private
   */
  add-declarant: ~>
    @panel-group.close-all!
    @panel-group.new-panel 'Declarante'

      dcl = Declarant._new _content-title: .._header._first._first
      .._body._append dcl.render!.el

      .._toggle!
    @el._first._append @panel-group.render!.el

  /** @override */
  initialize:->
    @panel-group = new PanelGroup

  /** @override */
  render: ->
    @el.html = "<div class='#{gz.Css \col-md-12}'></div>
                <button type='button'
                        class= '#{gz.Css \btn}
                              \ #{gz.Css \btn-default}'>
                Agregar
                </button>"
    @el._last.on-click @add-declarant

    super!

  /** @private */ panel-group :null


/** @export */
module.exports = Declarants


# vim: ts=2:sw=2:sts=2:et
