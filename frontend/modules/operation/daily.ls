/**
 * @module modules
 * @author gcca@gcca.tk (cristHian Gz. <gcca>)
 */

Module = require '../../workspace/module'
modal = App.widget.message-box
  Modal = ..Modal
table = App.widget.table
  Table = ..Table
OperationEdit = require './summary'

class Operations extends Module

  /** @override */
  render: ->
    @_desktop._lock!
    @_desktop._spinner-start!

    _labels =
      'Aduana'
      'N&ordm; Orden'
      'Rég.'
      'Razón social / Nombre'
      'N&ordm; DAM'
      'F. Declaración'
      'DI RO'

    _attributes =
      'jurisdiction.code'
      'order'
      'regime.code'
      'declaration.customer.name'
      'dam'
      'numeration_date'
      'diro'

    _column-cell-style =
      'declaration.customer.name': 'text-overflow:ellipsis;
                                    white-space:nowrap;
                                    overflow:hidden;
                                    max-width:27ch;
                                    text-align: left;'

    _template-pending =
      'diro': ->
        "<span class='#{gz.Css \label} #{gz.Css \label-danger}'>
           pendiente
         </span>"

    _template-accepting =
      'diro': ->
        "<span class='#{gz.Css \label} #{gz.Css \label-success}'>
           aceptado
         </span>"

    App.model.Dispatches._both (_pending, _accepting) ~>
    # '/api/customs_agency/list_dispatches'
      _table-pending = new Table do
                    _attributes: _attributes
                    _labels: _labels
                    _templates: _template-pending
                    _column-cell-style: _column-cell-style
                    on-dblclick-row: (evt) ~>
                      _model = evt._target._model
                      dam = _model._attributes.'dam'
                      if dam? and (dam isnt '')
                        @_desktop.load-next-page OperationEdit, do
                          model: _model
                      else
                        modal-dam = Modal._new do
                            _title: 'Advertencia'
                            _body: 'No puede ingresar, porque falta Numerar.'
                        modal-dam._show!

      _table-pending.set-rows _pending

      _table-accepting = new Table do
                    _attributes: _attributes
                    _labels: _labels
                    _templates: _template-accepting
                    _column-cell-style: _column-cell-style
                    on-dblclick-row: (evt) ~>
                      _model = evt._target._model
                      @_desktop.load-next-page OperationEdit, do
                          model: _model

      _table-accepting.set-rows _accepting

      @$el._append '<h4>Lista de despachos pendientes</h4>'
      @el._append _table-pending.render!.el

      @$el._append "<div class='#{gz.Css \col-md-12}'
                         style='margin-bottom:20px'>
                      <hr>
                    </div>"

      @$el._append '<h4>Lista de despachos aceptados</h4>'
      @el._append _table-accepting.render!.el
      @_desktop._unlock!
      @_desktop._spinner-stop!

    super!


  /** @protected */ @@_caption = 'RO - PROCESO DIARIO'
  /** @protected */ @@_icon    = gz.Css \flash
  /** @protected */ @@_hash  = 'auth-hash-operation'


/** @export */
module.exports = Operations


/* vim: ts=2 sw=2 sts=2 et: */
