# encoding: utf-8

"""
.. module:: plaft.application.util
   :synopsis: Provides minial data to work.

.. moduleauthor:: Gonzales Castillo, Cristhian A. <gcca@gcca.tk>


"""

from plaft.domain import model


def create_alerts():
    """Main alerts."""
    from plaft.application.util.data_generator.alerts import alerts
    for section, code, description in alerts:
        alert = model.Alert(section=section,
                            code=code,
                            description=description)
        alert.store()


# vim: et:ts=4:sw=4
