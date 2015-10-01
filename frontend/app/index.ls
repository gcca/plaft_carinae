/**
 * @module app
 *
 * You don't need to modify this file unless change the core source code.
 * Change under your own risk! Same warning for App sub-modules.
 *
 * @author gcca@gcca.tk (cristHian Gz. <gcca>)
 */


/**
 * Global application object.
 * @export
 */
module.exports = App = new Object

helpers = require './helpers'
builtins = require './builtins'


/**
 * App definitions.
 */
App <<<
  dom: document
  math: Math


/**
 * "Nulls" types.
 */
App._void = new Object <<<
  _Object: new Object
  _Array: new Array
  _Function: new Function
  _SyncOptions: new Object


/**
 * Debug utils.
 */
(App._debug = console) <<<
  /**
   * Throw assert exception.
   * TODO(...): Improve type error.
   * Throws {@code Error}
   * @param {boolean} condition
   * @param {string?} condition
   */
  _assert: (condition, message) ->
    unless condition
      message = message || 'Assertion failed'
      if typeof Error isnt \undefined
        throw new Error message
      throw message  # Fallback

  _assert: ref$\assert


/**
 * General utils
 */
App.utils =
  uid: (pf = '') -> pf + ((App.math.random! + '').slice 2)


/**
 * Global pool mixin's. Internal to App.
 */
NewMixin =
  _new: -> @Pool! if not @pool?;@_new = @_New;@_New ...
  _New: -> @pool.allocate.apply @pool, &
  Pool: !-> @pool = new builtins.ObjectPool @
  pool: null

FreeMixin =
  _free: !-> @'undelegateEvents'! ; @_remove!; @_constructor.pool.free @

PoolMixin =
  _free: !-> @_constructor.pool.free @

Pool = (_self) -> _._extend _self, NewMixin


/**
 * View
 * ----
 * Base class for views.
 */
class App.View extends Backbone\View implements FreeMixin

  /** @constructor */
  (args = App._void._Object) ->
    @\render = @render
    @\tagName = @_tagName
    @\className = @_className
    @\events = @events
    @\id = @_id
    @\el = @el if @el?
    @\cid = _._unique-id 'cgz'

    if args.el?
      @\el = args.el
      delete! args.el

    _._extend @, (_._pick args, @@base-args)
    @'_ensureElement'!
    @$el = @\$el
    @el  = @\el
    if @_events then for k of @_events then @el[k] @~(@_events[k])
    @initialize.apply @, &
    @'delegateEvents'!

  /**
   * Initialize view variables, atributtes, methods, etc.
   * @protected
   */
  initialize: -> @el.html = ''

  /**
   * Method reflection.
   */
  ::render  = ::\render
  ::on      = ::\on
  ::off     = ::\off
  ::trigger = ::\trigger
  ::_remove = ::\remove
  ::$       = ::\$

  /** @private */ _events: null

  _._extend @@, NewMixin

  @@_New = ->
    #TODO: Implement correct inheritance from NewMixin to View.
    @pool.allocate.apply @pool, &
      if &.0? then _._extend .., (_._pick &.0, @@base-args)

  /**
   * Basi attribute labels.
   */
  @@base-args = [k for k of {
    model      : null
    collection : null
    el         : null
    id         : null
    attributes : null
    className  : null
    tagName    : null
    events     : null}]


/**
 * Model
 * -----
 * Base class for models.
 */
class BaseModel extends Backbone\Model

  (_, o = new Object) ->
    @_parent?  = o._parent
    @\urlRoot  = @urlRoot
    @\defaults = @defaults
    super ...

  ::_fetch   = ::\fetch
  ::_save    = ::\save
  ::_url     = ::\url
  ::_get     = ::\get
  ::_set     = ::\set
  ::_sync    = ::\sync
  ::_toJSON  = ::\toJSON
  ::on       = ::\on
  ::off      = ::\off
  ::trigger  = ::\trigger
  ::_remove  = ::\remove
  ::is-new   = ::\isNew
  ::_destroy = ::\destroy

  _attributes:~
    -> @\attributes
    (x) -> @\attributes = x

  _id:~ -> @\id

  _parent: null

  store: -> @_save ...

  \url  : -> @_url ...
  \sync : -> @_sync ...


App.Events = Backbone\Events <<<
  on  : ref$\on
  off : ref$\off


class App.Model extends BaseModel

  @@API = '/api/'

  is-null = (x) ->
    | not x  => true
    | x.__proto__.constructor is Array => not x.length
    | x.__proto__.constructor is String => x is ''
    | x.__proto__.constructor is Object =>
      for k of x
        return false
      return true
    | otherwise => not x?

  get-array = (a, b, list) ->
    if are-diff a, b
      list.push b
    else
      list.push a

  process = (a, b) ->
    | b.__proto__.constructor is Object => get-diff a, b
    | b.__proto__.constructor is Array =>
      list = []
      for i, k in b
        get-array a[k], b[k], list
      list
    | otherwise => b

  are-diff = (a, b) ->
    | b.__proto__.constructor is Object =>
      if a?
        not is-null get-diff a, b
      else
        false
    | b.__proto__.constructor is Array =>
      if a?
        /**
         * @fileoverview
         * @suppress
         */
        for i, k in b
          return are-diff a[k], b[k]
      else
        false
    | otherwise => a != b

  get-diff = (a, b) ->
    c = {}
    for k of b
      if (not is-null b[k]) and (are-diff a[k], b[k])
        r = process a[k], b[k]
        if not is-null r
          c[k] = r
    c

  _set-diff = (a, b) ->
    for k of b
      if b.__proto__.constructor is Object
        if a[k]?
          _set-diff a[k], b[k]
        else
          a[k] = b[k]
      else if b.__proto__.constructor is Array
        a[k] = b[k]
      else
        a[k] = b[k]

  _url: ->
    if @_parent? then "#{@_parent._url!}/#{super!}" else "/api/#{super!}"

  _destroy: (opts = App._void._SyncOptions) ->
    # super \success : opts._success, \error : opts._error
    # TODO: Check error in original method of Model
    _req = new XMLHttpRequest
    _req.open 'delete', @_url!, on
    _req.onreadystatechange = ~>
      if 4 is _req.readyState
        if 200 is _req.status
          @'stopListening'!
          @'trigger' 'destroy', @, @'collection', opts
          opts._success @, _req if opts._success
        else
          opts._error _req if opts._error
    _req.send!

  _fetch: (opts = App._void._SyncOptions) ->
    super \success : opts._success, \error : opts._error

  _save: (keys, opts = App._void._SyncOptions) ->
    super keys, \success : opts._success, \error : opts._error

  _store: (keys, opts = App._void._SyncOptions) ->
    if @isNew!
      App.ajax._post @_url!, keys, do
        _success: (_dto) ~>
          _set-diff @_attributes, keys
          @_attributes['id'] = _dto.id
          opts._success ...
        _error: opts._error
      @_save keys, opts
    else
      final-attributes = get-diff @_attributes, keys
      final-attributes['id'] = @_attributes['id']
      App.ajax._put @_url!, final-attributes, do
        _success: ~>
          _set-diff @_attributes, final-attributes
          opts._success ...
        _error: opts._error


class BaseCollection extends Backbone\Collection

  (_, o = new Object) ->
    @_parent? = o._parent
    super ...
    @url = @_url
    @_attributes = @attributes

  ::fetch   = ::\fetch
  ::_fetch  = ::\fetch
  ::_save   = ::save
  ::_url    = ::url
  ::_get    = ::get
  ::_set    = ::set
  ::_sync   = ::\sync
  ::_toJSON = ::\toJSON
  ::on      = ::\on
  ::off     = ::\off
  ::trigger = ::\trigger
  ::_remove = ::\remove
  ::_bind   = ::\bind
  ::_add    = ::\add
  ::_sort   = ::\sort

  _parent : null
  urlRoot : null
  _id     :~ -> @id
  _models :~ -> @\models

  _comparator:~
    -> @'comparator'
    (x) -> @'comparator' = x

  _url  : -> @urlRoot  # @_url ...
  \sync : -> @_sync ...

class App.Collection extends BaseCollection

  @@API = '/api/'

  _url: -> "/api/#{super!}"

  fetch: (it = App._void._SyncOptions) ->
    super \success : it._success, \error : it._error
  _fetch: (it = App._void._SyncOptions) ->
    super \success : it._success, \error : it._error

  _save: (keys, opts = App._void._SyncOptions) ->
    super keys, \success : opts._success, \error : opts._error


/**
 * Builder.
 */
App.builder = require './builder'


/** @export */
App.builtins = builtins


/** @export */
App.lists = require './lists'


/** @export */
App.ajax = require './ajax'

App.form-ratio = require './form-ratio'


/** @export */
App._form =
  _toJSON: -> new formToObject it

  _fromJSON: (f, o) !->
    es = f.elements
    k = new Array
    _flatten o, k, ''
    for [i, v] in k
      if (i.indexOf '.') > 0
        i = i.replace /\./, \[
        i = i.replace /\./g, ']['
        i += \]
      e = es[i]
      if e?
        if e.type is \checkbox
          e._checked = v
        else
          e._value = v

flatten-loop = (cb, o, k, b) !-->
  for i of o
    v = o[i]
    if v?
      if v._constructor is Object
        flatten-loop cb, v, k, (b + "#i.")
      else
        cb k, (b + i), v

_flatten = flatten-loop (k, b, v) !-> k.push [b, v]

class formToObject
  (formRef) ->
    return false if not formRef
    @formRef = formRef
    @keyRegex = //[^\[\]]+//g
    @$form = null
    @$formElements = []
    @formObj = {}
    if not @setForm! then return false
    if not @setFormElements! then return false
    return @setFormObj!

  setForm: ->
    switch typeof @formRef
      case \string
        @$form = document.getElementById @formRef
      case \object
        @$form = @formRef if @isDomNode @formRef
    @$form

  setFormElements: -> # .elements HTML5 support
    ## @$formElements = @$form.querySelectorAll 'input, textarea, select'
    @$formElements = [.. for @$form.elements
                      when .. instanceof [HTMLInputElement,
                                          HTMLSelectElement,
                                          HTMLTextAreaElement]]
    @$formElements.length

  isDomNode: (n) -> typeof n is \object && \nodeType of n && n.nodeType is 1

  forEach: (arr, callback) !->
    return [].forEach.call arr, callback if [].forEach
    i = void
    [callback.call arr, arr[i] if Object::hasOwnProperty.call arr, i \
     for i of arr]

  addChild: (result, domNode, keys, value) ->
    if keys.length is 1
      if domNode.nodeName is \INPUT && domNode.type is \checkbox
        return result[keys] = domNode.checked
      if domNode.checked then return result[keys] = value \
        else return if domNode.nodeName is \INPUT && domNode.type is \radio
      ## if domNode.nodeName is \INPUT && domNode.type is \checkbox
        ## if domNode.checked
        ##   result[keys] = [] if not result[keys]
        ##   return result[keys].push value
        ## else
        ##   return
      if domNode.nodeName is \SELECT && domNode.type is \select-multiple
        result[keys] = []
        DOMchilds = domNode.querySelectorAll 'option[selected]'
        @forEach DOMchilds,
                 (child) -> result[keys].push child.value if DOMchilds
        return
      if domNode.name.endsWith '[]'
        list = result[keys.0]
        list ?= []
        list.push value
        return result[keys] = list

      result[keys] = value
    if keys.length > 1
      result[keys.0] = {} if not result[keys.0]
      return (@addChild result[keys.0], domNode,
                        (keys.splice 1, keys.length), value)
    result

  setFormObj: ->
    test = void
    i = 0
    while i < @$formElements.length
      if @$formElements[i].name && not @$formElements[i].disabled
        test = @$formElements[i].name.match @keyRegex
        @addChild @formObj, @$formElements[i], test, @$formElements[i].value
      i++
    @formObj



/** @export */
App.model = require './model'

/** @export */
App.widget = require './widget'

/** @export */
App.mixin = require './mixin'

# HARDCODE
if not window.plaft.'user'.'permissions'
  window.plaft.'user'.'permissions' =
    'modules': void
    'alerts': void
    'sections': void

App.permissions =
  modules: window.plaft.'user'.'permissions'.'modules'
  alerts: window.plaft.'user'.'permissions'.'alerts'
  sections: window.plaft.'user'.'permissions'.'sections'


App.GLOBALS =
  _declarants: window.plaft.'declarant'

  _stakeholders: window.plaft.'stakeholder'

  update_autocompleter: ->
    App.ajax._get '/autocompleters', false, do
      _success: (_autocompleters) ~>
        @_declarants = _autocompleters.'declarant'
        @_stakeholders = _autocompleters.'stakeholder'

  update_employees: ->
    App.ajax._get '/api/user', false, do
      _success: (employees) ->
        window.plaft.'us' = employees

  update_customs: ->
    App.ajax._get '/api/admin/customs_agency', true, do
      _success: (customs_agency) ->
        dto-customs = new Object
        for customs in customs_agency
          dto-customs[customs.'name'] = customs

        window.plaft.'customs' = dto-customs

window.plaft.'declarant' = void
window.plaft.'stakeholder' = void


# vim: ts=2:sw=2:sts=2:et
