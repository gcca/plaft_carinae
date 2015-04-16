from plaft.domain.model import Operation


def accept(dispatch):
    """Dipsatch to operation."""
    operation = Operation(dispatches=[dispatch.key],
                          customs_agency=dispatch.customs_agency,
                          customer=dispatch.customer)
    operation.store()

    dispatch.operation = operation.key
    dispatch.store()

    datastore = dispatch.customs_agency.get().datastore
    datastore.pending.remove(dispatch.key)
    datastore.accepting.append(dispatch.key)
    datastore.store()

    return operation


# vim: ts=4:sw=4:sts=4:et
