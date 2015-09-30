"""
.. module:: domain.shared
   :synopsis: Pattern interfaces and support code for the domain layer.

.. moduleauthor:: Gonzales Castillo, Cristhian A. <gcca@gcca.tk>


"""


class Entity(object):
    """An entity """

    def sameIdentityAs(self, other):
        """ (Entity, Entity) -> bool

        Entities compare by identity, not by attributes

        Args:
          other (Entity): The other entity

        Returns:
          `True` if the identities are the same,
          regardles of other attributes
        """
        pass


class Repository(object):

    def find_all(self):
        return NotImplemented

    def find(self, key):
        return NotImplemented

    def store(self):
        return NotImplemented

    def delete(self):
        return NotImplemented


class ValueObject(object):
    pass


class Singleton(object):
    pass


class Factory(object):
    pass


# vim: et:ts=4:sw=4
