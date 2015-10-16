/**
 * @module modules
 * @author gcca@gcca.tk (cristHian Gz. <gcca>)
 */

Module = require '../workspace-new/module'


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

  selected-codes: ->
    [parse-int .._value for @el.query-all \input when .._checked]

  render: (@model) ->
    console.log @model
    console.log @model._attributes
    _alerts = window.'plaft'.'lists'.'alert_s2'

    enable-ids = [..'info_key' for @model._get \alerts]

    th =
      "<table class='#{gz.Css \table}'>"
      '<thead>
         <th></th>
         <th>N</th>
         <th>Descripción</th>
         <th>&nbsp;</th>
       </thead>'
      '<tbody>'

    for _alert in _alerts
      th._push "
        <tr>
          <td style='text-align:center'>
            #{_alert.'section'}
          </td>
          <td style='text-align:center'>
            #{_alert.'code'}
          </td>
          <td style='text-align:justify'>
            #{_alert.'description'}
          </td>
          <td>
            <input type='checkbox'
                   value='#{_alert.'id'}'
                   #{if _alert.'id' in enable-ids then ' checked' else ''}>
          </td>
        </tr>
      "
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
    @el._append worker-checklist.render(knowledge-worker).el

    @el._first._first.on-click ~>
      @render-nav!

    @el._first._last.on-click ~>
      _dto =
        'alerts': [{ \
          'info_key': .. \
          } for worker-checklist.selected-codes!]
      knowledge-worker._save _dto, do
        ## _success: ~>
        ##   @trigger gz.Css \saved
        _error: ->
          alert 'ERROR: fb09cd78-6888-11e5-9c31-001d7d7379f5'
      # @render-nav!

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
      knowledge-worker = new @KnowledgeWorker do
        ## \worker : @model._id
        \alerts   : new Array
      @render-alerts knowledge-worker

    _ul = @el._last
    n = 0
    for knowledge-worker in @collection._models
      _created = knowledge-worker._get \created
      n++
      App.dom._new \a
        _ul._append ..
        ..html = "#n.&nbsp;&nbsp;#_created"
        .._class = gz.Css \list-group-item
        ..on-click ((knowledge-worker) ~>
          ~> @render-alerts knowledge-worker) knowledge-worker

  render: (@collection, @model, @KnowledgeWorker) ->
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
        _success: (knowledge-workers) ~>
          _modal = new App.widget.message-box.Modal do
            _title: 'Conocimiento del trabajador'
            _body: (new AssessWorker).render(knowledge-workers,
                                             @model,
                                             KnowledgeWorker).el
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
    @trigger gz.Css \saved
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
      ..on (gz.Css \saved), ~>
        @_desktop.notifier.notify do
          _message: 'Guardado'
          _type: @_desktop.notifier.kSuccess
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


  /** @protected */ @@_mod-caption = 'CONOCIMIENTO DEL TRABAJOR'
  /** @protected */ @@_mod-icon    = gz.Css \road
  /** @protected */ @@_mod-hash    = 'auth-hash-worker-alerts'


/** @export */
module.exports = WorkerAlerts


/* vim: ts=2 sw=2 sts=2 et: */
