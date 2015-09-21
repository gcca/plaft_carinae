# encoding: utf-8
"""
.. module:: plaft.interfaces.admin
   :synopsis: Admin view and handlers.

.. moduleauthor:: Gonzales Castillo, Cristhian A. <gcca@gcca.tk>


"""

from plaft.interfaces import Handler, DirectToController, RESTful
from plaft.domain import model
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import (SimpleDocTemplate, Paragraph,
                                Table, TableStyle)
from reportlab.lib.units import inch, mm
from reportlab.lib.enums import TA_JUSTIFY, TA_CENTER



__all__ = ['views', 'handlers']

UNIDADES = (
    '',
    'UN0 ',
    'DOS ',
    'TRES ',
    'CUATRO ',
    'CINCO ',
    'SEIS ',
    'SIETE ',
    'OCHO ',
    'NUEVE ',
    'DIEZ ',
    'ONCE ',
    'DOCE ',
    'TRECE ',
    'CATORCE ',
    'QUINCE ',
    'DIECISEIS ',
    'DIECISIETE ',
    'DIECIOCHO ',
    'DIECINUEVE ',
    'VEINTE '
)

DECENAS = (
    'VENTI',
    'TREINTA ',
    'CUARENTA ',
    'CINCUENTA ',
    'SESENTA ',
    'SETENTA ',
    'OCHENTA ',
    'NOVENTA ',
    'CIEN '
)

CENTENAS = (
    'CIENTO ',
    'DOSCIENTOS ',
    'TRESCIENTOS ',
    'CUATROCIENTOS ',
    'QUINIENTOS ',
    'SEISCIENTOS ',
    'SETECIENTOS ',
    'OCHOCIENTOS ',
    'NOVECIENTOS '
)


MONEDAS = {
    'S/.': ' NUEVOS SOLES',
    'USD': ' DÓLARES'
}


def _convert_number(n):
    output = []
    if(n == '100'):
        output.append('CIEN ')
    elif(n[0] != '0'):
        output.append(CENTENAS[int(n[0]) - 1])

    k = int(n[1:])
    if(k <= 20):
        output.append(UNIDADES[k])
    else:
        if((k > 30) & (n[2] != '0')):
            output.append('%sy %s' % (DECENAS[int(n[1]) - 2],
                                      UNIDADES[int(n[2])]))
        else:
            output.append('%s%s' % (DECENAS[int(n[1]) - 2],
                                    UNIDADES[int(n[2])]))

    return ''.join(output)


def number_letter(number, billing_type):

    converted = []

    int_number = int(number)
    decimal = int(round((number - int_number)*100))
    number_str = str(int_number).zfill(6)
    miles = number_str[:3]
    cientos = number_str[3:]

    if(number_str):
        if(miles == '001'):
            converted.append('MIL ')
        elif(miles != '000'):
            converted.append('%s%s' % (_convert_number(miles),
                                       'MIL '))
        else:
            converted.append('')

        if(cientos == '001'):
            converted.append('UN ')
        elif(int(cientos) > 0):
            converted.append(_convert_number(cientos))

    # Se agrega el decimal
    converted.append('con %s/100' % str(decimal))

    # Se agrega la moneda
    converted.append(MONEDAS[billing_type])

    return (''.join(converted)).upper().strip()


# views

class AdminSite(DirectToController):

    controller = 'admin'

    _user_model = model.Admin

    def _args(self):
        self.add_arg('user', self.user)
        self.add_arg('customs',
                     {c.customs['name']:c.customs for c in model.CustomsAgency.all()})


class Admin(DirectToController):
    """Welcome and sign in controller for users."""

    def post(self):
        """Login user."""

        username = self.request.get('username')
        password = self.request.get('password')

        user = model.Admin.authenticate(username, password)

        if user:
            self.login(user)
            print self.user
            self.redirect('/admin/site')
        else:
            self.write_template('e:-1')


class views(object):
    Admin = Admin
    AdminSite = AdminSite


# handlers

class CustomsAgency(Handler):

    _user_model = model.Admin

    def get(self):
        users = [c.customs for c in model.CustomsAgency.all()]
        self.render_json(users)

    def post(self):
        payload = self.query
        officer = payload['officer']
        username = officer['username']
        password = ('' if not officer['password']
                       else officer['password'])

        del payload['officer']

        customs_agency = model.CustomsAgency.new(payload)
        customs_agency.store()

        alerts_key = [a.key for a in model.Alert.query().fetch()]
        from plaft.application.util.data_generator import permissions
        permission = model.Permissions(modules=permissions.officer,
                                       alerts_key=alerts_key)
        permission.store()

        datastore = model.Datastore(customs_agency_key=customs_agency.key)
        datastore.store()

        officer = model.Officer(username=username,
                                password=password,
                                name=officer['name'],
                                customs_agency_key=customs_agency.key,
                                permissions_key=permission.key)
        officer.store()

        customs_agency.officer_key = officer.key
        customs_agency.store()
        self.render_json({'id': customs_agency.id})

    def put(self, id):
        payload = self.query
        officer_dto = payload['officer']

        del payload['officer']

        customs_agency = model.CustomsAgency.find(int(id))
        customs_agency << payload
        customs_agency.store()

        officer = customs_agency.officer
        officer << officer_dto
        officer.store()

        self.write_json('{}')

    def delete(self, id):
        customs_agency = model.CustomsAgency.find(int(id))
        customs_agency.delete()

class Billing(Handler):
    """."""

    _user_model = model.Admin

    def get(self, id):

        self.response.headers['Content-Type'] = 'application/pdf'
        bil = model.Bill.find(int(id))
        customs = bil.customs_agency

        def money_format(money):
            return '%s %s' %(bil.billing_type, format(money, '.2f'))

        def addDate(canvas, doc):
            canvas.drawString(3.25*inch, 6.15*inch,
                              bil.date_bill.strftime('%d/%m/%Y')) # fecha factura
            canvas.drawString(4.3*inch, 6.15*inch, bil.purchase) # ord/compra
            canvas.drawString(5.2*inch, 6.15*inch, bil.seller) # vendedor
            canvas.drawString(3.5*inch, 5.72*inch, bil.payment) # condiciones
            canvas.drawString(4.7*inch, 5.72*inch, bil.guide) # guia


        def addTotal(canvas, doc):
            canvas.drawString(0.5*inch, 1.84*inch,
                              money_format(bil.total)) # valor venta
            canvas.drawString(1.5*inch, 1.84*inch, 'Page #01') # descuento
            canvas.drawString(2.4*inch, 1.84*inch, 'Page #01') # flete
            canvas.drawString(3.4*inch, 1.84*inch,
                              money_format(bil.igv)) # igv
            canvas.drawString(4.5*inch, 1.84*inch,
                              money_format(bil.to_pay)) # pagar

            canvas.drawString(0.7*inch, 1.55*inch,
                              number_letter(bil.to_pay,
                                            bil.billing_type)) # num=> let


        def addTemplate(canvas, doc):

            canvas.setFont('Courier', 7.5)
            addDate(canvas, doc)
            addTotal(canvas, doc)

        styles = getSampleStyleSheet()

        # CUSTOMS NAME STYLE
        styles.add(ParagraphStyle(name='name-style', fontSize=7.5,
                                  leftIndent=40,
                                  spaceBefore=9, spaceAfter=9,
                                  fontName='Courier-Bold',))
        # CUSTOMS ADDRESS STYLE
        styles.add(ParagraphStyle(name='address-style', fontSize=7.5,
                                  leftIndent=40,
                                  spaceBefore=5.5, spaceAfter=5.5,
                                  fontName='Courier',leading=6))
        # CUSTOMS RUC
        styles.add(ParagraphStyle(name='ruc-style', fontSize=7.5,
                                  leftIndent=40,
                                  spaceBefore=9, spaceAfter=25,
                                  fontName='Courier',))

        doc = SimpleDocTemplate(self.response.out,
                                pagesize=(425, 566),
                                rightMargin=10,
                                leftMargin=10,
                                topMargin=106.29,
                                bottomMargin=55)



        story = []
        story.append(Paragraph(customs.name, styles['name-style']))
        story.append(Paragraph('%s <br/> &bnsp;' % customs.address,
                     styles['address-style']))
        story.append(Paragraph(customs.document_number, styles['ruc-style']))

        data = []
        for detail in bil.details:
            data.append([str(detail.quantity), detail.unit, detail.description,
                         money_format(detail.price),
                         money_format(detail.amount)])

        s = styles["BodyText"]
        s.wordWrap = 'LTR'
        s.alignment = TA_CENTER
        s.fontSize = 6.2
        s.fontName = 'Courier'
        data2 = [[Paragraph(cell, s) for cell in row] for row in data]
        t = Table(data2, colWidths=(0.38*inch, 0.33*inch, 3.06*inch,
                                  0.74*inch, 0.8*inch))
        story.append(t)

        doc.build(story, onFirstPage=addTemplate)


    def post(self):
        payload = self.query
        customs_dto = payload['customs']
        del payload['customs']
        customs = model.CustomsAgency.find(int(customs_dto['id']))

        billing = (model.Bill.find(int(payload['id']))
                   if payload['id'] else model.Bill())

        billing << payload
        billing.customs_agency_key = customs.key
        billing.store()
        self.render_json({'id': billing.id})


class handlers(object):
    Billing = Billing
    CustomsAgency = CustomsAgency

# vim: et:ts=4:sw=4
