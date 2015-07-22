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
    _dispatch = @model._attributes
    @el.html = "<div class='#{gz.Css \form-group}
                          \ #{gz.Css \col-md-5}'
                     style='padding:0px'>
                  <label class='#{gz.Css \col-md-4}'
                         style='text-align:center'>
                    Aduana
                  </label>
                  <label class='#{gz.Css \col-md-5}'
                         style='text-align:center;
                                padding:0px;
                                border-style:solid'>
                    #{_dispatch.'jurisdiction'.'code'}
                  </label>
                  <label class='#{gz.Css \col-md-4}'
                         style='text-align:center'>
                    Régimen
                  </label>
                  <label class='#{gz.Css \col-md-5}'
                         style='text-align:center;
                                padding:0px;
                                border-style:solid'>
                    #{_dispatch.'regime'.'code'}
                  </label>
                </div>
                <div class='#{gz.Css \form-group}
                          \ #{gz.Css \col-md-5}'>
                  <label class='#{gz.Css \col-md-6}'>
                    No Orden de Despacho
                  </label>
                  <label class='#{gz.Css \col-md-6}'
                         style='text-align:center;
                                border-style:solid'>
                    #{_dispatch.'order'}
                  </label>
                  <label class='#{gz.Css \col-md-6}'>
                    Razón Social/Nombre
                  </label>
                  <label class='#{gz.Css \col-md-6}'
                         style='text-align:center;
                                border-style:solid'>
                    #{_dispatch.'declaration'.'customer'.'name'}
                  </label>
                </div>"

    App.builder.Form._new @el, _FIELDS
      ..render!
      .._free!


    _dto = ["<p>#{..'section'+..'code'}). #{..'description'}</p></br>" for _dispatch.'alerts'].join ''

    @el._fromJSON _dispatch
    @$el._append "<div class='#{gz.Css \col-md-12}'>
                    <hr>
                    #{_dto}
                  </div>
                  <div class='#{gz.Css \col-md-12} ' style='padding:0'>
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
      _grid: _GRID._full
      _type: FieldType.kTextEdit

    * _name: 'suspects_by'
      _label: 'Descripcion:'
      _tip: 'Describir los argumentos porque fue aceptada'
      _grid: _GRID._full
      _type: FieldType.kTextEdit


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
