/** @module modules */


FieldType = App.builtins.Types.Field
DOCUMENT_TYPE_PAIR = App.lists.document-type._pair

/**
 * Shareholder
 * --------
 *
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
  buttonOnRemove: !~> @_free!

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
    $buttonRemove.0.onClick @buttonOnRemove
    @$el._append $buttonRemove

    @el._fromJSON @model
    super!

  /**
   * Shareholder form.
   * @return {string}
   * @private
   */
  template: ->
    "
    <div class='#{gz.Css \form-group} #{gz.Css \col-shareholder-1}'>
      <select class='#{gz.Css \form-control}' name='document[type]'>
        #_OPTIONS
      </select>
    </div>

    <div class='#{gz.Css \form-group} #{gz.Css \col-shareholder-2}'>
      <input type='text' class='#{gz.Css \form-control}'
          name='document[number]'>
    </div>

    <div class='#{gz.Css \form-group} #{gz.Css \col-shareholder-3}'>
      <input type='text' class='#{gz.Css \form-control}'
          name='name'>
    </div>

    <div class='#{gz.Css \form-group} #{gz.Css \col-shareholder-4}'>
      <input type='text' class='#{gz.Css \form-control}'
          name='ratio'>
    </div>"

  _OPTIONS = ["<option value='#k'>#v</option>" \
              for k,v of App.lists.document-type._pair]._join ''



class Shareholders extends App.View

  /** @override */
  _tagName: \div

  /**
   * Shareholder list to JSON.
   * @return {Array.<Shareholder-JSON>}
   * @override
   */
  _toJSON: -> [.._toJSON! for @shareholders]

  /**
   * (Event) On add shareholder to list.
   * @private
   */
  buttonOnClick: ~> @addShareholder!

  /**
   * Add shareholder to list.
   * @param {Object} model Shareholder DTO.
   * @private
   */
  addShareholder: (model) !->
    shareholder = Shareholder._new model: model
    @shareholders._push shareholder
    @xContainer._append shareholder.render!.el

  load-from: (_shareholders) ->
    for model in _shareholders
      @addShareholder model

  /**
   * @param {Object} options {@code options.shareholders} collection.
   * @override
   */
  initialize: (options) !->
    /**
     * Shareholder views.
     * @type {Shareholder}
     * @private
     */
    @shareholders = new Array

    /**
     * Shareholder JSON list.
     * @type {Object}
     * @private
     */
#    @collection = options.shareholders || new Array

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

    # TODO: Refactor to load shareholders from here.
    #       Remove load-shareholders method
    # # Initial shareholders
    # for model in @collection
    #   @addShareholder model

    super!


  /** @private */ xContainer: null


/** @export */
module.exports = Shareholders


# vim: ts=2:sw=2:sts=2:et
