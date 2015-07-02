/** @module modules */


FieldType = App.builtins.Types.Field
DOCUMENT_TYPE_PAIR = App.lists.document-type._pair

widget = App.widget.codename
  DisplaySelect = ..DisplaySelect

/**
 * Shareholder
 * --------
 *
 * @example
 * @class Shareholder
 * @extends View
 */
class Shareholder extends App.View

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
   * (Event) On remove shareholder from list.
   * @private
   */
  buttonOnRemove: ~>
    @trigger (gz.Css \drop-shareholder), @ # TODO:
    @$el.remove!

  /** @override */
  initialize: ({@dto=App._void._Object}=App._void._Object) ->
    super!

  /** @override */
  render: ->
    @el.html = @template!

    $buttonRemove = $ "
      <div class='#{gz.Css \form-group} #{gz.Css \col-shareholder-5}'>
        <span class='#{gz.Css \glyphicon}
                   \ #{gz.Css \glyphicon-remove}
                   \ #{gz.Css \toggle}'
            style='margin-top:8px;cursor:pointer;font-size:18px'></span>
      </div>"
    $buttonRemove.0.on-click @buttonOnRemove
    @$el._append $buttonRemove

    _select = new DisplaySelect do
                _list : App.lists.document-type
                _name : 'document_type'
                _value : @dto.'document_type'

    _document = @el.query ".#{gz.Css \col-shareholder-1}"
    _document._append _select.render!.el

    @el._fromJSON @dto
    super!

  /** @private */ _array-share : null
  /** @private */ _shareholders: null
  /** @private */ dto: null

  /**
   * Shareholder form.
   * @return {string}
   * @private
   */
  template: ->
    "
    <div class='#{gz.Css \form-group} #{gz.Css \col-shareholder-1}'>
    </div>

    <div class='#{gz.Css \form-group} #{gz.Css \col-shareholder-2}'>
      <input type='text' class='#{gz.Css \form-control}'
          name='document_number'>
    </div>

    <div class='#{gz.Css \form-group} #{gz.Css \col-shareholder-3}'>
      <input type='text' class='#{gz.Css \form-control}'
          name='name'>
    </div>

    <div class='#{gz.Css \form-group} #{gz.Css \col-shareholder-4}'>
      <input type='text' class='#{gz.Css \form-control}'
          name='ratio'>
    </div>"

/**
 * Shareholders
 * ------------
 *
 * @example
 * @class Shareholder
 * @extends View
 */

class Shareholders extends App.View

  /** @override */
  _tagName: \div

  /**
   * Shareholder list to JSON.
   * @return {Array.<Shareholder-JSON>} || {}
   * @override
   */
  _toJSON: ->
    _r =[.._toJSON! for @shareholders]

  /**
   * @see addShareholder
   */
  on-drop: (shareholder) ~>
    @shareholders._remove shareholder

  /**
   * (Event) On add shareholder to list.
   * @private
   */
  buttonOnClick: ~> @addShareholder!

  /**
   * Add shareholder to list.
   * @param {Object} dto Shareholder.
   * @private
   */
  addShareholder: (dto) !->
    shareholder = Shareholder._new dto: dto
    shareholder.on (gz.Css \drop-shareholder), @on-drop
    @shareholders._push shareholder
    @xContainer._append shareholder.render!.el

  load-from: (_shareholders) ->
    for dto in _shareholders
      @addShareholder dto

  /**
   * @param {Object} options {@code options.shareholders} collection.
   * @override
   */
  initialize: ->
    /**
     * Shareholder views.
     * @type {Shareholder}
     * @private
     */
    @shareholders = new Array

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

    @xContainer._append ($ "
      <form>
        <div class='#{gz.Css \form-group}
                  \ #{gz.Css \col-shareholder-header-1}'>
          <label>&nbsp;Documento</label>
        </div>

        <div class='#{gz.Css \form-group}
                  \ #{gz.Css \col-shareholder-header-2}'>
          <label>&nbsp;Número</label>
        </div>

        <div class='#{gz.Css \form-group}
                  \ #{gz.Css \col-shareholder-header-3}'>
          <label>&nbsp;Apellidos y nombres</label>
        </div>

        <div class='#{gz.Css \form-group}
                  \ #{gz.Css \col-shareholder-header-4}'>
          <label>&nbsp;Acciones (%)</label>
        </div>
      </form>").0

    super!


  /** @private */ xContainer: null


/** @export */
module.exports = Shareholders


# vim: ts=2:sw=2:sts=2:et
