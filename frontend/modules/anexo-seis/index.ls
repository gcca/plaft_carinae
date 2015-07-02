/**
 * @module modules
 * @author gcca@gcca.tk (cristHian Gz. <gcca>)
 */

Module = require '../../workspace/module'
table = App.widget.table
  Table = ..Table
SignalAlerts = require './signal-alert'

FieldType = App.builtins.Types.Field


/**
* @class Dispatch
* @extends Model
*/
class Dispatch extends App.Model
  urlRoot: 'dispatch'


/**
* @Class Dispatches
* @extends Collection
*/
class Dispatches extends App.Collection
  urlRoot: 'customs_agency/pending'
#  urlRoot: 'dispatch'
  model: Dispatch


/**
* @Class OperationEdit
* @extends Module
*/
class OperationEdit extends Module

  /** @override */
  _tagName: \form

  /** @override */
  on-save: ~>
    console.log @_toJSON!
    App.ajax._post "/api/dispatch/#{@model._id}/anexo_seis", @_toJSON!, do
      _success: ~>
        @_desktop.notifier.notify do
          _message : 'Se actualizó correctamente los datos'
          _type    : @_desktop.notifier.kSuccess
        @signalAlert.signalAlerts = []
      _bad-request: ~>
        alert 'ERROR: e746ae94-5a3a-11e4-9a1d-88252caeb7e8'

  _toJSON: ->
    @el._toJSON!
      ..'signal_alerts' = @signalAlert._toJSON!

  /** @override */
  render: ->
    App.builder.Form._new @el, _FIELDS
      @signalAlert = .._elements.'signal_alerts'._view
      ..render!
      .._free!

    @el._fromJSON @model._attributes
    @signalAlert.load-from @model._attributes.'signal_alerts'

    @$el._append "<div class='#{gz.Css \col-md-12} ' style='padding:0'>
                    <button type='button'
                            class='#{gz.Css \btn}
                                 \ #{gz.Css \btn-default}
                                 \ #{gz.Css \pull-right}'>
                      Generar Reporte
                    </button>
                  </div>"

    super!

  _GRID = App.builder.Form._GRID

  /** Field list for numeration form. (Array.<FieldOptions>) */
  _FIELDS =
    * _name: 'description'
      _label: 'Descripcion de la operación'
      _tip: 'Señale los argumentos que lo llevaron a calificar como inusual.'
      _grid: _GRID._full
      _type: FieldType.kTextEdit

    * _name: 'is_suspects'
      _label: '¿Ha sido calificado como sospechosa?'
      _type: FieldType.kRadioGroup
      _options: <[Si No]>

    * _name: 'ros'
      _label: 'Numero de ROS'
      _tip: 'Indicar el numero de ROS con el que se remitio en la UIF.'

    * _name: 'suspects_by'
      _label: 'Descripcion:'
      _tip: 'Describir los argumentos porque no fue calificada.'

    * _name: 'signal_alerts'
      _label: 'Señales de alerta.'
      _grid: _GRID._full
      _type: FieldType.kView
      _options: new SignalAlerts


/**
* @Class Operations
* @extends Module
*/
class Operations extends Module

  /** @override */
  render: ->
    _labels =
      'J. aduanera'
      'N Orden'
      'N regimen aduanero'
      'Nombre/Razon social'
      'N DAM'
      'Fecha declaracion aduanera'
      'DI RO'

    _attributes =
      'jurisdiction.code'
      'order'
      'regime.code'
      'declaration.customer.name'
      'dam'
      'numeration_date'
      'diro'

    _templates =
      'diro': ->
        "<span class='#{gz.Css \label} #{gz.Css \label-success}'>
           <span class='glyphicon glyphicon-ok'>
           </span>
         </span>"

    App.ajax._get '/api/customs_agency/list_dispatches', true, do
      _success: (dispatches) ~>
        _pending = new Dispatches dispatches.'pending'
        _tablaP = new Table do
                      _attributes: _attributes
                      _labels: _labels
                      _templates: _templates
                      on-dblclick-row: (evt) ~>
                        @_desktop.load-next-page OperationEdit, model: evt._target._model

        _tablaP.set-rows _pending

        @el._append _tablaP.render!.el

      _error: ->
        alert 'Error!!! NumerationP list'

    super!


  /** @protected */ @@_caption = 'ANEXO 6'
  /** @protected */ @@_icon    = gz.Css \flash
  /** @protected */ @@_hash    = 'ANX6-HASH'


/** @export */
module.exports = Operations


/* vim: ts=2 sw=2 sts=2 et: */
