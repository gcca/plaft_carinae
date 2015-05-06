from plaft.domain.model import Operation


def accept(dispatch):
    """Dipsatch to operation."""
    operation = Operation(dispatches_key=[dispatch.key],
                          customs_agency_key=dispatch.customs_agency_key,
                          customer_key=dispatch.customer_key)
    operation.store()

    dispatch.operation_key = operation.key
    dispatch.store()

    datastore = dispatch.customs_agency.datastore
    datastore.pending_key.remove(dispatch.key)
    datastore.accepting_key.append(dispatch.key)
    datastore.store()

    return operation


# vim: ts=4:sw=4:sts=4:et
