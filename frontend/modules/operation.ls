/**
 * @module modules
 * @author gcca@gcca.tk (cristHian Gz. <gcca>)
 */

Module = require '../workspace/module'
table = App.widget.table
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

  calculate-field: (n1, n2) ->
    result = parseFloat n1*n2
    result.to-fixed 2

  upper-field: (_field) ->
    if _field?
      return  _field.to-upper-case!
    else
      return 'No aplica'

  empty-field: (_field, message='No aplica') ->
    if _field?
      if _field is ""
        return message
      else
        return _field
    else
      return message

  in-country: (_field) ->
    if @_type
      return @empty-field _field
    else
      return 'No aplica'

  out-country: (_field) ->
    if not @_type
      return @empty-field _field
    else
      return 'No aplica'

  load-header: (_dto) ->
    _customer = _dto.'declaration'.'customer'
    if _customer.'document_type' is \ruc
      _name = _customer.'name'
    else
      _name = "#{_customer.'name'}
             \ #{_customer.'father_name'}
             \ #{_customer.'mother_name'}"
    $ @el._first ._append "
      <div class='#{gz.Css \col-md-4}'>
        <label class='#{gz.Css \col-md-4}'
               style='padding:0'>
          N&ordm; Orden
        </label>
        <label class='#{gz.Css \col-md-8}'
               style='border:solid'>
          #{_dto.'order'}
        </label>
        <label class='#{gz.Css \col-md-4}'
               style='padding:0'>
          N&ordm; DAM
        </label>
        <label class='#{gz.Css \col-md-8}'
               style='border:solid'>
          #{_dto.'dam'}
        </label>
        <label class='#{gz.Css \col-md-4}'
               style='padding:0'>
          Tipo de operación
        </label>
        <label class='#{gz.Css \col-md-8}'
               style='border:solid'>
          #{@check-code-sbs _dto.'regime'.'name'}
        </label>
      </div>

      <div class='#{gz.Css \col-md-8}'>
        <label class='#{gz.Css \col-md-4}'>
          Razón social/Nombre
        </label>
        <label class='#{gz.Css \col-md-8}'
               style='border:solid'>
          #{_name}
        </label>
        <label class='#{gz.Css \col-md-4}'>
          Fecha numeración
        </label>
        <label class='#{gz.Css \col-md-8}'
               style='border:solid'>
          #{_dto.'numeration_date'}
        </label>
        <label class='#{gz.Css \col-md-4}'>
          Descripción
        </label>
        <label class='#{gz.Css \col-md-8}'
               style='border:solid'>
          #{_dto.'regime'.'name'}
        </label>
      </div>"


  load-list-operation: (_dto) ->
    _customer = _dto.'declaration'.'customer'
    _stk = _dto.'stakeholders'.'0'
    _code-sbs = @check-code-sbs _dto.'regime'.'name'

    _list-operation = []
    _list-operation._push @empty-field _customer.'money_source_type'
    _list-operation._push _dto.'regime'.'name' + "("+_code-sbs+")"
    _list-operation._push 'No aplica'
    _list-operation._push @empty-field _dto.'description'
    _list-operation._push @empty-field _dto.'dam'
    _list-operation._push @empty-field _dto.'numeration_date'
    _list-operation._push @empty-field _customer.'money_source'
    _list-operation._push 'D'
    _list-operation._push 'No aplica'
    _list-operation._push @calculate-field _dto.'amount', _dto.'exchange_rate'
    _list-operation._push @empty-field _dto.'exchange_rate'
    _list-operation._push @in-country _stk.'country'  # Verificar de donde sacar el dato.
    _list-operation._push @out-country _stk.'country'  # Verificar de donde sacar el dato.


    @load-table App.lists.anexo2.operation._code,
                App.lists.anexo2.operation._display,
                _list-operation

  load-list-third: (_third) ->
    list-third = []
    if _third.'document_type'?
      if _third.'document_type' is \ruc
        _third-type = 'Persona Jurídica'
        _third-name = _third.'name'
        _name69 = 'No aplica'
        _dtype = 'No aplica'
      else
        _third-type = 'Persona Natural'
        _third-name = _third.'father_name'
        _name69 = _third.'name'
        _dtype = _third.'document_type'

      list-third._push @empty-field _third-type
      list-third._push @upper-field _dtype
      list-third._push @empty-field _third.'document_number'
      list-third._push @empty-field _third-name
      list-third._push @empty-field _third.'mother_name'
      list-third._push @empty-field _name69
      list-third._push @empty-field _third.'third_ok'
    else
        list-third = ['No aplica' for til 7]

    @load-table App.lists.anexo2.third._code,
                App.lists.anexo2.third._display,
                list-third

  load-list-declarant: (_dto) ->
    _declarant = _dto.'0'
    if not _declarant?
      list-declarant = ['-' for til 16]

      @load-table App.lists.anexo2.declarant._code,
                  App.lists.anexo2.declarant._display,
                  list-declarant
      return
    list-declarant = []


    if _declarant.'ciiu'?
      _ciiu = _declarant.'ciiu'.'name'

    if _declarant.'ubigeo'?
      _ubigeo = _declarant.'ubigeo'.'code' + " " + _declarant.'ubigeo'.'name'

    list-declarant._push @empty-field _declarant.'represents_to'
    list-declarant._push @empty-field _declarant.'residence_status'
    list-declarant._push @upper-field _declarant.'document_type'
    list-declarant._push @empty-field _declarant.'document_number'
    list-declarant._push @empty-field _declarant.'issuance_country'
    list-declarant._push @empty-field _declarant.'father_name'
    list-declarant._push @empty-field _declarant.'mother_name'
    list-declarant._push @empty-field _declarant.'name'
    list-declarant._push @empty-field _declarant.'nationality'
    list-declarant._push @empty-field _declarant.'activity'
    list-declarant._push 'No aplica'
    list-declarant._push @empty-field _ciiu
    list-declarant._push @empty-field _declarant.'position'
    list-declarant._push @empty-field _declarant.'address'
    list-declarant._push @empty-field _ubigeo
    list-declarant._push @empty-field _declarant.'phone'

    @load-table App.lists.anexo2.declarant._code,
                App.lists.anexo2.declarant._display,
                list-declarant

  load-list-customer: (_dto, _title, _isTrue=on) ->
    list-customer = []
    _customer = _dto.'declaration'.'customer'
    if _customer.'document_type' is \ruc
      _customer-type = 'Persona Jurídica'
      _dnumber = 'No aplica'
      _document-number = _customer.'document_number'
      _document-type = 'No aplica'
      _name = _customer.'name'
      _name35 = 'No aplica'
      _ocupation = 'No aplica'
      _activity = _customer.'activity'
    else
      _customer-type = 'Persona Natural'
      _dnumber = _customer.'document_number'
      _document-number = _customer.'ruc'
      _name = _customer.'father_name'
      _name35 = _customer.'name'
      _ocupation = _customer.'activity'
      _activity = 'No aplica'
      _document-type = _customer.'document_type'

    list-customer._push  _title
    if _isTrue
      _code-array = App.lists.anexo2.linked1._code
      _display-array = App.lists.anexo2.linked1._display
      list-customer._push  @empty-field _customer.'legal_type'
    else
      _code-array = App.lists.anexo2.linked2._code
      _display-array = App.lists.anexo2.linked2._display

    if _customer.'ciiu'?
      _ciiu = _customer.'ciiu'.'name'

    if _customer.'ubigeo'?
      _ubigeo = _customer.'ubigeo'.'code' + " " + _customer.'ubigeo'.'name'

    list-customer._push  @empty-field _customer.'condition'
    list-customer._push  _customer-type
    list-customer._push  @empty-field _document-type
    list-customer._push  _dnumber
    list-customer._push  @empty-field _customer.'issuance_country'
    list-customer._push  @empty-field _document-number
    list-customer._push  @empty-field _name
    list-customer._push  @empty-field _customer.'mother_name'
    list-customer._push  @empty-field _name35
    list-customer._push  @empty-field _customer.'nationality'
    list-customer._push  @empty-field _ocupation
    list-customer._push  'No aplica' # Ya no existe descripcion de otros
    list-customer._push  @empty-field _activity
    list-customer._push  @empty-field _ciiu
    list-customer._push  @empty-field _customer.'employment'
    list-customer._push  @empty-field _customer.'fiscal_address'
    list-customer._push  @empty-field _ubigeo
    list-customer._push  @empty-field _customer.'phone'

    @load-table _code-array,
                _display-array,
                list-customer

  load-list-stakeholder: (_stakeholders, _isTrue=on) ->
    for _stkholder in _stakeholders
      list-linked = []

      # Verificar stakeholder
      if _stkholder.'document_type' is \ruc
        _stkholder-type = 'Persona Jurídica'
        _name = _stkholder.'name'
        _name35 = 'No aplica'
      else
        _stkholder-type = 'Persona Natural'
        _name = _stkholder.'father_name'
        _name35 = _stkholder.'name' # Nombre de persona Natural

      list-linked._push  @empty-field _stkholder.'linked_type'
      if _isTrue
        _code-array = App.lists.anexo2.linked1._code
        _display-array = App.lists.anexo2.linked1._display
        list-linked._push  @empty-field _stkholder.'legal_type'
      else
        _code-array = App.lists.anexo2.linked2._code
        _display-array = App.lists.anexo2.linked2._display

      list-linked._push  @empty-field _stkholder.'condition'
      list-linked._push  _stkholder-type  # Verificar tipo de persona
      list-linked._push  @empty-field!
      list-linked._push  @empty-field!
      list-linked._push  @empty-field!
      list-linked._push  @empty-field!
      list-linked._push  _name
      list-linked._push  @empty-field _stkholder.'mother_name'
      list-linked._push  _name35
      list-linked._push  @empty-field!
      list-linked._push  @empty-field!
      list-linked._push  @empty-field!
      list-linked._push  @empty-field!
      list-linked._push  @empty-field!
      list-linked._push  @empty-field!
      list-linked._push  @empty-field _stkholder.'address'
      list-linked._push  @empty-field!
      list-linked._push  @empty-field!

      @load-table _code-array,
                  _display-array,
                  list-linked

  load-table: (list1, list2, list3) ->
    _table = App.dom._new \table
      .._class = "#{gz.Css \table}
                \ #{gz.Css \table-bordered}"
    _tbody = App.dom._new \tbody
    for [f, s, m] in _.zip list1, list2, list3
      _tr = App.dom._new \tr
      App.dom._new \td
        ..css = 'width: 0.5%'
        ..html = f
        _tr._append ..
      App.dom._new \td
        .._class = gz.Css \col-md-7
        ..html = s
        _tr._append ..
      App.dom._new \td
        .._class = gz.Css \col-md-5
        ..html = m
        _tr._append ..
      _tbody._append _tr
    _table._append _tbody
    @el._last._append _table

  check-commodity: (_name-regime) ->
    _k = App.lists.regime._display._index _name-regime

    return App.lists.regime._sbs[_k]

  check-code-sbs: (_name-regime) ->
    _k = App.lists.regime._display._index _name-regime

    return App.lists.regime._sbs-code[_k]


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
           style='padding:0;margin-bottom: 20px'>
        <button type='button'
                class='#{gz.Css \btn}
                     \ #{gz.Css \btn-info'}'>
          Generar
        </button>
      </div>
    </div>
    <div class='#{gz.Css \col-md-12}'>
    </div>"

    btn-accept = @el.query ".#{gz.Css \btn-success}"

    btn-accept.on-click @on-accept

    _dto-anexo2 = @model._attributes


    @load-header _dto-anexo2

    $ @el._last ._append '<h4>DATOS DE IDENTIFICACIÓN DE LAS PERSONAS
                          \ QUE SOLICITA O FISICAMENTE REALIZA LA OPERACIÓN
                          \ EN REPRESENTACIÓN DEL CLIENTE DEL SUJETO OBLIGADO
                          (DECLARANTE).</h4>'

    @load-list-declarant _dto-anexo2.'declaration'.'customer'.'declarants'

    @_type = @check-commodity _dto-anexo2.'regime'.'name'
    if @_type

      $ @el._last ._append '<h4>DATOS DE IDENTIFICACIÓN DE LAS PERSONAS
                          \ EN CUYOS NOMBRES SE REALIZA LA OPERACIÓN
                          \ ORDENANTES/PROVEEDOR EXTRANJERO (INGRESO DE
                          \ MERCANCÍA)/ EXPORTADOR(SALIDA DE MERCANCÍA)</h4>'

      @load-list-stakeholder _dto-anexo2.'stakeholders'

      $ @el._last ._append '<h4>DATOS DE IDENTIFICACIÓN DE LAS PERSONAS A FAVOR
                          \ DE QUIENES SE REALIZA LA OPERACIÓN: IMPORTADOR
                          \ (INGRESO DE MERCANCÍA)/DESTINATARIO DEL EMBARQUE
                          \ (SALIDA DE MERCANCÍA)</h4>'

      @load-list-customer _dto-anexo2, 'Importador', off

      console.log 'Entrada de mercaderia'

    else

      $ @el._last ._append '<h4>DATOS DE IDENTIFICACIÓN DE LAS PERSONAS
                          \ EN CUYOS NOMBRES SE REALIZA LA OPERACIÓN
                          \ ORDENANTES/PROVEEDOR EXTRANJERO (INGRESO DE
                          \ MERCANCÍA)/ EXPORTADOR(SALIDA DE MERCANCÍA)</h4>'

      @load-list-customer _dto-anexo2, 'Exportador'

      $ @el._last ._append '<h4>DATOS DE IDENTIFICACIÓN DE LAS PERSONAS A FAVOR
                          \ DE QUIENES SE REALIZA LA OPERACIÓN: IMPORTADOR
                          \ (INGRESO DE MERCANCÍA)/DESTINATARIO DEL EMBARQUE
                          \ (SALIDA DE MERCANCÍA)</h4>'

      @load-list-stakeholder _dto-anexo2.'stakeholders', off

      console.log 'Salida de mercaderia'


    $ @el._last ._append '<h4>DATOS DE IDENTIFICACIÓN DEL TERCERO POR
                        \ CUYO INTERMEDIO SE REALIZA LA OPERACIÓN, DE
                        \ SER EL CASO.</h4>'

    @load-list-third _dto-anexo2.'declaration'.'third'

    $ @el._last ._append '<h4>DATOS RELACIONADOS A LA DESCRIPCIÓN DE LA
                        \ OPERACIÓN</h4>'
    @load-list-operation _dto-anexo2

    super!

  _type: null


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
      'Aduana'
      'Orden N&ordm;'
      'Régimen'
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
                                    max-width:27ch'

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
                      _column-cell-style: _column-cell-style
                      on-dblclick-row: (evt) ~>
                        @_desktop.load-next-page OperationEdit, do
                          model: evt._target._model

        _table-pending.set-rows _pending

        _table-accepting = new Table do
                      _attributes: _attributes
                      _labels: _labels
                      _templates: _template-accepting
                      _column-cell-style: _column-cell-style

        _table-accepting.set-rows _accepting

        @$el._append '<h4>Lista de despachos pendientes</h4>'
        @el._append _table-pending.render!.el

        @$el._append "<div class='#{gz.Css \col-md-12}'
                           style='margin-bottom:20px'>
                        <hr>
                      </div>"

        @$el._append '<h4>Lista de despachos aceptados</h4>'
        @el._append _table-accepting.render!.el
      _error: ->
        alert 'Error!!! NumerationP list'



    super!


  /** @protected */ @@_caption = 'ANEXO 2'
  /** @protected */ @@_icon    = gz.Css \flash
  /** @protected */ @@_hash  = 'ANEXO2-HASH'


/** @export */
module.exports = Operations


/* vim: ts=2 sw=2 sts=2 et: */
