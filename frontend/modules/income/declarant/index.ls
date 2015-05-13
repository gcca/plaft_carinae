/** @module modules */

panelgroup = App.widget.panelgroup

FormBodyDeclarant = require './declarant'

class DeclarantHeading extends panelgroup.PanelHeading

  _controls: [panelgroup.ControlTitle,
              panelgroup.ControlSearch,
              panelgroup.ControlClose]


class DeclarantGroup extends panelgroup.PanelGroup

  /** @override */
  _tagName: \div

  _toJSON: -> for @_panels then .._body._json

  render-panel: (_dto) ->
    _declarant = @new-panel do
      _panel-heading: DeclarantHeading
      _panel-body: FormBodyDeclarant
    _declarant._header._get panelgroup.ControlTitle ._text = 'Declarante'
    _declarant._header._get panelgroup.ControlSearch ._apply-attr 'declarant',
                                                                  window.'plaft'.'declarant'
    _declarant._body._json = _dto

  /** @override */
  render: ->
    @$el.removeAttr('class')
    @$el.removeAttr('id')

    @el.html = "<div></div>
                <button type='button'
                        class= '#{gz.Css \btn}
                              \ #{gz.Css \btn-default}'>
                  Agregar"
    @_container = @el._first
    @el._last.on-click ~>
      @render-panel!

    super!


class BodyDeclarant extends panelgroup.JSONBody

  _json-getter: -> @_group-declarant._toJSON!

  _json-setter: (_dtos) ->
    for _dto in _dtos
      @_group-declarant.render-panel _dto

  render: ->
    @_group-declarant = new DeclarantGroup
    @el._append @_group-declarant.render!.el
    super!

  _group-declarant: null

/** @export */
module.exports = BodyDeclarant


# vim: ts=2:sw=2:sts=2:et
