# encoding: utf-8
"""
.. module:: plaft.interfaces.admin
   :synopsis: Admin view and handlers.

.. moduleauthor:: Gonzales Castillo, Cristhian A. <gcca@gcca.tk>


"""

from plaft.interfaces import Handler, DirectToController
from plaft.domain import model


__all__ = ['views', 'handlers']


# views

class AdminSite(DirectToController):

    controller = 'admin'

    def _args(self):
        customs = self.JSON.dumps(model.Customs.all())
        return 'cs:' + customs


class views(object):
    AdminSite = AdminSite


# handlers

class Officer(Handler):

    def post(self, customs_id):
        customs = model.Customs.find(int(customs_id))
        officer = model.Officer.new(self.json)
        try:
            officer.store()
            customs.officer_key = officer.key
            customs.store()
        except:
            self.status.INTERNAL_ERROR('Store error: 167SDQBE.')
        else:
            self.write_json('{"id":%s}' % officer.id)

    def put(self, customs_id, id):
        officer = model.Officer.find(int(id))
        officer << self.json
        try:
            officer.store()
        except:
            self.status.INTERNAL_ERROR('Store error: 708SCVE.')
        else:
            self.write_json('{}')


class Employee(Handler):

    def post(self, customs_id):
        customs = model.Customs.find(int(customs_id))
        officer = model.Employee.new(self.json)
        try:
            officer.store()
            customs.employees_key.append(officer.key)
            customs.store()
        except:
            self.status.INTERNAL_ERROR('Store error: 167SDQBE.')
        else:
            self.write_json('{"id":%s}' % officer.id)

    def put(self, customs_id, id):
        officer = model.Employee.find(int(id))
        officer << self.json
        try:
            officer.store()
        except:
            self.status.INTERNAL_ERROR('Store error: 708SCVE.')
        else:
            self.write_json('{}')


class Customs(Handler):

    def post(self):
        customs = model.Customs.new(self.json)
        try:
            customs.store()
        except:
            self.status.INTERNAL_ERROR('Store error: 78RT4.')
        else:
            self.write_json('{"id":%s}' % customs.id)

    def put(self, id):
        customs = model.Customs.find(int(id))
        customs << self.json
        try:
            customs.store()
        except:
            self.status.INTERNAL_ERROR('Store error: 78RT4.')
        else:
            self.write_json('{"id":%s}' % customs.id)


class handlers(object):
    AdminSite = AdminSite
    Officer = Officer
    Employee = Employee
    Customs = Customs

# vim: et:ts=4:sw=4
