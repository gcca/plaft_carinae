# encoding: utf-8

"""
.. module:: domain.model
   :synopsis: Domain model layer.

.. moduleauthor:: Gonzales Castillo, Cristhian A. <cristhian.gz@aol.com>


"""

from __future__ import unicode_literals
from plaft.infrastructure.persistence.datastore import ndb as dom

JSONEncoder = dom.JSONEncoderNDB


class User(dom.User, dom.PolyModel):

    name = dom.String()
    role = dom.String()

    @property
    def customs(self):
        return NotImplemented


class Officer(User):

    code = dom.String()

    @property
    def customs(self):
        return Customs.query(Customs.officer == self.key).get()


class Employee(User):

    @property
    def customs(self):
        return Customs.query(Customs.employees == self.key).get()


class CodeName(dom.Model):

    code = dom.String()
    name = dom.String()


class Third(dom.Model):
    name = dom.String()
    identification_type = dom.String()
    third_type = dom.String()
    document_type = dom.String()
    document_number = dom.String()
    third_ok = dom.String()
    father_name = dom.String()
    mother_name = dom.String()


class Declarant(dom.Model):
    represents_to = dom.String()
    residence_status = dom.String()
    document_type = dom.String()
    document_number = dom.String()
    issuance_country = dom.String()
    name = dom.String()
    father_name = dom.String()
    mother_name = dom.String()
    nationality = dom.String()
    activity = dom.String()
    ciiu = dom.Structured(CodeName)
    position = dom.String()
    address = dom.String()
    ubigeo = dom.String()
    phone = dom.String()

    slug = dom.Computed(lambda s: '%s %s %s' % (s.name,
                                                s.father_name,
                                                s.mother_name))


class Linked(dom.Model):
    link_type = dom.String()
    customer_type = dom.String()
    document_type = dom.String()
    document_number = dom.String()
    issuance_country = dom.String()
    social_object = dom.String()
    country = dom.String()
    residence_status = dom.String()
    is_pep = dom.String()
    pep_position = dom.String()
    birthday = dom.String()
    name = dom.String()
    father_name = dom.String()
    mother_name = dom.String()
    nationality = dom.String()
    activity = dom.String()
    ciiu = dom.Structured(CodeName)
    position = dom.String()
    address = dom.String()
    employer = dom.String()
    average_monthly_income = dom.String()
    position = dom.String()
    ubigeo = dom.String()
    phone = dom.String()

    slug = dom.Computed(lambda s: s.name
                        if 'Juridica' == s.customer_type
                        else '%s %s %s' % (s.name,
                                           s.father_name,
                                           s.mother_name))


class Customer(dom.Model):

    name = dom.String()
    document_number = dom.String()
    document_type = dom.String()
    legal_identification = dom.String()
    condition = dom.String()
    address = dom.String()
    fiscal_address = dom.String()
    phone = dom.String()
    activity = dom.String()
    employment = dom.String()
    money_source = dom.String()
    ciiu = dom.Structured(CodeName)
    ubigeo = dom.String()
    is_obligated = dom.String()
    has_officer = dom.String()
    reference = dom.String()
    ruc = dom.String()

    third = dom.Structured(Third)

    ############ PERSON ####################
    father_name = dom.String()
    mother = dom.String()
    civil_state = dom.String()
    partner = dom.String()
    birthplace = dom.String()
    birthday = dom.String()
    mobile = dom.String()
    email = dom.String()
    nationality = dom.String()
    issuance_country = dom.String()


    ############ BUSINESS ####################
    class Shareholder(dom.Model):
        name = dom.String()
        document_number = dom.String()
        document_type = dom.String()
        ratio = dom.Text()

    shareholders = dom.Structured(Shareholder, repeated=True)
    social_object = dom.String()
    identification = dom.String()


class Dispatch(dom.Model):
    reference = dom.String()
    order = dom.String()
    regime = dom.Structured(CodeName)
    jurisdiction = dom.Structured(CodeName)
    description = dom.String()
    income_date = dom.String()
    customer = dom.Key(Customer)
    declaration = dom.Structured(Customer)
    declarant = dom.Structured(Declarant, repeated=True)
    linked = dom.Structured(Linked, repeated=True)

    # Numeration
    dam = dom.String()
    #diferencia entre el incomedate y el numerationdate
    numeration_date = dom.String()
    amount = dom.String()
    currency = dom.String()
    exchange_rate = dom.String()
    canal = dom.String()

# vim: et:ts=4:sw=4
