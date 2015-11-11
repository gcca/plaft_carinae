# encoding: utf-8

from __future__ import unicode_literals

from plaft.infrastructure.persistence.datastore import ndb as dom
from datetime import date, timedelta, datetime
from plaft.domain.model.structs import CodeName, Third, Document


class Agency(dom.Model):
    """."""
    name = dom.String()
    employees_key = dom.Key(kind='User', repeated=True)
    officer_key = dom.Key(kind='User')
    employees_key = dom.Key(kind='User', repeated=True)

    @property
    def datastore(self):
        """Customs agency datastore model."""
        return Datastore.find(agency_key=self.key)

    @property
    def customs(self):
        dto = self.to_dto()
        del dto['employees']
        return dto


class Permissions(dom.Model):
    """."""
    modules = dom.Text(repeated=True)
    alerts_key = dom.Key(kind='Alert', repeated=True)


class User(dom.User, dom.PolyModel):

    role_choices = ('Comercial', 'Finanza', 'Operación')
    name = dom.String()
    agency_key = dom.Key(Agency)
    role = dom.Category(role_choices)
    permissions_key = dom.Key(Permissions)


    def to_dto(self):
        dct = super(User, self).to_dto()
        sections = list({a['section'] for a in dct['permissions']['alerts']})
        sections.sort()  # (-o-) Sort by roman instead length
        dct['permissions']['sections'] = sections
        return dct


class Officer(User):
    """Oficial de cumplimiento."""


class Employee(User):
    """."""


# Datos globales por agencia
class Alert(dom.Model):
    section = dom.String()
    code = dom.String()
    description = dom.Text()


class Declarant(dom.Model):
    """."""
    document_type = dom.String()
    document_number = dom.String()
    name = dom.String()
    father_name = dom.String()
    mother_name = dom.String()
    # Adress
    street = dom.String()
    address = dom.String()
    flat = dom.String()
    urbanization = dom.String()
    distrit = dom.String()
    province = dom.String()
    department = dom.String()

    slug = dom.Computed(lambda s: '%s %s %s' % (s.name,
                                                s.father_name,
                                                s.mother_name))

class Stakeholder(dom.Model):
    """."""
    name = dom.String()
    address = dom.String()
    phone = dom.String()
    country = dom.String()

    slug = dom.Computed(lambda s: s.name)


class Customer(dom.Model):
    """."""
    document_number = dom.String()
    document_type = dom.String()
    name = dom.String()
    declarant_key = dom.Key(Declarant)
    link_type = dom.String()
    # Person: `profesion`
    # Business: `Acividad Economica`
    activity = dom.String()
    money_source = dom.String()
    money_source_type = dom.String()

    # address
    address = dom.String()
    street = dom.String()
    flat = dom.String()
    urbanization = dom.String()
    distrit = dom.String()
    province = dom.String()
    department = dom.String()


    class Shareholder(dom.Model):
        """."""
        name = dom.String()
        # (-o-) A los dos.
        document_number = dom.String()
        document_type = dom.String()
        ratio = dom.Text()

    #Person
    other_document = dom.String()
    mobile = dom.String()
    email = dom.String()
    work_center = dom.String()
    pep_is_date = dom.Boolean()
    pep_country = dom.String()
    pep_country_description = dom.String()
    employment = dom.String()
    pep_organization = dom.String()


    #Business
    shareholders = dom.Structured(Shareholder, repeated=True)
    legal_key = dom.Key(Declarant)
    social_object = dom.String()

    condition = dom.String()
    represents_to = dom.String()
    ciiu = dom.Structured(CodeName)

class Business(Customer):
    """."""


class Dispatch(dom.Model):
    """."""
    order = dom.String()
    income_date = dom.Date()
    regime = dom.Structured(CodeName)
    jurisdiction = dom.Structured(CodeName)
    customer_key = dom.Key(Customer)
    agency_key = dom.Key(Agency)
    stakeholders = dom.Structured(Stakeholder, repeated=True)
    description = dom.String()

    exchange_rate = dom.Decimal()
    amount = dom.Decimal()
    dam = dom.String()
    numeration_date = dom.Date()
    channel = dom.String()
    reference = dom.String()
    historical_customer = dom.Structured(Customer)

    class Declaration(dom.Model):
        """."""
        customer = dom.Structured(Customer)

    @property
    def declaration(self):
        """Emulate declaration model property."""
        d = self.Declaration(customer=self.customer)
        # setattr(self, 'declaration', d)
        return d

    @declaration.setter
    def declaration(self, d):
        """Set pieces data declaration."""
        self.historical_customer = d.customer

    def to_dict(self, include=None):
        dct = super(Dispatch, self).to_dict(include=include)
        if include is not None and 'declaration' in include:
            dct['declaration'] = self.declaration.to_dict()
        return dct


class Operation(dom.Model):
    """Operación SBS.

    Una vez el `Dispatch` cumple su ciclo de vida en la agencia de aduanas,
    se debe 'convertir' en una operación que irá al registro de operaciones
    (tal vez incluyendo su notificación a la UIF).

    """

    counter = dom.Integer(default=0)
    dispatches_key = dom.Key(Dispatch, repeated=True)
    agency_key = dom.Key(Agency)
    customer_key = dom.Key(Customer)
    row_number = dom.Computed(lambda self: '%04d' % self.counter)
    register_number = dom.Computed(lambda self:
                                   '%s-%s' % (datetime.now().year,
                                              self.row_number))
    modalidad = dom.Computed(lambda self: 'M'
                             if len(self.dispatches_key) > 1
                             else 'U')

    def num_modalidad(self):
        return ([i+1 for i in range(len(self.dispatches_key))]
                if len(self.dispatches_key) > 1
                else [''])

    def to_dict(self):
        dct = super(Operation, self).to_dict()
        dct['num_modalidad'] = self.num_modalidad()
        return dct


class Datastore(dom.Model):
    """Pseudo-ValueObject for dispatch-operation transitions."""

    agency_key = dom.Key(Agency)
    operation_counter = dom.Integer(default=0)
    operation_last_year = dom.Integer()
    alerts_key = dom.Key(Alert, repeated=True)
    # Se guarda todas las operaciones del mes actual.
    operations_key = dom.Key(Operation, repeated=True)
    # Se guarda las operaciones despues del cierre del mes actual.
    operations_last_month_key = dom.Key(Operation, repeated=True)

    current_month = dom.Integer(default=datetime.now().month)  # TODO

    def next_operation_counter(self):
        current_year = datetime.now().year
        if (not self.operation_last_year or
            self.operation_last_year + 1 == current_year):
            self.operation_last_year = current_year
            self.operation_counter = 0
        self.operation_counter += 1
        self.store()
        return self.operation_counter


class Plaft(dom.Model):
    """Global status."""

    has_datastore = dom.Boolean(default=False)

# vim: et:ts=4:sw=4
