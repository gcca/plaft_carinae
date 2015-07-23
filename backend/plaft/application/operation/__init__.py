# encoding: utf-8

from plaft.domain.model import Operation, Customer


def accept(dispatch):
    """Dispatch to operation.

    TODO: Falta lanzar excepción cuando ya está aceptado.

    """
    datastore = dispatch.customs_agency.datastore
    counter = datastore.next_operation_counter()
    operation = Operation(dispatches_key=[dispatch.key],
                          customs_agency_key=dispatch.customs_agency_key,
                          customer_key=dispatch.customer_key,
                          counter=counter)
    operation.store()

    dispatch.operation_key = operation.key
    dispatch.store()


def reject(dispatch):
    operation = Operation.find(int(dispatch.operation.id))
    operation.delete()

    dispatch.operation_key = None
    dispatch.store()


def accept_multiple(customs_agency):
    """."""
    import datetime
    now = datetime.datetime.now()
    datastore = customs_agency.datastore
    pending = datastore.pending

    customers = {dispatch.customer_key for dispatch in pending}

    for customer_key in customers:
        pendings_customer = [dispatch for dispatch in pending
                             if dispatch.customer_key == customer_key and
                             dispatch.income_date.month == now.month]

        if pendings_customer:
            amount = sum(float(d.amount) for d in pendings_customer)
            if amount >= 50000:
                counter = datastore.next_operation_counter()
                operation = Operation(dispatches_key=[d.key
                                                      for d
                                                      in pendings_customer],
                                      customs_agency_key=customs_agency.key,
                                      customer_key=customer_key,
                                      counter=counter)
                operation.store()

                for dispatch in pendings_customer:
                    dispatch.operation_key = operation.key
                    dispatch.store()
                    datastore.pending_key.remove(dispatch.key)
                    datastore.accepting_key.append(dispatch.key)

                datastore.store()


# vim: ts=4:sw=4:sts=4:et
