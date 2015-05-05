# encoding: utf-8

"""
.. module:: plaft.interfaces.views
   :synopsis: Views.

.. moduleauthor:: Gonzales Castillo, Cristhian A. <cristhian.gz@aol.com>


"""

from plaft.interfaces import Handler, DirectToController
from plaft.domain import model
import plaft.config
from datetime import timedelta
import datetime
from reportlab.lib.enums import TA_JUSTIFY
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Image, \
                           Table, TableStyle


class SignIn(DirectToController):
    """Welcome and sign in controller for users."""

    def post(self):
        """Login user."""

        username = self.request.get('username')
        password = self.request.get('password')

        user = model.User.authenticate(username, password)

        if user:
            self.login(user)
            self.redirect('/dashboard')
        else:
            self.write_template('e:-1')


class Dashboard(DirectToController):
    """Users dashboard."""

    def _args(self):
        self.add_arg('linked',
                     {stk.slug: stk.id for stk in model.Stakeholder.all()})
        self.add_arg('declarant',
                     {dcl.slug: dcl.id for dcl in model.Declarant.all()})
        self.add_arg('user', self.user)
        self.add_arg('us', self.user.customs_agency.employees_key)


class Debug(Handler):
    """Only use to handtest."""

    def get(self):
        """Create entities."""
        from plaft.application.util import sample_data_generator
        sample_data_generator.create_sample_data()
        self.write('Don\'t worry... Be happy.')

    def post(self):
        """Delete entities."""
        import google.appengine.ext.ndb as ndb
        ndb.delete_multi(v for m in
                         [getattr(model, i) for i in dir(model)
                          if isinstance(getattr(model, i),
                                        ndb.model.MetaModel)]
                         for v in m.query().fetch(keys_only=True))
        self.write('The End.')


class DeclarationPDF(Handler):

    def shareholdersList(self, shareholders):
        list = []
        for s in shareholders:
            list.append(['    Nombre', s.name])
            list.append(['    Documento', s.document_type])
            list.append(['    Número', s.document_number])
            list.append(['', ''])
        return list

    def checkComplexKey(self, obj, _attr):
        levels = _attr.split('.')
        for key in levels:
            if hasattr(obj, key):
                obj = getattr(obj, key)
            else:
                return 'Llave no encontrada'
        return obj if obj else '-'

    # Only obj and value params are required!!
    def checkEmpty(self, obj, value, message='-'):
        if hasattr(obj, value):
            if getattr(obj, value):
                return getattr(obj, value)
            else:
                return message
        else:
            return 'No se encontro informacion'

    # Returns the partners name depending on the marital status
    def checkMaritalStatus(self, obj, partner, civil_state, status):
        if hasattr(obj, partner) and hasattr(obj, civil_state):
            if getattr(obj, civil_state) == status:
                return getattr(obj, partner)
            else:
                return '-'
        else:
            return '-'

    # Adds a paragraph to the pdf file
    def addParagraph(self, story, styles, text, space):
        story.append(
            Paragraph('<para>%s</para>' % text, styles['Normal']))
        story.append(Spacer(1, space))

    def addTable(self, story, data, space, autoColWidths=False):
        if autoColWidths:
            table = Table(data, colWidths='*')
            table.setStyle(TableStyle([('VALIGN',
                                        (0, 0),
                                        (-1, -1),
                                        'TOP')]))
            story.append(table)
            story.append(Spacer(1, space))
        else:
            table = Table(data, [2.2*inch, 3.5*inch])
            story.append(table)
            story.append(Spacer(1, space))

    # Adds all the paragraphs for the Person class.
    def makePersonPDF(self, story, styles, dispatch, customer):
        tab = '&nbsp;'*4
        story.append(Spacer(1, 12))
        self.addParagraph(story, styles,
                          'a) Nombres y apellidos', 4)
        self.addParagraph(story, styles,
                          tab + self.checkEmpty(customer, 'name'), 12)
        self.addParagraph(story, styles,
                          'b) Tipo y número de documento de identidad', 4)
        self.addParagraph(story, styles,
                          tab + self.checkEmpty(customer, 'document_type') +
                          tab + self.checkEmpty(customer, 'document_number'),
                          12)
        self.addParagraph(story, styles,
                          ('c) Registro único de contribuyente (RUC),'
                           ' de ser el caso.'),
                          4)
        self.addParagraph(story, styles,
                          tab + self.checkEmpty(customer, 'ruc', 'Sin ruc'),
                          12)
        self.addParagraph(story, styles,
                          'd) Lugar y fecha de nacimiento', 4)

        dateAndBirthTable = [['Lugar de nacimiento', 'Fecha de nacimiento'],
                             [self.checkEmpty(customer, 'birthplace'),
                              self.checkEmpty(customer, 'birthday')]]
        self.addTable(story, dateAndBirthTable, 12)

        self.addParagraph(story, styles,
                          'e) Nacionalidad', 4)
        self.addParagraph(story, styles,
                          tab + self.checkEmpty(customer, 'nationality'), 12)
        self.addParagraph(story, styles,
                          'f) Domicilio declarado (lugar de residencia)', 4)
        self.addParagraph(story, styles,
                          tab + self.checkEmpty(customer, 'address'), 12)
        self.addParagraph(story, styles,
                          'g) Domicilio fiscal, de ser el caso', 4)
        self.addParagraph(story, styles,
                          tab + self.checkEmpty(customer, 'fiscal_address'),
                          12)
        self.addParagraph(story, styles,
                          'h) Número de telefono (fijo y celular)', 4)

        homeAndMobilePhoneTable = [['Fijo', 'Celular'],
                                   [self.checkEmpty(customer, 'phone'),
                                    self.checkEmpty(customer, 'mobile')]]
        self.addTable(story, homeAndMobilePhoneTable, 12)

        self.addParagraph(story, styles, 'i) Correo electrónico', 4)
        self.addParagraph(story, styles,
                          tab + self.checkEmpty(customer, 'email'), 12)
        self.addParagraph(story, styles,
                          'j) Profesión u ocupación', 4)
        self.addParagraph(story, styles,
                          tab + self.checkEmpty(customer, 'activity'), 12)
        self.addParagraph(story, styles,
                          'k) Estado civil', 4)
        self.addParagraph(story, styles,
                          tab + self.checkEmpty(customer, 'civil_state'), 4)
        self.addParagraph(story, styles,
                          tab + '1. Nombre del conyuge, de ser casado: ' +
                          tab + (self.checkMaritalStatus(customer,
                                                         'partner',
                                                         'civil_state',
                                                         'Casado')),
                          4)
        self.addParagraph(story, styles,
                          tab + ('2. Si declara ser conviviente,'
                                 ' consignar nombre: ') +
                          tab + (self.checkMaritalStatus(customer,
                                                         'partner',
                                                         'civil_state',
                                                         'Conviviente')),
                          12)
        self.addParagraph(story, styles,
                          ('l) Cargo o función pública que desempeña o'
                           ' que haya desempeñado en los últimos'
                           ' dos (2) años,'
                           ' en Perú o en el extranjero, indicando el'
                           ' nombre del organismo público u organización'
                           ' internacional'),
                          4)
        self.addParagraph(story, styles,
                          tab + self.checkEmpty(customer,
                                                'employment',
                                                'Sin cargo publico'),
                          12)
        self.addParagraph(story, styles,
                          ('m) El origen de los fondos, bienes u otros'
                           ' activos involucrados en dicha transaccion'
                           ' (especifique)'),
                          4)
        self.addParagraph(story, styles,
                          tab + self.checkEmpty(dispatch.declaration,
                                                'money_source'),
                          12)
        self.addParagraph(story, styles,
                          'n) Es sujeto obligado informar a la UIF-Peru', 4)
        self.addParagraph(story, styles,
                          tab + self.checkEmpty(dispatch.declaration,
                                                'is_obligated'),
                          12)
        self.addParagraph(story, styles,
                          tab + ('En caso marco SI, indique si designo a'
                                 ' su Oficial de Cumplimiento'),
                          4)
        self.addParagraph(story, styles,
                          tab + self.checkEmpty(dispatch.declaration,
                                                'has_officer'),
                          12)
        self.addParagraph(story, styles,
                          ('o) Identificacion del tercero, sea persona'
                           ' natural (nombres y apellidos) o persona'
                           ' juridica (razon o denominacion social)'
                           ' por cuyo intermedio se realiza la operacion,'
                           ' de ser el caso'),
                          4)
        self.addParagraph(story, styles,
                          tab +
                          self.checkComplexKey(dispatch.declaration,
                                               'third.name'),
                          12)

    # Adds all the paragraphs for the Business class
    # @Params self, list, list, model, model
    def makeBusinessPDF(self, story, styles, dispatch, customer):
        tab = '&nbsp;'*4
        story.append(Spacer(1, 12))

        self.addParagraph(story, styles,
                          'a) Denominacion o razon social', 4)
        self.addParagraph(story, styles,
                          tab + self.checkEmpty(customer, 'name'), 12)
        self.addParagraph(story, styles,
                          'b) Registro Unico de Contribuyentes RUC', 4)
        self.addParagraph(story, styles,
                          tab + self.checkEmpty(customer,
                                                'document_number'),
                          12)
        self.addParagraph(story, styles,
                          ('c) Objeto social y actividad economica'
                           ' principal (Comercial, industrial,'
                           ' construccion, etc.)'),
                          4)
        self.addParagraph(story, styles,
                          tab +
                          'Objeto social: ' +
                          self.checkEmpty(customer, 'social_object'),
                          4)
        self.addParagraph(story, styles,
                          tab +
                          'Actividad economica: ' +
                          self.checkEmpty(customer, 'activity'),
                          12)
        self.addParagraph(story, styles,
                          ('d) Identificacion de los accionistas, socios'
                           ' o asociados, que tengan un porcentaje igual'
                           ' o mayor al 5% de las acciones'
                           ' o participaciones'),
                          4)

        if customer.shareholders:
            self.addTable(story,
                          self.shareholdersList(customer.shareholders),
                          12)
        else:
            self.addParagraph(story, styles, 'Sin accionistas', 12)

        self.addParagraph(story, styles,
                          ('e) Identificacion del representante legal'
                           ' o de quien comparece con facultades de'
                           ' representacion y/o disposicion de la'
                           ' persona juridica'),
                          4)
        self.addParagraph(story, styles,
                          tab + self.checkEmpty(customer,
                                                'identification'),
                          12)
        self.addParagraph(story, styles, 'f) Domicilio', 4)
        self.addParagraph(story, styles,
                          tab +
                          self.checkEmpty(customer,
                                          'address'), 12)  # falta mejorar
        self.addParagraph(story, styles, 'g) Domicio fiscal', 4)
        self.addParagraph(story, styles,
                          tab + self.checkEmpty(customer,
                                                'fiscal_address'), 12)
        self.addParagraph(story, styles,
                          ('h) Telefonos fijos de la oficina y/o de la'
                           ' persona de contacto incluyendo el codigo'
                           ' de la ciudad, sea que se trate del local'
                           ' principal, agencia, sucursal u otros locales'
                           ' donde desarrollan actividades propias al giro'
                           ' de su negocio'),
                          4)
        self.addParagraph(story, styles,
                          tab + self.checkEmpty(customer, 'phone'), 12)
        self.addParagraph(story, styles,
                          ('i) El origen de los fondos, bienes u otros'
                           ' activos involucrados en dicha transaccion'
                           ' (especifique)'),
                          4)
        self.addParagraph(story, styles,
                          tab + self.checkEmpty(customer,
                                                'money_source'),
                          12)
        self.addParagraph(story, styles,
                          'j) Es sujeto obligado informar a la UIF-Peru',
                          4)
        self.addParagraph(story, styles,
                          tab + self.checkEmpty(customer,
                                                'is_obligated'),
                          12)
        self.addParagraph(story, styles,
                          tab + ('En caso marco SI, indique si designo a'
                                 ' su Oficial de Cumplimiento'),
                          4)
        self.addParagraph(story, styles,
                          tab + self.checkEmpty(customer,
                                                'has_officer'),
                          12)
        self.addParagraph(story, styles,
                          ('k) Identificacion del tercero, sea persona'
                           ' natural (nombres y apellidos) o persona'
                           ' juridica (razon o denominacion social) por'
                           ' cuyo intermedio se realiza la operacion,'
                           ' de ser el caso'),
                          4)
        self.addParagraph(story, styles,
                          tab +
                          self.checkComplexKey(dispatch.declaration,
                                               'third.name'),
                          12)

    def get(self, id):
        self.response.headers['Content-Type'] = 'application/pdf'

        dispatch = model.Dispatch.find(int(id))
        customer = dispatch.declaration.customer

        if customer.document_type == 'ruc':
            customer = model.Business.new(customer.dict)
        else:
            customer = model.Person.new(customer.dict)

        styles = getSampleStyleSheet()
        styles.add(ParagraphStyle(name='Justify', alignment=TA_JUSTIFY))

        doc = SimpleDocTemplate(self.response.out,
                                pagesize=letter,
                                rightMargin=72,
                                leftMargin=72,
                                topMargin=72,
                                bottomMargin=72)

        story = []

        jurisdiccionTable = [['Código', 'Nombre'],
                             [self.checkEmpty(dispatch.jurisdiction,
                                              'code'),
                              self.checkEmpty(dispatch.jurisdiction,
                                              'name')]]
        headerTable = [['Ref. Cliente', 'N Orden Despacho', 'Jurisdiccion'],
                       [dispatch.reference, dispatch.order,
                        Table(jurisdiccionTable, colWidths='*')]]

        self.addTable(story, headerTable, 12, True)

        story.append(Paragraph('<para alignment=center>'
                               '<font size=12>'
                               '<b>ANEXO N&ordm;5</b>'
                               '</font>'
                               '</para>',
                               styles['Normal']))
        story.append(Spacer(1, 12))

        story.append(Paragraph('<para alignment=center>'
                               '<font size=12>'
                               '<b>Declaración Jurada De conocimiento'
                               ' del Cliente</b>'
                               '</font>'
                               '</para>',
                               styles['Normal']))

        title = ('Persona Jurídica'
                 if customer.document_type == 'ruc'
                 else 'Persona Natural')

        story.append(Paragraph('<para alignment=center>'
                               '<font size=12>'
                               '<b>%s</b>'
                               '</font>'
                               '</para>' % title, styles['Normal']))
        story.append(Spacer(1, 24))

        self.addParagraph(story, styles,
                          ('Por el presente documento, declaro bajo'
                           ' juramento, lo siguiente'),
                          8)

        if customer.document_type == 'ruc':
            self.makeBusinessPDF(story, styles, dispatch, customer)
        else:
            self.makePersonPDF(story, styles, dispatch, customer)

        story.append(Spacer(1, 30))
        ptext = ('<font size=10>'
                 'Afirmo y ratifico todo lo manifestado en'
                 ' la presente declaración jurada, en señal de lo cual'
                 '</font>')
        story.append(Paragraph(ptext, styles["Justify"]))
        story.append(Spacer(1, 1))

        story.append(Paragraph('<font size=10>la firmo,'
                               ' en la fecha que se indica:'
                               '</font>',
                     styles["Justify"]))
        story.append(Spacer(1, 30))

        ztime = datetime.datetime.utcnow() - timedelta(hours=5)
        # continue: declaration.created.utcnow() - timedelta(hours=5)
        bgdate = ztime.strftime('%d / %m / %Y')
        bgtime = ztime.strftime('%H:%M')

        data = [['____________________', 'Fecha :    ' + bgdate],
                ['               Firma', 'Hora   :    ' + bgtime]]
        table = Table(data, [3*inch, 2.1*inch], 2*[.2*inch])
        story.append(table)

        doc.build(story)


class NewUsers(Handler):

    @staticmethod
    def to_li(agency):
        officer = agency.officer.get()
        return (
            '<tr>'
            '<td style="padding:4px 14px">%s</td>'
            '<td style="padding:4px 14px">%s</td>'
            '<td style="padding:4px 14px">&times;</td>'
            '</tr>') % (agency.name, officer.username)

    def template(self, agency='', username='', customs_id='', password='',
                 msg='', mode='create'):

        title = 'Editar' if customs_id else 'Nuevo'
        agencies = ''.join(self.to_li(a) for a in model.CustomsAgency.all())

        return u"""
            <html>
                <body>
                    <h4>%(title)s</h4>
                    <form method='post'>
                        <label><i>Buscar (por nombre de agencia): </i></label>
                        <input type='text' name='search'>
                        <span style='color:red'>%(msg)s</span>
                        <br/>
                        <br/>
                        <label>Nombre de la agencia: </label>
                        <input type='text'
                               name='agency'
                               value='%(agency)s'>
                        <br/>
                        <label>Correo del oficial de cumplimiento: </label>
                        <input type='text'
                               name='username'
                               value='%(username)s'>
                        <br/>
                        <label>Contraseña: </label>
                        <input type='text'
                               name='password'
                               value='%(password)s'>
                        <br/>
                        <input type='submit'>
                        <a href=''>Nuevo</a>
                        <input type='hidden'
                               name='customs_id'
                               value='%(customs_id)s'>
                        <input type='hidden'
                               name='mode'
                               value='s'>
                    </form>
                </body>
                <hr>
                <table>
                  %(agencies)s
                </table>
            </html>
        """ % {
            'agency': agency,
            'username': username,
            'customs_id': customs_id,
            'password': password,
            'title': title,
            'msg': msg,
            'agencies': agencies
        }

    def get(self):
        self.write(self.template())

    def post(self):
        search = unicode(self.request.get('search'))
        if search:
            customs_agency = model.CustomsAgency.find(name=search)
            if customs_agency:
                username = customs_agency.officer_key.username
                self.write(self.template(search,
                                         username,
                                         customs_agency.id))
            else:
                self.write(self.template(msg='No encontrado.'))

            return

        agency_name = unicode(self.request.get('agency'))
        username = unicode(self.request.get('username'))
        password = unicode(self.request.get('password'))
        customs_id = unicode(self.request.get('customs_id'))

        if customs_id:
            customs_agency = model.CustomsAgency.find(int(customs_id))

            customs_agency.name = agency_name
            customs_agency.store()

            officer = customs_agency.officer_key
            officer.username = username
            officer.populate(password=password)
            officer.store()
        else:
            customs_agency = model.CustomsAgency(name=agency_name)
            customs_agency.store()

            datastore = model.Datastore(customs_agency_key=customs_agency.key)
            datastore.store()

            officer = model.Officer(username=username,
                                    password=password,
                                    customs_agency_key=customs_agency.key)
            officer.store()

            customs_agency.officer_key = officer.key
            customs_agency.store()

        self.write(self.template(agency_name,
                                 username,
                                 customs_agency.id,
                                 password))


# vim: et:ts=4:sw=4
