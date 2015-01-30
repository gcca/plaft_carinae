/**
 * @module modules
 * @author gcca@gcca.tk (cristHian Gz. <gcca>)
 */

/**
 * 2 - 9 - 1 - 8 - 7 - 6 - 3
 */


Module = require '../../workspace/module'
Customer = require '../../customer'

FieldType = App.builtins.Types.Field

DOCUMENT_TYPE_PAIR = App.lists.document-type._pair


class IncomeModel extends App.Model

  urlRoot: 'dispatch/income'

  defaults:
    'dispatch':
      'linked': []
    'customer': {}

class Base-se-se extends App.View

  /** @override */
  _tagName: \form

#  search-by: ~>
#   query = @el._first._first._value

   #@load-form!

  on-selected: (evt, _params) ~>
    App.ajax._get ('/api/stakeholder/' + _params._id), null, do
      _success: (stakeholder-dto) ~>
        @load-form stakeholder-dto'customer_type'.0.to-lower-case!
        App._form._fromJSON @el, stakeholder-dto

  new-item: ~>
    if @_both
      _radio = @el.query-all 'input[type=radio]'

      (@load-form _radio.0._value; return) if _radio.0._checked
      (@load-form _radio.1._value; return) if _radio.1._checked

      alert 'ERROR: 546FFS87-02VM'
    else
      @load-form!

  /** @override */
  render: ->

    if @model and @model\customer_type
      @load-form if @model\customer_type is 'Jurídica' then 'j' else 'n'
      @el._fromJSON @model
      return super!

#        <button type='button' class='#{gz.Css \btn} #{gz.Css \btn-info}'>
#          Buscar
#        </button>
    @el.html = "
      <div class='#{gz.Css \form-group} #{gz.Css \col-md-6}'>
        <input type='text' class='#{gz.Css \form-control}'
            placeholder='Buscar'>
      </div>
      <div class='#{gz.Css \form-group} #{gz.Css \col-md-6}'
          style='margin-left:-24px'>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <button type='button' class='#{gz.Css \btn} #{gz.Css \btn-default}'>
          Nuevo
        </button>
      </div>"

    @el._last
#      .._first.on-click @search-by
      .._last.on-click @new-item

    if @_both
      App.dom._new \span
        ..html = "
          &nbsp;&nbsp;&nbsp;&nbsp;
          <div class='#{gz.Css \radio-inline}'>
            <label>
              <input type='radio' value='j' checked>
              Jurídico
            </label>
          </div>
          <div class='#{gz.Css \radio-inline}'>
            <label>
              <input type='radio' value='n'>
              Natural
            </label>
          </div>"
        @el._last._append ..

    (new App.widget.Typeahead do
      el: @el._first._first
      _source:
        _display: App.widget.Typeahead.Source.kDisplay
        _tokens: App.widget.Typeahead.Source.kTokens
      _limit: 9
      _collection: [{
        _name: stk\d, \
        _code: '<span style="color:#555;font-size:9px">...</span>', \
        _id: stk\n, \
        _display: stk\d, \
        _tokens: stk\d} \
        for stk in window'plaft'\stakeholders]
      _template: (p) -> "
        <p style='float:right;font-style:italic;margin-left:1em'>
          #{p._code}</p>
        <p style='font-size:14px;text-align:justify'>#{p._name}</p>")
      ..on-selected @on-selected
      ..render!

    super!


  /** @protected */ _both: true



class Declarant extends Base-se-se

  load-form: ->
    @el.html = ''

    App.builder.Form._new @el, _FIELDS
      .._class gz.Css \col-md-6
      ..render!
      .._free!

  render: ->
    r = super!

    # Check if exists declarant
    # TODO: Improve code to check
    if @model and @model\document
      @load-form!
      @el._fromJSON @model

    r

  /** @protected */ _both: false

  _FIELDS =
    * _name: 'represents_to'
      _label: '9) PSOFRO actúa en representación:'
      _type: FieldType.kComboBox
      _options:
        'Ordenante'
        'Beneficiario'

    * _name: 'residence_status'
      _label: '10) Condición de residencia: PSOFRO'
      _type: FieldType.kComboBox
      _options:
        'Residente'
        'No residente'

    * _name: 'document[type]'
      _label: '11) Tipo de documento de la PSOFRO'
      _type: FieldType.kComboBox
      _options: DOCUMENT_TYPE_PAIR

    * _name: 'document[number]'
      _label: '12) N&ordm; de documento PSOFRO'

    * _name: 'issuance_country'
      _label: '13) País de emisión del documento PSOFRO'

    * _name: 'father_name'
      _label: '14) Apellido paterno PSOFRO'

    * _name: 'mother_name'
      _label: '15) Apellido materno PSOFRO'

    * _name: 'name'
      _label: '16) Nombres PSOFRO'

    * _name: 'nationality'
      _label: '17) Nacionalidad PSOFRO'

    * _name: 'activity'
      _label: '18) Ocupación, oficio o profesión PSOFRO'
      _type: FieldType.kComboBox
      _options: App.lists.activity._display

    * _name: 'activity_description'
      _label: '19) Descripcion de la ocupación "Otros"'

    * _name: 'activity_CIIU'
      _label: '20) Código CIIU de la ocupación de la PSOFRO'
      _type: FieldType.kComboBox
      _options: App.lists.ciiu._display

    * _name: 'position'
      _label: '21) Cargo de la PSOFRO'

    * _name: 'address'
      _label: '22) Nombre y N° de la vía de la dirección PSOFRO'

    * _name: 'ubigeo'
      _label: '23) Código UBIGEO del PSOFRO'

    * _name: 'phone'
      _label: '24) Teléfono de la PSOFRO'



class Stakeholder extends Base-se-se

  load-form: ->
    @el.html = ''

    _fields = if it is \j then _FIELDS_BUSINESS else _FIELDS_PERSON

    App.builder.Form._new @el, _fields
      .._class gz.Css \col-md-6
      ..render!
      .._free!

    @$el._append "<div class='#{gz.Css \col-md-12}'><hr></div>"

  _FIELDS_BUSINESS =
    * _name: 'link_type'
      _label: 'Tipo de vinculación'
      _type: FieldType.kComboBox
      _options:
        'Proveedor'
        'Destinatario'

    * _name: 'customer_type'
      _label: 'Tipo de persona'
      _type: FieldType.kComboBox
      _options: <[ Jurídica ]>

    * _name: 'name'
      _label: 'Razon social'

    * _name: 'social_object'
      _label: 'Objeto social'

    * _name: 'address'
      _label: 'Nombre y N° via direccion'

    * _name: 'phone'
      _label: 'Teléfono de la persona en cuyo nombre'

    * _name: 'country'
      _label: 'País origen o destino (según el caso)'

#      * _name: 'country'
#        _label: 'Pais origen (solo vincu=1=prov)'

#      * _name: 'name'
#        _label: 'Pais destino (solo vinc=3=Dest Emb)'

  _FIELDS_PERSON =
    * _name: 'link_type'
      _label: 'Tipo de vinculación'
      _type: FieldType.kComboBox
      _options:
        'Proveedor'
        'Destinatario'

    * _name: 'customer_type'
      _label: 'Tipo de persona'
      _type: FieldType.kComboBox
      _options: <[ Natural ]>

    * _name: 'document[type]'
      _label: 'Tipo de documento de identidad'
      _type: FieldType.kComboBox
      _options: DOCUMENT_TYPE_PAIR

    * _name: 'document[number]'
      _label: 'Número de documento de identidad'

    * _name: 'residence_status'
      _label: 'Condición de residencia'
      _type: FieldType.kComboBox
      _options:
        'Residente'
        'No residente'

    * _name: 'issuance_country'
      _label: 'País de emisión del documento'

    * _name: 'is_pep'
      _label: '¿La persona es PEP?'
      _type: FieldType.kCheckbox

    * _name: 'pep_position'
      _label: 'Si es PEP, indicar cargo público'

    * _name: 'father_name'
      _label: 'Apellido paterno'

    * _name: 'mother_name'
      _label: 'Apellido materno'

    * _name: 'name'
      _label: 'Nombres'

    * _name: 'nationality'
      _label: 'Nacionalidad'

    * _name: 'birthday'
      _label: 'Fecha de nacimiento'

    * _name: 'activity'
      _label: 'Ocupación, oficio o profesión'

    * _name: 'activity_description'
      _label: 'Descripcion de la ocupación (en caso de "Otros")'

    * _name: 'employer'
      _label: 'Empleador (en caso de ser dependiente)'

    * _name: 'average_monthly_income'
      _label: 'Ingresos promedios mensuales'

    * _name: 'position'
      _label: 'Cargo (si aplica)'

    * _name: 'address'
      _label: 'Nombre y N° de la vía dirección'

    * _name: 'phone'
      _label: 'Teléfono de la persona operación'


class Stakeholders extends App.View

  /** @override */
  _tagName: \div

  _toJSON: -> [.._toJSON! for @el.query-all \form]

  add-stakeholder: (dto) ~>
    new Stakeholder model: dto
      @_container._append ..render!.el
      ..$el._append "<div class='#{gz.Css \col-md-12}'><hr></div>"

  /** @override */
  render: ->

    @el.html = "
      <div class='#{gz.Css \col-md-12}'></div>
      <button type='button' class='#{gz.Css \btn} #{gz.Css \btn-default}'
          style='margin-left:15px'>
        Agregar
      </button>
      <br><br>"

    @_container = @el._first
    @el._first._next.on-click @add-stakeholder

    if @collection._length
      for dto in @collection
        @add-stakeholder dto
    else
      @add-stakeholder!

    super!

  /** @private */ stakeholders: null
  /** @private */ _container: null


/**
 *
 */
class Declaration extends App.View

  /** @override */
  _tagName: \form

  /** @override */
  render: ->
    App.builder.Form._new @el, _FIELDS
      .._class gz.Css \col-md-6
      ..render!
    super!



/** -------------
 *  CodeNameField
 *  -------------
 * Widget field to manage relation between name and code text.
 * TODO(...): Move to internal-module app widgets.
 * @class UiCodeNameField
 * @extends View
 */
class CodeNameField extends App.View

#class
#    (new App.widget.Typeahead do
#      el: @el.query '[name=jurisdiction]'
#      _source:
#        _display: App.widget.Typeahead.Source.kDisplay
#        _tokens: App.widget.Typeahead.Source.kTokens
#      _limit: 9
#      _collection: [{
#        _name: _n, \
#        _code: "<span style='color:#555;font-size:10pt'>#_c</span>", \
#        _id: _c, \
#        _display: _n, \
#        _tokens: _n} \
#        for _c, _n of JURISDICTION_PAIR]
#      _template: (p) -> "
#        <p style='float:right;font-style:italic;margin-left:1em'>
#          #{p._code}</p>
#        <p style='font-size:14px;text-align:justify'>#{p._name}</p>")
#      ..render!
  /** @override */

  _tagName: \div

  /** @override */
  _className: "#{gz.Css \input-group} #{gz.Css \field-codename}"

  /**
   * (Event) On change input value.
   * @param {Object} evt
   * @private
   */
  changeCode: (evt) ~> @_span.html = @_hidden._value

  /**
   * (Event) On change cursor for name.
   * @param {Event} _
   * @param {Object} _data Same data from collection.
   * @private
   */
  changeName: (_, _data) ~>
    @_span.html = _data._code
    @_hidden._value = _data._code

  /**
   * (Event) On change value from number.
   * @private
   */
  changeValue: ~>
    _value = @_input._value
    if _value._match /\d+/
      i = @_code._index _value
      if i is -1
        @_input._value = 'Código inválido'
        @_span.html = '000'
        @_hidden._value = '000'
      else
        @_input._value = @_name[i]
        @_span.html = _value
        @_hidden._value = _value
    else
      _code = @_code[@_name._index _value]
      @_input._value = _value
      @_span.html = _code
      @_hidden._value = _code

  /**
   * @param {Object.<Array.<string>, Array.<string>, string>}
   * @override
   */
  initialize: ({@_code, @_name, @_field}) !->

  /** @private */ _field  : null
  /** @private */ _code   : null
  /** @private */ _name   : null
  /** @private */ _input  : null
  /** @private */ _span   : null
  /** @private */ _hdiden : null

  /** @override */
  render: ->
    @_input = App.dom._new \input
      .._type = \text
      .._name = "#{@_field}[name]"
      .._class = gz.Css \form-control

    @_span = App.dom._new \span
      .._class = gz.Css \input-group-addon
      ..html = '000'

    @_hidden = App.dom._new \input
      .._type = \hidden
      .._name = "#{@_field}[code]"

    # Hack
    Object._properties @_hidden, do
      _value:
        get: -> @value
        set: (a) ->  @value = a ; $ @ .trigger \change

    @el._append @_hidden
    @el._append @_input
    @el._append @_span

    (new App.widget.Typeahead do
      el          : @_input
      _source     :
        _display : App.widget.Typeahead.Source.kDisplay
        _tokens  : App.widget.Typeahead.Source.kTokens
      _limit      : 10
      _collection : [{
        _name    : n, \
        _code    : c, \
        _display : n, \
        _tokens  : n + ' ' + c } \
        for [n, c] in _.zip @_name, @_code]
      _template   : (p) -> "
        <p style='float:right;font-style:italic;margin-left:1em'>#{p._code}</p>
        <p style='font-size:14px;text-align:justify'>#{p._name}</p>")
      ..onCursorChanged @changeName
      ..onClosed @changeValue
      ..render!
    @_hidden.onChange @changeCode

    super!



/**
 * Dispatch
 * --------
 * Dispatch section
 * @class Dispatch
 * @extends View
 */
class Dispatch extends App.View

  /** @override */
  _tagName: \form

  /** @override */
  initialize: ({@dispatch}) ->

  /** @override */
  render: ->
    @el.html = ''  # TODO: remove, enable clean on init.


    /** Field list for dispatch form. (Array.<FieldOptions>) */
    _FIELDS =
      * _name: 'reference'
        _label: 'Ref. cliente'

      * _name: 'jurisdiction'
        _label: 'Aduana despacho/Jurisdicción'
        _type: FieldType.kView
        _options : new CodeNameField do
                     _code : App.lists.jurisdiction._code
                     _name : App.lists.jurisdiction._display
                     _field : 'jurisdiction'

      * _name: 'order'
        _label: 'N&ordm; Orden despacho'

      * _name: 'income_date'
        _label: 'Fecha ingreso orden despacho'

      * _name: 'regime'
        _label: 'Régimen aduanero'
        _type: FieldType.kView
        _options : new CodeNameField do
                     _code : App.lists.regime._code
                     _name : App.lists.regime._display
                     _field : 'regime'

      * _name: 'description'
        _label: 'Descripción de la mercancía'

      * _name: 'third'
        _label: 'Identificación del tercero, de ser el caso'



    App.builder.Form._new @el, _FIELDS
      .._class gz.Css \col-md-6
      ..render!
      .._free!

    @el._fromJSON @dispatch

    super!

/**
 * Income
 * ------
 * @class Income
 * @extends Module
 */
class Income extends Module

  /** @override */
  _id: gz.Css \id-income

  /** @override */
  _className: gz.Css \panel-group

  /** @override */
  _free: ->
    @ui-customer._free! if @ui-customer?
    @ui-dispatch._free! if @ui-dispatch?
    super!

  /**
   * On search event.
   * @param {string} query
   * @param {string} _type
   * @override
   * @protected
   */
  on-search: (query, _type) ~>

#    if /^\d+$/ is query
#      dto = \document : \number : query
#    else
#      dto = \order : query


#    @income-model = new IncomeModel dto
#    @income-model = new IncomeModel \query : query
#    @income-model._fetch do
#      _success: ~>
#        @render-income!

#      _error: ~>
#          alert 'No existe el despacho-cliente'

    _dto = \query : query

    _dto\by = _type if _type?

    App.ajax._get '/api/dispatch/income', _dto, do
      _success: (income-dto) ~>
        @income-model = new IncomeModel income-dto
        @render-income!
        if income-dto\id
          @customer-heading @ui-panel-customer, income-dto\id
      _not-found: (e) ~>
        if _type?
          alert e.'responseJSON'.\e
        else
          @load-main-form query

#    if /^\d+$/ is query
#      App.ajax._get '/api/customer/by_document', (\number : query), do
#        _success: (customer-dto) ~>
#          customer = new App.model.Customer customer-dto
#          @render-income customer
#        _not-found: ->
#          alert 'No existe el cliente'
#    else
#      App.ajax._get '/api/dispatch/find', (\order : query), do
#        _success: (dispatch-dto) ~>
#          customer = new App.model.Customer dispatch-dto'declaration'\customer
#          @render-income customer
#          App._form._fromJSON @ui-dispatch.el, dispatch-dto
#        _not-found: ->
#          alert 'No existe el despacho'

  /**
   * Load income form basic dto.
   * @param {?string} _query
   * @private
   */
  load-main-form: (_query) ->
    dto =
      'customer':
        'document':
          'number': _query
    @income-model = new IncomeModel dto
    @render-income!

  /**
   * On save event.
   * @override
   * @protected
   */
  on-save: ~>
    dto =
      \customer : @ui-customer.el._toJSON!
      \dispatch : @ui-dispatch.el._toJSON!

    # TODO: Improve hidden shareholders attribute. Override _toJSON
    dto.'customer'.\shareholders = @ui-customer._shareholders._view._toJSON!

    # TODO: Idem above
    dto.'dispatch'.\linked = @ui-stakeholders._toJSON!

    # TODO: Idem above
    dto.'dispatch'.\declarant = @ui-declarant.el._toJSON!

    @income-model._save dto, do
      _success: (income-model) ~>
        @customer-heading @ui-panel-customer, (income-model._get \id)
        alert 'Guardado'
      _error: ->
        console.log 'Error: 869171b8-3f8e-11e4-a98f-88252caeb7e8'

  /**
   * Add new form panel.
   * @param {HTMLElement} _el Element to be added.
   * @param {string} _title
   * @param {string} _sid Name ID to identify panel-content.
   * @param {boolean} _in First panel to show.
   * @param {function(HTMLDivElement)} heading-callback
   * @return HTMLElement
   * @private
   * @see render-register
   */
  add-panel: (_el, _title, _sid, _in, heading-callback) ->
    App.dom._new \div
      .._class = "#{gz.Css \panel} #{gz.Css \panel-default}"
      ..html = "
        <div class='#{gz.Css \panel-heading}'>
          <h4 class='#{gz.Css \panel-title}' style='display:inline'>
            <a data-toggle='#{gz.Css \collapse}'
                data-parent='##{gz.Css \id-income}'
                href='##{gz.Css \id-collapse}-#_sid'>
              #_title
            </a>
          </h4>
        </div>
        <div id='#{gz.Css \id-collapse}-#_sid'
            class='#{gz.Css \panel-collapse}
                 \ #{gz.Css \collapse}
                   #{if _in then ' ' + (gz.Css \in) else ''}'>
          <div class='#{gz.Css \panel-body}'></div>
        </div>"
      .._last._first._append _el
      @el._append ..
      #if heading-callback then heading-callback ..

  /**
   * Sync typeahead completion with panel overflow.
   * @private
   */
  trick-typeahead: ->
    @$ ".#{gz.Css \tt-input}"  # Hack to panel and typeahead
      ..on \focus (evt) ->
        $ evt._target .parents ".#{gz.Css \panel-default}"
          .css \overflow \visible
      ..on \blur (evt) ->
        $ evt._target .parents ".#{gz.Css \panel-default}"
          .css \overflow \hidden

  /**
   * Customer heading callback.
   * @param {HTMLDivElement}
   * @param {number}
   * @see render-income
   * @private
   */
  customer-heading: (_panel, _id) ->
    $ _panel._first ._append "
      <span>
        <a class='#{gz.Css \btn}
                \ #{gz.Css \btn-info}
                \ #{gz.Css \pull-right}'
                href='/pdf/#_id'
                target='_blank'>
          PDF <i class='#{gz.Css \glyphicon}
                      \ #{gz.Css \glyphicon-bookmark}'></i>
        </a>
      </span>"

#    App.dom._new \button
#      .._class = "#{gz.Css \btn} #{gz.Css \btn-info} #{gz.Css \pull-right}"
#      ..html = "PDF <i class='#{gz.Css \glyphicon}
#                            \ #{gz.Css \glyphicon-bookmark}'></i>"
#      _panel._first._append ..

  /**
   * Show forms for customer, dispatch and stakeholders.
   * @param {Model} customer-model
   * @private
   */
  #render-income: (customer-model) ->
  render-income: ->
    @clean!

    customer = new App.model.Customer @income-model._attributes\customer
    # dispatch = new App.model.Dispatch @income-model._attributes\dispatch
    @ui-customer = Customer._new customer: customer

    @ui-dispatch = Dispatch._new dispatch: @income-model._attributes\dispatch

    @ui-stakeholders = Stakeholders._new do
      collection: @income-model._attributes.'dispatch'.\linked

    @ui-declarant = new Declarant do
      model: @income-model._attributes.'dispatch'\declarant

    @ui-panel-customer = @add-panel(@ui-customer.render!.el,
               'Declaración Jurada - Anexo 5',
               (gz.Css \one),
               on,
               @customer-heading)
    @add-panel(@ui-dispatch.render!.el, 'Operación', (gz.Css \two), on)
    @add-panel(@ui-stakeholders.render!.el, 'Vinculado', (gz.Css \three), on)
    @add-panel(@ui-declarant.render!.el,
               "Datos de identificación de las personas que solicita
                \ o físicamente realiza la operación en representación
                \ del cliente del sujeto obligado (DECLARANTE)
                <br><br>
                <span style='font-size:10pt'>PSOFRO = Persona que solicita o físicamente realiza
                \ la operación.</span>",
               (gz.Css \four), on)

    @trick-typeahead!

  /**
   * Actions to do.
   * @private
   */
  start-actions: ->

    show-form = (_type, _caption) ~>
      _id_back = App.utils.uid 'b'
      _id_into = App.utils.uid 'b'

      @el.html = "
        <div class='#{gz.Css \col-md-12}'>

          <div class='#{gz.Css \col-md-12}'
              style='margin-bottom:1em'>
            Ingrese #_caption
          </div>

          <form style='padding-left:15px' class='#{gz.Css \col-md-12}'>
            <div class='#{gz.Css \input-group} #{gz.Css \col-md-7}'
                style='margin-bottom:1em'>
              <input type='text' class='#{gz.Css \form-control}'>
              <div class='#{gz.Css \input-group-btn}'>
                <button class='#{gz.Css \btn} #{gz.Css \btn-default}'
                    style='border-top-right-radius:4px;
                           border-bottom-right-radius:4px'>
                  Buscar
                  &nbsp;&nbsp;
                  <i class='#{gz.Css \glyphicon}
                          \ #{gz.Css \glyphicon-search}'></i>
                </button>
              </div>
            </div>
            <div class='#{gz.Css \input-group} #{gz.Css \col-md-7}'>
              <button type='button' class='#{gz.Css \btn}
                                         \ #{gz.Css \btn-default}'
                  id='#_id_back'
                  style='border-radius:4px;
                         width:7em'>
                Regresar
              </button>
              <button type='button' class='#{gz.Css \btn}
                                         \ #{gz.Css \btn-primary}'
                  id='#_id_into'
                  style='margin-left:3em;
                         border-radius:4px;
                         width:7em'>
                Nuevo
              </button>
            </div>
          </form>
        </div>"

      @el.query \form .on-submit (evt) ~>
        evt.prevent!
        @on-search evt._target._elements.0._value, _type
        @$ "##_id_into" ._show!

      @el.query "##_id_back" .on-click -> _start-form!

      @el.query "##_id_into"
        $ .. ._hide!
        ..on-click ~> @load-main-form (@el.query \form ._elements.0._value)


    _start-form = ~>
      _id1 = App.utils.uid 'b'
      _id2 = App.utils.uid 'b'

      @el.html = "
        <div class='#{gz.Css \col-md-12}'>
          <div class='#{gz.Css \col-md-12}'
              style='margin-bottom:1em'>
            ¿Qué desea hacer?
          </div>
          <div class='#{gz.Css \col-md-12}'>
            <button type='button' class='#{gz.Css \btn} #{gz.Css \btn-default}'
                id='#_id1' style='margin-right:2em'>
              <b>Crear</b> una nueva operación
            </button>
            <button type='button' class='#{gz.Css \btn} #{gz.Css \btn-default}'
                id='#_id2'>
              <b>Editar</b> los datos de una operación
            </button>
          </div>
        </div>"

      # New
      @el.query "##_id1" .on-click ~>
        show-form('document',
          'número del documento de identidad (RUC, DNI, PA, CE, etc.)')

      # Edit
      @el.query "##_id2" .on-click ~>
        show-form('order',
          'número de orden del despacho')

    _start-form!

  /** @override */
  render: ->
    @start-actions!
    super!


  /** @protected */ @@_caption = 'INGRESO DE OPERACIÓN O DESPACHO'
  /** @protected */ @@_icon    = gz.Css \file

  # TODO: This could be removed.
  /** @private */ ui-customer: null
  /** @private */ ui-dispatch: null
  /** @private */ ui-stakeholders: null
  /** @private */ ui-declarant: null
  /** @private */ income-model: null

  # TODO(...): Change implementation, remove this attribute.
  /** @private */ ui-panel-customer: null


/** @export */
module.exports = Income


# vim: ts=2:sw=2:sts=2:et
