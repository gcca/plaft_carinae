/**
 * @module modules
 * @author gcca@gcca.tk (cristHian Gz. <gcca>)
 */

Module = require '../../workspace/module'
SignalAlerts = require './alerts'
Utils = require './utils-anexo6'

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
class Anexo6 extends Module

  /** @override */
  _tagName: \form

  /** @override */
  on-save: ~>
    App.ajax._post "/api/dispatch/#{@model._id}/anexo_seis", @_toJSON!, do
      _success: ~>
        @_desktop.notifier.notify do
          _message : 'Se actualizó correctamente los datos'
          _type    : @_desktop.notifier.kSuccess
      _bad-request: ~>
        alert 'ERROR: e746ae94-5a3a-11e4-9a1d-88252caeb7e8'


  /** @override */
  render: ->
    App.builder.Form._new @el, _FIELDS
      ..render!
      .._free!

    _alerts = App.lists.alerts._display
    _dto = ["<li>#{_alerts[i*3]}</li>" for i from 1 to 4].join ''

    @el._fromJSON @model._attributes
    @$el._append "<div class='#{gz.Css \col-md-12}'><hr></hr></div>"
    @$el._append "<div class='#{gz.Css \col-md-12}'>
                    <ul>#{_dto}</ul></div>"
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


/**
* @Class Operations
* @extends Module
*/
class ListAnexo6 extends Module

  /** @override */
  render: ->
    (new Utils do
      _desktop: @_desktop
      _parent: @
      _child: Anexo6)._load-module!

    super!


  /** @protected */ @@_caption = 'ANEXO 6'
  /** @protected */ @@_icon    = gz.Css \flash
  /** @protected */ @@_hash    = 'ANX6-HASH'


/** @export */
module.exports = ListAnexo6


/* vim: ts=2 sw=2 sts=2 et: */
