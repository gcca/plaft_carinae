/** @module App */

# Change type extends
class FormRatio

  ({@fields, _templates = {},}) ->

    @_names = [field._name for field in @fields ]

    for _name in @_names
      if not _templates[_name]
        _templates[_name] = one-template
    @_templates = _templates

  __get-values = (_value, _attr) ->
    _value[_attr]

  one-template = ->
    if it?
      if it is ''
        1
      else
        0
    else
      1

  _calculate: (_dto) ->
    _pon = 0
    for _name in @_names
      _pon += @_templates[_name] __get-values _dto, _name
    100 - (App.math.trunc _pon/@_names.length* 100)

  fields: null
  _templates: null
  _names: null


/** @export */
module.exports = FormRatio


# vim: ts=2:sw=2:sts=2:et
