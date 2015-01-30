/**
 * Admin module manage user creation.
 * @module admin
 * TODO(...): merge on-save.
 */

App = require './app'


class Employee extends App.Model

  /** @override */
  urlRoot: \employee


class EmployeeItem extends App.View

  /** @override */
  _tagName: \div

  /** @override */
  _className: gz.Css \list-group-item

  /**
   * (Event) Save officer data.
   * @private
   */
  on-save: ~>
    dto = @el._last._toJSON!

    delete! dto\password if dto\password is ''

    @model._save dto, do
      _success: ->
        console.log &
      _error: ->
        console.log \error
        console.log \help

  /** @override */
  initialize: ({@customs}) ->
    @model._parent = @customs

  /** @override */
  render: ->
    @el.html = "
      <span class='#{gz.Css \list-group-item-heading}'>
        <span style='font-size:16pt'>
          &nbsp;
        </span>
        <button type='button' class='#{gz.Css \btn}
                                   \ #{gz.Css \btn-default}
                                   \ #{gz.Css \pull-right}'>
          Guardar
        </button>
      </span>
      <form class='#{gz.Css \list-group-item-text}'></form>"


    @el._first._last.on-click @on-save

    _form = @el._last

    App.builder.Form._new _form, _FIELDS
      #.._class gz.Css \col-md-6
      ..render!
      .._free!

    App._form._fromJSON _form, @model._attributes

    super!


  _FIELDS =
    * _name: 'username'
      _label: 'Correo electrónico'

    * _name: 'name'
      _label: 'Nombre'

    * _name: 'password'
      _label: 'Contraseña'



class EmployeeList extends App.View

  /** @override */
  _tagName: \div

  /** @override */
  _className: gz.Css \list-group

  /**
   * Add employee to list.
   * @param {Object} dto Employee data.
   * @private
   */
  _add: (dto) ->
    new EmployeeItem model: (new Employee dto), customs: @customs
      @_container._append ..render!.el

  /** @override */
  initialize: ({@customs}) ->

  /** @override */
  render: ->
    @el.html = "
      <h4>Oficial asistente</h4>
      <div></div>
      <button type='button' class='#{gz.Css \btn} #{gz.Css \btn-default}'>
        Agregar
      </button>"
    @_container = @el._first._next
    @el._last.on-click ~> @_add!

    for dto in @customs._attributes\employees
      @_add dto

    super!


  /** @private */ _container: null


class Officer extends App.Model

  urlRoot: \officer


class OfficerItem extends App.View

  /** @override */
  _tagName: \div

  /**
   * (Event) Save officer data.
   * @private
   */
  on-save: ~>
    dto = @el._last._toJSON!

    delete! dto\password if dto\password is ''

    @model.save dto
#    , do
#      _success: ->
#        console.log &
#      _error: ->
#        console.log \error
#        console.log \help

  /** @override */
  initialize: ({@customs}) ->
    @model._parent = @customs

  /** @override */
  render: ->
    @el.html = "
      <span>
        <span style='font-size:16pt'>
          Oficial de cumplimiento
        </span>
        <button type='button' class='#{gz.Css \btn}
                                   \ #{gz.Css \btn-default}
                                   \ #{gz.Css \pull-right}'>
          Guardar
        </button>
      </span>
      <form></form>"

    @el._first._last.on-click @on-save

    _form = @el._last
    App.builder.Form._new _form, _FIELDS
      #.._class gz.Css \col-md-6
      ..render!
      .._free!
    App._form._fromJSON _form, @model._attributes

    super!


  /** @private */ customs: null

  _FIELDS =
    * _name: 'username'
      _label: 'Correo electrónico'

    * _name: 'name'
      _label: 'Nombre'

    * _name: 'code'
      _label: 'Código de UIF'

    * _name: 'password'
      _label: 'Contraseña'



class Customs extends App.Model

  /** @override */
  urlRoot: 'admin/customs'

  defaults:
    \employees : App._void._Array
    \officer : new Object

class CustomsItem extends App.View

  /** @override */
  _tagName: \div

  /** @override */
  _className: "#{gz.Css \panel} #{gz.Css \panel-default}"

  /**
   * (Event) Save officer data.
   * @private
   */
  on-save: ~>
    dto = App._form._toJSON @_form

    delete! dto\password if dto\password is ''

    @model._save dto, do
      _success: ->
        console.log &
      _error: ->
        console.log \error
        console.log \help

  /** @override */
  initialize: ({@_in = false}) ->

  /** @override */
  render: ->
    _sid = ++@@_count
    @el.html = "
      <div class='#{gz.Css \panel-heading}'>
        <h4 class='#{gz.Css \panel-title}' style='display:inline'>
          <a data-toggle='#{gz.Css \collapse}'
              data-parent='##{gz.Css \id-customs-list}'
              href='##{gz.Css \id-collapse}-#_sid'>
            #{@model._attributes.\name}
          </a>
        </h4>
      </div>
      <div id='#{gz.Css \id-collapse}-#_sid'
          class='#{gz.Css \panel-collapse}
               \ #{gz.Css \collapse}
                 #{if @_in then ' ' + (gz.Css \in) else ''}'>
        <div class='#{gz.Css \panel-body}'>
          <span>
            &nbsp;
            <button type='button' class='#{gz.Css \btn}
                                       \ #{gz.Css \btn-default}
                                       \ #{gz.Css \pull-right}'>
              Guardar
            </button>
          </span>
          <form></form>
          <hr>
        </div>
      </div>"

    @_form = @el._last._first._first._next
    App.builder.Form._new @_form, _FIELDS
      #.._class gz.Css \col-md-6
      ..render!
      .._free!
    App._form._fromJSON @_form, @model._attributes

    @el._last._first._first.on-click @on-save

    officer = new Officer @model._attributes\officer
    officer-item = new OfficerItem do
                     model: officer
                     customs: @model
    @el._last._first._append officer-item.render!.el

    App.dom._new \hr
      .._class = gz.Css \col-md-12
      ..css._margin-top = 0
      @el._last._first._append ..

    @el._last._first._append (new EmployeeList customs: @model).render!.el

    super!


  /** @private */ _form: null
  /** @private */ @@_count = 0
  /** @private */ @@_in = 0

  _FIELDS =
    * _name: 'code'
      _label: 'Código de Agencia de Aduana'

    * _name: 'name'
      _label: 'Nombre'




class CustomsList extends App.View

  /** @override */
  _tagName: \div

  /** @override */
  _id: gz.Css \id-customs-list

  /** @override */
  _className: "#{gz.Css \col-md-8} #{gz.Css \panel-group}"

  /**
   * Add new customs to list.
   * @param {Object} dto Customs DTO.
   * @return CustomsItem
   * @private
   */
  _add: (dto) ->
    CustomsItem._new model: (new Customs dto), _in: not dto
      @el._append ..render!.el

  /** @override */
  render: ->
    @el.html = "<button type='button' class='#{gz.Css \btn}
                                           \ #{gz.Css \btn-primary}'>
                  Agregar
                </button>
                <hr>"

    @el._first.on-click ~> @_add!

    for dto in window.'plaft'.\cs
      @_add dto

    super!




/**
 * Admin
 * -----
 * @class Admin
 * @extends View
 */
class Admin extends App.View

  /** @override */
  el: $ \body

  /** @override */
  render: ->
    @el.html = "
      <div class='#{gz.Css \container} #{gz.Css \app-container}'></div>"

    _container = @el._first
    _container._append (new CustomsList).render!.el

    super!


(new Admin).render!


/* vim: ts=2 sw=2 sts=2 et: */
