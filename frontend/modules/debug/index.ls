/**
 * @module modules
 */

panelgroup = App.widget.panelgroup
Module = require '../../workspace-new/module'
Register = require './dependency-register'
Delete = require './dependency-delete'
NoDependency = require './no-dependency'

class Debug extends Module

  /** @override */
  _tagName: \div

  /** @override */
  render: ->
    _panel-group = new panelgroup.PanelGroup

    no-dependency = _panel-group.new-panel do
      _panel-heading: panelgroup.Heading
      _panel-body: NoDependency

    insert = _panel-group.new-panel do
      _panel-heading: panelgroup.Heading
      _panel-body: Register

    drop = _panel-group.new-panel do
      _panel-heading: panelgroup.Heading
      _panel-body: Delete

    no-dependency._header._get panelgroup.ControlTitle ._text = 'DEBUG - TABLAS PRINCIPALES'
    insert._header._get panelgroup.ControlTitle ._text = 'DEBUG - REGISTRO'
    drop._header._get panelgroup.ControlTitle ._text = 'DEBUG - ELIMINAR'

    @el._append _panel-group.render!.el

    super!

  /** @protected */ @@_mod-caption = 'DEBUG'
  /** @protected */ @@_mod-icon = gz.Css \th
  /** @protected */ @@_mod-hash    = 'auth-hash-log'



/** @export */
module.exports = Debug


/* vim: ts=2 sw=2 sts=2 et: */
