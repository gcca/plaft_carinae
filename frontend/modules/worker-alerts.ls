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


#############################################################################
# KnowledgeWorker #
###################

class WorkerChecklist extends App.View

  _tagName: \div

  render: ->
    _alerts =
      'El estilo de vida del trabajador no corresponde a sus ingresos
      \ o existe un cambio notable e inesperado en su situación económica.'
      'El trabajador utiliza su domicilio personal o el de un tercero,
      \ para recibir documentación de los clientes del sujeto obligado,
      \ sin la autorización respectiva.'
      'El domicilio del trabajador consta en operaciones realizadas
      \ en la oficina en la que trabaja, en forma reiterada y/o por montos
      \ significativos, sin vinculación aparente de aquel con el cliente.'
      'Se presenta un crecimiento inusual o repentino del número
      \ de operaciones que se encuentran a cargo del trabajador.'
      'Se comprueba que el trabajador no ha comunicado o ha ocultado
      \ al oficial de cumplimiento del sujeto obligado, información relativa
      \ al cambio de comportamiento de algún cliente.'
      'El trabajador se niega a actualizar la información sobre
      \ sus antecedentes personales, laborales y patrimoniales o se verifica
      \ que ha falseado información.'
      'El trabajador está involucrado en organizaciones cuyos objetivos
      \ han quedado debidamente demostrados que se encuentran relacionados
      \ con la ideología, reclamos, demandas o financiamiento
      \ de una organización terrorista nacional o extranjera, siempre que ello
      \ sea debidamente demostrado.'

    th =
      "<table class='#{gz.Css \table}'>"
      '<thead><th>N</th><th>Descripción</th><th>&nbsp;</th></thead>'
      '<tbody>'

    n = 1
    for _text in _alerts
      th._push "
        <tr>
          <td>#n</td>
          <td style='text-align:justify'>#_text</td>
          <td><input type='checkbox'></td>
        </tr>
      "
      n++
    th._push '</tbody></table>'

    @el.html = th._join ''

    super!


class AssessWorker extends App.View

  _tagName: \div

  render-alerts: (knowledge-worker) ->
    @el.html = "
      <div class='#{gz.Css \btn-group}' style='margin-bottom:1em'>
        <button type='button'
                class='#{gz.Css \btn}
                     \ #{gz.Css \btn-default}'>
          Regresar
        </button>
        <button type='button'
                class='#{gz.Css \btn}
                     \ #{gz.Css \btn-primary}'>
          Guardar
        </button>
      </div>
    "

    worker-checklist = new WorkerChecklist
    @el._append worker-checklist.render!.el

    @el._first._first.on-click ~>
      @render-nav!

    @el._first._last.on-click ~>
      knowledge-worker._save do
        ## _success: ~>
        _error: ->
          alert 'ERROR: fb09cd78-6888-11e5-9c31-001d7d7379f5'
      @render-nav!

  render-nav: ->
    @el.html = "
      <button type='button'
              style='margin-bottom:1em'
              class='#{gz.Css \btn}
                   \ #{gz.Css \btn-default}'>
        Agregar
      </button>
      <div class='#{gz.Css \list-group}'></div>
    "

    @el._first.on-click ~>
      class KnowledgeWorker extends App.Model
        urlRoot: "worker/#{worker-id}/knowledge"

      @render-alerts!

    _ul = @el._last
    n = 0
    for knowledge-worker in @collection._models
      _created = knowledge-worker._get \created
      n++
      App.dom._new \a
        _ul._append ..
        ..html = "#n.&nbsp;&nbsp;#_created"
        .._class = gz.Css \list-group-item
        ..on-click ~>
          @render-alerts knowledge-worker

  render: (@collection) ->
    @render-nav!
    super!


#############################################################################

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
    @el.css = 'border: 1px solid #ddd;
               border-radius: 4px;
               padding: 8px 0;
               margin-bottom: 4px;'

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

    @el.query ".#{gz.Css \glyphicon-remove}" .on-click ~>
      @model._destroy do
        _error: ->
          alert 'ERROR: af8f4bfc-67bb-11e5-89f3-001d7d7379f5'

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
      worker-id = @model._id

      class KnowledgeWorker extends App.Model
        urlRoot: "worker/#{worker-id}/knowledge"

      class KnowledgeWorkers extends App.Collection
        urlRoot: "worker/#{worker-id}/knowledge"
        model: KnowledgeWorker

      knowledge-workers = new KnowledgeWorkers
      knowledge-workers._fetch do
        _success: (knowledge-workers) ->
          _modal = new App.widget.message-box.Modal do
            _title: 'Conocimiento del trabajador'
            _body: (new AssessWorker).render(knowledge-workers).el
          _modal._show App.widget.message-box.Modal.CLASS.large
        _error: ->
          alert 'ERROR: 92199648-6858-11e5-9c31-001d7d7379f5'

    super!


class WorkerList extends App.View

  _tagName: \ul

  _className: gz.Css \col-md-6

  _add: (worker) ->
    @collection._add worker

  initialize: (options) ->
    super ...
    @el.css = 'padding:4px 12px;
               list-style-type:none;'

    @collection = new Workers
      .._comparator = (worker) -> worker._attributes.'name'.toUpperCase!

  on-model-change: ~>
    @collection._sort!
    @render!

  on-model-destroy: (worker) ~>
    @collection._remove worker
    @on-model-change!

  render: ->
    @el.html = null
    for worker in @collection._models
      worker-item = new WorkerItem
      @el._append (worker-item.render worker).el
      worker.off 'change:name' @on-model-change
      worker.on 'change:name' @on-model-change
      worker.off 'destroy' @on-model-destroy
      worker.on 'destroy' @on-model-destroy
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

    workers = worker-list.collection

    workers._fetch do
      _success: (workers) ->
        for worker in workers
          worker-list._add worker
        worker-list.render!
      _error: ->
        alert 'ERROR: b9963032-6790-11e5-89f3-001d7d7379f5'

    workers._bind \add (worker) ->
      worker-list._add worker
      worker-list.render!  # Possible bad performance on init re-render

    super!


  /** @protected */ @@_caption = 'CONOCIMIENTO DEL TRABAJOR'
  /** @protected */ @@_icon    = gz.Css \road
  /** @protected */ @@_hash    = 'auth-hash-worker-alerts'


/** @export */
module.exports = WorkerAlerts


/* vim: ts=2 sw=2 sts=2 et: */