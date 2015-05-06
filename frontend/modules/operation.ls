/**
 * @module modules
 * @author gcca@gcca.tk (cristHian Gz. <gcca>)
 */

Module = require '../workspace/module'
table = require '../app/widgets/table'
  Table = ..Table

FieldType = App.builtins.Types.Field


class OperationEdit extends Module

  /** @override */
  _tagName: \form

  /** @override */
  on-save: ~>
    ########################################################################
    # VER ON-SAVE DE NUMERATION.LS
    _dto = @model._attributes
    for stk in _dto.'stakeholders'
      delete stk.'slug'
    for declarant in _dto.'declarants'
      delete declarant.'slug'
    ########################################################################

    @model._save @el._toJSON!, do
      _success: ->
        @_desktop.notifier.notify do
          _message : 'Se actualizó correctamente los datos'
          _type    : @_desktop.notifier.kSuccess
      _error: ->
        alert 'ERROR: e746ae94-5a3a-11e4-9a1d-88252caeb7e8'

  /**
   * (Event) Accept dispatch (to operation).
   * @private
   */
  on-accept: ~>
    App.ajax._post "/api/dispatch/#{@model._id}/accept", null, do
      _success: ~>
        alert 'ACEPTADO'
      _bad-request: ~>
        alert 'DENEGADO (Error)'

  /** @override */
  render: ->
    @el.html = "
    <div class='#{gz.Css \col-md-11}' style='padding:0'>
    </div>
    <div class='#{gz.Css \col-md-1}' style='padding:0'>
      <div class='#{gz.Css \col-md-12}
                \ #{gz.Css \col-sm-6}'
           style='padding:0'>
        <button type='button'
                class='#{gz.Css \btn}
                     \ #{gz.Css \btn-success'}'>
          Aceptar
        </button>
      </div>
      <div class='#{gz.Css \col-md-12}
                \ #{gz.Css \hidden-sm}'
           style='padding:0'>
        &nbsp;
      </div>
      <div class='#{gz.Css \col-md-12}
                \ #{gz.Css \col-sm-6}'
           style='padding:0'>
        <button type='button'
                class='#{gz.Css \btn}
                     \ #{gz.Css \btn-info'}'>
          Generar
        </button>
      </div>
    </div>"

    btn-accept = @el.query ".#{gz.Css \btn-success}"
    # btn-generate = @el.query ".#{gz.Css \btn-info}"  # TODO

    btn-accept.on-click @on-accept

    App.builder.Form._new @el._first, _FIELDS
      .._class = gz.Css \col-md-6
      ..render!
      .._free!
    @el._fromJSON @model._attributes

    super!

  /** Field list for numeration form. (Array.<FieldOptions>) */
  _FIELDS =
    * _name: 'tipo_fondos'
      _label: 'Tipo de fondos'
      _type: FieldType.kComboBox
      _options:
        'Efectivo'
        'No efectivo'

    * _name: 'tipo_operacion'
      _label: 'Tipo de operacion'
      _type: FieldType.kComboBox
      _options:
        'Importacion definitiva'
        'Reimportacion en el mismo estado'
        'Exportacion definitiva'
        'Exportacion temporal para reimportacion en el mismo estado'
        'Exportacion temporal para perfeccionamiento pasivo'
        'Admision temporal para reexportacion del mismo estado'
        'Reestitucion de derechos - Drawback'
        'Reposicion de mercancias con franquicia arancelaria'
        'Deposito aduanero'
        'Reembarque'
        'Transito aduanero'
        'Otra operacion de comercio exterior'
        'Otras que determinan la SBS'

    * _name: 'description'
      _label: 'Descripcion del tipo de operacion'

    * _name: 'dam'
      _label: 'Numero dam'

    * _name: 'numeration_date'
      _label: 'Fecha de numeracion de la dam'

    * _name: 'currency'
      _label: 'Tipo de moneda'
      _type: FieldType.kComboBox
      _options:
        'USD'
        'EUR'
        'PEN'
        'OTRO'

    * _name: 'otro_tipo_moneda'
      _label: 'Descripcion del tipo de moneda'

    * _name: 'ammount'
      _label: 'Monto de la operacion'

    * _name: 'exchange'
      _label: 'Tipo de cambio'

    * _name: 'from_country_code'
      _label: 'Pais de origen'
      _type: FieldType.kComboBox
      _options:
        'PERU'
        'ARGENTINA'
        'CHILE'
        'ECUADOR'

    * _name: 'to_country_code'
      _label: 'Pais de destino'
      _type: FieldType.kComboBox
      _options:
        'PERU'
        'ARGENTINA'
        'CHILE'
        'ECUADOR'


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
class DispatchesA extends App.Collection
  model: Dispatch


/**
* @Class Dispatches
* @extends Collection
*/
class DispatchesP extends App.Collection
  model: Dispatch


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

    App.ajax._get '/api/customs_agency/list_dispatches', do
      _success: (dispatches) ~>
        _pending = new DispatchesP dispatches.'pending'
        _accepting = new DispatchesA dispatches.'accepting'

        _table-pending = new Table do
                      _attributes: _attributes
                      _labels: _labels
                      _templates: _template-pending
                      on-dblclick-row: (evt) ~>
                        @_desktop.load-next-page OperationEdit, model: evt._target._model

        _table-pending.set-rows _pending

        _table-accepting = new Table do
                      _attributes: _attributes
                      _labels: _labels
                      _templates: _template-accepting

        _table-accepting.set-rows _accepting

        @$el._append '<h4>Lista de despachos pendientes</h4>'
        @el._append _table-pending.render!.el


        @$el._append '<h4>Lista de despachos aceptados</h4>'
        @el._append _table-accepting.render!.el
      _error: ->
        alert 'Error!!! NumerationP list'



    super!


  /** @protected */ @@_caption = 'ANEXO 2'
  /** @protected */ @@_icon    = gz.Css \flash


/** @export */
module.exports = Operations


/* vim: ts=2 sw=2 sts=2 et: */
