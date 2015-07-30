/** @module app
 *
 * Basic datatypes.
 */


/** @export */
exports <<<
  /** @typedef */
  Serializable:
    _toJSON: -> @$el._toJSON!

  /** @typedef */
  Enum: class Enum
    (objKeys, i = 0) ->
      Object.getOwnPropertyNames objKeys .forEach (prop) !~>
        objKeys[prop] = ++i
        Object.defineProperty @, prop,
          Object.getOwnPropertyDescriptor objKeys, prop
      Object.freeze @

  /** Internal types */
  Types:
    /** @typedef */
    Field : new Enum do
      kLineEdit  : null
      kComboBox  : null
      kTextEdit  : null
      kCheckBox  : null
      kRadioGroup: null
      kView      : null
      kHidden    : null
      kYesNo     : null

    /**
     * @typedef {{
     *   _type: FieldType,
     *   _name: string,
     *   _label: string,
     *   _placeholder: string,
     *   _tip: string,
     *   _options: (Object|Array),
     *   _class: string,
     *   _head: string,
     *   _hide: boolean
     */
    Options:
      _type       : null
      _name       : null
      _label      : null
      _placeholder: null
      _tip        : null
      _options    : null
      _class      : null
      _head       : null
      _hide       : null  # change name

  /** @class Pool */
  Pool: class Pool
    (objects) ->
      @queue = new Array
      @objects = object

    _add: (object) ->
      @objects.push object
      @call!

    call: ->
      if @objects.length and @queue.length
        fn = @queue.shift!
        obj = @objects.shift!
        fn obj, @
      @

    act: (fn) ->
      @queue.push fn
      @call!

  /** @class ObjectPool */
  ObjectPool: class ObjectPool
    (Cls) ->
      @cls = Cls
      @metrics = new Object
      @_clearMetrics!
      @_objpool = new Array

    allocate: ->
      if 0 == @_objpool._length
        obj = new @cls ...
        @metrics.totalalloc++
      else
        obj = @_objpool._pop!
        @metrics.totalfree--
      obj.initialize.apply obj, &
      obj

    free: (obj) !->
      @_objpool._push obj
      @metrics.totalfree++
      for k in obj then delete! obj[k]
      # obj.initialize.call obj

    preAllocate: ->

    collect: (cls) !->
      @_objpool = new Array
      inUse = @metrics.totalalloc - @metrics.totalfree
      @_clearMetrics inUse

    _clearMetrics: (allocated) !->
      @metrics.totalalloc = allocated || 0
      @metrics.totalfree = 0

  /** @class Set */
  Set: class extends Array
    (_list) ->
      if _list? and _list._constructor is Array
        for e in _list
          @push e

    cardinality: -> @_length

    # in, not in

    is-disjoint: (other) ->

    is-subset: (other) ->  # <=, < : set <= other and set != other.

    is-superset: (other) ->  # >=, > : set >= other and set != other.

    union: (other) ->  # set | other | ...

    intersection: (other) ->  # set & other & ...

    difference: (other) ->  # set - other - ...

    symmetric_difference: (other) ->  # set ^ other

    copy: ->


# vim: ts=2:sw=2:sts=2:et
