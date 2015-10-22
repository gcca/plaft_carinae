# encoding: utf-8

from plaft.domain.model import Declarant, CodeName


raw_declarants = (
    # (name, father_name, mother_name, address)
    ('Jesus', 'Peralta', 'Wiese', 'direccion'),
    ('Mariela', 'Trujillo', 'Suarez', 'direccion'),
    ('Jose Luis', 'Abanto', 'Somocursio', 'direccion'),
    ('Alfredo', 'Nakamura', 'Diaz', 'direccion'),
    ('Mariela', 'Mendoza', 'Lizandro', 'direccion'),
    ('Juana', 'Del Solar', 'Arrospide', 'direccion'),
    ('Nancy', 'Gamboa', 'Abelardo', 'direccion'),
    ('Luisa', 'Matias', 'Sarda', 'direccion'),
    ('Rosalia', 'Montenegro', 'Vinatea', 'direccion'),
    ('Henry', 'Mejia', 'Flor', 'direccion')
)

declarants = tuple(Declarant(name=j[0],
                             father_name=j[1],
                             mother_name=j[2],
                             # address=j[3],
                             represents_to='Ordenante',
                             residence_status='Residente',
                             document_type='dni',
                             document_number='09774462',
                             issuance_country='Perú',
                             # father_name='Suarez',
                             # mother_name='Perez',
                             # name='Luisa',
                             nationality='Peruana',
                             activity=('SECRETARIA, RECEPCIONISTA,'
                                       ' TELEFONISTA'),
                             ciiu=CodeName(code='18100',
                                           name=('FAB. DE PRENDAS'
                                                 ' DE VESTIR.')),
                             address='Av. Las Amapolas 569 Chacarilla',
                             ubigeo=CodeName(code='150115',
                                             name=('LIMA - LIMA -'
                                                   ' LA VICTORIA')),
                             phone='511 336-5812 Anexo 80',
                             position='Gerente de operaciones')
                   for j in raw_declarants)


# vim: et:ts=4:sw=4
