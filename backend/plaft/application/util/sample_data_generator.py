# encoding: utf-8
"""
.. module:: plaft.application.util
   :synopsis: Provides sample data.

.. moduleauthor:: Gonzales Castillo, Cristhian A. <gcca@gcca.tk>


"""

from __future__ import unicode_literals
from plaft.domain.model import (Datastore, CustomsAgency,
                                Officer, Permissions, Admin)
from plaft.application.util import data_generator


def _create_sample_data():
    if CustomsAgency.find(name='CavaSoft SAC'):
        return

    ca = CustomsAgency(name='CavaSoft SAC')
    ca.store()

    ds = Datastore(customs_agency_key=ca.key,
                   alerts_key=[])
    ds.store()

    perms = Permissions(modules=data_generator.permissions.officer)
    perms.store()

    of = Officer(customs_agency_key=ca.key,
                 name='César Vargas',
                 username='cesarvargas@cavasoftsac.com',
                 password='123',
                 permissions_key=perms.key)
    ca.officer_key = of.store()
    ca.store()

    da = Admin(name='Cesar Vargas',
               username='cesarvargas@cavasoftsac.com',
               password='123')
    da.store()


def create_sample_data():
    from plaft.application.util.data_generator import init
    init()
    _create_sample_data()

# vim: et:ts=4:sw=4
