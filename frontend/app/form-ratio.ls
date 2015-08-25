/** @module App */

FieldType    = builtins.Types.Field
# Change type extends
class FormRatio

  /** initialize */
  ({@fields, @el}) ->
    @len-values = [f._name for f in @fields when f._name?]._length

  is-not-null = (value) ->
    | not value? => false
    | value.__proto__.constructor is String => value isnt ''
    | value.__proto__.constructor is Object =>
      for k of value
        return true
      return false
    | value.__proto__.constructor is Array  => value._length?
    | value.__proto__.constructor is Boolean  => true
    | otherwise => value?

  __validate = (field, is-null) ->
    field-value = (@el.query "[name='#{field._name}']")
    switch field._type
      | FieldType.kView =>
        @is-disabled = false
        parent-field = field._options.el._parent
      | FieldType.kRadioGroup => parent-field = field-value._parent._parent
      | FieldType.kLabel => return
      | otherwise =>
        @is-disabled = field-value._disabled
        parent-field = field-value._parent

    if is-null and not @is-disabled
      parent-field._class._add gz.Css \has-error
    else
      parent-field._class._remove gz.Css \has-error

  _calculate: (_dto) ->
    balanced = 0
    for field in @fields
      if is-not-null _dto[field._name]
        balanced += 1
        __validate field, off
      else
        __validate field, on

    App.math.trunc (balanced/@len-values) * 100

  /** @private */ fields: null
  /** @private */ len-values: null
  /** @private */ el: null
  /** @private */ is-disabled: null

/** @export */
module.exports = FormRatio


# vim: ts=2:sw=2:sts=2:et
