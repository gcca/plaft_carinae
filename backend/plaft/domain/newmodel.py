# encoding: utf-8

from __future__ import unicode_literals

from plaft.infrastructure.persistence.datastore import ndb as dom
from plaft.domain.model.structs import CodeName, Third, Document
from plaft.domain.model import CustomsAgency


class Stakeholder(dom.Model):
    """."""
    name = dom.String()
    address = dom.String()
    phone = dom.String()
    country = dom.String()

    slug = dom.Computed(lambda s: s.name)

class Customer(dom.Model):
    """."""
    document_number = dom.String()
    document_type = dom.String()
    name = dom.String()
    address = dom.String()


class Dispatch(dom.Model):
    """."""
    order = dom.String()
    income_date = dom.Date()
    regime = dom.Structured(CodeName)
    jurisdiction = dom.Structured(CodeName)
    exchange_rate = dom.Decimal()
    amount = dom.Decimal()
    dam = dom.String()
    numeration_date = dom.Date()
    channel = dom.String()
    reference = dom.String()
    customer_key = dom.Key(Customer)
    customs_agency_key = dom.Key(CustomsAgency)
    stakeholders = dom.Structured(Stakeholder, repeated=True)


    def to_dto(self):
        dct = super(Dispatch, self).to_dto()
        dct['declaration'] = {
            'customer': self.customer
        }
        del dct['customer']
        return dct


# vim: et:ts=4:sw=4
