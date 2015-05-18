/** @module modules */

widget = App.widget.codename
  InputName = ..InputName
  CodeNameField = ..CodeNameField

panelgroup = App.widget.panelgroup

FieldType = App.builtins.Types.Field
DOCUMENT_TYPE_PAIR = App.lists.document-type._pair


/**
 * Stakeholder
 * -----------
 * @class Stakeholder
 * @extends View
 */
class FormStakeholder extends panelgroup.FormBody

  _json-setter: (_dto) ->
    if _dto.'document_type'?
      if _dto.'document_type' isnt \ruc
        FIELD = @_FIELD_PERSON
        TYPE = @@Type.kPerson

      else
        FIELD = @_FIELD_BUSINESS
        TYPE = @@Type.kBusiness

      @render-skateholder FIELD, TYPE
    super _dto

  _json-getter: ->
    _dto = super!
    delete! _dto.'customer_type'
    _dto

  /**
   * @param {Array.<FieldOptions>} _fields
   * @param {Integer} _next-type
   * @private
   */
  render-skateholder: (_fields, _next-type) ->
    @el._last.html = ''
    App.builder.Form._new @el._last, _fields
      @_person-type-html = .._elements.'customer_type'._element
      ..render!
      .._free!
    @_person-type-html._selected-index = _next-type
    @_person-type-html.on-change ~>
      @_render-by-type!

  /** @see render-stakeholder */
  _render-by-type: ->
    _type = @_type!

    if _type is @@Type.kPerson
      @render-skateholder @_FIELD_PERSON, _type

    if _type is @@Type.kBusiness
      @render-skateholder @_FIELD_BUSINESS, _type

  /**
   * Obtiene el codigo de customer_type
   * @private
   */
  _type: ->
    @_person-type-html._selected-index

  /** @private */ _person-type-html: null

  /**
   * Opciones de Tipo de Persona
   */
  @@Type =
    kPerson: 0
    kBusiness: 1

  _FIELD_PERSON: null
  _FIELD_BUSINESS: null

/** @export */
module.exports = FormStakeholder


# vim: ts=2:sw=2:sts=2:et
