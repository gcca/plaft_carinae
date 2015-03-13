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








class Customer(dom.Model):

    name = dom.String()
    document_number = dom.String()
    document_type = dom.String()

# vim: et:ts=4:sw=4
