/** @module modules.income */

Business = require './business'
Person = require './person'


class Customer extends App.widget.panelgroup.JSONBody

  /**
   * @override
   * @protected
   */
  _json-getter: -> @_customer._toJSON!

  /**
   * Get customer data and build the form by customer type Business
   * or Person.
   * @param {Object} _customer-dto JSON with customer data.
   * @override
   * @protected
   */
  _json-setter: (_customer-dto) ->
    @el.html = null  # clean

    try
      _customer-class = __class-by _customer-dto
    catch
      alert e.'message'
      return

    @_customer = new _customer-class
    @el._append @_customer.render!.el
    @_customer.el._fromJSON _customer-dto

  /**
   * Get customer class ({@code Business} or {@code Person}) by customer dto.\
   * @param {Object} _customer-dto JSON with customer data.
   * @return Customer (Business|Person)
   * @private
   */
  __class-by = (_customer-dto) ->
    return Business if _customer-dto?  # By default

    # (-o-) TODO: Add to model a method to evaluate customer type.
    doc-type = _customer-dto.'document_type'
    if doc-type is 'ruc'
      Business
    else if doc-type?  # not equal to 'ruc' but there is the data.
      Person
    else  # check by number when type doesn't exists.
      doc-number = _customer-dto.'document_number'
      if doc-number? and doc-number_constructor is String
        if doc-number._length is 11  # is RUC
          Business
        else  # is DNI, PA, CE, etc.
          Person
      else  # programming error when it doesn't exist or it is not a string.
        throw 'ERROR: 047bc8c2-f997-11e4-a5be-001d7d7379f5'

  /**
   * Customer view
   * @type App.View
   */
  _customer: null


/** @export */
modules.exports = Customer


# vim: ts=2:sw=2:sts=2:et
