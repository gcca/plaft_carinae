/** @modules.income */


Module = require '../workspace-new/module'
Table = App.widget.table.Table


class Dispatch extends App.Model
  urlRoot: \income


class Dispatches extends App.Collection
  urlRoot: \income
  model: Dispatch


/**
 * Income
 * ------
 * @class Income
 * @extends Module
 */
class Income extends Module

  /** @override */
  on-search: (query) ->

  /** @override */
  render: ->
    @_desktop._lock!
    @_desktop._spinner-start!

    _labels =
      'Aduana'
      'N&ordm; Orden'
      'Rég.'
      'Razón social / Nombre'
      'Fecha'
      'RUC/DNI'
      ''

    _attributes =
      'jurisdiction.code'
      'order'
      'regime.code'
      'customer_name'
      'income_date'
      'customer_number'
      'dummy'

    _templates =
      'dummy': @on-dummy

    dispatches = new Dispatches
    dispatches._fetch do
      _success: (dispatches) ~>
        _table = new Table do
          _attributes: _attributes
          _labels: _labels
          _templates: _templates
          on-dblclick-row: (evt) ~>
            @_desktop.load-next-page(IncomenEdit, do
                                     model: evt._target._model)

        _table.set-rows dispatches

        @el._append _table.render!.el
        @_desktop._unlock!
        @_desktop._spinner-stop!
    super!

  /** @protected */ @@_mod-caption = 'INGRESO DE OPERACIONES'
  /** @protected */ @@_mod-icon    = gz.Css \print
  /** @protected */ @@_mod-hash    = 'auth-hash-income'


/** @export */
module.exports = Income


/* vim: ts=2 sw=2 sts=2 et: */
