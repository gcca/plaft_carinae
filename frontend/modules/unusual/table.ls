/**
 * @author Javier Huaman
 */
table = App.widget.table
  Table = ..Table

/**
 * @Class UtilAnexo
 */
class UtilAnexo

  ({@_desktop, @_parent, @_child, @_title}) ->

  is_officer: -> window.plaft.'user'.'class_'.'1' is 'Officer'

  get-section-code: (alert) ->
    alert.'info'.'section' + alert.'info'.'code'

  _load-module: (_active-transitions=on) ->
    comercial_alertas = ['I1', 'I2', 'I9', 'I10', 'I11', 'I14', 'I16']

    operacion_alertas = ['I3', 'I5', 'I7', 'I8', 'I10', 'I11', 'I12',
                         'I13', 'I14', 'I15', 'I16', 'I17', 'I18'] ++ ["III#i" for i from 1 to 33]

    finanza_alertas = ['I4', 'I6', 'I9', 'I11', 'I13', 'I15', 'I17', 'I18']

    if _active-transitions
      @_desktop._lock!
      @_desktop._spinner-start!

    _labels =
      'Aduana'
      'N&ordm; Orden'
      'Rég.'
      'Nombre/Razon social'
      'N&ordm; DAM'
      'Fecha Declaración'
      'Fecha UIF'

    _attributes =
      'jurisdiction.code'
      'order'
      'regime.code'
      'declaration.customer.name'
      'dam'
      'numeration_date'
      'last_date_ros'

    _templates = {}

    _column-cell-style =
      'order': 'width:92px'
      'declaration.customer.name': 'text-overflow: ellipsis;
                                    white-space: nowrap;
                                    overflow: hidden;
                                    max-width: 27ch;
                                    text-align: left;'

    __template-column = (_value, _dto, _attr) ~>
      __cell = (_value) ->
        if _value
          "<span class='#{gz.Css \label}
                      \ #{gz.Css \label-danger}'>
            <i class='#{gz.Css \glyphicon}
                    \ #{gz.Css \glyphicon-remove}'></i>
           </span>"
        else
          "<span class='#{gz.Css \label}
                      \ #{gz.Css \label-success}'>
            <i class='#{gz.Css \glyphicon}
                    \ #{gz.Css \glyphicon-ok}'></i>
           </span>"

      # TODO: La excepción para el oficial debe venir desde el backend.
      #       Los "vistos" deben manejarse de otra manera para hacer
      #       el código fluído.
      #       Este código está horrible.
      #       Ver `widget/table.ls`: `__get-value` <- `_attr`
      if @is_officer!  # Si es oficial, se muestran según los empleados
        employees = window.'plaft'.'user'.'customs_agency'.'employees'
        for employee in employees
          if (('is_' + employee.'role'.to-lower-case!) is _attr
              and "#{employee.'id'}" in _dto.'alerts_visited')
            return __cell _value
        ''
      else  # De no ser oficial, se muestran como columna simple
        _id-user = "#{window.'plaft'.'user'.'id'}"
        if _id-user in _dto.'alerts_visited'
          __cell _value
        else
          ''

    __add-column = (label, attribute) ->
      _labels._push label
      _attributes._push attribute
      _templates[attribute] = __template-column

    dct-role =
      'Comercial':
        'label': 'Comer.'
        'attribute': 'is_comercial'
        'title': 'ÁREA COMERCIAL'
      'Operación':
        'label': 'Oper.'
        'attribute': 'is_operación'
        'title': 'ÁREA OPERACIONES'
      'Finanza':
        'label': 'Finan.'
        'attribute': 'is_finanza'
        'title': 'ÁREA FINANZA'


    role = window.plaft.'user'.'role'

    App.model.Dispatches._all (dispatches) ~>
      for dispatch in [.._attributes for dispatches._models]
        is_comercial = off
        is_operativo = off
        is_finanza = off

        for sc in [@get-section-code a for a in dispatch.'alerts']
          if sc in comercial_alertas
            is_comercial = on
          if sc in operacion_alertas
            is_operativo = on
          if sc in finanza_alertas
            is_finanza = on

        dispatch
          ..'is_comercial' = is_comercial
          ..'is_operación' = is_operativo
          ..'is_finanza' = is_finanza

      _pending = dispatches

      if @is_officer!
        title-module = 'OFICIAL CUMPLIMIENTO'

        for rol in ['Comercial', 'Operación', 'Finanza']
          __add-column dct-role[rol].'label',
                       dct-role[rol].'attribute'
      else
        __add-column dct-role[role].'label',
                     dct-role[role].'attribute'
        title-module = dct-role[role].'title'

      # CREATE TABLE
      _tabla = new Table do
                    _attributes: _attributes
                    _labels: _labels
                    _templates: _templates
                    _column-cell-style: _column-cell-style
                    on-dblclick-row: (evt) ~>
                      @_desktop.load-next-page @_child, do
                        model: evt._target._model
                        _parent: @_parent

      _tabla.set-rows _pending

      if not @_title?
        @_title = "IDENTIFICACIÓN DE OI - #{title-module}"
      @_parent.el.html = "<h3 style='text-align:center;margin-top:0px'>
                            #{@_title}</h3>"
      @_parent.el._append _tabla.render!.el
      if _active-transitions
        @_desktop._unlock!
        @_desktop._spinner-stop!

  _reload-module: -> @_load-module off

  /** @private */ _desktop: null
  /** @private */ _parent: null
  /** @private */ _child: null
  /** @private */ _url: null
  /** @private */ _title: null

/** @export */
module.exports = UtilAnexo

# vim: ts=2:sw=2:sts=2:et
