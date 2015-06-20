/** @module App */

# Change type extends
class FormRatio

  ({@fields, _templates = {},}) ->

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
        | Object => int-value = calculate-object value
        | Array  => int-value = calculate-array value
        | otherwise =>
          if value isnt ''
            int-value = 1
    int-value

  _calculate: (_dto) ->
    _pon = 0
    for _field in @fields
      _name = _field._name
      _pon += @_templates[_name] __get-values _dto, _name
    App.math.trunc _pon/@_names.length* 100

  fields: null
  _templates: null
  _names: null


/** @export */
module.exports = FormRatio


# vim: ts=2:sw=2:sts=2:et
