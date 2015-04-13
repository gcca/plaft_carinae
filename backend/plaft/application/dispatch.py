from plaft.domain.model import Dispatch


def create(dispatch, customs_agency, customer=None):
    """Crea despacho y lo agrega a la lista de pendientes.

    Cuando se crea el despacho, se verifica que el numero de
    order sea unico.

    Se agrega el despacho en la lista de despachos pendientes
    en el datastore.

    Args:
        dispatch (Dispatch): Instancia del Despacho.
        customer (Customer): Instancia del Customer.
        customs_agency ?(Customs): Instancia de la Agencia.

    Returns:
        None

    """
    dispatch.customs_agency = customs_agency.key
    dispatch.customer = customer.key
    dispatch.store()

    datastore = customs_agency.datastore
    datastore.pending.append(dispatch.key)
    datastore.store()


def numerate(dispatch, **args):
    """ Enumera el despacho.

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


def pending(customs_agency):
  """
    Arg:
      param1 (CustomsAgency): Agencia de aduana

    Returns:
      Lista de despachos

    Raises:

  """
  dispatches = Dispatch.find(customs_agency=customs_agency.key)
  return dispatches


# vim: et:ts=4:sw=4
