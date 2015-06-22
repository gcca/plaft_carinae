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

    def template(self, agency='', username='', password='',
                 msg='', mode='create'):

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
                               value='s'>
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
            'msg': msg,
            'agencies': agencies
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
                officer.populate(username=username,
                                 password=password)
                officer.store()
                self.write(self.template())
            else:
                return

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


# REST Handlers

class Operation(RESTful):
    """Operation RESTful."""


class Datastore(RESTful):
    """Datastore RESTful."""


# vim: et:ts=4:sw=4
