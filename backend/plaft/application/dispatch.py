from plaft.domain.model import Dispatch, Customer, Declaration


def create(payload, customs_agency, customer=None):
    """Crea despacho y lo agrega a la lista de pendientes.

    Cuando se crea el despacho, se verifica que el numero de
    order sea unico.

    Se verifica si el customer existe, si no existe se procede
    a crear dependiendo del payload.

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
        customer ?(Customer): Instancia del Customer.

    Returns:
        dispatch: Instancia del modelo Despacho.

    Raises:
        IOError: Cuando se intente guardar alguna entidad.

    """
    declaration = Declaration.new(payload['declaration'])
    declaration.store()

    if not customer:
        customer = Customer.new(payload['declaration']['customer'])
        customer.store()

    dispatch = Dispatch.new(payload)
    dispatch.customs_agency = customs_agency.key
    dispatch.customer = customer.key
    dispatch.store()

    datastore = customs_agency.datastore
    datastore.pending.append(dispatch.key)
    datastore.store()

    return dispatch


def numerate(dispatch, **args):
    """ Numera el despacho.

    Se verifica en el despacho que el dam no exista.

    Se modifica el despacho.

    Args:
        dispatch (Dispatch): Instancia del Despacho.
        **args: Argumentos para modificar el despacho.

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


def dispatches_by_customs_agency(customs_agency):
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
    return {'p': [d.get() for d in customs_agency.datastore.pending],
            'a': [d.get() for d in customs_agency.datastore.accepting]}


# vim: et:ts=4:sw=4
