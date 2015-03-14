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
            raise RESTError('{"e":"No RESTHandler model class name:'
                            ' %s."}' % self.__name)

        super(RESTHandler, self).__init__(*args, **kwargs)

    def get(self, id=None):
        if id:
            try:
                instance = self.__model.find(int(id))
            except ValueError:
                self.status.BAD_REQUEST('{"e":"Bad id: %s"}' % id)
            else:
                if instance:
                    self.render_json(instance)
                else:
                    self.status.BAD_REQUEST('{"e":"Bad id: %s"}' % id)

        else:
            self.render_json(self.__model.all(**self.query))

    def post(self):
        query = self.query

        if query:
            if type(query) is list:  # create batch
                instances = []
                try:
                    for dto in query:
                        instance = self.__model.new(dto)
                        instance.store()
                        instances.append(instance)
                except IOError:
                    for instance in instances:
                        instance.delete()
                    self.status.INTERNAL_ERROR('{"e":"Internal store"}')
                else:
                    self.render_json(instance.id for instance in instances)
            else:  # create single
                instance = self.__model.new(query)
                try:
                    instance.store()
                except IOError:
                    self.status.INTERNAL_ERROR('{"e":"Internal store"}')
                else:
                    self.write_json('{"id":%d}' % instance.id)
        else:
            self.status.BAD_REQUEST('{"e":"No query"}')



class Customer(RESTHandler):
    pass


class Dispatch(RESTHandler):
    pass


# vim: et:ts=4:sw=4
