/** @module modules */

PanelGroup = App.widget.panelgroup.PanelGroup

class exports.DTOPanelGroup extends PanelGroup

  new-panel: ({_panel-body, _panel-header, _dto, _get-title}) ->
    super ...
      if dto?
        .._header.set-title _get-title _dto


# vim: ts=2:sw=2:sts=2:et
