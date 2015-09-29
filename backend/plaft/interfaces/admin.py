# encoding: utf-8
"""
.. module:: plaft.interfaces.admin
   :synopsis: Admin view and handlers.

.. moduleauthor:: Gonzales Castillo, Cristhian A. <gcca@gcca.tk>


"""

from plaft.interfaces import (Handler, DirectToController,
                              RESTful, handler_method)
from plaft.domain import model
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import (SimpleDocTemplate, Paragraph,
                                Table, TableStyle)
from reportlab.lib.units import inch, mm
from reportlab.lib.pagesizes import letter, A4
from reportlab.lib.enums import TA_JUSTIFY, TA_CENTER
from reportlab.pdfgen import canvas



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

        if 'officer' in payload:
            officer = payload['officer']
            username = officer['username']
            password = (officer['password']
                        if 'password' in officer else '')

            del payload['officer']

            customs_agency = model.CustomsAgency.new(payload)
            customs_agency.store()

            alerts_key = [a.key for a in model.Alert.query().fetch()]
            from plaft.application.util.data_generator import permissions
            permission = model.Permissions(modules=permissions.officer,
                                           alerts_key=alerts_key)
            permission.store()

            officer = model.Officer(username=username,
                                    password=password,
                                    name=officer['name'],
                                    customs_agency_key=customs_agency.key,
                                    permissions_key=permission.key)
            officer.store()

            customs_agency.officer_key = officer.key
            customs_agency.store()
        else:

            customs_agency = model.CustomsAgency.new(payload)
            customs_agency.store()


        datastore = model.Datastore(customs_agency_key=customs_agency.key)
        datastore.store()
        self.render_json({'id': customs_agency.id})

    def put(self, id):
        payload = self.query
        officer_dto = payload['officer']
        if officer_dto:
            del payload['officer']

            customs_agency = model.CustomsAgency.find(int(id))
            customs_agency << payload
            customs_agency.store()

            if not customs_agency.officer_key:
                officer = model.Officer.new(officer_dto)
                officer.store()
                customs_agency.officer_key = officer.key

            officer = customs_agency.officer
            officer << officer_dto
            officer.store()
        else:
            customs_agency = model.CustomsAgency.find(int(id))
            customs_agency << payload
            customs_agency.store()

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

        def encode_str(string):
            f = (string).encode('utf-8').replace('&', '&amp;')
            return f

        styles = getSampleStyleSheet()

        styles.add(ParagraphStyle(name='name-style', fontSize=10,
                                  leftIndent=50,
                                  spaceBefore=9, spaceAfter=9,
                                  fontName='Helvetica-Bold'))
        # CUSTOMS NORMAL STYLE
        styles.add(ParagraphStyle(name='normal-style', fontSize=10,
                                  leftIndent=50,
                                  spaceBefore=5.5, spaceAfter=5.5,
                                  fontName='Helvetica',leading=10))
        # CUSTOMS DETRACCION STYLE
        styles.add(ParagraphStyle(name='detraccion-style', fontSize=9,
                                  leftIndent=50,
                                  spaceBefore=5.5, spaceAfter=5.5,
                                  fontName='Helvetica',leading=10))
        # CUSTOMS MONEY STYLE
        styles.add(ParagraphStyle(name='money-style', fontSize=10,
                                  leftIndent=50,
                                  spaceBefore=5.5, spaceAfter=5.5,
                                  fontName='Helvetica'))


        c = canvas.Canvas(self.response.out, pagesize=A4)

        # Descripcion de la agencia de aduana
        p = Paragraph(encode_str(customs.name), style=styles["name-style"])
        p.wrapOn(c, 200, 10)
        p.drawOn(c, 23, 680, mm)

        p = Paragraph(encode_str(customs.address),
                      style=styles["normal-style"])
        p.wrapOn(c, 240, 10)
        p.drawOn(c, 23, 657, mm)

        p = Paragraph(encode_str(customs.document_number),
                      style=styles["normal-style"])
        p.wrapOn(c, 20, 10)
        p.drawOn(c, 23, 638, mm)

        # Descripcion de la factura
        p = Paragraph(bil.date_bill.strftime('%d/%m/%Y'),
                      style=styles["name-style"])  # FECHA DE LA FACTURA
        p.wrapOn(c, 20, 10)
        p.drawOn(c, 270, 690, mm)

        p = Paragraph(encode_str(bil.purchase), style=styles["normal-style"])
        p.wrapOn(c, 150, 10)
        p.drawOn(c, 375, 690, mm)  # ORD/COMPRA

        p = Paragraph(encode_str(bil.seller), style=styles["name-style"])
        p.wrapOn(c, 170, 10)
        p.drawOn(c, 465, 687, mm) # VENDEDOR

        p = Paragraph(encode_str(bil.payment), style=styles["normal-style"])
        p.wrapOn(c, 150, 10)
        p.drawOn(c, 270, 649, mm) # CONDICIONES PAGO

        p = Paragraph(encode_str(bil.guide), style=styles["normal-style"])
        p.wrapOn(c, 150, 10)
        p.drawOn(c, 425, 649, mm) # GUIA

        # Detalle de la factura
        data = []
        for detail in bil.details:
            data.append([str(detail.quantity), detail.unit,
                         detail.description,
                         money_format(detail.price),
                         money_format(detail.amount)])

        s = styles['Normal']
        s.wordWrap = 'LTR'
        s.fontSize = 9
        s.fontName = 'Helvetica'
        data2 = [[Paragraph(encode_str(cell), s) for cell in row] for row in data]
        t = Table(data2, colWidths=(.45*inch, .6*inch, 4.3*inch,
                                  1*inch, 1.2*inch))
        t.wrapOn(c, 170, 4000)
        t.setStyle(TableStyle([
                ('VALIGN',(0, 0),(-1,-1),'TOP'),
                ]))
        t.drawOn(c, 25, 500, mm)

        if bil.is_service:
            #DETRACCION
            p = Paragraph('AFECTO A LA DETRACCION<br/>CTA  CTE. BANCO'
                          ' DE<br/>LA NACION Nº 00058000779',
                          style=styles["detraccion-style"])
            p.wrapOn(c, 450, 10)
            p.drawOn(c, 50, 250, mm)

        # Descripcion del total
        data = [[money_format(bil.total), 'S/. 0.00' , '  ',
                 money_format(bil.igv), money_format(bil.to_pay)]]
        s = styles['BodyText']
        s.wordWrap = 'LTR'
        s.alignment = TA_CENTER
        s.fontSize = 9
        s.fontName = 'Helvetica'
        data2 = [[Paragraph(encode_str(cell), s) for cell in row] for row in data]
        table = Table(data2, colWidths=(1.32*inch, 1.22*inch, 1.32*inch,
                                  1.52*inch, 1.82*inch))
        table.wrapOn(c, 800, 100)
        table.drawOn(c, 20, 180, mm)


        # Nombre del monto
        p = Paragraph(number_letter(bil.to_pay,
                                    bil.billing_type),
                      style=styles["money-style"])
        p.wrapOn(c, 450, 10)
        p.drawOn(c, 20, 155, mm)

        c.save()


    def post(self):
        payload = self.query
        customs_dto = payload['customs_agency']
        del payload['customs_agency']
        customs = model.CustomsAgency.find(int(customs_dto['id']))

        billing = (model.Bill.find(int(payload['id']))
                   if 'id' in payload else model.Bill())

        billing << payload
        billing.customs_agency_key = customs.key
        billing.store()
        self.render_json({'id': billing.id})

@handler_method
def list_billing(handler):
    handler.render_json(model.Bill.all())


class handlers(object):
    Billing = Billing
    CustomsAgency = CustomsAgency
    ListBilling = list_billing

# vim: et:ts=4:sw=4
