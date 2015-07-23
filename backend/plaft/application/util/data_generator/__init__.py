# encoding: utf-8

"""
.. module:: plaft.application.util
   :synopsis: Provides minial data to work.

.. moduleauthor:: Gonzales Castillo, Cristhian A. <gcca@gcca.tk>


"""

from plaft.domain import model


__all__ = ['init']


def create_alerts():
    """Main alerts."""
    from plaft.application.util.data_generator.alerts import alerts
    for section, code, description in alerts:
        alert = model.Alert(section=section,
                            code=code,
                            description=description)
        alert.store()


def init():
    """Initialize datastore."""
    plaft = model.Plaft.query().get()

    if not plaft:
        plaft = model.Plaft()
        plaft.store()

    if not plaft.has_datastore:
        create_alerts()

        plaft.has_datastore = True
        plaft.store()


# vim: et:ts=4:sw=4
