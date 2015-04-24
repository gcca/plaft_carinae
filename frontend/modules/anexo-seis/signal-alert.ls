/** @module modules */


FieldType = App.builtins.Types.Field
DOCUMENT_TYPE_PAIR = App.lists.document-type._pair

/**
 * SignalAlert
 * --------
 *
 * @example
 * @class SignalAlert
 * @extends View
 */
class SignalAlert extends App.View

  /** @override */
  _tagName: \form

  /** @override */
  _className: gz.Css \parent-toggle

  /**
   * Form to JSON.
   * @return {Object}
   * @override
   */
  _toJSON: -> @el._toJSON!

  /**
   * (Event) On remove signalAlert from list.
   * @private
   */
  buttonOnRemove: ~>
    @$el.remove!
    @_array-share.trigger (gz.Css \drop-signal), @el._id

  /**
   * Get signalAlert list.
   * @public
   */
  _array-signalAlert: (_signals)->
    @_array-share = _signals

  /** @override */
  initialize: ->
    @el._id= App.utils.uid!
    super!

  /** @override */
  render: ->
    @el.html = "
    <div class='#{gz.Css \col-md-11}' style='padding:0'>
    </div>
    <div class='#{gz.Css \col-md-1}' style='padding:0'>
      <div class='#{gz.Css \form-group} #{gz.Css \col-md-5}'>
          <span class='#{gz.Css \glyphicon}
                     \ #{gz.Css \glyphicon-remove}
                     \ #{gz.Css \toggle}'
              style='margin-top:8px;cursor:pointer;font-size:18px'>
          </span>
      </div>
    </div>"

    App.builder.Form._new @el._first, _FIELD_SIGNAL
      ..render!
      .._free!

    @el._last.on-click @buttonOnRemove

    $ @el._first ._append "<div class='#{gz.Css \col-md-12}'><hr></div>"

    @el._fromJSON @model
    super!

  /** @private */ _array-share : null
  /** @private */ _signals: null

  _FIELD_SIGNAL =
    * _name: 'id_signal'
      _label: 'Código'

    * _name: 'signal'
      _label: 'Descripción de la señal de alerta'
      _type: FieldType.kComboBox
      _options: App.lists.alerts._display

    * _name: 'font_signal'
      _label: 'Fuenta de la señal de la alerta'
      _type: FieldType.kComboBox
      _options:
        'Sistema de Monitoreo'
        'Área Comercial'
        'Análisis del SO'
        'Medio Periodistico'
        'Otras Fuentes'

    * _name: 'description_font_signal'
      _label: 'Descripción de otros.'

/**
 * SignalAlerts
 * ------------
 *
 * @example
 * @class SignalAlerts
 * @extends View
 */
class SignalAlerts extends App.View

  /** @override */
  _tagName: \div

  /**
   * SignalAlert list to JSON.
   * @return [Array.<signalAlert-JSON>] || []
   * @override
   */
  _toJSON: -> [.._toJSON! for @signalAlerts]

  /**
   * Send signalAlert list to each signal.
   * @private
   */
  _array-share: ->
    for @signalAlerts then
      .._array-signalAlert @signalAlerts
  /**
   * Remove signal from signalAlert list.
   * @private
   */
  _on-share: (id) ~>
    @signalAlerts = [sh for sh in @signalAlerts when sh.el._id !== id]
    _._extend(@signalAlerts, App.Events);
    @signalAlerts.on (gz.Css \drop-signal), @_on-share
    @_array-share!

  /**
   * (Event) On add signalAlert to list.
   * @private
   */
  buttonOnClick: ~> @addSignal!

  /**
   * Add signalAlert to list.
   * @param {Object} model SignalAlert DTO.
   * @private
   */
  addSignal: (model) !->
    signalAlert = SignalAlert._new model: model
    @signalAlerts._push signalAlert
    @xContainer._append signalAlert.render!.el
    @_array-share!
    console.log @signalAlerts

  load-from: (_signals) ->
    for model in _signals
      @addSignal model

  /**
   * @param {Object} options {@code options.signalAlerts} collection.
   * @override
   */
  initialize: (options) !->
    /**
     * SignalAlert views.
     * @type {SignalAlert}
     * @private
     */
    @signalAlerts = new Array
    _._extend(@signalAlerts, App.Events);

    /**
     * SignalAlert JSON list.
     * @private
     */
    @signalAlerts.on (gz.Css \drop-signal), @_on-share
    # Style
    App.dom._write ~> @el.css._marginBottom = '1em'

  /** @override */
  render: ->
    @el.html = "
      <div class='#{gz.Css \col-md-12}'
          style='padding-left:0;padding-right:0'></div>
      <button type='button' class='#{gz.Css \btn} #{gz.Css \btn-default}'
          style='margin-left:15px'>
        Agregar
      </button>"

    @xContainer = @el._first
    xButton = @el._last

    xButton.onClick @buttonOnClick


    super!


  /** @private */ xContainer: null


/** @export */
module.exports = SignalAlerts


# vim: ts=2:sw=2:sts=2:et
