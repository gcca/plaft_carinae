# encoding: utf-8

"""
.. module:: plaft.application.util
   :synopsis: Provides minial data to work.

.. moduleauthor:: Gonzales Castillo, Cristhian A. <gcca@gcca.tk>


"""

from __future__ import unicode_literals

from plaft.domain import model
from plaft.application.util.data_generator import permissions


__all__ = ['init']


def create_alerts():
    """Main alerts."""
    from plaft.application.util.data_generator.alerts import alerts
    for section, code, description, help in alerts:
        alert = model.Alert(section=section,
                            code=code,
                            description=description)
        alert.store()


def create_documents():
    """Public documents."""
    import pickle
    from plaft.application.util.data_generator.documents import document

    def docu(name):
        return document[name.encode('utf8').upper()]

    def doc(name):
        return document[name.encode('utf8')]

    TEND = None

    # node[0] : title
    # node[1] : sub tree if iterable
    # node[1] : body if text
    tree = (
        ('Base legal', (
            ('SBS - UIF Perú', (
                ('Ley creación UIF Perú', (
                    ('Ley N° 27693', docu('Ley N° 27693')),
                    ('Ley N° 28306', docu('Ley N° 28306')),
                    ('Ley N° 29038', docu('Ley N° 29038')),
                    ('D. Leg. N° 1106', docu('D. Leg. N° 1106')),
                )),
                ('Reglamento UIF', (
                    ('DS N° 018-2006-JUS', docu('DS N° 018-2006-JUS')),
                )),
            )),
            ('SO Despachadores de aduana', (
                ('RESOL. SBS N° 2249-2013',
                 doc('RESOL. SBS N° 2249-2013')),
                ('RESOL. SBS N° 2249-2013 Anexo N° 1',
                 doc('RESOL. SBS N° 2249-2013 Anexo N° 1')),
                ('RESOL. SBS N° 2249-2013 Anexo N° 2',
                 doc('RESOL. SBS N° 2249-2013 Anexo N° 2')),
                ('RESOL. SBS N° 2249-2013 Anexo N° 3',
                 doc('RESOL. SBS N° 2249-2013 Anexo N° 3')),
                ('RESOL. SBS N° 2249-2013 Anexo N° 3-A',
                 # ERROR: doc name
                 doc('RESOL. SBS N° 2249-2013 Anexo N° 3°A')),
                ('RESOL. SBS N° 2249-2013 Anexo N° 3-B',
                 # ERROR: doc name
                 doc('RESOL. SBS N° 2249-2013 Anexo N° 3°B')),
                ('RESOL. SBS N° 2249-2013 Anexo N° 4',
                 doc('RESOL. SBS N° 2249-2013 Anexo N° 4')),
                ('RESOL. SBS N° 2249-2013 Anexo N° 4-A',
                 # ERROR: doc name
                 doc('RESOL. SBS N° 2249-2013 Anexo N° 4A')),
                ('RESOL. SBS N° 2249-2013 Anexo N° 5',
                 doc('RESOL. SBS N° 2249-2013 Anexo N° 5')),
                ('RESOL. SBS N° 2249-2013 Anexo N° 6',
                 doc('RESOL. SBS N° 2249-2013 Anexo N° 6')),
                ('RESOL. SBS N° 5388-2013',
                 doc('RESOL. SBS N° 5388-2013')),
                ('RESOL. SBS N° 3227-2014',
                 doc('RESOL. SBS N° 3227-2014')),
                ('RESOL. SBS N° 6414-2014',
                 doc('RESOL. SBS N° 6414-2014')),
            )),
            ('Infracciones y sanciones', (
                ('RESOL. SBS N° 9999-2015', TEND),
            )),
        )),
        ('Manuales PLA/FT', (
            ('Manual PLA/FT', (
                ('Manual - Anexo N° 3', TEND),
                ('DJ de recepción y conocimiento del manual', TEND),
                ('DJ de antecedentes personales, laborales y patrimoniales',
                 TEND),
            )),
            ('Código Conducta PLA/FT', (
                ('DJ de recepción y conocimiento del código de conducta',
                 TEND),
            )),
        )),
        ('Procedimientos', (
            ('Conocimiento del cliente', (
                ('Identificación del cliente', TEND),
                ('Régimen reforzado', TEND),
            )),
            ('Perfiles de clientes', TEND),
        )),
        ('Títulos de temas', TEND),
    )

    from plaft.domain.model.documents import Header, Body

    def create(parent_key, subtree):
        for node in subtree:
            header = Header(title=node[0], parent_key=parent_key)
            new_parent_key = header.store()
            if node[1]:
                if isinstance(node[1], tuple):
                    create(new_parent_key, node[1])
                else:
                    body = Body(content=node[1]['html'],
                                source=pickle.loads(node[1]['pdf']))
                    header.body_key = body.store()
                    header.store()

    create(None, tree)


def init():
    """Initialize datastore."""
    plaft = model.Plaft.query().get()

    if not plaft:
        plaft = model.Plaft()
        plaft.store()

    if not plaft.has_datastore:
        create_alerts()
        create_documents()

        plaft.has_datastore = True
        plaft.store()


# vim: ts=4:sw=4:sts=4:et
