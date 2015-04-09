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
    for linked in _dto.'linked'
      delete linked.'slug'
    for declarant in _dto.'declarant'
      delete declarant.'slug'
    ########################################################################

    @model._save @el._toJSON!, do
      _success: ->
        console.log 'Notificar'
      _error: ->
        console.log 'ERROR: e746ae94-5a3a-11e4-9a1d-88252caeb7e8'

  /** @override */
  render: ->
    App.builder.Form._new @el, _FIELDS
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
class Dispatches extends App.Collection
  urlRoot: \dispatch
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
      'Aqui va una funcion'

    _dto-list = new Array

    dispatches = new Dispatches
    dispatches._fetch do
      _success: (dispatches) ~>
        _tabla = new Table do
                      _attributes: _attributes
                      _labels: _labels
                      on-dblclick-row: (evt) ~>
                        @_desktop.load-next-page OperationEdit, model: evt._target._model

        _tabla.set-rows dispatches

        @el._append _tabla.render!.el

      _error: ->
        alert 'Error!!! Numeration list'

    super!


  /** @protected */ @@_caption = 'OPERACIONES'
  /** @protected */ @@_icon    = gz.Css \flash


/** @export */
module.exports = Operations


/* vim: ts=2 sw=2 sts=2 et: */

