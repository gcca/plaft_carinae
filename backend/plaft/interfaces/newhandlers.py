# encoding: utf-8
"""
.. module:: plaft.interfaces.handlers
   :synopsis: Handlers.

.. moduleauthor:: Gonzales Castillo, Cristhian A. <gcca@gcca.tk>


"""

from plaft.domain import model
from plaft.interfaces.newrest import RESTful


class Income(RESTful):

    _model = model.Dispatch

    def get(self):
        user_agency_key = self.user.customs_agency_key
        self.render_json(
            self.get_include(dispatch)
            for dispatch
            in self._model.query(
                self._model.customs_agency_key == user_agency_key
            ).order(self._model.order).fetch(100))

    @staticmethod
    def get_include(dispatch):
        settings = dispatch.to_dict(include=(
            'jurisdiction',
            'order',
            'regime',
            'income_date'
        ))
        customer = dispatch.customer
        settings['customer_name'] = (customer.name
                                     if type(customer) is model.Business
                                     else ('%s %s %s'
                                           % (customer.name,
                                              customer.father_name,
                                              customer.mother_name)))
        settings['customer_number'] = customer.document_number
        return settings


# vim: et:ts=4:sw=4
