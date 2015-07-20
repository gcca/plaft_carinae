# encoding: utf-8

"""
.. module:: plaft.interfaces.sys
   :synopsis: System internal processes handlers.

.. moduleauthor:: Gonzales Castillo, Cristhian A. <gcca@gcca.tk>


"""

from plaft.interfaces import route


@route
def sys_datastore(handler):
    handler.write('PLAFT-sw')


# vim: et:ts=4:sw=4
