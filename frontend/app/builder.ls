/** @module App */

FieldType    = builtins.Types.Field
FieldOptions = builtins.Types.Options


/**
 * Form
 * ----
 * Builder {@code HTMLFormElement} by field options list.
 *
 * @example
 * >>> el = document.getElementById 'some-id'  # HTMLElement
 * >>> options =
 * ...   * _name: \firstname
 * ...     _label: 'First name'
 * ...     _type: App.builtins.Types.Field.kLineEdit
 * ...   * _name: \age
 * ...     _label: 'Age'
 * ...     _type: App.builtins.Types.Field.kLineEdit
 * ...     _tip: 'Description about age blah, blah, blah, blah.'
 * >>> form-builder = Form._new el, options
 * >>> form-builder.render!  # DOM construction.
 *
 * TODO(1.2): Create internal form-group object to get parts of form group
 *   easly. To get label, field, group, etc.
 *
 * @class Form
 * @extends Array
 * @export
 */
class exports.Form extends Array implements PoolMixin

  /**
   * Push fieldset.
   * @param {string} _legend
   * @param {Array.<FieldOptions>} _options-list
   * @param {?string} _tip
   * @return {HTMLElement}
   */
  fieldset: (_legend, _options-list, _tip) ->
    App.dom._new \fieldset
      @_push ..
      ..html = "<legend>#_legend</legend>"
      for _options in _options-list
        .._append @field _options

  /**
   * Push field.
   * @param {FieldOptions} _options
   * @return {HTMLElement}
   */
  fields: (_options) ->
    for _option in _options
      @field _option

  /**
   * Apply changes by callback.
   * @param {function(HTMLElement)} _callback Evaluate a form-group.
   */
  _apply: (_callback) !->
    for el in @ then _callback el

  /**
   * From string list to `options` html-tag list.
   * @param {Array.<string>} _options
   * @return string
   * @private
   */
  __field-options = (_options) ->
    | not _options => ''
    | _options._constructor is Array =>
      ["<option>#{..}</option>" for _options]._join ''
    | _options._constructor is Object =>
      ["<option value='#{_value}'>#{_option}</option>" \
       for _value, _option of _options]._join ''
    | otherwise => 'Error options'

  /**
   * Enable tip to label.
   * @param {HTMLElement} _label
   * @param {String} _tip
   * @private
   */
  __enable-tip = (_label, _tip)->
    _info = App.dom._new \i
      .._class = "#{gz.Css \glyphicon}
               \ #{gz.Css \glyphicon}-#{gz.Css \info}-#{gz.Css \sign}
               \ #{gz.Css \pull-right}
               \ #{gz.Css \toggle}"
      ..title = _tip
    _label._append _info

  /**
   * Create field by field type.
   * @param {FieldOptions}
   * @return {string}
   * @private
   */
  __element-by = ({_type = FieldType.kLineEdit, \
                   _name, \
                   _placeholder = '', \
                   _tip = '', _options}:_external) ->
    | _type is FieldType.kLineEdit =>
      App.dom._new \input
        ..type = 'text'
        .._class = gz.Css \form-control
        .._name = _name
        .._placeholder = _placeholder
    | _type is FieldType.kComboBox =>
      _options = __field-options _options
      App.dom._new \select
        .._class = gz.Css \form-control
        .._name = _name
        ..html = _options
    | _type is FieldType.kTextEdit =>
      App.dom._new \textarea
        .._class = gz.Css \form-control
        .._name = _name
        .._placeholder = _placeholder
    | _type is FieldType.kCheckBox =>
      App.dom._new \label
        .._class = gz.Css \checkbox
        ..html = "<span title='#_tip'
                      style='font-weight:normal;
                             margin-left:2em'>
                    #{'&nbsp;'*2}
                    Sí <i class='#{gz.Css \glyphicon}
                               \ #{gz.Css \glyphicon-check}'></i>
                    #{'&nbsp;'*4}
                    No <i class='#{gz.Css \glyphicon}
                               \ #{gz.Css \glyphicon-unchecked}'></i>
                  </span>
                  &nbsp;
                  <input type='checkbox'
                      name='#{_external._name}'
                      placeholder='#{_external._placeholder}'>"
    | _type is FieldType.kRadioGroup =>
      App.dom._new \div
        ..html =["<label class='#{gz.Css \radio-inline}'>
                    <input type='radio' name='#_name' value='#{..}'> #{..}
                  </label>" for _options]._join ''
    | _type is FieldType.kView =>
      _options.render!.el
    | _type is FieldType.kHidden =>
      App.dom._new \input
        ..type = 'hidden'
        ..name = _name
        ..value = _options
    | otherwise => throw "Error: Bad type"

  /**
   * Grid options to html class (style).
   * @param {?number} _val
   * TODO(...): Improve using dict.
   * @private
   */
  __grid = (_val) ->
    __grid-array._length = 0
    __grid-array
      .._push gz.Css \col-md-6 if not _val
      .._push "#{gz.Css \col-md-12} #{gz.Css \inline-control}" \
        if _val .&. @@_GRID._inline
      .._push gz.Css \col-md-6 if _val .&. @@_GRID._half
      .._push 'Not implemented yet' if _val .&. @@_GRID._flush-left
      .._push 'Not implemented yet' if _val .&. @@_GRID._flush-right
      .._push gz.Css \col-md-12 if _val .&. @@_GRID._full
      .._push 'BAD GRID' if not __grid-array._length
    __grid-array._join ' '

  /** @private */ __grid-array = new Array

  /**
   * Push field string.
   * @param {FieldOptions} _options
   * @return {HTMLElement}
   */
  field: ({_type = FieldType.kLineEdit, _label, _name,\
           _grid, _field-attrs, _tip}:_options) ->
    label = App.dom._new \label
      .._class = "#{gz.Css \col-md-12}
                \ #{gz.Css \control-label}
                \ #{gz.Css \parent-toggle}"
      ..css = "padding-left:0;
               padding-right:0"
      ..html = _label

    App.dom._new \div
      .._class = "#{gz.Css \form-group} #{__grid _grid}"
      .._append label
      .._append _el = __element-by _options
      @_push ..

      # basic
      @_elements[_name] = _field: .., _element: _el

      ## TODO(...): Apply only to radios.
      #_element-t = _field: ..
      #Object._properties _element-t, do
      #  _element: get: ~>
      #    # @el._elements[_name]
      #    @el._elements[_name]
      #@_elements[_name] = _element-t

      if _type is FieldType.kView
        @_elements[_name]._view = _options._options
      ########################################################
      # TODO: Implement all again to avoid things like this: #
      #       - each field has his own header,               #
      #         usually "div";                               #
      #       - improve filtering fields and their elements. #
      ########################################################
      if _type is FieldType.kHidden
        ..css\display = \none

      # Field attributes
      _el._disabled = on if _field-attrs .&. @@_FIELD_ATTR._disabled

      # Enable tip
      if _tip?
        __enable-tip label, _tip

  /**
   * @type Object
   * @public
   */
  _elements: new Object

  /** @override */
  initialize: (@el, _options) ->
    @_length = 0

    if _options?
      @fields _options

  ->
    super!
    @initialize ...

  /** Create pool */ Pool @@

  /** @override */
  render: ->
    for el in @ then @el._append el
    @

  /**
   * @type HTMLElement
   * @private
   */
  el: null

  /**
   * Grid options
   * @public
   */
  @@_GRID =
    _inline: 1
    _half: 2
    _flush-left: 4
    _flush-right: 8
    _full: 16

  /**
   * Field attribute
   * @public
   */
  @@_FIELD_ATTR =
    _disabled: 1


# vim: ts=2:sw=2:sts=2:et
