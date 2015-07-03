/** @module App */

FieldType    = builtins.Types.Field
# Change type extends
class FormRatio

  ({@fields, @el, _templates = {}}) ->
    @_names = [field._name for field in @fields ]

    for _field in @fields
      _name = _field._name
      if not _templates[_name]
        _templates[_name] = template-calculate
    @_templates = _templates

  __get-values = (_value, _attr) ->
    _value[_attr]

  calculate-object = (obj) ->
    _length = Object.keys(obj).length
    int-object = 0
    for k of obj
      int-object += template-calculate obj[k]
    int-object/_length

  calculate-array = (obj) ->
    int-array = 0
    _length = obj._length
    for i,k in obj
      int-array += template-calculate obj[k]
    int-array/_length

  template-calculate = (value) ->
    int-value = 0
    if value?
      switch value.__proto__.constructor
        | Object =>
          for k of value
            int-value = calculate-object value
        | Array  =>
          if value._length?
            int-value = calculate-array value
        | String =>
          if value isnt ''
            int-value = 1
        | otherwise =>
          if value?
            int-value = 1
    else
      int-value = 0
    int-value

  _validate-field: (_field, _type) ->
    if _field._type is FieldType.kView
      _parent = _field._options.el._parent
    else if _field._type is FieldType.kRadioGroup
      _parent = (@el.query "[name=#{_field._name}]")._parent._parent
    else
      @is_disabled = (@el.query "[name=#{_field._name}]")._disabled
      _parent = (@el.query "[name=#{_field._name}]")._parent

    if _type?
      if @is_disabled? and not @is_disabled
        _parent._class._add gz.Css \has-error
    else
      _parent._class._remove gz.Css \has-error

  _calculate: (_dto) ->
    _pon = 0
    for _field in @fields
      _name = _field._name
      if (@_templates[_name] __get-values _dto, _name) is 1
        _pon += 1
        @_validate-field _field
      else
        @_validate-field _field, 'NULO'

    App.math.trunc _pon/@_names.length* 100

  /** @private */ fields: null
  /** @private */ _templates: null
  /** @private */ _names: null
  /** @private */ el: null
  /** @private */ is_disabled: null

/** @export */
module.exports = FormRatio


# vim: ts=2:sw=2:sts=2:et
