# encoding: utf-8

"""
.. module:: plaft.interfaces.views
   :synopsis: Views.

.. moduleauthor:: Gonzales Castillo, Cristhian A. <cristhian.gz@aol.com>


"""

from plaft.interfaces import Handler, DirectToController
from plaft.domain.model import User


class SignIn(DirectToController):
    """Welcome and sign in controller for users."""

    def post(self):
        """Login user."""

        username = self.request.get('username')
        password = self.request.get('password')

        user = User.authenticate(username, password)

        if user:
            self.login(user)
            self.redirect('/dashboard')
        else:
            self.write_template('e:-1')


class Dashboard(DirectToController):
    """Users dashboard."""


class Debug(Handler):
    """Only use to handtest."""

    def get(self):
        """Create entities."""
        from plaft.application.util import sample_data_generator
        sample_data_generator.users()
        self.write('Don\'t worry... Be happy.')

    def post(self):
        """Delete entities."""
        from plaft.infrastructure.persistence.datastore.ndb import Model
        import google.appengine.ext.ndb as ndb
        from plaft.domain import model
        ndb.delete_multi(v for m in
                         [getattr(model, i) for i in dir(model)
                          if type(getattr(model, i)) is ndb.model.MetaModel]
                         for v in m.query().fetch(keys_only=True))
        self.write('The End.')


# vim: et:ts=4:sw=4
