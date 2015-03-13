# encoding: utf-8
"""
.. module:: plaft.interfaces.handlers
   :synopsis: Handlers.

.. moduleauthor:: Gonzales Castillo, Cristhian A. <gcca@gcca.tk>


"""

from plaft.interfaces import Handler
from plaft.domain import model


class RESTError(Exception):
    pass

class RESTHandler(Handler):


    def __init__(self, *args, **kwargs):
        self.__name = self.__class__.__name__

        try:
            self.__model = getattr(model, self.__name)
        except AttributeError:
            raise RESTError('No RESTHandler model class name:'
                            ' %s.' % self.__name)

        super(RESTHandler, self).__init__(*args, **kwargs)

    def get(self, id=None):
        if id:
            try:
                instance = self.__model.find(int(id))
            except ValueError:
                self.status.BAD_REQUEST('Bad id: ' + id)
            else:
                if instance:
                    self.render_json(instance)
                else:
                    self.status.BAD_REQUEST('Bad id: ' + id)

        else:
            self.render_json(self.__model.all(**self.query))


class Customer(RESTHandler):
    pass


# vim: et:ts=4:sw=4
