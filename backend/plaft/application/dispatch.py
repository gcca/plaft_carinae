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
  dispatches = model.dispatch.find(customs_agency.id)
  return dispatches

