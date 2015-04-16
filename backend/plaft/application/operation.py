from plaft.domain.model import Operation


def accept_dispatch(dispatch):
    """Dipsatch to operation."""
    operation = Operation(dispatches=[dispatch.key],
                          customs_agency=dispatch.customs_agency,
                          customer=dispatch.customer)
    operation.store()

    dispatch.operation = operation.key
    dispatch.store()

    return operation


# vim: ts=4:sw=4:sts=4:et
