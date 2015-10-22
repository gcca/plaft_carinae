# encoding: utf-8

from plaft.domain.model import CodeName

raw_regimes = (
    ('Importacion para el Consumo', '10'),
    # ('Reimportacion en el mismo Estado', '36'),
    # ('Exportacion Definitiva', '40'),
    # ('Exportacion Temporal para Reimportacion en el mismo Estado', '51'),
    # ('Exportacion Temporal para Perfeccionamiento Pasivo', '52'),
    # ('Admision temporal para Perfeccionamiento Activo', '21'),
    # ('Admision temporal para Reexportacion en el mismo Estado', '20'),
    ('Drawback', '41'),
    # ('Reposicion de Mercancias con Franquicia Arancelaria', '41'),
    # ('Deposito Aduanero', '70'),
    # ('Reembarque', '89'),
    # ('Transito Aduanero', '80'),
    # ('Importacion Simplificada', '18'),
    # ('Exportacion Simplificada', '48'),
    # ('Material de Uso Aeronautico', '71'),
    # ('Destino Especial de Tienda Libre (DUTY FREE)', '72'),
    # ('Rancho de naves', '99'),
    # ('Material de Guerra', '99'),
    # ('Vehiculos para Turismo', '99'),
    # ('Material uso Aeronautico', '99'),
    # ('Ferias o Exposiciones Internacionales', '20')
)

regimes = tuple(CodeName(name=j[0], code=j[1]) for j in raw_regimes)


# vim: et:ts=4:sw=4
