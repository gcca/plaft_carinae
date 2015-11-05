# encoding: utf-8

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
    'COD UBIC.GEOG': 'ubigeo',
    'TIP DOC DECL.DAM': 'document_type'
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


# vim: ts=4:sw=4:sts=4:et
