# encoding: utf-8
"""
.. module:: plaft.interfaces.handlers
   :synopsis: Handlers.

.. moduleauthor:: Gonzales Castillo, Cristhian A. <cristhian.gz@aol.com>


"""

from plaft.interfaces import Handler
from plaft.domain import model


class Customer(object):
    """."""

    class by_document(Handler):
        """."""

        def get(self):
            """."""
            number = self.request.get('number')
            customer = model.Customer.find({'document.number': number})
            if customer:
                self.render_json(customer)
            else:
                self.status.NOT_FOUND('No document number: ' + number)


class Dispatch(Handler):
    """."""

    def get(self):
        self.render_json(model.Dispatch.all(customs=self.user.customs.key))

    class find(Handler):

        def get(self):
            order = self.request.get('order')
            dispatch = model.Dispatch.find(order=order)
            if dispatch:
                self.render_json(dispatch)
            else:
                self.status.NOT_FOUND('No order: ' + order)

    class income(Handler):

        def get_by_document(self, number):
            customer = model.Customer.find({'document.number': number})
            if customer:
                return {
                    'customer': customer,
                    'dispatch': model.Dispatch()
                }

        def get_by_order(self, order_number):
            dispatch = model.Dispatch.find(order=order_number)
            if dispatch:  # query is order
                return {
                    'id': dispatch.id,
                    'dispatch': dispatch,
                    'customer': dispatch.customer.get()
                }

        def get(self):
            query = self.request.get('query')
            by_filter = self.request.get('by')

            if by_filter:
                if 'document' == by_filter:
                    res = self.get_by_document(query)
                    msg = 'document'
                elif 'order' == by_filter:
                    res = self.get_by_order(query)
                    msg = 'order'

                if res:
                    return self.render_json(res)
                else:
                    self.status.NOT_FOUND('No %s number: %s' % (msg, query))
            else:
                #if query:
                dispatch = model.Dispatch.find(order=query)
                if dispatch:  # query is order
                    self.render_json({
                        'id': dispatch.id,
                        'dispatch': dispatch,
                        'customer': dispatch.customer.get()
                    })
                else:  # query is document number
                    customer = \
                        model.Customer.find({'document.number': query})
                    if customer:
                        self.render_json({
                            'customer': customer,
                            'dispatch': model.Dispatch()
                        })
                    else:
                        self.status.NOT_FOUND(
                            'No order or document number: ' + query)

        def post(self):
            payload = self.json

            customer_dto = payload['customer']
            dispatch_dto = payload['dispatch']

            customer = model.Customer.query(
                model.Customer.document == model.Document(
                    number=customer_dto['document']['number'])).get()

            if not customer:
                # TODO: MODIFY to avoid "if"
                if 8 == len(customer_dto['document']['number']):
                    customer = model.Person()
                else:
                    customer = model.Business()

            customer << customer_dto
            customer.store()

            declaration = model.Declaration.new(customer_dto)
            declaration.store()

            #dispatch_dto['customer'] = customer.key
            #dispatch_dto['declaration'] = declaration.key
            dispatch = model.Dispatch.new(dispatch_dto)
            dispatch.customer = customer.key
            dispatch.declaration = declaration.key
            dispatch.customs = self.user.customs.key

            dispatch.store()

            self.write_json('{"id":%s}' % dispatch.id)

        def put(self, id):
            payload = self.json

            customer_dto = payload['customer']
            dispatch_dto = payload['dispatch']

            customer = model.Customer.query(
                model.Customer.document == model.Document(
                    number=customer_dto['document']['number'])).get()

            if not customer:
                customer = model.Customer()

            customer << customer_dto
            customer.store()

            #dispatch_dto['customer'] = customer.key
            #dispatch_dto['declaration'] = declaration.key
            dispatch = model.Dispatch.find(int(id))
            dispatch.customer = customer.key

            # update declaration
            if dispatch.declaration:
                declaration = dispatch.declaration.get()
            else:
                declaration = model.Declaration()

            declaration << dispatch_dto
            declaration.store()

            # TODO: Abstraction
            if not dispatch.declaration:
                dispatch.declaration = declaration.key

            dispatch << dispatch_dto
            dispatch.store()

            self.write_json('{}')

class Stakeholder(Handler):

    def get(self, id=None):

        stakeholder = model.Stakeholder.find(int(id))
        if stakeholder:
            self.render_json(stakeholder)
        else:
            self.status.BAD_REQUEST('No toques el código')


class Numeration(Handler):

    def put(self, id):
        dispatch = model.Dispatch.find(int(id))
        dispatch << self.json
        try:
            dispatch.store()
        except:
            self.status.INTERNAL_ERROR('Update error: 46XC.')
        else:
            self.write_json('{}')


# vim: et:ts=4:sw=4
