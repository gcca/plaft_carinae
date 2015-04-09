# encoding: utf-8

"""
.. module:: plaft.interfaces.views
   :synopsis: Views.

.. moduleauthor:: Gonzales Castillo, Cristhian A. <cristhian.gz@aol.com>


"""

from plaft.interfaces import Handler, DirectToController
from plaft.domain import model


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
        self.add_arg('linked', {stk.slug: stk.id for stk in model.Linked.all()})
        self.add_arg('declarant', {dcl.slug: dcl.id for dcl in model.Declarant.all()})


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


import sys
import os
sys.path.append(os.path.join(os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'infrastructure'),'support'))

from datetime import timedelta
from reportlab.lib.enums import TA_JUSTIFY
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Image, \
                               Table, TableStyle
import datetime

class DeclarationPDF(Handler):

    def shareholdersList(self, shareholders):
        list = []
        for s in shareholders:
            if int(s.ratio) >= 5:
                list.append(['    Nombre', s.name])
                list.append(['    Documento', s.document_type])
                list.append(['    Número', s.document_number])
                list.append(['', ''])
        return list

    def checkComplexKey(self, obj, _attr):
        levels = _attr.split('.')
        print(levels)
        for key in levels:
            if hasattr(obj, key):
                obj = getattr(obj, key)
            else:
                return 'Llave no encontrada'
        return obj


    ### Only obj and value params are required!!
    # @Param {Model} obj
    # @Param {String} value
    def checkEmpty(self, obj, value, message = '-'):
        if hasattr(obj, value):
            if getattr(obj, value):
                return getattr(obj, value)
            else:
                return message
        else:
            return 'No se encontro informacion'

    # Returns the partners name depending on the marital status
    # @Param {Model} obj
    # @Param {String} partner property of the model.
    # @Param {String} civil_state property of the model.
    # @Param {String} status string used to compare the civil_state
    def checkMaritalStatus(self, obj, partner, civil_state, status):
        if hasattr(obj, partner) and hasattr(obj, civil_state):
            if getattr(obj, civil_state) == status:
                return getattr(obj, partner)
            else:
                return '-'
        else: return '-'

    # Adds a paragraph to the pdf file
    # @Param {list} story
    # @Param {list} styles
    # @Param {String} text string used to fill the paragraph
    # @Param {int} space number used for spacer.
    def addParagraph(self, story, styles, text, space):
        story.append(
            Paragraph('<para>%s</para>' %text, styles['Normal']))
        story.append(Spacer(1, space))

    def addTable(self, story, data, space, autoColWidths=False):
        if autoColWidths == False:
            table = Table(data, [2.2*inch, 3.5*inch])
            story.append(table)
            story.append(Spacer(1, space))
        else:
            table = Table(data, colWidths='*')
            table.setStyle(TableStyle([('VALIGN',(0,0),(-1,-1),'TOP')]))
            story.append(table)
            story.append(Spacer(1, space))

    # Adds all the paragraphs for the Person class.
    # @Params self, list, list, model, model
    def makePersonPDF(self, story, styles, dispatch, customer):
        tab = '&nbsp;'*4
        story.append(Spacer(1, 12))
        self.addParagraph(story, styles, 'a) Nombres y apellidos', 4)
        self.addParagraph(story, styles, tab + self.checkEmpty(customer, 'name'), 12)
        self.addParagraph(story, styles, 'b) Tipo y número de documento de identidad', 4)
        self.addParagraph(story, styles, tab + self.checkEmpty(customer, 'document_type') +
                                         tab + self.checkEmpty(customer, 'document_number'), 12)
        self.addParagraph(story, styles, 'c) Registro único de contribuyente (RUC), de ser el caso.', 4)
        self.addParagraph(story, styles, tab + self.checkEmpty(customer, 'ruc', 'Sin ruc'), 12)
        self.addParagraph(story, styles, 'd) Lugar y fecha de nacimiento', 4)

        dateAndBirthTable = [['Lugar de nacimiento', 'Fecha de nacimiento'],
                             [self.checkEmpty(customer, 'birthplace'),
                              self.checkEmpty(customer, 'birthday')]]
        self.addTable(story, dateAndBirthTable, 12)

        self.addParagraph(story, styles, 'e) Nacionalidad', 4)
        self.addParagraph(story, styles, tab + self.checkEmpty(customer, 'nationality'), 12)
        self.addParagraph(story, styles, 'f) Domicilio declarado (lugar de residencia)', 4)
        self.addParagraph(story, styles, tab + self.checkEmpty(customer, 'address'), 12)
        self.addParagraph(story, styles, 'g) Domicilio fiscal, de ser el caso', 4)
        self.addParagraph(story, styles, tab + self.checkEmpty(customer, 'fiscal_address'), 12)
        self.addParagraph(story, styles, 'h) Número de telefono (fijo y celular)', 4)

        homeAndMobilePhoneTable = [['Fijo', 'Celular'],
                                   [self.checkEmpty(customer, 'phone'),
                                    self.checkEmpty(customer, 'mobile')]]
        self.addTable(story, homeAndMobilePhoneTable, 12)

        self.addParagraph(story, styles, 'i) Correo electrónico', 4)
        self.addParagraph(story, styles, tab + self.checkEmpty(customer, 'email'), 12)
        self.addParagraph(story, styles, 'j) Profesión u ocupación', 4)
        self.addParagraph(story, styles, tab + self.checkEmpty(customer, 'activity'), 12)
        self.addParagraph(story, styles, 'k) Estado civil', 4)
        self.addParagraph(story, styles, tab + self.checkEmpty(customer, 'civil_state'),4)
        self.addParagraph(story, styles, tab + '1. Nombre del conyuge, de ser casado: ' +
                                         tab + (self.checkMaritalStatus(customer, 'partner', 'civil_state', 'Casado')), 4)
        self.addParagraph(story, styles, tab + '2. Si declara ser conviviente, consignar nombre: ' +
                                         tab + (self.checkMaritalStatus(customer, 'partner', 'civil_state', 'Conviviente')), 12)
        self.addParagraph(story, styles, 'l) Cargo o función pública que desempeña o que haya desempeñado en los últimos dos (2) años, ' +
                                         'en Perú o en el extranjero, indicando el nombre del organismo público u organización internacional', 4)
        self.addParagraph(story, styles, tab + self.checkEmpty(customer, 'employment', 'Sin cargo publico'), 12)
        self.addParagraph(story, styles, 'm) El origen de los fondos, bienes u otros activos involucrados en dicha transaccion (especifique)', 4)
        self.addParagraph(story, styles, tab + self.checkEmpty(dispatch.declaration, 'money_source'), 12)
        self.addParagraph(story, styles, 'n) Es sujeto obligado informar a la UIF-Peru', 4)
        self.addParagraph(story, styles, tab + self.checkEmpty(dispatch.declaration, 'is_obligated'), 12)
        self.addParagraph(story, styles, tab + 'En caso marco SI, indique si designo a su Oficial de Cumplimiento', 4)
        self.addParagraph(story, styles, tab + self.checkEmpty(dispatch.declaration, 'has_officer'), 12)
        self.addParagraph(story, styles, 'o) Identificacion del tercero, sea persona natural (nombres y apellidos) o persona juridica (razon o denominacion social) por cuyo intermedio se realiza la operacion, de ser el caso', 4)
        self.addParagraph(story, styles, tab + self.checkComplexKey(dispatch.declaration.get(), 'third.name'), 12)

    # Adds all the paragraphs for the Business class
    # @Params self, list, list, model, model
    def makeBusinessPDF(self, story, styles, dispatch, customer):
        tab = '&nbsp;'*4
        story.append(Spacer(1, 12))

        self.addParagraph(story, styles, 'a) Denominacion o razon social', 4)
        self.addParagraph(story, styles, tab + self.checkEmpty(customer, 'name'), 12)
        self.addParagraph(story, styles, 'b) Registro Unico de Contribuyentes RUC', 4)
        self.addParagraph(story, styles, tab + self.checkEmpty(customer, 'document_number'), 12)
        self.addParagraph(story, styles, 'c) Objeto social y actividad economica principal (Comercial, industrial, construccion, etc.)', 4)
        self.addParagraph(story, styles, tab + 'Objeto social: ' + self.checkEmpty(customer, 'social_object'), 4)
        self.addParagraph(story, styles, tab + 'Actividad economica: '+ self.checkEmpty(customer, 'activity'), 12)
        self.addParagraph(story, styles, 'd) Identificacion de los accionistas, socios o asociados, que tengan un porcentaje igual o mayor al 5% de las acciones o participaciones', 4)

        self.addTable(story, self.shareholdersList(customer.shareholders), 12) if customer.shareholders else self.addParagraph(story, styles, 'Sin accionistas', 12)

        self.addParagraph(story, styles, 'e) Identificacion del representante legal o de quien comparece con facultades de representacion y/o disposicion de la persona juridica', 4)
        self.addParagraph(story, styles, tab + self.checkEmpty(customer, 'identification'), 12)
        self.addParagraph(story, styles, 'f) Domicilio', 4)
        self.addParagraph(story, styles, tab + self.checkEmpty(customer, 'address'), 12) #falta mejorar
        self.addParagraph(story, styles, 'g) Domicio fiscal', 4)
        self.addParagraph(story, styles, tab + self.checkEmpty(customer, 'fiscal_address'), 12)
        self.addParagraph(story, styles, 'h) Telefonos fijos de la oficina y/o de la persona de contacto incluyendo el codigo de la ciudad, sea que se trate del local principal, agencia, sucursal u otros locales donde desarrollan actividades propias al giro de su negocio', 4)
        self.addParagraph(story, styles, tab + self.checkEmpty(customer, 'phone'), 12)
        self.addParagraph(story, styles, 'i) El origen de los fondos, bienes u otros activos involucrados en dicha transaccion (especifique)', 4)
        self.addParagraph(story, styles, tab + self.checkEmpty(customer, 'money_source'), 12)
        self.addParagraph(story, styles, 'j) Es sujeto obligado informar a la UIF-Peru', 4)
        self.addParagraph(story, styles, tab + self.checkEmpty(customer, 'is_obligated'), 12)
        self.addParagraph(story, styles, tab + 'En caso marco SI, indique si designo a su Oficial de Cumplimiento', 4)
        self.addParagraph(story, styles, tab + self.checkEmpty(customer, 'has_officer'), 12)
        self.addParagraph(story, styles, 'k) Identificacion del tercero, sea persona natural (nombres y apellidos) o persona juridica (razon o denominacion social) por cuyo intermedio se realiza la operacion, de ser el caso', 4)
        self.addParagraph(story, styles, tab + self.checkComplexKey(dispatch.declaration.get(), 'third.name'), 12)

    def get(self, id):
        self.response.headers['Content-Type'] = 'application/pdf'

        dispatch = model.Dispatch.find(int(id))
        customer = dispatch.declaration.get().customer

        if customer.document_type == 'ruc':
            customer = model.Business.new(customer.dict)
        else:
            customer = model.Person.new(customer.dict)

        styles=getSampleStyleSheet()
        styles.add(ParagraphStyle(name='Justify', alignment=TA_JUSTIFY))

        doc = SimpleDocTemplate(self.response.out,
                                pagesize=letter,
                                rightMargin=72,
                                leftMargin=72,
                                topMargin=72,
                                bottomMargin=72)

        story=[]

        jurisdiccionTable = [['Código', 'Nombre'],
                             [self.checkEmpty(dispatch.jurisdiction, 'code'),
                              self.checkEmpty(dispatch.jurisdiction, 'name')]]
        headerTable = [['Ref. Cliente', 'N Orden Despacho', 'Jurisdiccion'],
                       [dispatch.reference, dispatch.order, Table(jurisdiccionTable, colWidths='*')]]

        self.addTable(story, headerTable, 12, True)

        story.append(
            Paragraph('<para alignment=center><font size=12><b>ANEXO N&ordm;5</b></font></para>',
                      styles['Normal']))
        story.append(Spacer(1, 12))

        story.append(
            Paragraph('<para alignment=center><font size=12><b>Declaración Jurada De conocimiento del Cliente</b></font></para>',
                      styles['Normal']))

        title = 'Persona Jurídica' if customer.document_type == 'ruc' else 'Persona Natural'

        story.append(
            Paragraph('<para alignment=center><font size=12><b>%s</b></font></para>' %title, styles['Normal']))
        story.append(Spacer(1, 24))

        self.addParagraph(story, styles, 'Por el presente documento, declaro bajo juramento, lo siguiente', 8)

        ## FALTA LA FIRMA

        if customer.document_type == 'ruc':
            self.makeBusinessPDF(story, styles, dispatch, customer)
        else:
            self.makePersonPDF(story, styles, dispatch, customer)

        story.append(Spacer(1, 30))
        ptext = '<font size=10>Afirmo y ratifico todo lo manifestado en la presente declaración jurada, en señal de lo cual</font>'
        story.append(Paragraph(ptext, styles["Justify"]))
        story.append(Spacer(1, 1))

        story.append(Paragraph('<font size=10>la firmo, en la fecha que se indica:</font>', styles["Justify"]))
        story.append(Spacer(1, 30))

        ztime = datetime.datetime.utcnow() -timedelta(hours=5) #declaration.created.utcnow() - timedelta(hours=5)
        bgdate = ztime.strftime('%d / %m / %Y')
        bgtime = ztime.strftime('%H:%M')

        data = [['____________________' , 'Fecha :    ' + bgdate],
                ['               Firma', 'Hora   :    ' +bgtime]]
        table = Table(data, [3*inch, 2.1*inch], 2*[.2*inch])
        story.append(table)

        doc.build(story)


# vim: et:ts=4:sw=4
