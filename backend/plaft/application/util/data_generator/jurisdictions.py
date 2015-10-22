# encoding: utf-8

from plaft.domain.model import CodeName

raw_jurisdiction = (
    # ('A NIVEL NACIONAL', '983'),
    ('AÉREA DEL CALLAO', '235'),
    # ('AEROPUERTO DE TACNA', '947'),
    # ('ALMACÉN SANTA ANITA', '974'),
    # ('AREQUIPA', '154'),
    # ('CETICOS - TACNA', '956'),
    # ('CHICLAYO', '055'),
    # ('CHIMBOTE', '091'),
    # ('COMPLEJO FRONTERIZO SANTA ROSA - TACNA', '929'),
    # ('CUSCO', '190'),
    # ('DEPENDENCIA FERROVIARIA TACNA', '884'),
    # ('DEPENDENCIA POSTAL DE AREQUIPA', '910'),
    # ('DEPENDENCIA POSTAL DE SALAVERRY', '965'),
    # ('DEPENDENCIA POSTAL TACNA', '893'),
    # ('DESAGUADERO', '262'),
    # ('ILO', '163'),
    # ('INTENDENCIA DE PREVENCIÓN Y CONTROL FRONTERIZO', '316'),
    # ('INTENDENCIA NACIONAL DE FISCALIZACIÓN ADUANERA (INFA)', '307'),
    # ('IQUITOS', '226'),
    # ('LA TINA', '299'),
    # ('LIMA METROPOLITANA', '992'),
    ('MARÍTIMA DEL CALLAO', '118'),
    # ('MOLLENDO - MATARANI', '145'),
    # ('OFICINA POSTAL DE LINCE', '901'),
    # ('PAITA', '046'),
    # ('PISCO', '127'),
    # ('POSTAL DE LIMA', '244'),
    # ('PUCALLPA', '217'),
    # ('PUERTO MALDONADO', '280'),
    # ('PUNO', '181'),
    # ('SALAVERRY', '082'),
    # ('SEDE CENTRAL - CHUCUITO', '000'),
    # ('TACNA', '172'),
    # ('TALARA', '028'),
    # ('TARAPOTO', '271'),
    # ('TERMINAL TERRESTRE TACNA', '928'),
    # ('TUMBES', '019'),
    # ('VUCE ADUANAS', '848')
)

jurisdictions = tuple(CodeName(name=j[0], code=j[1])
                      for j in raw_jurisdiction)


# vim: et:ts=4:sw=4
