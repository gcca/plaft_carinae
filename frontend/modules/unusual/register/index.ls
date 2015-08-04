/**
 * @module modules
 * @author gcca@gcca.tk (cristHian Gz. <gcca>)
 */

Module = require '../../../workspace/module'
Utils = require '../table'
Alerts = require './panel'

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
class Register extends Module

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

  _toJSON: ->
    @el._toJSON!
      ..'alerts' = @_png-alerts._toJSON!

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

    _link-rosel = "<a class='#{gz.Css \btn}
                           \ #{gz.Css \btn-primary}
                           \ #{gz.Css \btn-xs}
                           \ #{gz.Css \pull-right}'
                      target='_blank'
                      href='//rosel.sbs.gob.pe'>LINK ROSEL</a>"

    App.builder.Form._new @el, _FIELDS

      _input-ros = .._elements.'ros'._element

      _ros = .._elements.'ros'._field
        .._first._class._remove gz.Css \col-md-12
        .._first._class._add gz.Css \col-md-6
        .._remove .._last
        $ .. ._append _link-rosel
        .._append _input-ros
        $ .. ._hide!

      _suspects-by = .._elements.'suspects_by'._field
        $ .. ._hide!

      _is-suspects = .._elements.'is_suspects'
        .._element.on-change ~>
          if .._radios._no._checked
            $ _ros ._hide!
            $ _suspects-by ._show!
          else
            $ _ros ._show!
            $ _suspects-by ._hide!
      ..render!
      .._free!

    if _dispatch.'is_suspects'?
      if _dispatch.'is_suspects'
        _is-suspects._radios._yes._checked = true
        $ _ros ._show!
        $ _suspects-by ._hide!
      else
        _is-suspects._radios._no._checked = true
        $ _ros ._hide!
        $ _suspects-by ._show!


    @el._fromJSON _dispatch

    @$el._append "<h4 class='#{gz.Css \col-md-12}'>
                    SEÑALES DE ALERTA IDENTIFICADAS
                  </h4>"
    @_png-alerts = new Alerts
    @_png-alerts._fromJSON _dispatch.'alerts'
    @_png-alerts.el._class._add gz.Css \col-md-12
    @el._append @_png-alerts.render!.el

    @$el._append "<div class='#{gz.Css \col-md-12} ' style='padding:0'>
                    <button type='button'
                            class='#{gz.Css \btn}
                                 \ #{gz.Css \btn-default}
                                 \ #{gz.Css \pull-right}'>
                      Generar Reporte
                    </button>
                  </div>"

    super!

  _png-alerts: null

  _GRID = App.builder.Form._GRID

  /** Field list for numeration form. (Array.<FieldOptions>) */
  _FIELDS =
    * _name: 'description_unusual'
      _label: 'Descripcion de la operación'
      _tip: 'Señale los argumentos que lo llevaron a calificar como inusual
           \ la operación.'
      _grid: _GRID._full
      _type: FieldType.kTextEdit

    * _name: 'numeration_date'
      _label: 'Fecha de Numeración'

    * _name: 'last_date_ros'
      _label: 'Último dia de RO'

    * _name: 'is_suspects'
      _label: '¿Ha sido calificado como sospechosa?'
      _type: FieldType.kYesNo

    * _name: 'ros'
      _label: 'Número de ROS'
      _tip: 'Indicar el numero de ROS con el que se remitio en la UIF.'

    * _name: 'suspects_by'
      _label: 'Describir los argumentos porque no calificada como sospechosa'
      _tip: 'Describir los argumentos por los cuales esta operación no
           \ fue calificada como sospechosa.'
      _grid: _GRID._full
      _type: FieldType.kTextEdit


/**
* @Class Operations
* @extends Module
*/
class ListRegister extends Module

  /** @override */
  render: ->
    (new Utils do
      _desktop: @_desktop
      _parent: @
      _child: Register
      _url: 'api/customs_agency/dispatches_without_IO')._load-module!

    super!


  /** @protected */ @@_caption = 'CONTROL OI - OFICIAL CUMPLIMIENTO'
  /** @protected */ @@_icon    = gz.Css \flash
  /** @protected */ @@_hash    = 'auth-hash-register'


/** @export */
module.exports = ListRegister


/* vim: ts=2 sw=2 sts=2 et: */
