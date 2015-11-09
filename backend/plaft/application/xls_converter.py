# encoding: utf-8
from plaft.domain import model

DISPATCH_HEADER = {
    'NRO ORDEN': 'order',
    'F. ORDEN': 'income_date',
    'REG': 'regime',
    'ADU': 'jurisdiction',
    'FACT.$': 'exchange_rate',
    'FOB US$': 'amount',
    'DUA': 'dam',
    'F. DAM': 'numeration_date',
    'C': 'channel',
    'RUCCLIENTE': 'document_number',
    'RAZON SOCIAL CLIENTE': 'name',
    'NUMEROOC': 'reference',
    'DIRECCION CLIENTE': 'address',
    'COD UBIC.GEOG': 'ubigeo'
}

STAKEHOLDER_HEADER = {
    'NRO ORDEN': 'order',
    'NOMBRE PROVEEDOR': 'name',
    'DIRECCION PROVEEDOR': 'address',
    'TELEFONO': 'phone',
    'CP': 'country'
}

# => return List<{'order': value_in_xls}>


def converter(workbook, XLSDTO, index=4):
    sheet = workbook[workbook.get_sheet_names()[0]]
    s = 65
    H2K = {}

    while True:
        text = sheet['%s%d' %(chr(s), index)].value
        if not text or text is '':
            break
        H2K[text] = chr(s)
        s = s + 1
    lts = []
    row = index + 1

    while True:
        dct = {}
        for k in XLSDTO:
            text = sheet['%s%s' %(H2K[k], row)].value
            dct[XLSDTO[k]] = text

        if not dct['order']:
            break
        lts.append(dct)
        row = row + 1

    return lts


def dto2dispatch(dtos):
    from plaft.application.util import data_generator

    jurisdictions = data_generator.jurisdictions.jurisdictions
    regimes = data_generator.regimes.regimes

    dispatches = []
    for payload in dtos:
        payload['customer'] = {
            'document_number': payload['document_number'],
            'document_type': 'ruc',
            'name': payload['name'],
            'address': payload['address']
        }
        document_number = payload['customer']['document_number']
        c = model.Customer.find(document_number=document_number)

        if not c:
            c = model.Customer.new(payload['customer'])
            c.store()

        payload['exchange_rate'] = str(payload['exchange_rate'])
        payload['jurisdiction'] = [j.to_dto() for j in jurisdictions
                                   if j.code == payload['jurisdiction']][0]
        payload['regime'] = [r.to_dto() for r in regimes
                             if r.code == payload['regime']][0]

        del payload['customer']
        del payload['document_number']
        del payload['name']
        del payload['address']
        dispatch = model.Dispatch.new(payload)
        dispatch.customer_key = c.key
        dispatches.append(dispatch)

    return dispatches

def save_dispatches(dispatches, customs_agency):
    for dispatch in dispatches:
        find = model.Dispatch.find(order=dispatch.order)
        if not find:
            dispatch.customs_agency_key = customs_agency.key
            dispatch.store()


# vim: ts=4:sw=4:sts=4:et
