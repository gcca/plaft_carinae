/** @module modules */

FieldType = App.builtins.Types.Field
DOCUMENT_TYPE_PAIR = App.lists.document-type._pair

/**
 * Person
 * ----------
 * TODO
 *
 * @class Person
 * @extends View
 */
class Person extends App.View

  /** @override */
  _tagName: \div

  clean-text-partner: ~>
    @el.query('[name=partner]')._disabled = on
    @el.query('[name=partner]').value = ""

  on-civil_state-change: ~>
    _civil_type = @el.query('[name=civil_state]').selectedIndex
    switch _civil_type
      | 1, 4 => @el.query('[name=partner]')._disabled = off
      | otherwise => @clean-text-partner!

  on-is_obligated-change: ~>
    @_form._elements'has_officer'._element
      _officer-yes = ..query '[value=Sí]'
      _officer-no = ..query '[value=No]'
    is_obligated = @el.query('[name=is_obligated]:checked').value
    if is_obligated === 'No'
      _officer-yes._disabled = on
      _officer-no._checked = on
    else
      _officer-yes._disabled = off

  /** @override */
  render: ~>

    @_form = App.builder.Form._new @el, _FIELD_PERSON
#      .._elements.'ubigeo'._field._class = "#{gz.Css \form-group} #{gz.Css \col-md-12}"
      ..render!
      .._free!

    @_form._elements'civil_state'._element
      ..on-change @on-civil_state-change

    @_form._elements.'is_obligated'._element
      ..on-change @on-is_obligated-change

    @_form._elements.'ruc'._element
      ..attr('maxlength',11)

    @_form._elements.'birthday'._element
      ..attr('maxlength',10)

    super!

  /** Local variable for settings. */
  _GRID = App.builder.Form._GRID
  _FIELD_ATTR = App.builder.Form._FIELD_ATTR

  /** FIELD */
  _FIELD_PERSON =

    * _name: 'name'
      _label: 'a) Nombres'

    * _name: 'father_name'
      _label: 'Apellido Paterno'

    * _name: 'mother_name'
      _label: 'Apellido Materno'

    * _name: 'document[type]'
      _label: 'b) Tipo documento'
      _type: FieldType.kComboBox
      _options: DOCUMENT_TYPE_PAIR

    * _name: 'document[number]'
      _label: 'Número documento identidad'

    * _name: 'ruc'
      _label: 'c) RUC, de ser el caso'

    * _name: 'birthplace'
      _label: 'd) Lugar de nacimiento'

    * _name: 'birthday'
      _label: 'Fecha de nacimiento'
      _placeholder: 'dd/mm/YYYY'

    * _name: 'nationality'
      _label: 'e) Nacionalidad'

    * _name: 'address'
      _label: 'f) Domicilio declarado (lugar de residencia)'

    * _name: 'ubigeo'
      _label: 'Código Ubigeo'
      _grid: _GRID._complete

    * _name: 'fiscal_address'
      _label: 'g) Domicilio fiscal, de ser el caso'

    * _name: 'phone'
      _label: 'h) Número telefono fijo'

    * _name: 'mobile'
      _label: 'Número de celular'

    * _name: 'email'
      _label: 'i) Correo electrónico'
      _placeholder: 'domain@domain.com'

    * _name: 'activity'
      _label: 'j) Profesión u ocupación'
      _type: FieldType.kComboBox
      _options: App.lists.activity._display

    * _name: 'civil_state'
      _label: 'k) Estado civil'
      _type: FieldType.kComboBox
      _options:
        'Soltero'
        'Casado'
        'Viudo'
        'Divorciado'
        'Conviviente'

    * _name: 'partner'
      _label: 'Nombre Conviviente o Conyuge'
      _field-attrs: _FIELD_ATTR._disabled

    * _name: 'employment'
      _label: 'l) Cargo o función pública'

    * _name: 'is_obligated'
      _label: 'n) Si es Sujeto obligado'
      _type: FieldType.kRadioGroup
      _options: <[Sí No]>

    * _name: 'has_officer'
      _label: 'Oficial cumplimiento'
      _type: FieldType.kRadioGroup
      _options: <[Sí No]>

    * _name: 'money_source'
      _label: 'm) El origen de los fondos'
      _type: FieldType.kComboBox
      _options: App.lists.money_source._display

    * _name: 'reference'
      _label: 'Ref. Cliente'

/** @private */ _form: null


/** @export */
module.exports = Person


# vim: ts=2:sw=2:sts=2:et
