# encoding: utf-8

"""
.. module:: domain.model
   :synopsis: Domain model layer.

.. moduleauthor:: Gonzales Castillo, Cristhian A. <gcca@gcca.tk>

El proceso de lavado de activos se lleva a cabo con los `documentos
de despacho`.

Diagrama::

                           +-----------+
                 o---------| Datastore |
                 |         +-----------+
    +---------------+
    | CustomsAgency |--------------o               +---------+
    +---------------+              |           o---| Officer |
          |    |                +------+       |   +---------+
          |    |                | User |<------|
          |    o-----------o    +------+       |   +----------+
          |                |                   o---| Employee |
          |                |                       +----------+
      +-----------+        |
      | Operation |    +----------+           +-------------+
      +-----------+    | Dispatch |---o-------| Stakeholder |<---o
             |         +----------+   |       +-------------+    |
             |                |       |                          |
             o----------------o       |                          |
                                      |           +--------+     |
                                      |           | Linked |-----|
                   +-----------+      |           +--------+     |
                   | Declarant |------o                          |
                   +-----------+                +----------+     |
                                           o--->| Customer |-----o
                                           |    +----------+
                                           |
                                           o---------------o
                                           |               |
                                      +----------+     +--------+
                                      | Business |     | Person |
                                      +----------+     +--------+

"""

from __future__ import unicode_literals

from plaft.infrastructure.persistence.datastore import ndb as dom
from plaft.domain.model.structs import CodeName, Third, Document
from datetime import date, timedelta, datetime

JSONEncoder = dom.JSONEncoderNDB


# Agencia de aduanas

class CustomsAgency(dom.Model):
    """Agencia de aduanas."""

    code = dom.String()  # código otorgado por la UIF
    name = dom.String()  # Nombre de la agencia de aduanas
    employees_key = dom.Key(kind='User', repeated=True)
    officer_key = dom.Key(kind='User')
    address = dom.String()
    distrit = dom.String()
    province = dom.String()
    name_contact = dom.String()
    office_contact = dom.String()
    phone = dom.String()
    mobile = dom.String()
    email = dom.String()
    document_number = dom.String()
    document_type = dom.String()

    @property
    def datastore(self):
        """Customs agency datastore model."""
        return Datastore.find(customs_agency_key=self.key)

    @property
    def officers(self):
        if not self.officer_key:
            return
        officer = self.officer
        return {'agency': self.name,
                'name': officer.name,
                'username': officer.username,
                'id': self.id}

    @property
    def customs(self):
        dto = self.to_dto()
        del dto['employees']
        return dto


# Usuarios
class Permissions(dom.Model):
    """."""
    modules = dom.Text(repeated=True)
    alerts_key = dom.Key(kind='Alert', repeated=True)


class User(dom.User, dom.PolyModel):
    """Usuario de PLAFT.

    Puede ser `oficial de cumplimiento` o `asistente`.
    Permite autenticarse mediante el método de clase `authenticate`.

    v.g.,

    >>> User.authenticate('gcca', '123')
    ... <User:name='gcca'...>  # si existe el usuario.
    ... None  # si no existe o no puede ser autenticado.

    """

    role_choices = ('Comercial', 'Finanza', 'Operación')

    name = dom.String()
    is_officer = dom.Boolean(default=False)  # (-o-) Retirar.
    customs_agency_key = dom.Key(CustomsAgency)
    permissions_key = dom.Key(Permissions)
    role = dom.Category(role_choices)

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


# Clientes (de la agencia de aduanas)

# Tiene una referencia cruzada entre dispatch - * - customer
class Declarant(dom.Model):  # TODO: update in domain model
    """."""
    represents_to = dom.String()
    residence_status = dom.String()
    # (-o-) A los dos.
    document_type = dom.String()
    document_number = dom.String()

    issuance_country = dom.String()
    name = dom.String()
    father_name = dom.String(default='')
    mother_name = dom.String(default='')
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


class Customer(dom.Model, dom.PolyModel):
    """Cliente."""
    name = dom.String()  # nombre o razón social del cliente

    # (-o-) A los dos.
    document_number = dom.String()
    document_type = dom.String()  # tipo de documento: ruc, dni, etc.
    validity = dom.String()

    activity = dom.String()  # actividad (jurídica)
    # o profesión-ocupación (natural)

    birthday = dom.Date()  # fecha de registro (jurídica)
    # o fecha de nacimiento (natural)

    address = dom.String()
    phone = dom.String()
    ubigeo = dom.Structured(CodeName)  # (-o-) to string
    is_obligated = dom.Boolean()
    has_officer = dom.Boolean()
    condition = dom.Category(('Residente', 'No residente'))  # residencia

    declarants = dom.Structured(Declarant, repeated=True)

    def __new__(cls, **kwargs):
        """Polymorphic creation to implement the factory pattern
        under `Customer` model.

        Value argument `document_type` is necessary.

        (type, dict) -> Customer<Business, Person>

        """
        if cls is Customer and kwargs:
            if 'document_type' not in kwargs:
                return super(Customer, cls).__new__(Business, **kwargs)
                # TODO: Needs refactorization.
                # raise AttributeError('Customer needs the attribute'
                #                      ' `document_type` to construct'
                #                      ' a Business or Person.')

            document_type = kwargs['document_type']

            if document_type == 'ruc':
                return super(Customer, cls).__new__(Business, **kwargs)

            if document_type in ('dni', 'pa', 'ce'):
                return super(Customer, cls).__new__(Person, **kwargs)

            raise ValueError('document_type: Bad value.')
        else:
            return super(Customer, cls).__new__(cls, **kwargs)

    # PERSON
    father_name = dom.String(default='')
    mother_name = dom.String(default='')
    civil_state = dom.String()
    partner = dom.String()  # nombre de la pareja o conviviente
    birthplace = dom.String()
    mobile = dom.String()
    email = dom.String()
    nationality = dom.String()
    issuance_country = dom.String()  # país de emisión
    ruc = dom.String()
    employment = dom.String()  # cargo público
    # PERSON-ANEXO 6
    average_income = dom.String()
    is_pep = dom.Boolean()
    employer = dom.String()

    # BUSINESS
    money_source = dom.String()
    ciiu = dom.Structured(CodeName)
    ubigeo = dom.Structured(CodeName)
    reference = dom.String()
    social_object = dom.String()
    represents_to = dom.Category(('Representante Legal', 'Apoderado',
                                  'Mandatario', 'El mismo'))
    fiscal_address = dom.String()
    position = dom.String()

    class Shareholder(dom.Model):
        """."""
        name = dom.String()
        # (-o-) A los dos.
        document_number = dom.String()
        document_type = dom.String()
        ratio = dom.Text()

    shareholders = dom.Structured(Shareholder, repeated=True)

    # DISPATCH
    money_source_type = dom.Category(('No efectivo', 'Efectivo'))

    # TODO
    unusual_condition = dom.Category(('Involucrado', 'Vinculado'))
    link_type = dom.Category(('Importador', 'Exportador'))
    unusual_operation = dom.String()

    class Proxy(dom.Model):
        name = dom.String()
        father_name = dom.String()
        mother_name = dom.String()
        document_type = dom.String()
        document_number = dom.String()
        street = dom.String()
        address = dom.String()
        urbanization = dom.String()
        distrit = dom.String()
        province = dom.String()
        department = dom.String()
        flat = dom.String()

    class Legal(dom.Model):
        document_type = dom.String()
        document_number = dom.String()
        name = dom.String()

    # version 2
    proxy = dom.Structured(Proxy)  # Apoderado
    contributor = dom.String()
    urbanization = dom.String()
    distrit = dom.String()
    province = dom.String()
    department = dom.String()
    street = dom.String()
    flat = dom.String()
    # version 2 - business
    legal = dom.Structured(Legal)
    # version 2 - person
    work_center = dom.String()
    pep_is_date = dom.Boolean()
    pep_country = dom.String()
    pep_country_description = dom.String()
    pep_organization = dom.String()
    other_document = dom.String()


class Person(Customer):
    """."""


class Business(Customer):
    """."""


# Involucrados

class Stakeholder(dom.Model):
    """."""
    link_type = dom.Category(('Destinatario de embarque',
                              'Proveedor'))  # Proveedor o destinatario
    # (-o-) A los dos.
    document_type = dom.String()
    document_number = dom.String()
    represents_to = dom.String()
    condition = dom.Category(('Residente', 'No residente'))  # residencia
    address = dom.String()
    name = dom.String()
    father_name = dom.String(default='')
    mother_name = dom.String(default='')

    country = dom.String()
    activity = dom.String()
    phone = dom.String()
    nationality = dom.String()
    social_object = dom.String()

    # TODO
    # PERSON-ANEXO 6
    unusual_condition = dom.Category(('Involucrado', 'Vinculado'))
    average_income = dom.String()
    is_pep = dom.Boolean()
    employer = dom.String()
    issuance_country = dom.String()  # país de emisión
    employment = dom.String()
    birthday = dom.Date()
    unusual_operation = dom.String()

    slug = dom.Computed(lambda s: s.name
                        if 'ruc' == s.document_type
                        else '%s %s %s' % (s.name,
                                           s.father_name,
                                           s.mother_name))


class Dispatch(dom.Model):
    """."""
    order = dom.String()
    reference = dom.String()
    order = dom.String()
    regime = dom.Structured(CodeName)
    jurisdiction = dom.Structured(CodeName)
    description = dom.String()
    # income_date = dom.String()  # (-o-) date
    income_date = dom.Date()
    customer_key = dom.Key(Customer)

    third = dom.Structured(Third)
    historical_customer = dom.Structured(Customer)
    money_source = dom.String()

    stakeholders = dom.Structured(Stakeholder, repeated=True)

    # Numeration
    dam = dom.String()
    # diferencia entre el income_date y el numeration_date
    numeration_date = dom.Date()  # (-o-) date
    amount = dom.Decimal(default=0)
    # Campos para la Numeracion.
    exchange_rate = dom.String(default='0')
    amount_soles = dom.Computed(lambda self:
                                (self.amount if self.amount else 0 *
                                 float(self.exchange_rate if self.exchange_rate
                                       else '0')))
    currency = dom.String()
    channel = dom.String()

    # Campos para el anexo 6
    description_unusual = dom.String()
    is_suspects = dom.Boolean()
    suspects_by = dom.String()
    ros = dom.String()

    # Verificar campos
    class Alert(dom.Model):
        """."""
        info_key = dom.Key(kind='Alert')
        comment = dom.Text()
        source = dom.String()
        description_source = dom.String()

    alerts = dom.Structured(Alert, repeated=True)

    # Particular del módulo de alertas.
    # Sirve para saber si el despacho fue revisado.
    alerts_visited = dom.String(repeated=True)

    customs_agency_key = dom.Key(CustomsAgency)
    country_source = dom.String()
    country_target = dom.String()

    operation_key = dom.Key(kind='Operation')
    is_out = dom.Computed(lambda s:
                          s.regime.code in ['40', '51',
                                            '52', '21',
                                            '41', '89', '48'])

    def is_not_laborate(self, d):
        return date.isoweekday(d) in [6, 7]

    def calculate_date_works(self, start_date, final_date):
        date_i = start_date
        count = 0
        while date_i != final_date:
            if self.is_not_laborate(date_i):
                count += 1
            date_i = date_i + timedelta(days=1)

        dd = final_date + timedelta(days=count)
        if dd == final_date:
            return dd
        else:
            return self.calculate_date_works(final_date, dd)

    class Declaration(dom.Model):
        """."""
        customer = dom.Structured(Customer)
        third = dom.Structured(Third)

        def declarant(self, dto):
            customer = dto['customer']
            if customer['proxy'] and customer['proxy']['document_number']:
                dto['customer']['legal'] = {}
            else:
                dto['customer']['proxy'] = {}

        def to_dict(self):
            dto = super(Dispatch.Declaration, self).to_dict()
            self.declarant(dto)
            return dto

    @property
    def declaration(self):
        """Emulate declaration model property."""
        d = self.Declaration(customer=self.historical_customer,
                             third=self.third)
        # setattr(self, 'declaration', d)
        return d

    @declaration.setter
    def declaration(self, d):
        """Set pieces data declaration."""
        self.historical_customer = d.customer
        self.third = d.third
        self.money_source = d.customer.money_source_type

    def to_dict(self, include=None):
        dct = super(Dispatch, self).to_dict(include=include)
        if include is not None and 'declaration' in include:
            dct['declaration'] = self.declaration.to_dict()
        if include is not None and 'last_date_ros' in include:
            dct['last_date_ros'] = self.calculate_date_works(
                                        self.numeration_date,
                                        self.numeration_date+timedelta(days=15)
                                        ) if self.numeration_date else None
        # TODO: Implementar dict en lista de cascada para `Structured`
        if include is not None and 'alerts' in include:
            dct['alerts'] = [a.to_dto() for a in self.alerts]
        return dct

    @property
    def is_accepted(self):
        return self.operation_key is not None


class Operation(dom.Model):
    """Operación SBS.

    Una vez el `Dispatch` cumple su ciclo de vida en la agencia de aduanas,
    se debe 'convertir' en una operación que irá al registro de operaciones
    (tal vez incluyendo su notificación a la UIF).

    """

    counter = dom.Integer(default=0)
    dispatches_key = dom.Key(Dispatch, repeated=True)
    customs_agency_key = dom.Key(CustomsAgency)
    customer_key = dom.Key(Customer)
    country_source = dom.String()
    country_target = dom.String()
    row_number = dom.Computed(lambda self: '%04d' % self.counter)
    register_number = dom.Computed(lambda self:
                                   '%s-%s' % (datetime.now().year,
                                              self.row_number))
    modalidad = dom.Computed(lambda self: 'M'
                             if len(self.dispatches_key) > 1
                             else 'U')
#    operation_date = dom.Computed(lambda self: self.get_operation_date())

    def get_operation_date(self):
        dts = [d.numeration_date for d in self.dispatches]
        return (max(dts)).strftime("%d/%m/%Y") if dts else ''

    def num_modalidad(self):
        return ([i+1 for i in range(len(self.dispatches_key))]
                if len(self.dispatches_key) > 1
                else [''])

    def to_dict(self):
        dct = super(Operation, self).to_dict()
        dct['num_modalidad'] = self.num_modalidad()
        return dct


# Datos globales por agencia
class Alert(dom.Model):
    section = dom.String()
    code = dom.String()
    description = dom.Text()


class Datastore(dom.Model):
    """Pseudo-ValueObject for dispatch-operation transitions."""

    customs_agency_key = dom.Key(CustomsAgency)
    pending_key = dom.Key(Dispatch, repeated=True)
    accepting_key = dom.Key(Dispatch, repeated=True)
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


class Admin(dom.User, dom.PolyModel):
    """ Administrator """
    name = dom.String()

class Bill(dom.Model):
    date_bill = dom.Date()
    customs_agency_key = dom.Key(CustomsAgency)
    billing_type = dom.String()
    seller = dom.String()
    exchange_rate = dom.String()
    payment = dom.String()
    guide = dom.String()
    purchase = dom.String()
    method = dom.Category(('Boleta de Venta', 'Factura',
                           'Guia de remisión', 'Nota crédito'
                           'Nota de Abono'))

    total = dom.Float()
    igv = dom.Float()
    to_pay = dom.Float()
    is_service = dom.Boolean()

    class Details(dom.Model):
        quantity = dom.Integer()
        description = dom.String()
        price = dom.Float()
        unit = dom.String()
        amount = dom.Float()

    details = dom.Structured(Details, repeated=True)


class Worker(dom.Model):

    name = dom.String()
    document_number = dom.String()
    document_type = dom.String()

    def knowledge(self):
        ## TODO: change computed to accept 'false' objects: [], {}, etc.
        knowledge = [knowledge.to_dict()
                     for knowledge
                     in (KnowledgeWorker.query(
                         KnowledgeWorker.worker_key == self.key)
                         .order(KnowledgeWorker.created).fetch())]
        return knowledge if knowledge else None

    def to_dict(self):
        dct = super(Worker, self).to_dict()
        dct['knowledge'] = self.knowledge()
        return dct


class KnowledgeWorker(dom.Model):

    worker_key = dom.Key(Worker)
    created = dom.DateTime(auto_now_add=True)

    class InternalAlert(dom.Model):
        info_key = dom.Key(kind='Alert')
        comment = dom.Text()
        source = dom.String()
        description_source = dom.String()

    alerts = dom.Structured(InternalAlert, repeated=True)


# vim: et:ts=4:sw=4
