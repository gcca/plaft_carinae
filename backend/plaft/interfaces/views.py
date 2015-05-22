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
from reportlab.lib import colors
from reportlab.lib.enums import TA_JUSTIFY, TA_CENTER
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
        self.add_arg('stakeholder',
                     {stk.slug: stk.id for stk in model.Stakeholder.all()})
        self.add_arg('declarant',
                     {dcl.slug: dcl.id for dcl in model.Declarant.all()})
        self.add_arg('user', self.user)
        self.add_arg('us', self.user.customs_agency.employees_key)


class Debug(Handler):  # DEBUG
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
        html = []
        i = 1
        for s in shareholders:
            j = '0'+str(i) if i < 10 else str(i)
            html.append('<br/>')
            html.append('%s. %s <br/>%s %s<br/>' % (j,
                                                    s.document_number,
                                                    '&nbsp;'*(len(j)+3),
                                                    s.name))
            html.append('%s %s<br/>' % ('&nbsp;'*(len(j)+3),
                                        s.ratio))
            i += 1
        html.append('<br/>')
        return ''.join(html)

    def checkButtonchk(self, obj, value):
        if hasattr(obj, value):
            if getattr(obj, value):
                if getattr(obj, value) == 'No':
                    return 'SI( &nbsp; ) &nbsp;&nbsp; NO( X )'
                else:
                    return 'SI( X ) &nbsp;&nbsp; NO( &nbsp; )'
            else:
                return '-'
        else:
            return 'No se encontro informacion'



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

    def addTable(self, story, data, space, autoColWidths=False):
        table = Table(data, colWidths='*')
        table.setStyle(TableStyle([
        ('VALIGN',    (0, 0), (-1, -1), 'MIDDLE'),
        ('INNERGRID', (0, 0), (-1, -1), 0.25, colors.black),
        ('BOX',       (0, 0), (-1, -1), 0.25, colors.black),
        ('ALIGN',     (0, 0), (-1, -1), 'CENTER'),
        ('SPAN',      (0, 0), (-1, 0))]))
        story.append(table)

    # Adds all the paragraphs for the Person class.
    def makePersonPDF(self, story, dispatch, customer):
        content = []
        content.append(['a)','Nombres y apellidos',
                        self.checkEmpty(customer, 'name')])

        content.append(['b)','Tipo de documento de identidad',
                        (self.checkEmpty(customer, 'document_type')).upper()])

        content.append(['','Número del documento de identidad',
                        self.checkEmpty(customer, 'document_number')])

        content.append(['c)','''Registro Único de Contribuyentes (RUC),
                             de ser el caso''',
                        self.checkEmpty(customer, 'ruc', 'Sin ruc')])

        content.append(['d)','Lugar de nacimiento',
                        self.checkEmpty(customer, 'birthplace')])

        content.append(['','Fecha de nacimiento',
                        self.checkEmpty(customer, 'birthday')])

        content.append(['e)','Nacionalidad',
                        self.checkEmpty(customer, 'nationality')])

        content.append(['f)','Domicilio declarado (lugar de residencia)',
                        self.checkEmpty(customer, 'address')])

        content.append(['g)','Domicilio fiscal, de ser el caso',
                        self.checkEmpty(customer, 'fiscal_address')])

        content.append(['h)','Número de teléfono fijo',
                        self.checkEmpty(customer, 'phone')])

        content.append(['','Número de teléfono celular',
                        self.checkEmpty(customer, 'mobile')])

        content.append(['i)','Correo electrónico',
                        self.checkEmpty(customer, 'email')])

        content.append(['j)','Profesión u ocupación',
                        self.checkEmpty(customer, 'activity')])

        content.append(['k)','Estado civil',
                        self.checkEmpty(customer, 'civil_state')])

        content.append(['','1. Nombre del cónyuge, de ser casado:',
                        self.checkMaritalStatus(customer, 'partner',
                                                 'civil_state', 'Casado')])

        content.append(['','2. Si declara ser conviviente, consignar nombre',
                        self.checkMaritalStatus(customer, 'partner',
                                                 'civil_state', 'Conviviente')])

        content.append(['l)','''Cargo o función pública que desempeña o
                                que haya desempeñado en los últimos
                                dos (2) años,
                                en Perú o en el extranjero, indicando el
                                nombre del organismo público u organización
                                internacional''',
                        self.checkEmpty(customer, 'employment',
                                                'Sin cargo publico')])

        content.append(['m)','El origen de los fondos, bienes u otros'
                             ' activos involucrados en dicha transaccion'
                            ' (especifique)',
                        self.checkEmpty(customer,'money_source')])

        content.append(['n)','Es sujeto obligado informar a la UIF-Peru?',
                        self.checkButtonchk(dispatch.declaration.customer,
                                                'is_obligated')])

        content.append(['','En caso marco SI, indique si designo a'
                            ' su Oficial de Cumplimiento',
                        self.checkButtonchk(dispatch.declaration.customer,
                                                'has_officer')])

        content.append(['o)','Identificacion del tercero, sea persona'
                           ' natural (nombres y apellidos) o persona'
                           ' juridica (razon o denominacion social)'
                           ' por cuyo intermedio se realiza la operacion,'
                           ' de ser el caso',
                        self.checkComplexKey(dispatch.declaration,
                                               'third.name')])
        s = getSampleStyleSheet()
        s = s["BodyText"]
        s.wordWrap = 'LTR'
        contentTable = [[Paragraph(cell, s) for cell in row]
                             for row in content]
        table = Table(contentTable, colWidths=(0.3*inch, 4*inch, 3.2*inch))
        table.setStyle(TableStyle([
            ('VALIGN',    (0, 0), (-1, -1), 'MIDDLE'),
            ('INNERGRID', (0, 0), (-1, -1),  0.25, colors.black),
            ('BOX',       (0, 0), (-1, -1),  0.25, colors.black)
        ]))
        story.append(table)

    # Adds all the paragraphs for the Business class
    # @Params self, list, list, model, model
    def makeBusinessPDF(self, story, styles, dispatch, customer):
        content = []

        content.append(['a)','Denominación o razón social',
                        self.checkEmpty(customer, 'name')])

        content.append(['b)','Registro Unico de Contribuyentes RUC',
                        self.checkEmpty(customer, 'document_number')])

        content.append(['c)','Objeto social',
                        self.checkEmpty(customer, 'social_object')])

        content.append(['','Actividad económica'
                           ' principal (Comercial, industrial,'
                           ' construccion, etc.)',
                        self.checkEmpty(customer, 'activity')])

        content.append(['d)','Identificacion de los accionistas, socios'
                           ' o asociados, que tengan un porcentaje igual'
                           ' o mayor al 5% de las acciones'
                           ' o participaciones',
                        self.shareholdersList(customer.shareholders)])

        content.append(['e)','Identificacion del representante legal'
                           ' o de quien comparece con facultades de'
                           ' representacion y/o disposicion de la'
                           ' persona juridica',
                        self.checkEmpty(customer, 'legal')])

        content.append(['f)','Domicilio',
                        self.checkEmpty(customer, 'address')])

        content.append(['g)','Domicilio fiscal',
                        self.checkEmpty(customer, 'fiscal_address')])

        content.append(['h)','Telefonos fijos de la oficina y/o de la'
                           ' persona de contacto incluyendo el codigo'
                           ' de la ciudad, sea que se trate del local'
                           ' principal, agencia, sucursal u otros locales'
                           ' donde desarrollan actividades propias al giro'
                           ' de su negocio',
                        self.checkEmpty(customer, 'phone')])

        content.append(['i)','El origen de los fondos, bienes u otros'
                           ' activos involucrados en dicha transaccion'
                           ' (especifique)',
                        self.checkEmpty(customer, 'money_source')])

        content.append(['j)','Es sujeto obligado informar a la UIF-Peru?',
                        self.checkButtonchk(dispatch.declaration.customer,
                                                'is_obligated')])

        content.append(['','En caso marco SI, indique si designo a'
                            ' su Oficial de Cumplimiento',
                        self.checkButtonchk(dispatch.declaration.customer,
                                                'has_officer')])

        content.append(['k)','''Identificacion del tercero sea persona
                            natural (nombres y apellidos) o persona
                            juridica (razon o denominacion social)
                            por cuyo</br> intermedio se realiza la operacion,
                            de ser el caso''',
                        self.checkComplexKey(dispatch.declaration,
                                               'third.name')])



        s = getSampleStyleSheet()
        s = s["BodyText"]
        s.wordWrap = 'LTR'


        contentTable = [[Paragraph(row[cell], s)
                        for cell in range(len(row))]
                             for row in content]
        table = Table(contentTable, colWidths=(0.3*inch, 4*inch, 3.2*inch))
        table.setStyle(TableStyle([
            ('VALIGN',    (0, 0), (-1, -1), 'MIDDLE'),
            ('INNERGRID', (0, 0), (-1, -1),  0.25, colors.black),
            ('BOX',       (0, 0), (-1, -1),  0.25, colors.black)
        ]))

        story.append(table)


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
        styles.add(ParagraphStyle(name='Center', alignment=TA_CENTER))

        doc = SimpleDocTemplate(self.response.out,
                                pagesize=letter,
                                rightMargin=30,
                                leftMargin=30,
                                topMargin=20,
                                bottomMargin=30)

        story = []

        data = [[self.checkEmpty(dispatch.jurisdiction, 'code'),
                 self.checkEmpty(dispatch.jurisdiction, 'name')]]

        s = getSampleStyleSheet()
        s = s["BodyText"]
        s.wordWrap = 'LTR'
        jurisdiccionTable = [[Paragraph(cell, s) for cell in row]
                             for row in data]
        table = Table(jurisdiccionTable,  colWidths=(0.5*inch, 2.5*inch))
        table.setStyle(TableStyle([
        ('VALIGN',    (0, 0), (-1, -1), 'MIDDLE'),
        ('INNERGRID', (0, 0), (-1, -1), 0.25, colors.black),
        ('ALIGN',     (0, 0), (-1, -1), 'CENTER')]))

        anexo5 = Paragraph('<b>ANEXO Nº5</b>', styles['Center'])
        reference = Paragraph('<b>Ref. Cliente</b>', styles['Center'])
        order = Paragraph('<b>N Orden Despacho</b>', styles['Center'])
        jurisdiction = Paragraph('<b>Jurisdiccion</b>', styles['Center'])

        headerTable = [[anexo5],
                       [reference, order, jurisdiction],
                       [dispatch.reference, dispatch.order, table]]

        self.addTable(story, headerTable, 12)

        titlePDF = Paragraph('<b>DECLARACIÓN DE CONOCIMIENTO DEL CLIENTE</b>',
                            styles['Center'])

        title_customer = Paragraph('<b>%s</b>' %('PERSONA JURIDICA'
                                    if customer.document_type == 'ruc'
                                    else 'PERSONA NATURAL'),
                                    styles['Center'])
        title = [[titlePDF],
                 [''],
                 ['Por el presente documento, declaro bajo'
                 ' juramento, lo siguiente:'],
                 [title_customer]]

        table = Table(title, colWidths='*')
        table.setStyle(TableStyle([
            ('BOX',       (0, 0), (-1, -1),  0.25, colors.black),
            ('ALIGN',     (0,0),  (0, 0),  'CENTER'),
            ('BOX', (-1, -1), (0, 0), 0.25, colors.black),
            ('ALIGN',     (-1,-1),  (-1, -1),  'CENTER')
        ]))
        story.append(table)

        if customer.document_type == 'ruc':
            self.makeBusinessPDF(story, styles, dispatch, customer)
        else:
            self.makePersonPDF(story, dispatch, customer)

        ztime = datetime.datetime.utcnow() - timedelta(hours=5)
        bgdate = ztime.strftime('%d / %m / %Y')

        bottom = [['Afirmo y ratifico todo lo manifestado en'
                 ' la presente declaración jurada, en señal de lo cual'
                 ' la firmo, en la fecha que se indica:'],
                 ['','',bgdate],
                 ['','','FECHA: (dd/mm/aaaa)'],
                 ['&nbsp;'*46+'FIRMA']]

        s = getSampleStyleSheet()
        s = s["BodyText"]
        s.wordWrap = 'LTR'
        bottomTable = [[Paragraph(cell, s) for cell in row]
                             for row in bottom]

        table = Table(bottomTable, colWidths=(0.3*inch, 4*inch, 3.2*inch))
        table.setStyle(TableStyle([
        ('VALIGN',    (0, 0), (-1, -1), 'MIDDLE'),
        ('INNERGRID', (0, 0), (-1, -1), 0.25, colors.black),
        ('BOX',       (0, 0), (-1, -1), 0.25, colors.black),
        ('SPAN',      (0, 0), (-1, 0)),
        ('SPAN',      (0, -1), (-1, -1)),
        ('SPAN',(1, 1),(-2, -2)),
        ('SPAN',(0,1),(-3,-2))
        ]))
        story.append(table)

        doc.build(story)


class NewUsers(Handler):  # DEBUG

    @staticmethod
    def to_li(agency):
        officer = agency.officer
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
