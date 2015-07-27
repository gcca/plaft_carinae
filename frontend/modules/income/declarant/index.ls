/** @module modules */

panelgroup = App.widget.panelgroup

FormBodyDeclarant = require './declarant'

class DeclarantHeading extends panelgroup.PanelHeading

  _controls: [panelgroup.ControlTitle,
              panelgroup.ControlBar,
              panelgroup.ControlSearch,
              panelgroup.ControlClose]


class DeclarantGroup extends panelgroup.PanelGroup

  /** @override */
  _tagName: \div

  _toJSON: -> for @_panels then .._body._json

  _update-autocompleter: (declarants) ->
    for @_panels then .._header._get panelgroup.ControlSearch ._update-autocompleter declarants

  _on-blur-address: (_address) ->
    for @_panels then (.._body.el.query '[name=address]')._value = _address

  /** @override */
  new-panel: ->
    _declarant = super do
      _panel-heading: DeclarantHeading
      _panel-body: FormBodyDeclarant
    _declarant._header._get panelgroup.ControlTitle ._text = 'Declarante'
    _declarant._header._get panelgroup.ControlSearch ._create-autocompleter 'declarant',
                                                                  App.GLOBALS._declarants
    (_declarant._body.el.query '[name=address]')._value = @_address-declarant
    _declarant

  /** @override */
  render: ->
    @el.html = "<div></div>
                <button type='button'
                        class= '#{gz.Css \btn}
                              \ #{gz.Css \btn-default}'>
                  Agregar"
    @_container = @el._first
    @el._last.on-click ~>
      @new-panel!

    super!

  _address-declarant: null


class BodyDeclarant extends panelgroup.JSONBody

  /** @override */
  _json-getter: ->
    @_group-declarant._toJSON!

  /** @override */
  _json-setter: (_dtos) ->
    if _dtos?
      for _dto in _dtos
        @_group-declarant.new-panel!
          .._body._json = _dto

  _dcl-address-el: (address) ->
    @_group-declarant._on-blur-address address
    @_group-declarant._address-declarant = address

  _update-autocompleter: (declarants) ->
    @_group-declarant._update-autocompleter declarants

  /** @override */
  render: ->
    @_group-declarant = new DeclarantGroup
    @el._append @_group-declarant.render!.el
    super!

  _group-declarant: null

/** @export */
module.exports = BodyDeclarant


# vim: ts=2:sw=2:sts=2:et
