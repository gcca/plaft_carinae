# encoding: utf-8

"""
.. module:: plaft.domain.model
   :synopsis: Document models.

.. moduleauthor:: Gonzales Castillo, Cristhian A. <gcca@gcca.tk>


"""

from __future__ import unicode_literals

from plaft.infrastructure.persistence.datastore import ndb as dom


class Body(dom.Model):
    content = dom.Blob()
    source = dom.Blob()
    # header_key = dom.Key(kind='Header')  # circular for perfomance


class Header(dom.Model):
    title = dom.String()
    body_key = dom.Key(Body)
    parent_key = dom.Key(kind='Header')
    created = dom.DateTime(auto_now_add=True)


class Change(dom.Model):
    body_key = dom.Key(Body)
    content = dom.Text()
    start = dom.Integer()


# vim: et:ts=4:sw=4
