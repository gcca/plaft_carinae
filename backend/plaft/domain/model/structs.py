"""
Value objects.
"""

from plaft.infrastructure.persistence.datastore import ndb as dom


class Document(dom.Model):
  number = dom.String()
  type = dom.String()

class CodeName(dom.Model):
    """Estructura para los campos que requieren de valores compuestos."""
    code = dom.String()
    name = dom.String()


class Third(dom.Model):
    """Value object para el tercero en los despachos."""
    name = dom.String()
    identification_type = dom.String()
    third_type = dom.String()
    document_type = dom.String()
    document_number = dom.String()
    third_ok = dom.String()
    father_name = dom.String()
    mother_name = dom.String()




# vim: et:ts=4:sw=4
