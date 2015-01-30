# encoding: utf-8

"""
.. module:: domain.model
   :synopsis: Domain model layer.

.. moduleauthor:: Gonzales Castillo, Cristhian A. <cristhian.gz@aol.com>


"""

from __future__ import unicode_literals
from plaft.infrastructure.persistence.datastore import ndb as dom

JSONEncoder = dom.JSONEncoderNDB


class Document(dom.Model):
    """Identification document.

    Use value object for entities with identification document.

    Attributes:
        type: A string document type (RUC, DNI, etc).
        number: A string document number.
    """

    type_choices = ['DNI', 'RUC', 'Pasaporte', 'Carné de Extranjería']

    type = dom.String()  # (choices=type_choices)
    number = dom.String()




# User hierarchy

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


# Customs

class Customs(dom.Model):

    name = dom.String()
    code = dom.String()
    officer = dom.Key(Officer)
    employees = dom.Key(Employee, repeated=True)


# Customer

class CustomerBase(dom.Model):

    # customer
    person_type = dom.String()
    customer_type = dom.String()
    validity = dom.String()

    name = dom.String()
    document = dom.Structured(Document)
    social_object = dom.String()
    activity = dom.String()

    address = dom.String()
    phone = dom.String()

    ubigeo = dom.String()

    # person
    father_name = dom.String()
    mother_name = dom.String()
    ruc = dom.String()
    birthday = dom.String()

    # business
    salesman = dom.String()
    fiscal_address = dom.String()
    ubigeo_department = dom.String()
    ubigeo_province = dom.String()
    ubigeo_district = dom.String()
    contact = dom.String()

    is_obliged = dom.String()
    has_officer = dom.String()

class Customer(CustomerBase, dom.PolyModel):
    pass

class Person(Customer):

    @property
    def isbusiness(self):
        return False

    @property
    def isperson(self):
        return True

class Business(Customer):

    class Shareholder(dom.Model):
        """Customer shareholder.

        Attributes:
        document: A Document value object.
        name: A string shareholder name.
        """

        name = dom.String()
        document = dom.Structured(Document)
        ratio = dom.Text()

    shareholders = dom.Structured(Shareholder, repeated=True)

    @property
    def isbusiness(self):
        return True

    @property
    def isperson(self):
        return False

# Stakeholders

class Stakeholder(dom.Model):

    name = dom.String()
    link_type = dom.String()
    customer_type = dom.String()
    social_object = dom.String()
    address = dom.String()
    phone = dom.String()
    country = dom.String()

    represents_to = dom.String()
    residence_status = dom.String()
    document = dom.Structured(Document)
    issuance_country = dom.String()
    father_name = dom.String()
    mother_name = dom.String()
    # name = dom.String()
    nationality = dom.String()
    activity = dom.String()

    activity_description = dom.String()
    position = dom.String()
    average_monthly_income = dom.String()
    employer = dom.String()
    birthday = dom.String()

    pep_position = dom.String()
    is_pep = dom.String()

    slug = dom.Computed(lambda s: s.name
                                  if 'Jurídica' == s.customer_type
                                  else '%s %s %s' % (s.name,
                                                     s.father_name,
                                                     s.mother_name))


# Operations

class Declaration(CustomerBase):

    money_source = dom.Text()
    reference = dom.String()

    third = dom.String()

class CodeName(dom.Model):

    code = dom.String()
    name = dom.String()

class Dispatch(dom.Model):

    # Income
    reference = dom.String()
    order = dom.String()
    regime = dom.Structured(CodeName)
    jurisdiction = dom.Structured(CodeName)
    description = dom.String()
    # declaration = dom.Structured(Declaration)

    declaration = dom.Key(Declaration)
    customer = dom.Key(Customer)

    customs = dom.Key(Customs)

    linked = dom.Structured(Stakeholder, repeated=True)
    declarant = dom.Structured(Stakeholder)

    # Numeration
    dam = dom.String()
    numeration_date = dom.String()
    amount = dom.String()
    currency = dom.String()
    exchange_rate = dom.String()


# vim: et:ts=4:sw=4
