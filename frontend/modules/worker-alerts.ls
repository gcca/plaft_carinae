/**
 * @module modules
 * @author gcca@gcca.tk (cristHian Gz. <gcca>)
 */

Module = require '../workspace/module'


class Worker extends App.Model

  urlRoot: \worker


class Workers extends App.Collection

  model: Worker
  urlRoot: \worker


class WorkerInfo extends App.View

  /** @override */
  _tagName: \form

  /** @override */
  _className: gz.Css \form-horizontal

  /** @override */
  render: (@model) ->
    @el.html = "
      <div class='#{gz.Css \form-group}'>
        <label class='#{gz.Css \control-label} #{gz.Css \col-sm-4}'>
          Nombre
        </label>
        <div class='#{gz.Css \col-sm-8}'>
          <input type='text' class='#{gz.Css \form-control}'
                 name='name'>
        </div>
      </div>

      <div class='#{gz.Css \form-group}'>
        <label class='#{gz.Css \control-label} #{gz.Css \col-sm-4}'>
          Número de documento
        </label>
        <div class='#{gz.Css \col-sm-8}'>
          <input type='text' class='#{gz.Css \form-control}'
                 name='document_number'>
        </div>
      </div>

      <div class='#{gz.Css \form-group}'>
        <label class='#{gz.Css \control-label} #{gz.Css \col-sm-4}'>
          Tipo de documento
        </label>
        <div class='#{gz.Css \col-sm-8}'>
          <select name='document_type' class='#{gz.Css \form-control}'>
            <option>RUC</option>
            <option>DNI</option>
            <option>PA</option>
            <option>CE</option>
          </select>
        </div>
      </div>
    "

    @el._fromJSON @model._attributes
    super!


class WorkerItem extends App.View

  _tagName: \li

  _className: "#{gz.Css \col-sm-12} #{gz.Css \parent-toggle}"

  initialize: ->
    super!
    @el.css = 'border: 1px solid #bbb;
               border-radius: 4px;
               padding: 6px 0 6px 4px;
               margin-bottom: 6px;'

  render: (@model) ->
    @el.html = "
      <div class='#{gz.Css \col-sm-9}'>
        #{@model._get \name}
      </div>
      <div class='#{gz.Css \col-sm-3} #{gz.Css \toggle}'
           style='padding-right:0'>
        <i style='float:right;
                  cursor:pointer'
           class='#{gz.Css \glyphicon}
                \ #{gz.Css \glyphicon-remove}'>&nbsp;</i>
        <i style='float:right;
                  cursor:pointer'
           class='#{gz.Css \glyphicon}
                \ #{gz.Css \glyphicon-edit}'>&nbsp;</i>
        <i style='float:right;
                  cursor:pointer'
           class='#{gz.Css \glyphicon}
                \ #{gz.Css \glyphicon-check}'>&nbsp;</i>
      </div>
    "

    @el.query ".#{gz.Css \glyphicon-edit}" .on-click ~>
      worker-info = new WorkerInfo
      _modal = new App.widget.message-box.MessageBox do
        _title: 'Editar información de trabajador'
        _body: worker-info.render(@model).el
        _role: App.widget.message-box.MessageBox.ROLE.kAcceptCancel
        _callback: (is-accept) ~>
          if is-accept
            dto = worker-info.el._toJSON!
            @model._save dto, do
              _success: (worker) ~>
                @render worker
              _error: ->
                alert 'ERROR: e00241d6-6793-11e5-89f3-001d7d7379f5'
      _modal._show!

    @el.query ".#{gz.Css \glyphicon-check}" .on-click ~>
      _alerts = [
      'El estilo de vida del trabajador no corresponde a sus ingresos o existe un cambio notable e inesperado en su situación económica.'
      'El trabajador utiliza su domicilio personal o el de un tercero, para recibir documentación de los clientes del sujeto obligado, sin la autorización respectiva.'
      'El domicilio del trabajador consta en operaciones realizadas en la oficina en la que trabaja, en forma reiterada y/o por montos significativos, sin vinculación aparente de aquel con el cliente.'
      'Se presenta un crecimiento inusual o repentino del número de operaciones que se encuentran a cargo del trabajador.'
      'Se comprueba que el trabajador no ha comunicado o ha ocultado al oficial de cumplimiento del sujeto obligado, información relativa al cambio de comportamiento de algún cliente.'
      'El trabajador se niega a actualizar la información sobre sus antecedentes personales, laborales y patrimoniales o se verifica que ha falseado información.'
      'El trabajador está involucrado en organizaciones cuyos objetivos han quedado debidamente demostrados que se encuentran relacionados con la ideología, reclamos, demandas o financiamiento de una organización terrorista nacional o extranjera, siempre que ello sea debidamente demostrado.'
      ]
      th = [
        "<table class='#{gz.Css \table}'>"
        '<thead><th>N</th><th>Descripción</th></thead>'
        '<tbody>'
      ]

      n = 1
      for _text in _alerts
        th._push "
          <tr>
            <td>#n</td>
            <td>#_text</td>
            <td><input type='checkbox'></td>
          </tr>
        "
        n++
      th._push '</tbody></table>'

      _modal = new App.widget.message-box.Modal do
        _title: 'Editar información de trabajador'
        _body: th._join ''
      _modal._show!

    super!


class WorkerList extends App.View

  _tagName: \ul

  _className: gz.Css \col-md-6

  _add: (worker) ->
    new WorkerItem
      @el._append (..render worker).el

  initialize: ->
    super!
    @el.css = 'padding:4px 12px;
               list-style-type:none;'

  render: ->
    super!


class WorkerAlerts extends Module

  /** @override */
  render: ->
    @el.html = "
      <div class='#{gz.Css \col-md-12}'>
        <button type='button'
                class='#{gz.Css \btn}
                     \ #{gz.Css \btn-default}'>
          Agregar
        </button>
      </div>
    "

    @el._first._first.on-click ~>
      worker-info = new WorkerInfo
      _modal = new App.widget.message-box.MessageBox do
        _title: 'Editar información de trabajador'
        _body: worker-info.render(new Worker).el
        _role: App.widget.message-box.MessageBox.ROLE.kAcceptCancel
        _callback: (is-accept) ~>
          if is-accept
            dto = worker-info.el._toJSON!
            worker-info.model._save dto, do
              _success: (worker) ->
                workers._add worker
              _error: ->
                alert 'ERROR: e00241d6-6793-11e5-89f3-001d7d7379f5'
      _modal._show!

    worker-list = new WorkerList
    @el._append worker-list.render!.el

    workers = new Workers
    workers._bind \add (worker) ->
      worker-list._add worker
    workers._fetch do
      _error: -> alert 'ERROR: b9963032-6790-11e5-89f3-001d7d7379f5'

    super!


  /** @protected */ @@_caption = 'CONOCIMIENTO DEL TRABAJOR'
  /** @protected */ @@_icon    = gz.Css \road
  /** @protected */ @@_hash    = 'auth-hash-worker-alerts'


/** @export */
module.exports = WorkerAlerts


/* vim: ts=2 sw=2 sts=2 et: */
