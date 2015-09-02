# encoding: utf-8

"""
.. module:: plaft.interfaces.views
   :synopsis: Views.

.. moduleauthor:: Gonzales Castillo, Cristhian A. <gcca@gcca.tk>


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
from reportlab.lib.units import inch, mm
from reportlab.platypus import (SimpleDocTemplate, Paragraph,
                                Table, TableStyle)

plaft.config.init()


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
        self.add_arg('us', self.user.customs_agency.employees)
        self.add_arg('ig', plaft.config.DEBUG)  # is debug
        self.add_list('employees_roles', model.User.role_choices)
        from plaft.application.util.data_generator import alerts
        self.add_list('alert_s1', alerts.alerts_1)
        self.add_list('alert_s3', alerts.alerts_2)

        from plaft.application.dispatch import pending_and_accepting
        self.add_arg('dispatches_pa',
                     pending_and_accepting(self.user.customs_agency))

        from google.appengine.api import memcache
        counter = memcache.get('iocounter')
        if counter is None:
            counter = 0
            memcache.add('iocounter', counter)
        self.add_arg('counter', counter)


class DeclarationPDF(Handler):

    @staticmethod
    def shareholdersList(shareholders):
        html = []
        for s in shareholders:
            html.append('<br/>')
            html.append('%s - %s<br/>%s<br/>' % (s.document_number,
                                                 (s.document_type).upper(),
                                                 s.name))
            html.append('%s %%<br/>' % (s.ratio))
        html.append('<br/>')
        return ''.join(html)

    @staticmethod
    def checkButtonchk(obj, value):
        if hasattr(obj, value):
            if getattr(obj, value):
                return 'SI( X ) &nbsp;&nbsp; NO( &nbsp; )'
            elif getattr(obj, value) is None:
                return '-'
            else:
                return 'SI( &nbsp; ) &nbsp;&nbsp; NO( X )'
        else:
            return 'SI( &nbsp; ) &nbsp;&nbsp; NO( &nbsp; )'

    @staticmethod
    def checkComplexKey(obj, _attr):
        levels = _attr.split('.')
        for key in levels:
            if hasattr(obj, key):
                obj = getattr(obj, key)
            else:
                return '-'
        return obj if obj else '-'

    # Only obj and value params are required!!
    @staticmethod
    def checkEmpty(obj, value, message='-'):
        if hasattr(obj, value):
            if getattr(obj, value):
                return getattr(obj, value)
            else:
                return message
        else:
            return 'No se encontro informacion'

    def checkLength(self, obj, value, message='-'):
        msg = self.checkEmpty(obj, value, message)
        if len(msg) <= 41:
            msg = " <br/> " + msg + " <br/><br/>"
        return msg

    # Only obj and value params are required!!
    @staticmethod
    def checkDate(obj, value, message='-'):
        if hasattr(obj, value):
            if getattr(obj, value):
                return (getattr(obj, value)).strftime('%d/%m/%Y')
            else:
                return message
        else:
            return 'No se encontro informacion'

    # Returns the partners name depending on the marital status
    @staticmethod
    def checkMaritalStatus(obj, partner, civil_state, status):
        if hasattr(obj, partner) and hasattr(obj, civil_state):
            if getattr(obj, civil_state) == status:
                return getattr(obj, partner)
            else:
                return '-'
        else:
            return '-'

    # Adds all the paragraphs for the Person class.
    def makePersonPDF(self, story, dispatch, customer):
        content = []
        content.append(['a)', 'Nombres y apellidos',
                        self.checkEmpty(customer, 'name') + ", " +
                        self.checkEmpty(customer, 'father_name') + " " +
                        self.checkEmpty(customer, 'mother_name')])

        content.append(['b)', 'Tipo de documento de identidad',
                        (self.checkEmpty(customer, 'document_type')).upper()])

        content.append(['', 'Número del documento de identidad',
                        self.checkEmpty(customer, 'document_number')])

        content.append(['c)', '''Registro Único de Contribuyentes (RUC),
                             de ser el caso''',
                        self.checkEmpty(customer, 'ruc', 'Sin ruc')])

        content.append(['d)', 'Lugar de nacimiento',
                        self.checkEmpty(customer, 'birthplace')])

        content.append(['', 'Fecha de nacimiento',
                        self.checkDate(customer, 'birthday')])

        content.append(['e)', 'Nacionalidad',
                        self.checkEmpty(customer, 'nationality')])

        content.append(['f)', 'Domicilio declarado (lugar de residencia)',
                        self.checkEmpty(customer, 'address')])

        content.append(['g)', 'Domicilio fiscal, de ser el caso',
                        self.checkEmpty(customer, 'fiscal_address')])

        content.append(['h)', 'Número de teléfono fijo',
                        self.checkEmpty(customer, 'phone')])

        content.append(['', 'Número de teléfono celular',
                        self.checkEmpty(customer, 'mobile')])

        content.append(['i)', 'Correo electrónico',
                        self.checkEmpty(customer, 'email')])

        content.append(['j)', 'Profesión u ocupación',
                        self.checkEmpty(customer, 'activity')])

        content.append(['k)', 'Estado civil',
                        self.checkEmpty(customer, 'civil_state')])

        content.append(['', '1. Nombre del cónyuge, de ser casado:',
                        self.checkMaritalStatus(customer, 'partner',
                                                'civil_state', 'Casado')])

        content.append(['', '2. Si declara ser conviviente, consignar nombre',
                        self.checkMaritalStatus(customer, 'partner',
                                                'civil_state', 'Conviviente')])

        content.append(['l)', '''Cargo o función pública que desempeña o
                                que haya desempeñado en los últimos
                                dos (2) años,
                                en Perú o en el extranjero, indicando el
                                nombre del organismo público u organización
                                internacional''',
                        self.checkEmpty(customer, 'employment')])

        content.append(['m)', 'El origen de los fondos, bienes u otros'
                              ' activos involucrados en dicha transaccion'
                              ' (especifique)',
                        self.checkEmpty(customer, 'money_source')])

        content.append(['n)', 'Es sujeto obligado informar a la UIF-Peru?',
                        self.checkButtonchk(customer, 'is_obligated')])

        content.append(['', 'En caso marco SI, indique si designo a'
                            ' su Oficial de Cumplimiento',
                        self.checkButtonchk(customer, 'has_officer')])

        content.append(['o)', 'Identificacion del tercero, sea persona'
                              ' natural (nombres y apellidos) o persona'
                              ' juridica (razon o denominacion social)'
                              ' por cuyo intermedio se realiza la operacion, '
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
            ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
            ('INNERGRID', (0, 0), (-1, -1), 0.25, colors.black),
            ('BOX', (0, 0), (-1, -1), 0.25, colors.black)
        ]))
        story.append(table)

    # Adds all the paragraphs for the Business class
    def makeBusinessPDF(self, story, dispatch, customer):
        content = []

        content.append(['a)', 'Denominación o razón social',
                        ' <br/> %s <br/><br/>'
                        % (self.checkEmpty(customer, 'name')).upper()])

        content.append(['b)', 'Registro Unico de Contribuyentes RUC',
                        ' <br/> %s <br/><br/>'
                        % self.checkEmpty(customer, 'document_number')])

        content.append(['c)', 'Objeto social',
                        ' <br/> %s <br/><br/>'
                        % self.checkEmpty(customer, 'social_object')])

        content.append(['', 'Actividad económica'
                            ' principal (Comercial, industrial, '
                            ' construccion, etc.)',
                        self.checkEmpty(customer, 'activity')])

        content.append(['d)', 'Identificacion de los accionistas, socios'
                              ' o asociados, que tengan un porcentaje igual'
                              ' o mayor al 5% de las acciones'
                              ' o participaciones',
                        self.shareholdersList(customer.shareholders)])

        content.append(['e)', 'Identificacion del representante legal'
                              ' o de quien comparece con facultades de'
                              ' representacion y/o disposicion de la'
                              ' persona juridica',
                        self.checkEmpty(customer, 'legal.name')])

        content.append(['f)', 'Domicilio',
                        self.checkEmpty(customer, 'address')])

        content.append(['g)', 'Domicilio fiscal',
                        self.checkLength(customer, 'fiscal_address')])

        content.append(['h)', 'Telefonos fijos de la oficina y/o de la'
                              ' persona de contacto incluyendo el codigo'
                              ' de la ciudad, sea que se trate del local'
                              ' principal, agencia, sucursal u otros locales'
                              ' donde desarrollan actividades propias al giro'
                              ' de su negocio',
                        self.checkEmpty(customer, 'phone')])

        content.append(['i)', 'El origen de los fondos, bienes u otros'
                              ' activos involucrados en dicha transaccion'
                              ' (especifique)',
                        self.checkEmpty(customer, 'money_source')])

        content.append(['j)', 'Es sujeto obligado informar a la UIF-Peru?',
                        ' <br/> %s <br/><br/>'
                        % self.checkButtonchk(customer, 'is_obligated')])

        content.append(['', 'En caso marco SI, indique si designo a'
                            ' su Oficial de Cumplimiento',
                        self.checkButtonchk(customer, 'has_officer')])

        content.append(['k)', '''Identificacion del tercero sea persona
                            natural (nombres y apellidos) o persona
                            juridica (razon o denominacion social)
                            por cuyo intermedio se realiza la operacion,
                            de ser el caso''',
                        self.checkComplexKey(dispatch.declaration,
                                             'third.name')])

        s = getSampleStyleSheet()
        s = s["BodyText"]
        s.wordWrap = 'LTR'

        contentTable = [[Paragraph(row[cell], s) for cell in range(len(row))]
                        for row in content]
        table = Table(contentTable, colWidths=(0.3*inch, 4*inch, 3.2*inch))
        table.setStyle(TableStyle([
            ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
            ('INNERGRID', (0, 0), (-1, -1), 0.25, colors.black),
            ('BOX', (0, 0), (-1, -1), 0.25, colors.black)
        ]))

        story.append(table)

    def get(self, id):
        self.response.headers['Content-Type'] = 'application/pdf'
        dispatch = model.Dispatch.find(int(id))

        def _header(canvas, doc):
            """."""
            # Save the state of our canvas so we can draw on it
            canvas.saveState()

            # Header
            data = [[self.checkEmpty(dispatch.jurisdiction, 'code'),
                     self.checkEmpty(dispatch.jurisdiction, 'name')]]

            s = getSampleStyleSheet()
            s = s["BodyText"]
            s.wordWrap = 'LTR'
            jurisdiccionTable = [[Paragraph(cell, s) for cell in row]
                                 for row in data]
            table = Table(jurisdiccionTable, colWidths=(0.5*inch, 2.5*inch))
            table.setStyle(TableStyle([
                ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
                ('INNERGRID', (0, 0), (-1, -1), 0.25, colors.black),
                ('ALIGN', (0, 0), (-1, -1), 'CENTER')]))

            anexo5 = Paragraph('<b>ANEXO Nº5</b>', styles['Center'])
            reference = Paragraph('<b>Ref. Cliente</b>', styles['Center'])
            order = Paragraph('<b>N Orden Despacho</b>', styles['Center'])
            jurisdiction = Paragraph('<b>Jurisdiccion</b>', styles['Center'])
            titlePDF = Paragraph('<b>DECLARACIÓN JURADA DE CONOCIMIENTO \
                                  DEL CLIENTE</b>',
                                 styles['Center'])
            headerTable = [[anexo5],
                           [reference, order, jurisdiction],
                           [dispatch.reference, dispatch.order, table],
                           [titlePDF]]

            table = Table(headerTable, colWidths='*')
            table.setStyle(TableStyle([
                ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
                ('INNERGRID', (0, 0), (-1, -1), 0.25, colors.black),
                ('BOX', (0, 0), (-1, -1), 0.25, colors.black),
                ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
                ('SPAN', (0, 0), (-1, 0)),
                ('SPAN', (0, 3), (-1, 3))
                ]))
            table.wrapOn(canvas, 540, 150)
            table.drawOn(canvas, 12.7*mm, 240*mm)
            # Release the canvas
            canvas.restoreState()

        customer = dispatch.declaration.customer
        styles = getSampleStyleSheet()
        styles.add(ParagraphStyle(name='Justify', alignment=TA_JUSTIFY))
        styles.add(ParagraphStyle(name='Center', alignment=TA_CENTER))

        doc = SimpleDocTemplate(self.response.out,
                                pagesize=letter,
                                rightMargin=30,
                                leftMargin=30,
                                topMargin=105.54,
                                bottomMargin=55)
        story = []

        title_customer = Paragraph('<b>%s</b>' %
                                   ('PERSONA JURIDICA'
                                    if customer.document_type == 'ruc'
                                    else 'PERSONA NATURAL'),
                                   styles['Center'])
        title = [[''],
                 ['Por el presente documento, declaro bajo'
                  ' juramento, lo siguiente:'],
                 [title_customer]]

        table = Table(title, colWidths='*')
        table.setStyle(TableStyle([
            ('BOX', (0, 0), (-1, -1), 0.25, colors.black),
            ('ALIGN', (0, 0), (0, 0), 'CENTER'),
            ('BOX', (-1, 0), (1, 1), 0.25, colors.black),
            ('ALIGN', (-1, -1), (-1, -1), 'CENTER')
        ]))
        story.append(table)

        if customer.document_type == 'ruc':
            self.makeBusinessPDF(story, dispatch, customer)
        else:
            self.makePersonPDF(story, dispatch, customer)

        ztime = datetime.datetime.utcnow() - timedelta(hours=5)
        bgdate = ztime.strftime('%d / %m / %Y')

        bottom = [['Afirmo y ratifico todo lo manifestado en'
                   ' la presente declaración jurada, en señal de lo cual'
                   ' la firmo, en la fecha que se indica:'],
                  ['', '', bgdate],
                  ['', '', 'FECHA: (dd/mm/aaaa)'],
                  ['&nbsp;'*46+'FIRMA']]

        s = getSampleStyleSheet()
        s = s["BodyText"]
        s.wordWrap = 'LTR'
        bottomTable = [[Paragraph(cell, s) for cell in row]
                       for row in bottom]

        table = Table(bottomTable, colWidths=(0.3*inch, 4*inch, 3.2*inch))
        table.setStyle(TableStyle([
            ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
            ('INNERGRID', (0, 0), (-1, -1), 0.25, colors.black),
            ('BOX', (0, 0), (-1, -1), 0.25, colors.black),
            ('SPAN', (0, 0), (-1, 0)),
            ('SPAN', (0, -1), (-1, -1)),
            ('SPAN', (1, 1), (-2, -2)),
            ('SPAN', (0, 1), (-3, -2))
        ]))
        story.append(table)
        doc.build(story, onFirstPage=_header, onLaterPages=_header)


class DeclarationPDFv2(Handler):

    def shareholdersList(self, shareholders):
        html = []
        for s in shareholders:
            html.append('<br/>')
            html.append('<b>Numero de documento identidad:</b>  %s'
                        ' - %s<br/>' % (s.document_number,
                                        (s.document_type).upper()))
            html.append('<b>Apellidos y nombres:</b>  %s<br/>' % s.name)
            html.append('<b>%% Participacion:</b>  %s %%<br/>' % (s.ratio))
        html.append('<br/>')
        return ''.join(html)

    # Only obj and value params are required!!
    def checkEmpty(self, obj, value):
        if hasattr(obj, value):
            if getattr(obj, value):
                return (getattr(obj, value)).encode('utf-8')
            else:
                return '-'
        else:
            return '-'

    def make_address(self, obj, **kwargs):
        street = self.checkEmpty(obj, kwargs['street'])
        urbanization = self.checkEmpty(obj, kwargs['urbanization'])
        flat = self.checkEmpty(obj, kwargs['flat'])
        distrit = self.checkEmpty(obj, kwargs['distrit'])
        province = self.checkEmpty(obj, kwargs['province'])
        department = self.checkEmpty(obj, kwargs['department'])
        address = self.checkEmpty(obj, kwargs['address'])

        return ('%s %s %s <b>Dpto Nº</b> %s<br/>'
                '<b>Distrito:</b> %s <b>Provincia:</b> %s'
                ' <b>Departamento:</b> %s' % (street, urbanization,
                                              address, flat, distrit,
                                              province, department))

    def makedeclarant(self, declarant):
        name = '%s %s, %s' % (self.checkEmpty(declarant, 'father_name'),
                              self.checkEmpty(declarant, 'mother_name'),
                              self.checkEmpty(declarant, 'name'))
        document_number = self.checkEmpty(declarant, 'document_number')
        document_type = self.checkEmpty(declarant, 'document_type')
        address = self.make_address(declarant,
                                    address='address',
                                    street='street',
                                    urbanization='urbanization',
                                    flat='flat', distrit='distrit',
                                    province='province',
                                    department='department')

        return ('<b>1) Apellidos y nombres: </b>%s <br/>'
                '<b>2) N° y tipo de documento: </b>%s - %s <br/>'
                ' <b>Domicilio</b><br/> %s'
                % (name, document_number,
                   (document_type).upper(), address))

    def make_pep(self, customer):
        pep = []
        description = self.checkEmpty(customer, 'pep_country_description')
        employment = self.checkEmpty(customer, 'employment')
        organization = self.checkEmpty(customer, 'organization')
        pep.append('<br/>')

        pep.append('<b>Desempeña a la fecha :</b> %s'
                   % ('SI (X) NO (&nbsp;)' if customer.pep_is_date
                      else 'SI (&nbsp;) NO (X)'))
        pep.append('<br/>')

        if customer.pep_country == 'Perú':
            tuple_country = ('X', '&nbsp;')
        elif customer.pep_country == 'En el extranjero':
            tuple_country = ('&nbsp;', 'X')
        else:
            tuple_country = ('&nbsp;', '&nbsp;')

        pep.append('En el Peru ( %s ) En el Extranjero ( %s )' % tuple_country)
        pep.append('<br/>')

        pep.append('<b>Indique pais:</b> %s'
                   % (description if description else '____________'))
        pep.append('<br/>')

        pep.append('<b>Cargo funcion publica:</b> %s' % employment)
        pep.append('<br/>')

        pep.append('<b>Nombre del Organismo Publico u Organizacion'
                   ' internacional: </b> %s' % organization)
        pep.append('<br/>')

        return ''.join(pep)

    # Adds all the paragraphs for the Person class
    def makePersonPDF(self, story, customer):
        content = []

        content.append(['a)', 'Nombres y Apellidos',
                        '%s, %s %s'
                        % (self.checkEmpty(customer, 'name'),
                           self.checkEmpty(customer, 'father_name'),
                           self.checkEmpty(customer, 'mother_name'))])

        content.append(['b)', 'Tipo y Nº del documento de identidad',
                        '%s - %s'
                        % (self.checkEmpty(customer, 'document_number'),
                           (self.checkEmpty(customer,
                                            'document_type')).upper())])

        content.append(['c)', 'Condición en la que se realiza la operación',
                              self.checkEmpty(customer, 'link_type')])

        content.append(['d)', 'Nacionalidad',
                        self.checkEmpty(customer, 'nationality')])

        address = self.make_address(customer,
                                    address='address',
                                    street='street',
                                    urbanization='urbanization',
                                    flat='flat', distrit='distrit',
                                    province='province',
                                    department='department')

        content.append(['e)', '<b>Domicilio</b><br/>%s' % address])

        content.append(['f)', 'Numero de telefono (fijo y celular)',
                        '%s - %s' % (self.checkEmpty(customer, 'phone'),
                                     self.checkEmpty(customer, 'mobile'))])

        content.append(['g)', 'Correo electrónico',
                        self.checkEmpty(customer, 'email')])

        content.append(['h)', 'Profesión u ocupación',
                        self.checkEmpty(customer, 'activity')])

        content.append(['', 'Centro de labores',
                        self.checkEmpty(customer, 'work_center')])

        content.append(['i)', 'Cumple o en los últimos cinco anos ha cumplido '
                              'funciones publicas destacadas o funciones '
                              'prominentes en una organización internacional,'
                              'sea en el territorio nacional o extranjero o'
                              'extranjero, y cuyas circunstancias financieras'
                              'puedan ser objeto de un interés publico:%s'
                              % self.make_pep(customer)])

        content.append(['j)', ('El origen de los fondos, bienes u otros'
                               ' activos involucrados en dicha'
                               ' transacción (especifique):'),
                        self.checkEmpty(customer, 'money_source')])

        content.append(['k)', ('<b>IDENTIFICACION DEL DECLARANTE</b><br/>%s'
                               % self.makedeclarant(customer.proxy))])

        s = getSampleStyleSheet()
        s = s["BodyText"]
        s.wordWrap = 'LTR'

        contentTable = [[Paragraph(row[cell], s) for cell in range(len(row))]
                        for row in content]
        table = Table(contentTable, colWidths=(0.3*inch, 4*inch, 3.2*inch))
        table.setStyle(TableStyle([
            ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
            ('INNERGRID', (0, 0), (-1, -1), 0.25, colors.black),
            ('BOX', (0, 0), (-1, -1), 0.25, colors.black),
            ('SPAN', (1, 4), (-1, 4)), ('SPAN', (1, 9), (-1, 9)),
            ('SPAN', (1, 11), (-1, 11)),
        ]))

        story.append(table)

    # Adds all the paragraphs for the Business class
    def makeBusinessPDF(self, story, customer):
        content = []

        content.append(['a)', 'Denominación o razón social',
                        ' <br/> %s <br/><br/>'
                        % (self.checkEmpty(customer, 'name')).upper()])

        content.append(['b)', ('Nº de Registro Único de Contribuyentes RUC,'
                               'de ser el caso'),
                        ' <br/> %s <br/><br/>'
                        % self.checkEmpty(customer, 'document_number')])

        content.append(['c)', ('Condición en la que se realiza la operación'
                               ' (marque X según corresponda)'),
                        self.checkEmpty(customer, 'link_type')])

        content.append(['d)', ('Objeto social y actividad económica principal'
                               ' principal (comercial, industrial, '
                               ' construcción, transporte, etc.)'),
                        self.checkEmpty(customer, 'social_object')])

        content.append(['e)', 'Identificacion de los accionistas, socios'
                              ' o asociados, que tengan un porcentaje igual'
                              ' o mayor al 25%% de las acciones'
                              ' o participaciones sociales de la persona'
                              ' juridica (Indique nombres, apellidos y %%)'
                              ' <br/>%s'
                              % self.shareholdersList(customer.shareholders)])

        content.append(['f)', ('Identificación del representante legal o de'
                               ' quien comparece con facultades de'
                               ' representación y/o disposición de la'
                               ' persona jurídica<br/>'
                               '<b>(1) Apellidos y nombres: </b> %s <br/>'
                               '<b>(2) N° y tipo de documento: </b> %s - %s'
                               % (self.checkEmpty(customer,
                                                  'legal_name'),
                                  self.checkEmpty(customer,
                                                  'legal_document_number'),
                                  (self.checkEmpty(customer,
                                                   ('legal_document'
                                                    '_type'))).upper()))])

        address = self.make_address(customer,
                                    address='address',
                                    street='street',
                                    urbanization='urbanization',
                                    flat='flat', distrit='distrit',
                                    province='province',
                                    department='department')

        content.append(['g)', '<b>Domicilio</b><br/>%s' % address])

        content.append(['h)', 'Telefonos fijos de la oficina principal',
                        self.checkEmpty(customer, 'phone')])

        content.append(['i)', ('El origen de los fondos, bienes u otros'
                               ' activos involucrados en dicha'
                               ' transacción (especifique):'),
                        self.checkEmpty(customer, 'money_source')])

        content.append(['j)', ('<b>IDENTIFICACION DEL DECLARANTE</b>(complete'
                               ' esta informacion unicamente en el caso'
                               ' que el declarante sea una persona distinta'
                               ' a la consignada en el literal f.'
                               ' que antecede)<br/>%s'
                               % self.makedeclarant(customer.proxy))])

        s = getSampleStyleSheet()
        s = s["BodyText"]
        s.wordWrap = 'LTR'

        contentTable = [[Paragraph(row[cell], s) for cell in range(len(row))]
                        for row in content]
        table = Table(contentTable, colWidths=(0.3*inch, 4*inch, 3.2*inch))
        table.setStyle(TableStyle([
            ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
            ('INNERGRID', (0, 0), (-1, -1), 0.25, colors.black),
            ('BOX', (0, 0), (-1, -1), 0.25, colors.black),
            ('SPAN', (1, 4), (-1, 4)), ('SPAN', (1, 5), (-1, 5)),
            ('SPAN', (1, 6), (-1, 6)), ('SPAN', (1, 9), (-1, 9)),
        ]))

        story.append(table)

    def get(self, id):
        self.response.headers['Content-Type'] = 'application/pdf'
        dispatch = model.Dispatch.find(int(id))
        customer = dispatch.declaration.customer
        styles = getSampleStyleSheet()
        styles.add(ParagraphStyle(name='Justify', alignment=TA_JUSTIFY))
        styles.add(ParagraphStyle(name='Center', alignment=TA_CENTER))

        def _header(canvas, doc):
            """."""
            # Save the state of our canvas so we can draw on it
            canvas.saveState()

            # Header
            data = [[self.checkEmpty(dispatch.jurisdiction, 'code'),
                     self.checkEmpty(dispatch.jurisdiction, 'name')]]

            s = getSampleStyleSheet()
            s = s["BodyText"]
            s.wordWrap = 'LTR'
            jurisdiccionTable = [[Paragraph(cell, s) for cell in row]
                                 for row in data]
            table = Table(jurisdiccionTable, colWidths=(0.5*inch, 2.5*inch))
            table.setStyle(TableStyle([
                ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
                ('INNERGRID', (0, 0), (-1, -1), 0.25, colors.black),
                ('ALIGN', (0, 0), (-1, -1), 'CENTER')]))

            anexo5 = Paragraph('<b>ANEXO Nº5</b>', styles['Center'])
            reference = Paragraph('<b>Ref. Cliente</b>', styles['Center'])
            order = Paragraph('<b>N Orden Despacho</b>', styles['Center'])
            jurisdiction = Paragraph('<b>Jurisdiccion</b>', styles['Center'])
            titlePDF = Paragraph('<b>DECLARACIÓN JURADA DE CONOCIMIENTO \
                                  DEL CLIENTE</b>',
                                 styles['Center'])
            headerTable = [[anexo5],
                           [reference, order, jurisdiction],
                           [dispatch.reference, dispatch.order, table],
                           [titlePDF]]

            table = Table(headerTable, colWidths='*')
            table.setStyle(TableStyle([
                ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
                ('INNERGRID', (0, 0), (-1, -1), 0.25, colors.black),
                ('BOX', (0, 0), (-1, -1), 0.25, colors.black),
                ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
                ('SPAN', (0, 0), (-1, 0)),
                ('SPAN', (0, 3), (-1, 3))
                ]))
            table.wrapOn(canvas, 540, 150)
            table.drawOn(canvas, 12.7*mm, 240*mm)
            # Release the canvas
            canvas.restoreState()

        doc = SimpleDocTemplate(self.response.out,
                                pagesize=letter,
                                rightMargin=30,
                                leftMargin=30,
                                topMargin=105.54,
                                bottomMargin=55)
        story = []

        title_customer = Paragraph('<b>%s</b>' %
                                   ('PERSONA JURIDICA'
                                    if customer.document_type == 'ruc'
                                    else 'PERSONA NATURAL'),
                                   styles['Center'])
        title = [[''],
                 ['Por el presente documento, declaro bajo'
                  ' juramento, lo siguiente:'],
                 [title_customer]]

        table = Table(title, colWidths='*')
        table.setStyle(TableStyle([
            ('BOX', (0, 0), (-1, -1), 0.25, colors.black),
            ('ALIGN', (0, 0), (0, 0), 'CENTER'),
            ('BOX', (-1, 0), (1, 1), 0.25, colors.black),
            ('ALIGN', (-1, -1), (-1, -1), 'CENTER')
        ]))
        story.append(table)

        if customer.document_type == 'ruc':
            self.makeBusinessPDF(story, customer)
        else:
            self.makePersonPDF(story, customer)

        ztime = datetime.datetime.utcnow() - timedelta(hours=5)
        bgdate = ztime.strftime('%d / %m / %Y')

        bottom = [['Afirmo y ratifico todo lo manifestado en'
                   ' la presente declaración jurada, en señal de lo cual'
                   ' la firmo, en la fecha que se indica:'],
                  ['', '', bgdate],
                  ['', '', 'FECHA: (dd/mm/aaaa)'],
                  ['&nbsp;'*46+'FIRMA']]

        s = getSampleStyleSheet()
        s = s["BodyText"]
        s.wordWrap = 'LTR'
        bottomTable = [[Paragraph(cell, s) for cell in row]
                       for row in bottom]

        table = Table(bottomTable, colWidths=(0.3*inch, 4*inch, 3.2*inch))
        table.setStyle(TableStyle([
            ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
            ('INNERGRID', (0, 0), (-1, -1), 0.25, colors.black),
            ('BOX', (0, 0), (-1, -1), 0.25, colors.black),
            ('SPAN', (0, 0), (-1, 0)),
            ('SPAN', (0, -1), (-1, -1)),
            ('SPAN', (1, 1), (-2, -2)),
            ('SPAN', (0, 1), (-3, -2))
        ]))
        story.append(table)
        doc.build(story, onFirstPage=_header, onLaterPages=_header)

# vim: et:ts=4:sw=4
