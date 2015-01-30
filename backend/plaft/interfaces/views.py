# encoding: utf-8

"""
.. module:: plaft.interfaces.views
   :synopsis: Views.

.. moduleauthor:: Gonzales Castillo, Cristhian A. <cristhian.gz@aol.com>


"""

from plaft.interfaces import Handler, DirectToController
from plaft.domain.model import User, Stakeholder, Officer, Dispatch, \
                               Dispatch


class SignIn(DirectToController):
    """Welcome and sign in controller for users."""

    controller = 'signin'

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

    controller = 'dashboard'

    def _args(self):
        # TODO(...): Improve string for json builder pattern.
        builder = ['stakeholders:']
        stks = self.JSON.dumps([{'d': stk.slug, 'n': stk.id}
                               for stk in Stakeholder.all()])
        builder.append(stks)
        builder.append(',')

        if type(self.user) is Officer:
            builder.append('us:')
            builder.append(self.JSON.dumps(self.user.customs.employees))
            builder.append(',')

        builder.append('cu:')
        dto = self.user.dict
        # TODO: Add customs property to reference
        dto['customs'] = self.user.customs
        builder.append(self.JSON.dumps(dto))
        builder.append(',')

        builder.append('ds:')
        dispatches = Dispatch.all(customs=self.user.customs.key)
        builder.append(self.JSON.dumps(dispatches))

        return ''.join(builder)


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
            list.append(['    Nombre', s.name])
            if s.document:
                list.append(['    Documento', s.document.type])
                list.append(['    Número', s.document.number])
            list.append(['', ''])
        return list

    def addressList(self, caption, address):
        if address:
            chunkLength = 52
            return ([[caption], ['    ' + address[:chunkLength]]]
                    + [['    ' + address[i:i+chunkLength]]
                       for i in range(chunkLength, len(address), chunkLength)])
        else:
            return [[caption], ['    -']]

    def get(self, id):
#        try:
#            declaration = model.Declaration.by(int(id))
#            if not declaration:
#                self.status = self.rc.NOT_FOUND
#                return self.write('Not Found')
#        except ValueError as e:
#            self.status = self.rc.BAD_REQUEST
#            return self.write('Bad Request %s' % e)

#        customer = declaration.customer

        dispatch = Dispatch.find(int(id))
#        declaration = dispatch.declaration.get()
        customer = dispatch.customer.get()
        declaration = customer

        self.response.headers['Content-Type'] = 'application/pdf'
        doc = SimpleDocTemplate(self.response.out,
                                pagesize=letter,
                                rightMargin=72,
                                leftMargin=72,
                                topMargin=72,
                                bottomMargin=18)

        styles=getSampleStyleSheet()
        styles.add(ParagraphStyle(name='Justify', alignment=TA_JUSTIFY))

        story=[]


        story.append(
            Paragraph('&nbsp;' * 61 + '<font size=12><b>ANEXO N&ordm;5</b></font>',
                      styles['Normal']))
        story.append(Spacer(1, 12))
        story.append(
            Paragraph('&nbsp;' * 24 + '<font size=12><b>Declaración Jurada de Conocimiento del Cliente</b></font>',
                      styles['Normal']))
        story.append(Spacer(1, -10))


        # story.append(Paragraph('<para align=right><b>N&ordm; ' + declaration.tracking + '</b></para>', styles["Normal"]))
#        story.append(Paragraph('&nbsp;' * 132 + '<font><b>N&ordm; ' + declaration.tracking + '</b></font>', styles["Normal"]))
        story.append(Spacer(1, 12))

        title = 'Persona Jurídica' if customer.isbusiness else 'Persona Natural'
        story.append(
            Paragraph('&nbsp;' * 56 + '<font size=12><b>%s</b></font>' % title,
                      styles['Normal']))
        story.append(Spacer(1, 12))

        if customer.customer_type and 'Otros' != customer.customer_type:
            mull = 50 if 'Importador frecuente' == customer.customer_type else 52
            story.append(
                Paragraph('&nbsp;' * mull + '<font size=12><b>%s</b></font>'
                          % customer.customer_type,
                          styles['Normal']))
            story.append(Spacer(1, 12))

        story.append(Spacer(1, 24))

        ptext = '<font size=10>%s</font>' % 'Por el presente documento, declaro bajo juramento, lo siguiente:'
        story.append(Paragraph(ptext, styles["Normal"]))
        story.append(Spacer(1, 10))

        # (-o-) Refactor: use default value
        data = ([
            ['a) Nombres y apellidos:'],
            ['    ' + customer.name],

            ['\nb) Tipo y número del documento de identidad:'],
            ['    ' + customer.document.type
             + '    ' + customer.document.number],

            ['\nc) Registro Único de Contribuyente (RUC):'],
            [('    ' + customer.business) if customer.business else '    -'],

            ['\nd) Fecha y lugar de nacimiento:'],
            [('    ' + customer.birthday) if customer.birthday else '    -'],

            ['\ne) Nacionalidad:'],
            [('    ' + customer.nationality) if customer.nationality else '    -']]

            + self.addressList(
                '\nf) Domilicio declarado (lugar de residencia):',
                customer.address)
                + self.addressList('\ng) Domicilio fiscal:', customer.fiscal)
            + [

            ['\nh) Número de teléfono (fijo y celular):'],
            ['    Fijo: ' + (customer.phone if customer.phone else '    -')],
            ['    Celular: ' + (customer.mobile if customer.mobile else '    -')],

            ['\ni) Correo electrónico:'],
                [('    ' + customer.email) if customer.email else '    -'],

            ['\nj) Profesión u ocupación:'],
                [('    ' + customer.activity) if customer.email else '    -'],


            ['\nk) Estado civil:'],
                [('    ' + customer.status) if customer.status else '    -'],

            ['    1. Nombre del cónyuge:'],
                [('        ' + customer.marital) if customer.marital else '        -'],
            ['    2. Conviviente:'],
                [('        ' + customer.domestic) if customer.domestic else '        -'],

            ['\nl) Cargo o función pública que desempeña o que haya desempeñado en los últimos dos\n   (2) años,  en el Perú o en el extranjero,  indicando  el  nombre  del  organismo público\n   u organización internacional:'],
                [('    ' + customer.public) if customer.public else '    -'],

            ['\nm) El origen de los fondos, bienes u otros activos involucrados en dicha transacción:'],
                [('    ' + declaration.source) if declaration.source else '    -'],

            ['\nn)   ¿Es sujeto obligado informar a la UIF-Perú?'],
                ['         -' if customer.isobliged is None else ('    ' + customer.isobliged)],

            ['\n      ¿Tiene oficial de cumplimiento?'],
                ['         -' if customer.hasofficer is None else ('    ' + customer.hasofficer)],

            ['\no) Identificación del tercero, sea persona natural (nombres y apellidos) o persona jurídica\n    (razón o denominación social) por cuyo intermedio se realiza la operación:',  ''] ,
                [('    ' + declaration.third) if declaration.third else '    -']]) \
        if customer.document.type == 'DNI' else ([
            ['a) Denominación o razón social:'],
                ['    ' + customer.name],

            ['\nb) Registro Único de Contribuyente (RUC):'],
                ['    ' + customer.document.number],

            ['\nc) Objeto social y actividad económica principal (comercial, industrial, construcción,\n    transporte, etc.):'],
                ['    Objeto social: ' + customer.social_object if customer.social_object else '    -'],

                [u'    Actividad económica: ' + customer.activity if customer.activity else '    -'],

            ['\nd) Identificación de los accionistas, socios, asociados, que tengan un porcentaje igual\n   o mayor al 5% de las acciones o participaciones de la persona jurídica:', '']]

            + self.shareholdersList(customer.shareholders) + [

            ['e) Identificación del representate legal o de quien comparece con facultades\n    de representación y/o disposición de la persona jurídica:'],
                ['    ' + customer.salesman if customer.salesman else '-']]

            + self.addressList('\nf) Domilicio:', customer.address if customer.address else '-')

            + self.addressList('\ng) Domicilio fiscal:', customer.fiscal_address if customer.fiscal_address else '-')

            + [
            ['\nh) Teléfonos fijos de la oficina  y/o  de  la  persona de contacto  incluyendo el código\n    de la ciudad, sea que se trate del local principal, agencia, sucursal u otros locales\n    donde desarrollan las actividades propias al giro de su negocio:'],
                [u'        Teléfono: ' + customer.phone if customer.phone else '-'],
                [u'        Contacto: ' + customer.contact if customer.contact else '-'],

#            ['\ni) El origen de los fondos, bienes y otros activos involucrados en dicha transacción:'],
#                ['    ' + declaration.money_source if declaration.money_source else '-'],

            ['\nj) ¿Es sujeto obligado informar a la UIF-Perú?'],
                ['        ' + ('-' if customer.is_obliged is None else customer.is_obliged)],

            ['    ¿Tiene oficial de cumplimiento?'],
                ['        ' + ('-' if customer.has_officer is None else customer.has_officer)]
            ]

            + ([
                ['\nk) Identificación del tercero,  sea  persona  natural (nombres  y  apellidos) o persona\n    jurídica (razón o denominación social) por cuyo intermedio se realiza la operación:', ''],
#                ['    ' + (declaration.third if declaration.third else '-')]
            ])
            )

        table = Table(data, [2.2*inch, 3*inch]) #, 10*[.35*inch])
        story.append(table)
        story.append(Spacer(1, 24))

        ptext = '<font size=10>Afirmo y ratifico todo lo manifestado en la presente declaración jurada, en señal de lo cual</font>'
        story.append(Paragraph(ptext, styles["Justify"]))
        story.append(Spacer(1, 1))

        story.append(Paragraph('<font size=10>la firmo, en la fecha que se indica:</font>', styles["Justify"]))
        story.append(Spacer(1, 69))



        import datetime
        ztime = datetime.datetime.utcnow() #declaration.created.utcnow() - timedelta(hours=5)
        bgdate = ztime.strftime('%d / %m / %Y')
        bgtime = ztime.strftime('%H:%M')

        data = [['____________________' , 'Fecha :    ' + bgdate],
                ['               Firma', 'Hora   :    ' +bgtime]]
        table = Table(data, [3*inch, 2.1*inch], 2*[.2*inch])
        story.append(table)
        doc.build(story)


# vim: et:ts=4:sw=4
