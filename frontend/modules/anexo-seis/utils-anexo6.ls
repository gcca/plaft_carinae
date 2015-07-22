

table = App.widget.table
  Table = ..Table

class UtilAnexo

  ({@_desktop, @_parent, @_child}) ->

  _load-module: ->
    @_desktop._lock!
    @_desktop._spinner-start!
    _labels =
      'Juridicción'
      'N Orden'
      'Reg.'
      'Nombre/Razon social'
      'N DAM'
      'Fecha Declaración'
      'DI RO'

    _attributes =
      'jurisdiction.code'
      'order'
      'regime.code'
      'declaration.customer.name'
      'dam'
      'numeration_date'
      'it'

    _templates =
      'it': ->
        if it.'has_alerts'
          if it.'alerts'._length
            "<span class='#{gz.Css \label} #{gz.Css \label-danger}'>
               C/OI
             </span>"
          else
            "<span class='#{gz.Css \label} #{gz.Css \label-success}'>
               S/OI
             </span>"
        else
          ''

    App.ajax._get '/api/dispatch/list', true, do
      _success: (dispatches) ~>
        _pending = new Dispatches dispatches
        _tabla = new Table do
                      _attributes: _attributes
                      _labels: _labels
                      _templates: _templates
                      on-dblclick-row: (evt) ~>
                        @_desktop.load-next-page @_child, model: evt._target._model

        _tabla.set-rows _pending

        @_parent.el._append _tabla.render!.el
        @_desktop._unlock!
        @_desktop._spinner-stop!

      _error: ->
        alert 'Error!!! NumerationP list'

  /** @private */ _desktop: null
  /** @private */ _parent: null
  /** @private */ _child: null

/** @export */
module.exports = UtilAnexo

# vim: ts=2:sw=2:sts=2:et
