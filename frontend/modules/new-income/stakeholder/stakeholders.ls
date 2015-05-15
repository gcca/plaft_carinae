/** @module modules */

panelgroup = App.widget.panelgroup

class StakeholderHeading extends panelgroup.PanelHeading

  _controls: [panelgroup.ControlTitle,
              panelgroup.ControlSearch,
              panelgroup.ControlClose]


/**
 * Stakeholders
 * ----------
 * @class Stakeholders
 * @extends PanelGroup
 */
class Stakeholders extends panelgroup.PanelGroup

  /** @override */
  _tagName: \div

  /**
   * Form to JSON.
   * @return {Object}
   * @private
   */
  _toJSON: -> for @_panels then .._body._json

  set-panel: (_title, _body)->
    @_Body = _body
    @_title = _title
  /**
   * Mostrar un panel.
   */
  new-panel: (_panel-body=@_Body, _panel-heading=StakeholderHeading)->
    if @_Body?
      _r = super do
        _panel-heading: _panel-heading
        _panel-body:_panel-body


  /** @override */
  render: ->

    @el.html = "<div></div>
                <button type='button'
                        class= '#{gz.Css \btn}
                              \ #{gz.Css \btn-default}'>
                  Agregar
                </button>"
    @_container = @el._first
    @el._last.on-click ~>
      if @_Body?
        @new-panel @_Body
          .._header._get panelgroup.ControlTitle ._text = @_title
          .._header._get panelgroup.ControlSearch ._apply-attr 'stakeholder',
                                                                window.'plaft'.'stakeholder'
      else
        alert 'Debe escoger si es Salida o Entrada de Mercaderia.'

    super!

  /** @public */ _title: null
  /** @public */ _Body: null

/** @export */
exports <<<
  Stakeholders: Stakeholders
  StakeholderHeading: StakeholderHeading


# vim: ts=2:sw=2:sts=2:et
