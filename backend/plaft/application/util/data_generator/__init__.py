# encoding: utf-8

"""
.. module:: plaft.application.util
   :synopsis: Provides minial data to work.

.. moduleauthor:: Gonzales Castillo, Cristhian A. <gcca@gcca.tk>


"""

from __future__ import unicode_literals

from plaft.domain import model
from plaft.application.util.data_generator import (permissions, declarants,
                                                   regimes, jurisdictions,
                                                   stakeholders, alerts)


__all__ = ['init']


def init():
    """Initialize datastore."""
    plaft = model.Plaft.query().get()

    if not plaft:
        plaft = model.Plaft()
        plaft.store()

    if not plaft.has_datastore:

        plaft.has_datastore = True
        plaft.store()


# vim: ts=4:sw=4:sts=4:et
