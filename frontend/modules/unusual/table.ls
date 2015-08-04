

table = App.widget.table
  Table = ..Table

class UtilAnexo

  ({@_desktop, @_parent, @_child, @_url='/api/dispatch/list'}) ->

  is_officer: -> window.plaft.'user'.'class_'.'1' is 'Officer'

  get-section-code: (alert) ->
    alert.'info'.'section' + alert.'info'.'code'

  _load-module: ->
    comercial_alertas = ['I1', 'I2', 'I9', 'I10', 'I11', 'I14', 'I16']

    operacion_alertas = ['I3', 'I5', 'I7', 'I8', 'I10', 'I11', 'I12',
                         'I13', 'I14', 'I15', 'I16', 'I17', 'I18']

    finanza_alertas = ['I4', 'I6', 'I9', 'I11', 'I13', 'I15', 'I17', 'I18']


    @_desktop._lock!
    @_desktop._spinner-start!

    _labels =
      'Aduana'
      'N&ordm; Orden'
      'Rég.'
      'Nombre/Razon social'
      'N&ordm; DAM'
      'Fecha Declaración'

    _attributes =
      'jurisdiction.code'
      'order'
      'regime.code'
      'declaration.customer.name'
      'dam'
      'numeration_date'

    _templates = {}

    __template-column = ->
      if it
        console.log 'ENTRO AQUI !!!!'
        "<span class='#{gz.Css \label}
                    \ #{gz.Css \label-success}'>
          <i class='#{gz.Css \glyphicon}
                  \ #{gz.Css \glyphicon-ok}'/>
         </span>"
      else
        ''

    __add-column = (label, attribute) ->
      _labels._push label
      _attributes._push attribute
      _templates[attribute] = __template-column

    dct-role =
      'Comercial':
        'attribute': 'is_comercial'
        'title': 'ÁREA COMERCIAL'
      'Operación':
        'attribute': 'is_operativo'
        'title': 'ÁREA OPERACIONES'
      'Finanza':
        'attribute': 'is_finanza'
        'title': 'ÁREA FINANZA'


    role = window.plaft.'user'.'role'

    App.ajax._get @_url, true, do
      _success: (dispatches) ~>

        for dispatch in dispatches
          is_comercial = off
          is_operativo = off
          is_finanza = off

          for sc in [@get-section-code a for a in dispatch.'alerts']
            if sc in comercial_alertas
              is_comercial = on
            else if sc in operacion_alertas
              is_operativo = on
            else if sc in finanza_alertas
              is_finanza = on

          dispatch
            ..'is_comercial' = is_comercial
            ..'is_operativo' = is_operativo
            ..'is_finanza' = is_finanza

        _pending = new Dispatches dispatches

        if @is_officer!
          title-module = 'OFICIAL CUMPLIMIENTO'

          for rol in ['Comercial', 'Operación', 'Finanza']
            __add-column rol, dct-role[rol].'attribute'
        else
          __add-column role, dct-role[role].'attribute'
          title-module = dct-role[role].'title'

        console.log _templates
        # CREATE TABLE
        _tabla = new Table do
                      _attributes: _attributes
                      _labels: _labels
                      _templates: _templates
                      on-dblclick-row: (evt) ~>
                        @_desktop.load-next-page @_child, model: evt._target._model

        _tabla.set-rows _pending

        @_parent.el.html = "<h3 style='text-align:center'>
                            \ IDENTIFICACIÓN DE OI - #{title-module}
                            </h3>
                            <h4 style='text-align:center'>
                            \ SECCION I - OPERACIONES O CONDUCTAS
                          \ INUSUALES RELATIVAS AL CLIENTE</h4>"
        @_parent.el._append _tabla.render!.el
        @_desktop._unlock!
        @_desktop._spinner-stop!

      _error: ->
        alert 'Error!!! NumerationP list'

  /** @private */ _desktop: null
  /** @private */ _parent: null
  /** @private */ _child: null
  /** @private */ _url: null

/** @export */
module.exports = UtilAnexo

# vim: ts=2:sw=2:sts=2:et