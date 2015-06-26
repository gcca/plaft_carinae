# encoding: utf-8

from plaft.domain.model import Operation, Customer


def accept(dispatch):
    """Dispatch to operation.

    TODO: Falta lanzar excepción cuando ya está aceptado.

    """
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


def accept_multiple(customs_agency):
    """."""
    import datetime
    now = datetime.datetime.now()
    datastore = customs_agency.datastore
    pending = datastore.pending


    customers = {dispatch.customer_key for dispatch in pending}

    for customer_key in customers:
        pendings_customer = [dispatch for dispatch in pending
                             if dispatch.customer_key == customer_key
                             and dispatch.income_date.month == now.month]

        if pendings_customer:
            amount = sum(float(d.amount) for d in pendings_customer)
            if amount >= 50000:
                operation = Operation(dispatches_key=[d.key for d in pendings_customer],
                                      customs_agency_key=customs_agency.key,
                                      customer_key=customer_key)
                operation.store()

                for dispatch in pendings_customer:
                    dispatch.operation_key = operation.key
                    dispatch.store()
                    datastore.pending_key.remove(dispatch.key)
                    datastore.accepting_key.append(dispatch.key)

                datastore.store()


# vim: ts=4:sw=4:sts=4:et
