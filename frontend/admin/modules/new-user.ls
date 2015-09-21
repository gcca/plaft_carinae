/** @module modules */

Module = require '../../workspace/module'
table = App.widget.table
  Table = ..Table

modal = App.widget.message-box
MessageBox = modal.MessageBox

/**
 * CustomsModel
 * --------
 *
 * @class CustomsModel
 * @extends Model
 */
class CustomsModel extends App.Model

  /** @override */
  urlRoot: 'admin/customs_agency'

/**
 * CollectionCustoms
 * --------
 *
 * @class CollectionCustoms
 * @extends Collection
 */
class CollectionCustoms extends App.Collection

  /** @override */
  model: CustomsModel


/**
 * CustomsItem
 * --------
 *
 * @class CustomsItem
 * @extends Module
 */
class CustomsItem extends Module

  /** @override */
  _tagName: \form

  /** @override */
  on-save: ->
    _dto = @el._toJSON!

    officer = _dto.'officer'

    if (not officer.'password') or (officer.'password' is '')
      delete officer.'password'

    @model._save _dto, do
      _success: ~>
        @model._set _dto
        @_desktop.notifier.notify do
          _message : 'Se ha registrado satisfactoriamente'
          _type    : @_desktop.notifier.kSuccess

  /** @override */
  render: ->
    App.builder.Form._new @el, _FIELD_USER
      ..render!
      .._free!

    @el._fromJSON @model._attributes

    super!


  _FIELD_USER =
    * _name: 'name'
      _label: 'Nombre de Agencia'
      _tip: 'Nombre de la agencia de aduana.'

    * _name: 'document_number'
      _label: 'N RUC'

    * _name: 'address'
      _label: 'Dirección fiscal'

    * _name: 'district'
      _label: 'Distrito'

    * _name: 'province'
      _label: 'Departamento'

    * _name: 'name_contact'
      _label: 'Nombre de la persona de contacto'

    * _name: 'office_contact'
      _label: 'Cargo de la persona de contacto'

    * _name: 'phone'
      _label: 'Teléfono fijo (incluir codigo de la ciudad)'

    * _name: 'mobile'
      _label: 'Teléfono movil'

    * _name: 'email'
      _label: 'Correo Electronico'

    * _name: 'officer[name]'
      _label: 'Nombre de oficial'
      _tip: 'Nombre de oficial de cumplimiento'

    * _name: 'officer[username]'
      _label: 'Usuario de oficial'
      _tip: 'Correo de oficial de cumplimiento'

    * _name: 'officer[password]'
      _label: 'Contraseña'



/**
 * Customs
 * --------
 *
 * @class Customs
 * @extends Module
 */
class Customs extends Module

  /** @override */
  render: ->
    @_desktop._lock!
    @_desktop._spinner-start!

    _labels =
      'Nombre/Razón Social'
      'Dirección'
      'Celular'
      ''

    _attributes =
      'name'
      'address'
      'phone'
      'remove'

    _templates =
      'remove':  (_value, _dto, _attr, _tr) ->
        _span = App.dom._new \span
          .._class = "#{gz.Css \glyphicon}
                    \ #{gz.Css \glyphicon-remove}"
          ..css = 'cursor:pointer;font-size:18px'
          ..on-click ~>
            see-button = (_value) ->
              if _value
                App.ajax._delete "/api/admin/customs_agency/#{_dto.'id'}", do
                  _success: ->
                    $ _tr ._remove!

            message = MessageBox._new do
              _title: 'Eliminación de despacho.'
              _body: '<h5>¿Desea eliminar el cliente?</h5>'
              _callback: see-button
            message._show!

    App.ajax._get '/api/admin/customs_agency', true, do
      _success: (dto) ~>
        _table = new Table do
          _attributes: _attributes
          _labels: _labels
          _templates: _templates
          on-dblclick-row: (evt) ~>
            @_desktop.load-next-page(CustomsItem, do
                                     model: evt._target._model)

        _table.set-rows new CollectionCustoms dto

        @el.html = "<h3 class='#{gz.Css \text-center}'>
                      GESTION DE CLIENTES
                    </h3>"

        new-customs = App.dom._new \button
          ..html = 'Agregar Nuevo Cliente'
          .._class = "#{gz.Css \btn} #{gz.Css \btn-primary}"
          ..on-click ~> @_desktop.load-next-page(CustomsItem, do
                                                 model: new CustomsModel)
          @el._append ..

        @el._append _table.render!.el
        @_desktop._unlock!
        @_desktop._spinner-stop!

    super!

  /** @protected */ @@_caption = 'REGISTRAR USUARIO'
  /** @protected */ @@_icon    = gz.Css \user
  /** @protected */ @@_hash    = 'auth-hash-new-user'

/** @export */
module.exports = Customs

# vim: ts=2:sw=2:sts=2:et
