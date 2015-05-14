/** @module modules */

FieldType = App.builtins.Types.Field
DOCUMENT_TYPE_PAIR = App.lists.document-type._pair

panelgroup = App.widget.panelgroup


class Customer extends App.View

  /** @override */
  _tagName: \form

  /**
   * Customer form to JSON.
   * @return Object
   * @protected
   */
  _toJSON: -> @el._toJSON!

  /**
   * See Business and Person initialize and their events.
   * @see initialize
   * @private
   */ form-builder: null


/** @export */
module.exports = Customer


# vim: ts=2:sw=2:sts=2:et
