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
    datastore.operations_key.append(operation.key)
    datastore.store()


def reject(dispatch):
    operation = Operation.find(int(dispatch.operation.id))
    operation.delete()

    dispatch.operation_key = None
    dispatch.store()


# vim: ts=4:sw=4:sts=4:et
