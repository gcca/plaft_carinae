# encoding: utf-8

"""
User default permissions.

"""


module = {  # TODO: `None`s are temporal. See next `TODO`
    'welcome': None,         # pantalla inicial
    'income': None,          # ingreso de operación
    'numeration': None,      # numeración
    'operation': None,       # anexo 2
    'alerts': None,          # identificación de señales de alerta
    'monthly_report': None,  # reporte mensual
    'report': None,          # anexo 6
    'register': None,        # registrar anexo 6
    'preview_multi': None,   # contador de montos (preview de múltiples)
    'operation-list': None,  # lista de operaciones (cierre mensual)
    'simulate': None,        # simulación (operaciones múltiples)
}

for name in module:  # TODO: Remove when create module auth system
    module[name] = 'auth-hash-' + name


# Officer permissions
officer = [m_hash for _, m_hash in module.items()]


# Employee permissions
employee = [
    module['welcome'],
    module['income'],
    module['numeration'],
    module['alerts'],
    module['operation'],
    module['monthly_report'],
    module['report']
]


# vim: et:ts=4:sw=4
