/** @module modules */

panelgroup = App.widget.panelgroup
LinkedBody = require './linked'

class StakeholderHeading extends panelgroup.PanelHeading

  _controls: [panelgroup.ControlTitle,
              panelgroup.ControlBar,
              panelgroup.ControlSearch,
              panelgroup.ControlClose]


/**
 * Stakeholders
 * ----------
 * @class Stakeholders
 * @extends PanelGroup
 */
class LinkedGroup extends panelgroup.PanelGroup

  /** @override */
  _tagName: \div

  /**
   * Form to JSON.
   * @return {Object}
   * @private
   */
  _toJSON: -> for @_panels then .._body._json

  _update-autocompleter: (stakeholders) ->
    for @_panels then .._header._get panelgroup.ControlSearch ._update-autocompleter stakeholders

  /**
   * Mostrar un panel.
   */
  new-panel: ->
    _stkholder = super do
      _panel-heading: StakeholderHeading
      _panel-body: LinkedBody
    _stkholder._header._get panelgroup.ControlTitle ._text = 'Vinculado'
    _stkholder._header._get panelgroup.ControlSearch ._create-autocompleter 'stakeholder',
                                                                  App.GLOBALS._stakeholders
    _stkholder


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
      @new-panel!

    super!

  /** @public */ _title: null
  /** @public */ _Body: null


class BodyLinked extends panelgroup.JSONBody

  _json-getter: -> @_pgStakeholder._toJSON!

  _json-setter: (_stakeholders) ->
    if _stakeholders?
      for stakeholder in _stakeholders
        @_pgStakeholder.new-panel!
          .._body._json = stakeholder

  _update-autocompleter: (stakeholders) ->
    @_pgStakeholder._update-autocompleter stakeholders

  set-type: (_type) ->
    @render!
    if _type?
      if _type  # Entrada de mercaderia
        @_title = 'Proveedores'
        LinkedBody._operation-type-to-in!  # (-o-) HARDCODE
      else  # Salida de mercaderia
        @_title = 'Destinatarios de embarque'
        LinkedBody._operation-type-to-out!  # (-o-) HARDCODE

    @$el._append "<h3>#{if @_title? then @_title else ''}</h3>"
    @el._append @_pgStakeholder.render!.el

  render: ->
    @el.html = null
    @_pgStakeholder = new LinkedGroup
    super!

  /** @private */ _pgStakeholder: null
  /** @private */ _title: null


/** @export */
module.exports = BodyLinked

# vim: ts=2:sw=2:sts=2:et
