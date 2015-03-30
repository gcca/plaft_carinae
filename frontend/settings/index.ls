/**
 * @module settings
 * @author gcca@gcca.tk (cristHian Gz. <gcca>)
 */


FieldType = App.builtins.Types.Field

class Employee extends App.Model

  /** @override */
#  urlRoot: "officer/#{window.'plaft'.'cu'.\id}/employee"

class EmployeeItem extends App.View

  /** @override */
  _tagName: \div

  /** @override */
  _className: "#{gz.Css \panel} #{gz.Css \panel-default}"

  /**
   * Local panel identifier for group.
   * @return string
   * @private
   */
  get-local-uid: ->
    "#{App.math._random!}"._substring 2

  /** @override */
  render: ->
    employee-t = @model._attributes
    uid = @get-local-uid!

    @el.html = "
      <div class='#{gz.Css \panel-heading}'>
        <h4 class='#{gz.Css \panel-title}'>
          <a data-toggle='collapse'
              data-parent='##{gz.Css \id-employee-list}'
              href='##uid'>
            #{employee-t\username}
          </a>
          <i class='#{gz.Css \glyphicon}
                  \ #{gz.Css \glyphicon-remove-circle}
                  \ #{gz.Css \pull-right}'></i>
        </h4>
      </div>
      <div id='#uid' class='#{gz.Css \panel-collapse}
                                 \ #{gz.Css \collapse}'>
        <div class='#{gz.Css \panel-body}'><form></form></div>
      </div>"

    _form = @el.query \form

    _fields =
      * _name: 'name'
        _label: 'Nombre'

      * _name: 'rolex'
        _label: 'Rol'
        _type: FieldType.kComboBox
        _options: <[Sectorista Liquidador Financiero ETC]>

    App.builder.Form._new _form, _fields
      ..render!
      .._free!

    App._form._fromJSON _form, employee-t

    super!


class EmployeeList extends App.View

  /** @override */
  _tagName: \div

  /** @override */
  _className: gz.Css \panel-group

  /** @override */
  _id: gz.Css \id-employee-list

  /** @override */
  render: ->
    @el.html = ''

    for dto in window.'plaft'.\us
      employee = new Employee dto
      @el._append (new EmployeeItem model: employee).render!.el

    super!



MODULES = App.MODULES



class Permissions extends App.View

  /** @override */
  _tagName: \table

  /** @override */
  _className: "#{gz.Css \table}
             \ #{gz.Css \table-stripped}
             \ #{gz.Css \table-hover}"

  /** @override */
  render: ->
    @el.html = ''

    t-head = App.dom._new \thead
    t-body = App.dom._new \tbody

    tr-header = App.dom._new \tr
      .._append App.dom._new \th

    for m in MODULES
      App.dom._new \th
        ..html = m._caption
        tr-header._append ..

    for dto in window.'plaft'.\us
      App.dom._new \tr
        ..html = ("<td>#{dto\username}</td>" +
                  '<td>
                    <input type="checkbox" checked>
                   </td>' * MODULES._length)
        t-body._append ..

    t-head._append tr-header
    @el._append t-head
    @el._append t-body

    super!










class Settings extends App.View

  /** @override */
  _tagName: \div

  /** @override */
  render: ->
    @el.html = ''
    @el._append (new EmployeeList).render!.el
    @el._append (new Permissions).render!.el
    super!


/** @export */
module.exports = Settings


# vim: ts=2:sw=2:sts=2:et
