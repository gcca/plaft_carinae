# encoding: utf-8

"""
.. module:: plaft.interfaces.views
   :synopsis: Views.

.. moduleauthor:: Gonzales Castillo, Cristhian A. <cristhian.gz@aol.com>


"""

from plaft.interfaces import Handler, DirectToController
from plaft.domain.model import User, Dispatch


class SignIn(DirectToController):
    """Welcome and sign in controller for users."""

    def post(self):
        """Login user."""

        username = self.request.get('username')
        password = self.request.get('password')

        user = User.authenticate(username, password)

        if user:
            self.login(user)
            self.redirect('/dashboard')
        else:
            self.write_template('e:-1')


class Dashboard(DirectToController):
    """Users dashboard."""


class Debug(Handler):
    """Only use to handtest."""

    def get(self):
        """Create entities."""
        from plaft.application.util import sample_data_generator
        sample_data_generator.users()
        self.write('Don\'t worry... Be happy.')

    def post(self):
        """Delete entities."""
        from plaft.infrastructure.persistence.datastore.ndb import Model
        import google.appengine.ext.ndb as ndb
        from plaft.domain import model
        ndb.delete_multi(v for m in
                         [getattr(model, i) for i in dir(model)
                          if type(getattr(model, i)) is ndb.model.MetaModel]
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

    def checkEmpty(self, value, message = '-'):
        if value:
            return value
        else:
            return message

    def addParagraph(self, story, styles, text, space):
        story.append(
            Paragraph('<para>%s</para>' %text, styles['Normal']))
        story.append(Spacer(1, space))

    def addTable(self, story, data, space):
        table = Table(data, [2.2*inch, 3.5*inch])
        story.append(table)
        story.append(Spacer(1, space))

    def isPerson(self, story, styles, dispatch):
        tab = '&nbsp;'*4
        story.append(Spacer(1, 12))
        self.addParagraph(story, styles, 'a) Nombres y apellidos', 4)
        self.addParagraph(story, styles, tab + self.checkEmpty(dispatch.declaration.name), 12)
        self.addParagraph(story, styles, 'b) Tipo y numero de documento de identidad', 4)
        self.addParagraph(story, styles, tab + self.checkEmpty(dispatch.declaration.document_type) +
                                         tab + self.checkEmpty(dispatch.declaration.document_number), 12)
        self.addParagraph(story, styles, 'c) Registro unico de contribuyente (RUC), de ser el caso.', 4)
        self.addParagraph(story, styles, tab + self.checkEmpty(dispatch.declaration.ruc, 'Sin ruc'), 12)
        self.addParagraph(story, styles, 'd) Lugar y fecha de nacimiento', 4)

        dateAndBirthTableHeader = []
        dateAndBirthTableHeader.append(['Lugar de nacimiento', 'Fecha de nacimiento'])
        dateAndBirthTableBody = []
        dateAndBirthTableBody.append([dispatch.declaration.birthplace, dispatch.declaration.birthday])
        self.addTable(story, dateAndBirthTableHeader, 0)
        self.addTable(story, dateAndBirthTableBody, 12)

        self.addParagraph(story, styles, 'e) Nacionalidad', 4)
        self.addParagraph(story, styles, tab + self.checkEmpty(dispatch.declaration.nationality), 12)
        self.addParagraph(story, styles, 'f) Domicilio declarado (lugar de residencia)', 4)
        self.addParagraph(story, styles, tab + self.checkEmpty(dispatch.declaration.address), 12)
        self.addParagraph(story, styles, 'g) Domicilio fisca, de ser el caso', 4)
        self.addParagraph(story, styles, tab + self.checkEmpty(dispatch.declaration.fiscal_address), 12)
        self.addParagraph(story, styles, 'h) Numero de telefono (fijo y celular)', 4)

        homeAndMobilePhoneTableH = []
        homeAndMobilePhoneTableB = []
        homeAndMobilePhoneTableH.append(['Fijo', 'Celular'])
        homeAndMobilePhoneTableB.append([self.checkEmpty(dispatch.declaration.phone),
                                         self.checkEmpty(dispatch.declaration.mobile)])
        self.addTable(story, homeAndMobilePhoneTableH, 0)
        self.addTable(story, homeAndMobilePhoneTableB, 12)

        self.addParagraph(story, styles, 'i) Correo electronico', 4)
        self.addParagraph(story, styles, tab + self.checkEmpty(dispatch.declaration.email), 12)
        self.addParagraph(story, styles, 'j) Profesion u ocupacion', 4)
        self.addParagraph(story, styles, tab + self.checkEmpty(dispatch.declaration.activity), 12)
        self.addParagraph(story, styles, 'k) Estado civil', 4)
        self.addParagraph(story, styles, tab + self.checkEmpty(dispatch.declaration.civil_state),4)
        self.addParagraph(story, styles, tab + '1. Nombre del conyuge, de ser casado: ' +
                                         tab + (self.checkEmpty(dispatch.declaration.partner) if dispatch.declaration.civil_state == 'Casado' else '-'), 4)
        self.addParagraph(story, styles, tab + '2. Si declara ser conviviente, consignar nombre: ' +
                                         tab + (self.checkEmpty(dispatch.declaration.partner) if dispatch.declaration.civil_state == 'Conviviente' else '-'), 12)
        self.addParagraph(story, styles, 'l) Cargo o funcion publica que desempeña o que haya desempeñado en los ultimos dos (2) años, en el Peru o en el extranjero, indicando el nombre del organismo publico u organizacion internacional', 4)
        self.addParagraph(story, styles, tab + self.checkEmpty(dispatch.declaration.employment, 'Sin cargo publico'), 12)
        self.addParagraph(story, styles, 'm) El origen de los fondos, bienes u otros activos involucrados en dicha transaccion (especifique)', 4)
        self.addParagraph(story, styles, tab + self.checkEmpty(dispatch.declaration.money_source), 12)
        self.addParagraph(story, styles, 'n) Es sujeto obligado informar a la UIF-Peru', 4)
        self.addParagraph(story, styles, tab + self.checkEmpty(dispatch.declaration.is_obligated), 12)
        self.addParagraph(story, styles, tab + 'En caso marco SI, indique si designo a su Oficial de Cumplimiento', 4)
        self.addParagraph(story, styles, tab + self.checkEmpty(dispatch.declaration.has_officer), 12)
        self.addParagraph(story, styles, 'o) Identificacion del tercero, sea persona natural (nombres y apellidos) o persona juridica (razon o denominacion social) por cuyo intermedio se realiza la operacion, de ser el caso', 4)
        self.addParagraph(story, styles, tab + self.checkEmpty(dispatch.declaration.third.name) if dispatch.declaration.third else 'Sin tercero', 12)

    def isBusiness(self, story, styles, dispatch):
        tab = '&nbsp;'*4
        story.append(Spacer(1, 12))
        self.addParagraph(story, styles, 'a) Denominacion o razon social', 4)
        self.addParagraph(story, styles, tab + self.checkEmpty(dispatch.declaration.name), 12)
        self.addParagraph(story, styles, 'b) Registro Unico de Contribuyentes RUC', 4)
        self.addParagraph(story, styles, tab + self.checkEmpty(dispatch.declaration.document_number), 12)
        self.addParagraph(story, styles, 'c) Objeto social y actividad economica principal (Comercial, industrial, construccion, etc.)', 4)
        self.addParagraph(story, styles, tab + 'Objeto social: '+self.checkEmpty(dispatch.declaration.social_object), 4)
        self.addParagraph(story, styles, tab + 'Actividad economica: '+self.checkEmpty(dispatch.declaration.activity), 12)
        self.addParagraph(story, styles, 'd) Identificacion de los accionistas, socios o asociados, que tengan un porcentaje igual o mayor al 5% de las acciones o participaciones', 4)
        self.addTable(story, self.shareholdersList(dispatch.declaration.shareholders), 12) if dispatch.declaration.shareholders else addParagraph(story, styles, 'Sin accionistas', 12)
        self.addParagraph(story, styles, 'e) Identificacion del representante legal o de quien comparece con facultades de representacion y/o disposicion de la persona juridica', 4)
        self.addParagraph(story, styles, tab + self.checkEmpty(dispatch.declaration.identification), 12)
        self.addParagraph(story, styles, 'f) Domicilio', 4)
        self.addParagraph(story, styles, tab + self.checkEmpty(dispatch.declaration.address), 12) #falta mejorar
        self.addParagraph(story, styles, 'g) Domicio fiscal', 4)
        self.addParagraph(story, styles, tab + self.checkEmpty(dispatch.declaration.fiscal_address), 12)
        self.addParagraph(story, styles, 'h) Telefonos fijos de la oficina y/o de la persona de contacto incluyendo el codigo de la ciudad, sea que se trate del local principal, agencia, sucursal u otros locales donde desarrollan actividades propias al giro de su negocio', 4)
        self.addParagraph(story, styles, tab + self.checkEmpty(dispatch.declaration.phone), 12)
        self.addParagraph(story, styles, 'i) El origen de los fondos, bienes u otros activos involucrados en dicha transaccion (especifique)', 4)
        self.addParagraph(story, styles, tab + self.checkEmpty(dispatch.declaration.money_source), 12)
        self.addParagraph(story, styles, 'j) Es sujeto obligado informar a la UIF-Peru', 4)
        self.addParagraph(story, styles, tab + self.checkEmpty(dispatch.declaration.is_obligated), 12)
        self.addParagraph(story, styles, tab + 'En caso marco SI, indique si designo a su Oficial de Cumplimiento', 4)
        self.addParagraph(story, styles, tab + self.checkEmpty(dispatch.declaration.has_officer), 12)
        self.addParagraph(story, styles, 'k) Identificacion del tercero, sea persona natural (nombres y apellidos) o persona juridica (razon o denominacion social) por cuyo intermedio se realiza la operacion, de ser el caso', 4)
        self.addParagraph(story, styles, tab + self.checkEmpty(dispatch.declaration.third.name) if dispatch.declaration.third else 'Sin tercero', 12)


    def get(self,id):
        self.response.headers['Content-Type'] = 'application/pdf'

        dispatch = Dispatch.find(int(id))
        print(dispatch)

        styles=getSampleStyleSheet()
        styles.add(ParagraphStyle(name='Justify', alignment=TA_JUSTIFY))

        doc = SimpleDocTemplate(self.response.out,
                                pagesize=letter,
                                rightMargin=72,
                                leftMargin=72,
                                topMargin=72,
                                bottomMargin=18)

        story=[]

        headerTitle = []
        headerJurisdiccion = []
        headerBody = []

        headerTitle.append(['Ref. Cliente', 'N Orden Despacho', 'Jurisdiccion'])
        headerJurisdiccion.append([dispatch.jurisdiction.code, dispatch.jurisdiction.name])
        headerBody.append([dispatch.reference, dispatch.order, Table(headerJurisdiccion, colWidths='*')])

        tabla = Table(headerTitle, colWidths='*')
        tabla2= Table(headerBody, colWidths='*')
        story.append(tabla)
        story.append(tabla2)
        story.append(Spacer(1, 12))

        story.append(
            Paragraph('<para alignment=center><font size=12><b>ANEXO N&ordm;5</b></font></para>',
                      styles['Normal']))
        story.append(Spacer(1, 12))

        story.append(
            Paragraph('<para alignment=center><font size=12><b>Declaración Jurada De conocimiento del Cliente</b></font></para>',
                      styles['Normal']))

        title = 'Persona Jurídica' if dispatch.declaration.document_type == 'ruc' else 'Persona Natural'
        story.append(
            Paragraph('<para alignment=center><font size=12><b>%s</b></font></para>' %title, styles['Normal']))
        story.append(Spacer(1, 24))

        self.addParagraph(story, styles, 'Por el presente documento, declaro bajo juramento, lo siguiente', 8)

        if dispatch.declaration.document_type == 'ruc':
            self.isBusiness(story, styles, dispatch)
        else:
            self.isPerson(story, styles, dispatch)

        doc.build(story)
# vim: et:ts=4:sw=4
