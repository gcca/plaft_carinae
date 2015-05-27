"""Dispatch use cases."""

from plaft.domain.model import (Dispatch, Customer, Declaration, Operation,
                                Declarant, Stakeholder)
from plaft.domain.model.dispatch import UniqueSpecification


def it_satisfies(specs, *args):
    for spec in specs:
        if not spec.is_satisfied_by(args[0]):
            raise spec.error


create_pre = [UniqueSpecification]


def update_stakeholders(dispatch):
    customer = dispatch.customer
    customer << dispatch.declaration.dict['customer']
    customer.store()

    for stakeholder in dispatch.stakeholders:
        new_stakeholder = Stakeholder.find(slug=stakeholder.slug)
        if not new_stakeholder:
            new_stakeholder = Stakeholder()
        dct = stakeholder.dict
        del dct['slug']
        new_stakeholder << dct
        new_stakeholder.store()

    for dcl in dispatch.declarants:
        new_dcl = Declarant.find(slug=dcl.slug)
        if not new_dcl:
            new_dcl = Declarant()
        dct = dcl.dict
        del dct['slug']
        new_dcl << dct
        customer.declarant_key = new_dcl.store()  # WARNING: only a declarant
        customer.store()  # TODO: Change this when update domain model.


def create(payload, customs_agency, customer=None):
    """Crea despacho y lo agrega a la lista de pendientes.

    Cuando se crea el despacho, se verifica que el numero de
    order sea unico.

    Se verifica si el customer existe, si no existe se procede
    a crear dependiendo del payload.

    De la agencia de aduanas se extraer el datastore.

    Se agrega el despacho creado en la lista de despachos pendientes
    del datastore.

    Args:
        payload (dict): Diccionario de datos del Despacho.
        example:
            {'order': '123-123',
             'declaration': {
                'customer': {
                    'document_number': '12341234',
                    'document_type': 'dni'
                }
             },
             'description': 'Example'
            }

        customs_agency (Customs): Instancia de la Agencia.
        customer ?(Customer): El customer que se va a crear.
                             (Instancia del customer)

    Returns:
        dispatch: Despacho generado(Instancia del modelo Despacho.)

    Raises:
        IOError: Cuando se intente guardar alguna entidad.

    """
    # it_satisfies(create_pre, payload)

    declaration = Declaration.new(payload['declaration'])
    declaration.store()

    if not customer:
        customer = Customer.new(payload['declaration']['customer'])
        customer.store()

    del payload['declaration']

    dispatch = Dispatch.new(payload)
    dispatch.customs_agency_key = customs_agency.key
    dispatch.customer_key = customer.key
    dispatch.declaration_key = declaration.key
    dispatch.store()

    update_stakeholders(dispatch)

    datastore = customs_agency.datastore
    datastore.pending_key.append(dispatch.key)
    datastore.store()

    return dispatch


def update(dispatch, payload):
    """Modifica el despacho.

    Modifica la declaracion y lo guarda.

    Se verifica si el customer existe, si no existe se procede
    a buscar dependiendo del payload.

    Args:
        dispatch (Dispatch): El despacho a modificar(Instancia del despacho.)
        payload (dict): Diccionario de datos del Despacho.
        example:
            {'order': '123-123',
             'declaration': {
                'customer': {
                    'document_number': '12341234',
                    'document_type': 'dni'
                }
             },
             'description': 'Example'
            }

        customer ?(Customer): El customer que se va a modificar.
                             (Instancia del customer)

    Returns:
        dispatch: Despacho modificado(Instancia del modelo Despacho.)

    Raises:
        IOError: Cuando se intente guardar alguna entidad.

    """
    declaration = dispatch.declaration
    declaration << payload['declaration']
    declaration.store()

    del payload['declaration']
    dispatch << payload
    dispatch.store()

    update_stakeholders(dispatch)

    return dispatch


def numerate(dispatch, **args):
    """ Numera el despacho.

    Se verifica en el despacho que el dam no exista.

    Se modifica el despacho.

    Args:
        dispatch (Dispatch): Despacho a modificar (Instancia del Despacho).

    Kargs:
        args: Argumentos(atributos) para modificar el despacho.

    Returns:
        None

    """
    dispatch << args
    dispatch.store()


def register(dispatch, country_source, country_target):
    """
    Actualiza los campos del despacho enviado.
    Los campos a actualizar del despacho son:
      country_source y country_target

    Se modifica ambos campos en el despacho

    Arg:
      param1 (Dispatch): El despacho a actualizar
      param2 (String): El pais de origen
      param3 (String): El pais de destino

    Returns:
      None

    Raises:
      None
    """
    dispatch.country_source = country_source
    dispatch.country_target = country_target
    dispatch.store()


def pending_and_accepting(customs_agency):
    """
    Verifica que la agencia aduanas exista

    Regresa un diccionario conteniendo 2 listas:
      Lista de despachos pendientes de una agencia y
      lista de despachos aceptados de una agencia

    Arg:
      param1 (CustomsAgency): Agencia de aduana

    Returns:
      Diccionario de despachos
      p -> Representa la lista de despachos pendientes
      a -> Representa la lista de despachos aceptados

    Raises:

    """
    return {
        'pending': sorted([d for d in customs_agency.datastore.pending],
                          key=lambda d: d.jurisdiction.code + d.order),
        'accepting': [d for d in customs_agency.datastore.accepting]
    }


def anexo_seis(dispatch, **args):
    """."""
    dispatch << args
    dispatch.store()


def list_operations(customs_agency):
    """."""
    return [operation
            for operation
            in Operation.all(customs_agency_key=customs_agency.key)]


def list_dispatches(customs_agency):
    """."""
    return sorted(Dispatch.all(customs_agency_key=customs_agency.key),
                  key=lambda d: d.order)


# vim: et:ts=4:sw=4
