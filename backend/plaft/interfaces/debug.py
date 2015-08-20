# encoding: utf-8

"""
.. module:: plaft.interfaces.debug
   :synopsis: Views.

"""

from plaft.interfaces import Handler, RESTful
from plaft.domain import model


class IsDebug(Handler):

    def get(self):
        import plaft.config
        self.write(plaft.config.DEBUG)


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


class NewUsers(Handler):

    @staticmethod
    def to_li(agency):
        officer = agency.officer
        return (
            """
            <div style='width:100%%;display:table-row-group;margin:4px 0'>
                <form method='post' action='/new-user/%(agency_id)s?opt=edit'
                        style='width:70%%;display:table-cell'>
                    <label style='width:30%%;min-width:250px;
                        margin:0 5px'>%(agency_name)s</label>
                    <input
                        type='hidden'
                        value='%(agency_name)s'
                        name='agency'/>
                    <input style='width:40%%;margin:0 5px'
                        type='text'
                        value='%(office_name)s'
                        name='username'/>
                    <input style='width:20%%;margin:0 5px'
                        type='text'
                        name='password'/>
                    <input type='submit' value='GRD'>
                </form>

                <form method='post' action='/new-user/%(agency_id)s?opt=delete'
                    style='display:table-cell'>
                    <input type='submit' value='X'>
                </form>
            </div>
            <br/>""") % {
            'agency_name': agency.name,
            'office_name': officer.username,
            'agency_id': agency.id
        }

    def template(self, agency='', username='', password='', mode='create'):

        agencies = ''.join(self.to_li(a) for a in model.CustomsAgency.all())

        return u"""
            <html>
                <body>
                    <h4>Nuevo Registro</h4>
                    <form method='post'>
                        <table>
                         <tr>
                          <td>
                            <label>Nombre de la agencia: </label>
                          </td>
                          <td>
                            <label>Correo del oficial de cumplimiento: </label>
                          </td>
                          <td>
                            <label>Contraseña: </label>
                          </td>
                         </tr>
                         <tr>
                          <td>
                            <input type='text'
                               name='agency'
                               value='%(agency)s'>
                          </td>
                          <td>
                            <input type='text'
                                   name='username'
                                   value='%(username)s'>
                          </td>
                          <td>
                            <input type='text'
                               name='password'
                               value='%(password)s'>
                          </td>
                         </tr>

                        </table>
                        <br/>
                        <input type='submit' value='Registrar'>
                        <a href=''>Nuevo</a>
                        <input type='hidden'
                               name='mode'
                               value='%(mode)s'>
                    </form>
                </body>
                <hr>
                <div style='width:900px;display:table'>
                  %(agencies)s
                </div>
            </html>
        """ % {
            'agency': agency,
            'username': username,
            'password': password,
            'agencies': agencies,
            'mode': mode
        }

    def get(self):
        self.write(self.template())

    def post(self, customs_id=None):

        agency_name = unicode(self.request.get('agency'))
        username = unicode(self.request.get('username'))
        password = unicode(self.request.get('password'))
        operation = unicode(self.request.get('opt'))

        if customs_id:
            if operation == 'edit':
                customs_agency = model.CustomsAgency.find(int(customs_id))

                customs_agency.name = agency_name
                customs_agency.store()

                officer = customs_agency.officer
                if not officer.permissions_key:

                    permission = model.Permissions(modules=['WEL-HASH',
                                                            'NUM-HASH',
                                                            'ANEXO2-HASH',
                                                            'INCOME-HASH',
                                                            'OPLIST-HASH'],
                                                   signals=[])
                    permission.store()
                    officer.permissions_key = permission.key

                officer.populate(username=username,
                                 password=password)
                officer.store()
                self.write(self.template())
            else:
                customs_agency = model.CustomsAgency.find(int(customs_id))
                customs_agency.delete()
                self.write(self.template())

        else:
            customs_agency = model.CustomsAgency(name=agency_name)
            customs_agency.store()

            permission = model.Permissions(modules=['WEL-HASH',
                                                    'NUM-HASH',
                                                    'ANEXO2-HASH',
                                                    'INCOME-HASH',
                                                    'OPLIST-HASH'],
                                           signals=[])
            permission.store()

            datastore = model.Datastore(customs_agency_key=customs_agency.key)
            datastore.store()

            officer = model.Officer(username=username,
                                    password=password,
                                    customs_agency_key=customs_agency.key,
                                    permissions_key=permission.key)
            officer.store()

            customs_agency.officer_key = officer.key
            customs_agency.store()

            self.write(self.template(agency_name,
                                     username,
                                     password))


class UsersFromFile(Handler):

    def get(self):
        self.write("""
          <html>
            <body>
              <form method='post'
                    enctype="multipart/form-data"
                    accept-charset='utf-8'>
                <input type='file' name='users_file'>
                <input type='submit'>
              </form>
            </body>
          </html>
        """)

    def post(self):
        users_file = (self.request.get('users_file')
                      .decode('cp1252', 'replace')
                      .encode('utf-8'))

        user_rows = (l.split(',') for l in users_file.split('\n') if l)

        for agency_name, username, password in user_rows:
            agency = model.CustomsAgency(name=agency_name)
            agency.store()

            permission = model.Permissions(modules=['WEL-HASH',
                                                    'NUM-HASH',
                                                    'ANEXO2-HASH',
                                                    'INCOME-HASH',
                                                    'OPLIST-HASH'],
                                           signals=[])
            permission.store()

            datastore = model.Datastore(customs_agency_key=agency.key)
            datastore.store()

            officer = model.Officer(customs_agency_key=agency.key,
                                    permissions_key=permission.key)
            officer.populate(username=username, password=password)

            agency.officer_key = officer.store()
            agency.store()

        self.write('OK')


class DataToRestore(Handler):

    @staticmethod
    def format_dispatches(dispatches):
        dispatches = [dispatch.to_dto() for dispatch in dispatches]

        def clean(dct):
            if 'id' in dct:
                del dct['id']

            if 'class_' in dct and isinstance(dct['class_'], list):
                dct['class_'] = dct['class_'][-1]

            for _, value in dct.items():
                if isinstance(value, dict):
                    clean(value)

                if isinstance(value, list):
                    for item in value:
                        if isinstance(item, dict):
                            clean(item)

            return dct

        def clear(dct):
            if dct['operation']:
                dct['operation'] = dct['operation']['id']
            del dct['declaration']
            return dct

        dispatches = [clean(clear(dispatch)) for dispatch in dispatches]
        return dispatches

    @staticmethod
    def format_users(users):
        formated_users = []
        for user in users:
            customs_agency_name = user.customs_agency.name
            user.customs_agency_key = None
            formated_user = user.to_dto()
            formated_user['customs_agency'] = customs_agency_name
            formated_user['class_'] = formated_user['class_'][-1]
            formated_user['password'] = user.password
            del formated_user['id']
            del formated_user['permissions']['id']
            formated_users.append(formated_user)
        return formated_users

    def get(self):
        # from base64 import b64encode
        def b64encode(x):
            return x
        data = b64encode(self.JSON.dumps({
            'dispatches': self.format_dispatches(model.Dispatch.all()),
            'users': self.format_users(model.User.all())
        }))

        self.write_json(data)  # , 'data-plaft')


class RestoreData(Handler):

    def get(self):
        self.write('<html>'
                   '<body>'
                   '<form method="post" '
                   'enctype="multipart/form-data" '
                   'accept-charset="utf-8">'
                   '<input type="file" name="data">'
                   '<br>'
                   '<input type="submit">'
                   '</form>'
                   '</body>'
                   '</html>')

    def post(self):
        # from base64 import b64decode
        def b64decode(x):
            return x
        data = self.JSON.loads(b64decode(self.request.get('data')
                                         .decode('cp1252', 'replace')
                                         .encode('utf-8')))

        self.create_users(data['users'])
        self.create_dispatches(data['dispatches'])

        self.write('OK')

    def create_users(self, dcts):
        for dct in dcts:
            cls = (model.Officer
                   if dct['class_'] == 'Officer'
                   else (model.Employee
                         if dct['class_'] == 'Employee'
                         else None))

            if cls is None:
                raise AttributeError('Bad User class name.')

            ca_name = dct['customs_agency']
            per_dct = dct['permissions']

            del dct['class_']
            del dct['customs_agency']
            del dct['permissions']

            user = cls(**dct)
            user.password = dct['password']
            user.store()

            customs_agency = self.get_customs_agency(ca_name)
            user.customs_agency_key = customs_agency.key
            user.store()
            # TODO: USer previous conditional to eval Officer-Employee user.
            if cls is model.Officer:
                customs_agency.officer_key = user.key
            elif cls is model.Employee:
                customs_agency.employees_key.append(user.key)
            else:
                raise TypeError('Bad class type.')
            customs_agency.store()

            permissions = model.Permissions.new(per_dct)
            user.permissions_key = permissions.store()
            user.store()

    def create_dispatches(self, dcts):
        # TODO: Remove this function.
        #       Implement right filter for computed properties.
        def clean(dct):
            if 'slug' in dct:
                del dct['slug']
            for key in dct:
                if isinstance(dct[key], dict):
                    clean(dct[key])

                if isinstance(dct[key], list):
                    for item in dct[key]:
                        if isinstance(item, dict):
                            clean(item)

        self.cache = {}
        for dct in dcts:
            customs_agency_dct = dct['customs_agency']
            customs_agency_name = customs_agency_dct['name']
            customs_agency = self.get_customs_agency(customs_agency_name,
                                                     customs_agency_dct)
            del dct['customs_agency']

            customer_dct = dct['customer']
            customer_document_number = customer_dct['document_number']
            customer = self.get_(model.Customer,
                                 document_number=customer_document_number)
            del dct['customer']

            # TODO: Remove this.
            if 'declaration' in dct:
                del dct['declaration']

            operation_key = self.get_operation_key(dct['operation'])
            del dct['operation']

            clean(dct)
            dispatch = model.Dispatch.new(dct)
            dispatch.customs_agency_key = customs_agency.key
            dispatch.customer_key = customer.key
            dispatch.store()

            if operation_key:
                dispatch.operation_key = operation_key
                dispatch.store()

    @staticmethod
    def get_operation_key(hsh):
        if hsh:
            model.Operation()

    @staticmethod
    def get_(model, dct=None, **kwargs):
        instance = model.find(**kwargs)
        if not instance:
            instance = model(**kwargs)
            if dct:
                instance << dct
            # Callbacks in a dict. E.g, datastore when customs agency.
            instance.store()
        return instance

    @staticmethod
    def get_customs_agency(name, dct=None):
        customs_agency = model.CustomsAgency.find(name=name)
        if not customs_agency:
            customs_agency = model.CustomsAgency(name=name)
            if dct:
                customs_agency << dct
            key = customs_agency.store()

            datastore = model.Datastore(customs_agency_key=key)
            datastore.store()

        return customs_agency


class SwitchUser(Handler):

    def get(self, user_id):
        user = model.User.find(int(user_id))
        self.login(user)
        self.redirect('/dashboard')


# REST Handlers

class Operation(RESTful):
    """Operation RESTful."""


class Datastore(RESTful):
    """Datastore RESTful."""


# vim: et:ts=4:sw=4
