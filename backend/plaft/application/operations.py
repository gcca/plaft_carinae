# encoding: utf-8

from plaft.domain.model import Operation, Customer
from datetime import datetime


def dispatches_in_operation(customs_agency):
    """."""
    import datetime
    datastore = customs_agency.datastore
    pending = datastore.pending
    accepting = datastore.accepting
    current_month = datastore.current_month

    dispatches = [d for d in (pending+accepting) if not d.operation_key]

    customers = {dispatch.customer_key for dispatch in dispatches}

    dispatches_operations = []

    for customer_key in customers:
        pendings_customer = [dispatch for dispatch in dispatches
                             if dispatch.customer_key == customer_key and
                             dispatch.numeration_date.month == current_month-1]
        amount = sum(float(dispatch.amount) for dispatch in pendings_customer)

        if amount >= 50000:
            dispatches_operations.append(pendings_customer)

    return dispatches_operations


def accept_multiple(customs_agency):
    """."""
    datastore = customs_agency.datastore
    dispatches_operation = dispatches_in_operation(customs_agency)

    for dispatches in dispatches_operation:
        dispatches_key = [d.key for d in dispatches]
        customer_key = dispatches[0].customer_key

        counter = datastore.next_operation_counter()
        operation = Operation(dispatches_key=dispatches_key,
                              customs_agency_key=customs_agency.key,
                              customer_key=customer_key,
                              counter=counter)
        operation.store()
        datastore.operations_key.append(operation.key)

        for dispatch in dispatches:
            dispatch.operation_key = operation.key
            dispatch.store()
            datastore.pending_key.remove(dispatch.key)
            datastore.accepting_key.append(dispatch.key)

        datastore.store()


def close_month(customs_agency, current_month=datetime.now().month):
    datastore = customs_agency.datastore
    if current_month > datastore.current_month:
        accept_multiple(customs_agency)
        datastore.operations_last_month_key = datastore.operations_key
        del datastore.operations_key[:]
        del datastore.pending_key[:]
        del datastore.accepting_key[:]
        datastore.store()
        boolean = True
    else:
        boolean = False

    return boolean

# vim: ts=4:sw=4:sts=4:et
