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


class MetaAdmin(type):

    def __init__(self, *args, **kwargs):
        self._user_model = model.Admin


class AdminFixin(object):

    __metaclass__ = MetaAdmin


class AdminSite(DirectToController, AdminFixin):

    controller = 'admin'

    def _args(self):
        self.add_arg('user', self.user)
        self.add_arg('cs', model.CustomsAgency.all())


class Admin(DirectToController):
    """Welcome and sign in controller for users."""

    def post(self):
        """Login user."""

        username = self.request.get('username')
        password = self.request.get('password')

        user = model.Admin.authenticate(username, password)

        if user:
            self.login(user)
            print self.user
            self.redirect('/admin/site')
        else:
            self.write_template('e:-1')


class views(object):
    Admin = Admin
    AdminSite = AdminSite


# handlers

class Officer(Handler, AdminFixin):

    def get(self):
        users = [customs.officers for customs in model.CustomsAgency.all()]
        self.render_json(users)

    def post(self):
        payload = self.query
        agency_name = payload['agency']
        username = payload['username']
        password = payload['password']
        officer_name = payload['name']
        customs_agency = model.CustomsAgency(name=agency_name)
        customs_agency.store()
        alerts_key = [a.key for a in model.Alert.query().fetch()]
        from plaft.application.util.data_generator import permissions
        permission = model.Permissions(modules=permissions.officer,
                                       alerts_key=alerts_key)
        permission.store()

        datastore = model.Datastore(customs_agency_key=customs_agency.key)
        datastore.store()

        officer = model.Officer(username=username,
                                password=password,
                                name=officer_name,
                                customs_agency_key=customs_agency.key,
                                permissions_key=permission.key)
        officer.store()

        customs_agency.officer_key = officer.key
        customs_agency.store()
        self.render_json({'id': customs_agency.id})

    def put(self, id):
        payload = self.query
        agency_name = payload['agency']
        customs_agency = model.CustomsAgency.find(int(id))
        customs_agency.name = agency_name
        customs_agency.store()

        del payload['agency']

        officer = customs_agency.officer
        officer << payload
        officer.store()

        self.write_json('{}')

    def delete(self, id):
        customs_agency = model.CustomsAgency.find(int(id))
        customs_agency.delete()


class handlers(object):
    Officer = Officer

# vim: et:ts=4:sw=4
