/** @module modules.income */


Customer = require './customer'

App.widget.codename
  InputName = ..InputName
  CodeNameField = ..CodeNameField

FieldType = App.builtins.Types.Field
DOCUMENT_TYPE_PAIR = App.lists.document-type._pair


class Person extends Customer

  clean-text-partner: ~>
    @el.query('[name=partner]')._disabled = on
    @el.query('[name=partner]').value = ""

  on-civil_state-change: ~>
    _civil_type = @el.query('[name=civil_state]').selectedIndex
    switch _civil_type
      | 1, 4 => @el.query('[name=partner]')._disabled = off
      | otherwise => @clean-text-partner!

  on-is_obligated-change: ~>
    @form-builder._elements'has_officer'._element
      _officer-yes = ..query '[value=Sí]'
      _officer-no = ..query '[value=No]'
    is_obligated = @el.query('[name=is_obligated]:checked').value
    if is_obligated === 'No'
      _officer-yes._disabled = on
      _officer-no._checked = on
    else
      _officer-yes._disabled = off

  /** @override */
  render: ->
    @form-builder = new App.builder.Form @el, _FIELD_PERSON

      .._elements'civil_state'._element
        ..on-change @on-civil_state-change

      .._elements.'is_obligated'._element
        ..on-change @on-is_obligated-change

      # Update issuance_country by document_type
      issuance-country-el = .._elements.'issuance_country'._element
        .._disabled = on

      .._elements.'document_type'._element.on-change (evt) ->
        doc-type-el = evt._target
        issuance-country-el._disabled = doc-type-el._value is 'dni'

      ..render!

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

    * _name: 'document_type'
      _label: 'b) Tipo documento'
      _tip: 'Tipo de documento de la persona en cuyon nombre se
           \ realiza la operación.'
      _type: FieldType.kComboBox
      _options: DOCUMENT_TYPE_PAIR

    * _name: 'document_number'
      _label: 'Número documento identidad'
      _tip: 'Número de documento de la persona en cuyo nombre se realiza
           \ la operación.'

    * _name: 'issuance_country'
      _label: 'País documento emitido extranjero'
      _tip: 'País de emisión del documento de la persona en cuyo nombre
           \ se realiza la operación.'

    * _name: 'ruc'
      _label: 'c) RUC, de ser el caso'
      _tip: 'Número de RUC de la persona en cuyo nombre se realiza la operación.'

    * _name: 'birthplace'
      _label: 'd) Lugar de nacimiento'

    * _name: 'birthday'
      _label: 'Fecha de nacimiento'

    * _name: 'nationality'
      _label: 'e) Nacionalidad'
      _tip: 'Nacionalidad de la persona en cuyo nombre se realiza
           \ la operación.'

    * _name: 'address'
      _label: 'f) Domicilio declarado (lugar de residencia)'

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
      _tip: 'Ocupación, oficio o profesión de la persona en cuyo nombre se
           \ realiza la operación.'
      _type: FieldType.kView
      _options : new InputName do
                   _name : App.lists.activity._display
                   _field : 'activity'

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

    * _name: 'money_source_type'
      _label: 'm) El origen de los fondos'
      _type: FieldType.kComboBox
      _options:
        'No efectivo'
        'Efectivo'

    * _name: 'money_source'
      _label: 'Descripción del origen de los fondos'

    * _name: 'is_obligated'
      _label: 'n) Si es Sujeto obligado'
      _tip: 'Es sujeto obligado informar a la UIF-Perú.'
      _type: FieldType.kRadioGroup
      _options: <[Sí No]>

    * _name: 'has_officer'
      _label: 'Oficial cumplimiento'
      _type: FieldType.kRadioGroup
      _options: <[Sí No]>

    * _name: 'reference'
      _label: 'Ref. Cliente'
      _tip: 'Referencia del cliente.'
      _grid: _GRID._inline


/** @export */
module.exports = Person


# vim: ts=2:sw=2:sts=2:et
