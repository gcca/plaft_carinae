/** @module app
 * Warning. Don't touch. Unless you do as well as know !!!
 * @author gcca@gcca.tk (cristHian Gz. <gcca>)
 */


/**
 * Extra shortcuts for {@code document} {@code Object}.
 */
(κ = document) <<<
  _new : ref$\createElement
  query: ref$\querySelector
  query-all: ref$\querySelectorAll

(κ = Object) <<<
  defineProperty: ref$\defineProperty
  defineProperties: ref$\defineProperties
  _property: ref$\defineProperty
  _properties: ref$\defineProperties

(k = Math) <<<
  _log: ref$\log
  _floor: ref$\floor
  _random: ref$\random


/**
 * {@code Object} shortcuts.
 */
Object._properties Object::, do
  _constructor: get: -> @\constructor


/**
 * Fast dom access.
 */
((fastdom) ->
  window
    raf = (..\requestAnimationFrame
           || ..\webkitRequestAnimationFrame
           || ..\mozRequestAnimationFrame
           || ..\msRequestAnimationFrame
           || (cb) -> ..\setTimeout cb, 1000 / 60)
    caf = (..\cancelAnimationFrame
           || ..\cancelRequestAnimationFrame
           || ..\mozCancelAnimationFrame
           || ..\mozCancelRequestAnimationFrame
           || ..\webkitCancelAnimationFrame
           || ..\webkitCancelRequestAnimationFrame
           || ..\msCancelAnimationFrame
           || ..\msCancelRequestAnimationFrame
           || (id) -> ..\clearTimeout id)
  class FastDom
    ->
      @frames = []
      @lastId = 0
      @raf = raf
      @batch =
        hash: {}
        read: []
        write: []
        mode: null

    _read: (fn, ctx) ~>
      job = @add 'read', fn, ctx
      id = job.id
      @batch.read.push job.id
      doesntNeedFrame = @batch.mode is 'reading' || @batch.scheduled
      return id if doesntNeedFrame
      @scheduleBatch!
      id

    _write: (fn, ctx) ~>
      job = @add 'write', fn, ctx
      mode = @batch.mode
      id = job.id
      @batch.write.push job.id
      doesntNeedFrame = (mode is 'writing'
                         || mode is 'reading'
                         || @batch.scheduled)
      return id if doesntNeedFrame
      @scheduleBatch!
      id
    defer: (frame, fn, ctx) ->
      if typeof frame is 'function'
        ctx = fn
        fn = frame
        frame = 1
      self = this
      index = frame - 1
      @schedule index, ->
        self.run {
          fn: fn
          ctx: ctx
        }
    clear: (id) ->
      return @clearFrame id if typeof id is 'function'
      job = @batch.hash[id]
      if not job then return
      list = @batch[job.type]
      index = list.indexOf id
      delete! @batch.hash[id]
      if ~index then list.splice index, 1
    clearFrame: (frame) ->
      index = @frames.indexOf frame
      @frames.splice index, 1 if ~index
    scheduleBatch: ->
      self = this
      @schedule 0, ->
        self.batch.scheduled = false
        self.runBatch!
      @batch.scheduled = true
    uniqueId: -> ++@lastId
    flush: (list) ->
      id = void
      while id = list.shift!
        @run @batch.hash[id]
    runBatch: ->
      try
        @batch.mode = 'reading'
        @flush @batch.read
        @batch.mode = 'writing'
        @flush @batch.write
        @batch.mode = null
      catch e
        @runBatch!
        throw e
    add: (type, fn, ctx) ->
      id = @uniqueId!
      @batch.hash[id] = {
        id: id
        fn: fn
        ctx: ctx
        type: type
      }
    run: (job) ->
      ctx = job.ctx || this
      fn = job.fn
      delete! @batch.hash[job.id]
      return fn.call ctx if not @onError
      (try
        fn.call ctx
      catch e
        @onError e)
    loop: ->
      self = this
      raf := @raf
      return  if @looping
      raf frame = ->
        fn = self.frames.shift!
        if not self.frames.length then self.looping = false else raf frame
        if fn then fn!
      @looping = true
    schedule: (index, fn) ->
      return @schedule index + 1, fn if @frames[index]
      @loop!
      @frames[index] = fn
  fdom = new FastDom
  document <<<
    _write : fdom._write
    _read  : fdom._read)!


/**
 * Extra {@code HTMLElement} shortcuts.
 */
HTMLElement::=
  html:~
    -> @\innerHTML
    (x) -> @\innerHTML = x

  css:~
    -> @\style
    (x) -> @'style'\cssText = x

  _class:~
    -> @\classList
    (x) -> @\className = x

  _append: ref$\appendChild

  _type:~
    -> @\type
    (x)-> @\type = x

  _first :~ -> @\firstElementChild
  _last  :~ -> @\lastElementChild
  _next  :~ -> @\nextElementSibling
  _parent:~ -> @\parentElement

  _disabled:~
    -> @\disabled
    (x) -> @\disabled = x

  _id:~
    -> @\id
    (x) -> @\id = x

  attr: (key, value) ->
    if value? then
      @\setAttribute key, value
    else
      @\getAttribute key

  query: ref$\querySelector
  query-all: ref$\querySelectorAll

  on-click    : -> @\onclick    = it
  on-dbl-click: -> @\ondblclick = it
  on-change   : -> @\onchange   = it
  on-blur     : -> @\onblur     = it
  on-key-up   : -> @\onkeyup    = it
  on-submit   : -> @\onsubmit   = it


/**
 * {@code Array} and {@code String}  shortcuts.
 */
Array::=
  _push  : ref$\push
  _pop   : ref$\pop
  _join  : ref$\join
  _index : ref$\indexOf

  _length:~
    -> @\length
    (x) -> @\length = x

String::=
  _length:~ -> @\length
  _match: ref$\match
  _slice: ref$\slice
  _substring: ref$\substring


/**
 * {@code Event} shortcuts.
 */
Event::=
  _target:~ -> @\currentTarget
  _key:~ -> @\key
  _keyCode:~ -> @\keyCode
  _shiftKey:~ -> @\shiftKey
  _ctrlKey:~ -> @\ctrlKey

$'Event'::
  ..prevent = ..\preventDefault

Event::
  ..prevent = ..\preventDefault

$'Event'::=
  _target:~ -> @\currentTarget


/**
 * Form basic shortcuts:
 *   {@code HTMLInputElement},
 *   {@code HTMLSelectElement},
 *   {@code HTMLButtonElement},
 *   {@code Collection},
 *   {@code HTMLAnchorElement}.
 */
with {
    _value: get: (-> @\value), set: (x) !-> @\value = x
    _name: get: (-> @\name), set: (x) !-> @\name = x }
  Object._properties HTMLInputElement::, ..
  Object._properties HTMLSelectElement::, ..

HTMLInputElement::=
  _checked:~
    (x) -> @\checked = x
    -> @\checked

  _placeholder:~
    (x) -> @\placeholder = x
    -> @\placeholder

HTMLButtonElement::=
  _disabled:~
    (x) -> @\disabled = x
    -> @\disabled

HTMLAnchorElement::=
  _target:~
    (x) -> @\target = x
    -> @\target

HTMLSelectElement::=
  _selected-index:~
    -> @\selectedIndex
    (x) -> @\selectedIndex = x

  _selected-options:~
    -> @\selectedOptions
    (x) -> @\selectedOptions = x

  _length:~ -> @\length

HTMLInputElement::=
  with-name: (x) -> @\name  = x ; @
  with-value: (x) -> @\value = x ; @

HTMLFormElement::=
  _elements:~
    -> @elements

  _toJSON: -> App._form._toJSON @
  _fromJSON: -> App._form._fromJSON @, it

HTMLCollection::=
  _length:~ -> @\length


App.B = Backbone


/**
 * {@code DOMTokenList} basic shortcuts.
 */
DOMTokenList::=
  _add    : ref$\add
  _remove : ref$\remove
  _toggle : ref$\toggle


/**
 * CSS properties.
 */
κ = (n) -> get: (-> @[n]), set: (x) !-> @[n] = x
Object._properties (CSS2Properties ? CSSStyleDeclaration)::, do
  _margin: κ \margin
  _font-size: κ \fontSize
  _display: κ \display
  _margin-top: κ \marginTop


/**
 * Extra {@code `_`} shortcuts.
 */
_ <<<
  _uniqueId: _\uniqueId
  _extend: _\extend
  _pick: _\pick
  _bind: _\bind
  _object: _\object
  _keys: _\keys
  _values: _\values


/**
 * Extra {@code `$.fn`} shortcuts.
 */
$\fn <<<
  html: ref$\html
  _append: ref$\append
  _parent: ref$\parent
  add-class: ref$\addClass
  remove-class: ref$\removeClass
  typeahead: ref$\typeahead
  _hide: ref$\hide
  _show: ref$\show


/**
 * HTML5: while support not implemented yet.
 */
# Maintain while HTML5 - bind not implemented (on testing)
(Function::bind = ->
  ((s, t, p) -> -> s.apply t, p)(@, [].shift.apply(&), &)) if not (->).bind

# Maintain while ECMA 6
if not String::endsWith
  (->
    defineProperty = (->
      try
        object = {}
        $defineProperty = Object.defineProperties
        result = ($defineProperty object, []) && $defineProperty
      catch
      result)!
    toString = {}.toString
    endsWith = (search) ->
      throw TypeError! if not this?
      string = String this
      if search && (toString.call search) is '[object RegExp]' then throw TypeError!
      stringLength = string.length
      searchString = String search
      searchLength = searchString.length
      pos = stringLength
      if &length > 1
        position = &.1
        if position isnt ``undefined``
          pos = if position then Number position else 0
          pos = 0 if not (pos is pos)
      end = Math.min (Math.max pos, 0), stringLength
      start = end - searchLength
      if start < 0 then return false
      index = -1
      while ++index < searchLength
        if not ((string.charCodeAt start + index) is searchString.charCodeAt index) then return false
      true
    if defineProperty
      defineProperty String.prototype, do
        endsWith: {
          value: endsWith
          configurable: true
          writable: true
        }
    else
      String::endsWith = endsWith)!

# Maintain while HTML5 - RadioNodeList not implemented yet
NodeList::=
  value:~
    ->
      for node in @
        if node.checked is yes
          return node.value
      ''
    !(value) ->
      for node in @
        if value == node.value
          node.checked = yes
          break
  _value:~
    ->
      for node in @
        if node.checked is yes
          return node.value
      ''
    !(value) ->
      for node in @
        if value == node.value
          node.checked = yes
          break



# vim: ts=2:sw=2:sts=2:et
