# encoding: utf-8

"""
.. module:: domain.model
   :synopsis: Domain model layer.

.. moduleauthor:: Gonzales Castillo, Cristhian A. <cristhian.gz@aol.com>


"""

from __future__ import unicode_literals
from plaft.infrastructure.persistence.datastore import ndb as dom
from plaft.domain.model.structs import CodeName, Third, Document

JSONEncoder = dom.JSONEncoderNDB


# Agencia de aduanas

class CustomsAgency(dom.Model):
    """Agencia de aduanas."""

    code = dom.String()  # código otorgado por la UIF
    name = dom.String()  # Nombre de la agencia de aduanas
    employees_key = dom.Key(kind='User', repeated=True)
    officer_key = dom.Key(kind='User')

    @property
    def datastore(self):
        return Datastore.find(customs_agency_key=self.key)


# Usuarios
class User(dom.User, dom.PolyModel):
    """Usuario de PLAFT.

    Puede ser `oficial de cumplimiento` o `asistente`.
    Permite autenticarse mediante el método de clase `authenticate`.

    v.g.,

    >>> User.authenticate('gcca', '123')
    ... <User:name='gcca'...>  # si existe el usuario.
    ... None  # si no existe o no puede ser autenticado.

    """
    name = dom.String()
    is_officer = dom.Boolean(default=False)  # (-o-) Retirar.
    customs_agency_key = dom.Key(CustomsAgency)


class Officer(User):
    """Oficial de cumplimiento."""


class Employee(User):
    """."""


# Clientes (de la agencia de aduanas)

class Customer(dom.Model, dom.PolyModel):
    """Cliente."""
    name = dom.String()  # nombre o razón social del cliente

    # (-o-) A los dos.
    document_number = dom.String()
    document_type = dom.String()  # tipo de documento: ruc, dni, etc.
    client_type = dom.String()
    validity = dom.String()
    document = dom.Structured(Document)

    activity = dom.String()  # actividad (jurídica)
    # o profesión-ocupación (natural)

    birthday = dom.String()  # fecha de registro (jurídica)
    # o fecha de nacimiento (natural)

    address = dom.String()
    phone = dom.String()
    ubigeo = dom.Structured(CodeName)  # (-o-) to string
    is_obligated = dom.String()  # (-o-) boolean
    has_officer = dom.String()  # (-o-) boolean
    condition = dom.String()  # residencia

    def __new__(cls, **kwargs):
        """Polymorphic creation to implement the factory pattern
        under `Customer` model.

        Value argument `document_type` is necessary.

        (Customer, dict) -> Customer<Business, Person>

        """
        if cls is Customer and kwargs:
            if 'document_type' not in kwargs:
                return super(Customer, cls).__new__(Business, **kwargs)
                raise AttributeError('Customer needs the attribute'
                                     ' `document_type` to construct'
                                     ' a Business or Person.')

            document_type = kwargs['document_type']

            if document_type == 'ruc':
                return super(Customer, cls).__new__(Business, **kwargs)

            if document_type in ('dni', 'pa', 'ce'):
                return super(Customer, cls).__new__(Person, **kwargs)

            raise ValueError('document_type: Bad value.')
        else:
            return super(Customer, cls).__new__(cls, **kwargs)

    # PERSON
    father_name = dom.String()
    mother_name = dom.String()
    civil_state = dom.String()
    partner = dom.String()  # nombre de la pareja o conviviente
    birthplace = dom.String()
    mobile = dom.String()
    email = dom.String()
    nationality = dom.String()
    issuance_country = dom.String()  # país de emisión
    ruc = dom.String()
    employment = dom.String()  # cargo público

    # BUSINESS
    money_source = dom.String()
    ciiu = dom.Structured(CodeName)
    ubigeo = dom.Structured(CodeName)
    reference = dom.String()
    social_object = dom.String()
    legal = dom.String()  # Representante legal
    legal_type = dom.String()
    fiscal_address = dom.String()

    class Shareholder(dom.Model):
        """."""
        name = dom.String()
        # (-o-) A los dos.
        document_number = dom.String()
        document_type = dom.String()
        ratio = dom.Text()

    shareholders = dom.Structured(Shareholder, repeated=True)


class Person(Customer):
    """."""


class Business(Customer):
    """."""


# Involucrados

class Declarant(dom.Model):
    """."""
    represents_to = dom.String()
    residence_status = dom.String()
    # (-o-) A los dos.
    document_type = dom.String()
    document_number = dom.String()

    issuance_country = dom.String()
    name = dom.String()
    father_name = dom.String()
    mother_name = dom.String()
    nationality = dom.String()
    activity = dom.String()
    ciiu = dom.Structured(CodeName)  # (-o-) dom.String
    position = dom.String()
    address = dom.String()
    ubigeo = dom.Structured(CodeName)  # (-o-) dom.String
    phone = dom.String()

    slug = dom.Computed(lambda s: '%s %s %s' % (s.name,
                                                s.father_name,
                                                s.mother_name))


class Stakeholder(dom.Model):
    """."""
    link_type = dom.String()  # Proveedor o destinatario
    # (-o-) A los dos.
    document_type = dom.String()
    document_number = dom.String()

    issuance_country = dom.String()  # país de emisión
    social_object = dom.String()
    country = dom.String()
    residence_status = dom.String()
    is_pep = dom.String()  # (-o-) boolean
    pep_position = dom.String()  # cargo público que ocupa u ocupó.
    birthday = dom.String()  # (-o-) date
    name = dom.String()
    father_name = dom.String()
    mother_name = dom.String()
    nationality = dom.String()
    activity = dom.String()
    ciiu = dom.Structured(CodeName)  # (-o-) str
    position = dom.String()
    address = dom.String()
    employer = dom.String()
    average_monthly_income = dom.String()
    position = dom.String()  # cargo que ocupa
    ubigeo = dom.Structured(CodeName)  # (-o-) str
    phone = dom.String()
    represents_to = dom.String()

    slug = dom.Computed(lambda s: s.name
                        if 'ruc' == s.document_type
                        else '%s %s %s' % (s.name,
                                           s.father_name,
                                           s.mother_name))


class Declaration(dom.Model):
    """."""
    customer = dom.Structured(Customer)
    third = dom.Structured(Third)


class Dispatch(dom.Model):
    """."""
    order = dom.String()
    reference = dom.String()
    order = dom.String()
    regime = dom.Structured(CodeName)
    jurisdiction = dom.Structured(CodeName)
    description = dom.String()
    income_date = dom.String()  # (-o-) date
    customer_key = dom.Key(Customer)
    declaration_key = dom.Key(Declaration)
    declarants = dom.Structured(Declarant, repeated=True)
    sender_stakeholders = dom.Structured(Stakeholder, repeated=True)
    reciever_stakeholders = dom.Structured(Stakeholder, repeated=True)

    stakeholders = dom.Structured(Stakeholder, repeated=True)

    # Numeration
    dam = dom.String()
    # diferencia entre el income_date y el numeration_date
    numeration_date = dom.String()  # (-o-) date
    amount = dom.String()
    currency = dom.String()
    channel = dom.String()
    # Campos para la Numeracion.
    exchange_rate = dom.String()

    # Campos para el anexo 6
    description = dom.String()
    is_suspects = dom.String()
    suspects_by = dom.String()

    class Signal(dom.Model):
        """."""
        code = dom.String()
        signal = dom.String()
        source = dom.String()
        description_source = dom.String()

    signal_alerts = dom.Structured(Signal, repeated=True)

    customs_agency_key = dom.Key(CustomsAgency)
    country_source = dom.String()
    country_target = dom.String()

    operation_key = dom.Key(kind='Operation')


class Operation(dom.Model):
    """Operación SBS.

    Una vez el `Dispatch` cumple su ciclo de vida en la agencia de aduanas,
    se debe 'convertir' en una operación que irá al registro de operaciones
    (tal vez incluyendo su notificación a la UIF).

    """
    dispatches_key = dom.Key(Dispatch, repeated=True)
    customs_agency_key = dom.Key(CustomsAgency)
    customer_key = dom.Key(Customer)
    country_source = dom.String()
    country_target = dom.String()


# Datos globales por agencia

class Datastore(dom.Model):
    """Pseudo-ValueObject for dispatch-operation transitions."""
    customs_agency_key = dom.Key(CustomsAgency)
    pending_key = dom.Key(Dispatch, repeated=True)
    accepting_key = dom.Key(Dispatch, repeated=True)


# vim: et:ts=4:sw=4
