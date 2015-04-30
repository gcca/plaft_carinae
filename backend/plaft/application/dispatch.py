"""Dispatch use cases."""

from plaft.domain.model import Dispatch, Customer, Declaration, Operation


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
    declaration = Declaration.new(payload['declaration'])
    declaration.store()

    if not customer:
        customer = Customer.new(payload['declaration']['customer'])
        customer.store()

    del payload['declaration']

    dispatch = Dispatch.new(payload)
    dispatch.customs_agency = customs_agency.key
    dispatch.customer = customer.key
    dispatch.declaration = declaration.key
    dispatch.store()

    datastore = customs_agency.datastore
    datastore.pending.append(dispatch.key)
    datastore.store()

    return dispatch


def update(dispatch, payload, customer=None):
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
    declaration = dispatch.declaration.get()
    declaration << payload['declaration']
    declaration.store()

    if not customer:
        document_number = payload['declaration']['customer']['document_number']
        customer = Customer.find(document_number=document_number)

    customer << payload['declaration']['customer']
    customer.store()

    dispatch.customer = customer.key

    del payload['declaration']

    dispatch << payload
    dispatch.store()

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
        'pending': [d.get() for d in customs_agency.datastore.pending],
        'accepting': [d.get() for d in customs_agency.datastore.accepting]
    }


def anexo_seis(dispatch, **args):
    """."""
    from pprint import pprint
    pprint(args)
    dispatch << args
    dispatch.store()


def list_operations(customs_agency):
    """."""
    return [operation
            for operation
            in Operation.all(customs_agency=customs_agency.key)]


# vim: et:ts=4:sw=4
