# encoding: utf-8

from plaft.domain.model import Stakeholder

raw_stakeholders = (
    # (document_type, name, address)
    ('ruc', 'Breaker Tecnology, Ltd.', 'direccion'),
    ('ruc', 'Empresa Pinto S.A.', 'direccion'),
    ('ruc', 'Ford Motor Corporation Inc', 'direccion'),
    ('ruc', 'Guangdong Textiles Imp.and Exp.Co.LTD', 'direccion'),
    ('ruc', 'INTAI SPA', 'direccion'),
    ('ruc', 'Idustria AVM S.A.', 'direccion'),
    ('ruc', 'MIQ Global LLC DBA MIQ Logistics', 'direccion'),
    ('ruc', 'Nestle Chile S.A.', 'direccion'),
    ('ruc', 'Prov Blue Diamont', 'direccion'),
    ('ruc', 'Prov Diesel', 'direccion'),
    ('ruc', 'Prov Hielos', 'direccion'),
    ('ruc', 'Prov Romovic', 'direccion'),
    ('ruc', 'Rubbermix S.A.S.', 'direccion'),
    ('ruc', 'Samsung Electronics CO., LTD', 'direccion'),
    ('ruc', 'Shu Far Enterprise Co. Ltd.', 'direccion')
)

stakeholders = tuple(Stakeholder(document_type=j[0],
                                 name=j[1],
                                 address=j[2],
                                 social_object='Fabricante',
                                 activity='Mayorista',
                                 # address='Por averiguar',
                                 phone='025 4566-56',
                                 country='Brasil')
                     for j in raw_stakeholders)


# vim: et:ts=4:sw=4
