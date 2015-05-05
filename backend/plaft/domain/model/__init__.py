# encoding: utf-8

"""
.. module:: domain.model
   :synopsis: Domain model layer.

.. moduleauthor:: Gonzales Castillo, Cristhian A. <cristhian.gz@aol.com>


"""

from __future__ import unicode_literals
from plaft.infrastructure.persistence.datastore import ndb as dom
from plaft.domain.model.structs import CodeName, Third

JSONEncoder = dom.JSONEncoderNDB


# Agencia de aduanas

class CustomsAgency(dom.Model):
    """Agencia de aduanas."""

    code = dom.String()  # código otorgado por la UIF
    name = dom.String()  # Nombre de la agencia de aduanas
    employees = dom.Key(kind='User', repeated=True)
    officer = dom.Key(kind='User')

    @property
    def datastore(self):
        return Datastore.find(customs_agency=self.key)


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
    role = dom.String()
    is_officer = dom.Boolean(default=False)
    customs_agency = dom.Key(CustomsAgency)


class Officer(User):
    """Oficial de cumplimiento."""


class Employee(User):
    """."""


# Clientes (de la agencia de aduanas)

class Customer(dom.Model, dom.PolyModel):
    """Cliente."""
    name = dom.String()  # nombre o razón social del cliente

    document_number = dom.String()
    document_type = dom.String()  # tipo de documento: ruc, dni, etc.

    activity = dom.String()  # actividad (jurídica)
    # o profesión-ocupación (natural)

    birthday = dom.String()  # fecha de registro (jurídica)
    # o fecha de nacimiento (natural)

    address = dom.String()
    phone = dom.String()
    ubigeo = dom.Structured(CodeName)
    is_obligated = dom.String()
    has_officer = dom.String()
    identification = dom.String()
    fiscal_address = dom.String()

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

    class Shareholder(dom.Model):
        """."""
        name = dom.String()
        document_number = dom.String()
        document_type = dom.String()
        ratio = dom.Text()

    shareholders = dom.Structured(Shareholder, repeated=True)


class Person(Customer):
    """."""
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
    employment = dom.String()


class Business(Customer):
    """."""
    legal_identification = dom.String()
    condition = dom.String()
    money_source = dom.String()
    ciiu = dom.Structured(CodeName)
    ubigeo = dom.Structured(CodeName)
    reference = dom.String()
    social_object = dom.String()


# Involucrados

class Declarant(dom.Model):
    """."""
    represents_to = dom.String()
    residence_status = dom.String()
    document_type = dom.String()
    document_number = dom.String()
    issuance_country = dom.String()
    name = dom.String()
    father_name = dom.String()
    mother_name = dom.String()
    nationality = dom.String()
    activity = dom.String()
    ciiu = dom.Structured(CodeName)  # TODO: dom.String
    position = dom.String()
    address = dom.String()
    ubigeo = dom.Structured(CodeName)  # TODO: dom.String
    phone = dom.String()

    slug = dom.Computed(lambda s: '%s %s %s' % (s.name,
                                                s.father_name,
                                                s.mother_name))


class Linked(dom.Model):
    """."""
    link_type = dom.String()
    customer_type = dom.String()
    document_type = dom.String()
    document_number = dom.String()
    issuance_country = dom.String()
    social_object = dom.String()
    country = dom.String()
    residence_status = dom.String()
    is_pep = dom.String()
    pep_position = dom.String()
    birthday = dom.String()
    name = dom.String()
    father_name = dom.String()
    mother_name = dom.String()
    nationality = dom.String()
    activity = dom.String()
    ciiu = dom.Structured(CodeName)
    position = dom.String()
    address = dom.String()
    employer = dom.String()
    average_monthly_income = dom.String()
    position = dom.String()
    ubigeo = dom.Structured(CodeName)
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
    income_date = dom.String()
    customer = dom.Key(Customer)
    declaration = dom.Key(Declaration)
    declarant = dom.Structured(Declarant, repeated=True)
    linked = dom.Structured(Linked, repeated=True)

    # Numeration
    dam = dom.String()
    # diferencia entre el income_date y el numeration_date
    numeration_date = dom.String()
    amount = dom.String()
    currency = dom.String()
    exchange_rate = dom.String()
    canal = dom.String()
    # Campos para la Numeracion.
    exchange_rate = dom.String()
    ammount_soles = dom.String()
    uif_last_day = dom.String()
    expire_date_RO = dom.String()

    # Campos para el anexo 6
    operation_description = dom.String()
    is_suspects = dom.String()
    ros = dom.String()
    suspects_description = dom.String()

    class Signal(dom.Model):
        """."""
        code = dom.String()
        signal = dom.String()
        source = dom.String()
        description_source = dom.String()

    signal_alerts = dom.Structured(Signal, repeated=True)

    customs_agency = dom.Key(CustomsAgency)
    country_source = dom.String()
    country_target = dom.String()

    operation = dom.Key(kind='Operation')


class Operation(dom.Model):
    """Operación SBS.

    Una vez el `Dispatch` cumple su ciclo de vida en la agencia de aduanas,
    se debe 'convertir' en una operación que irá al registro de operaciones
    (tal vez incluyendo su notificación a la UIF).

    """
    dispatches = dom.Key(Dispatch, repeated=True)
    customs_agency = dom.Key(CustomsAgency)
    customer = dom.Key(Customer)


# Datos globales por agencia

class Datastore(dom.Model):
    """Pseudo-ValueObject for dispatch-operation transitions."""
    customs_agency = dom.Key(CustomsAgency)
    pending = dom.Key(Dispatch, repeated=True)
    accepting = dom.Key(Dispatch, repeated=True)


# vim: et:ts=4:sw=4
