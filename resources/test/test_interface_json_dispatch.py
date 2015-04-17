import testplaft
from plaft.domain.model import CustomsAgency, Datastore, Customer, \
                               Dispatch, Officer, Declaration

class InterfaceJSONDispatchTest(testplaft.TestCase):

    def setUp(self):
        super(InterfaceJSONDispatchTest, self).setUp()

        customs_agency = CustomsAgency()
        customs_agency.store()
        self.customs_agency = customs_agency

        datastore = Datastore(customs_agency=customs_agency.key)
        datastore.store()

        customer = Customer(document_type='ruc',
                            document_number='96385274136')
        customer.store()
        self.customer = customer

        officer = Officer(username='dipsy',
                          password='123',
                          customs_agency=customs_agency.key)
        officer.store()

        self.testapp.post('/', {
            'username': 'dipsy',
            'password': '123'
        })

    def test_create_with_customer(self):
        dto = {
            'order': '666-666',
            'declaration': {
                'customer': {
                    'name': 'Teletubbies'
                }
            },
            'customer': self.customer.id
        }

        resp = self.testapp.put_json('/api/dispatch/create', dto)

        dispatch_test = Dispatch.find(order='666-666')

        self.assertIsNotNone(dispatch_test)
        self.assertEqual(dispatch_test.id, resp.json['id'])
        self.assertEqual(self.customer.id, resp.json['customer'])

    def test_create_without_customer(self):
        dto = {
            'order': '666-666',
            'declaration': {
                'customer': {
                    'name': 'Teletubbies'
                }
            }
        }

        resp = self.testapp.put_json('/api/dispatch/create', dto)

        dispatch_test = Dispatch.find(order='666-666')

        self.assertIsNotNone(dispatch_test)
        self.assertIsNotNone(dispatch_test.customer)
        self.assertEqual(dispatch_test.id, resp.json['id'])

    def test_update_with_customer(self):
        dto = {
            'order': '666-666',
            'declaration': {
                'customer': {
                    'name': 'Teletubbies'
                }
            },
            'customer': self.customer.id
        }
        customer = Customer(name='Teletubbies')
        customer.store()

        declaration = Declaration(customer=customer)
        declaration.store()

        dispatch = Dispatch(order='666-666')
        dispatch.declaration = declaration.key
        dispatch.store()

        _url = "/api/dispatch/create/%d" % dispatch.id

        resp = self.testapp.put_json(_url, dto)

    def test_update_without_customer(self):
        dto = {
            'order': '666-666',
            'declaration': {
                'customer': {
                    'document_number': '12312312',
                    'document_type': 'dni'
                }
            }
        }
        customer = Customer(document_number='12312312')
        customer.store()

        declaration = Declaration()
        declaration.store()

        dispatch = Dispatch(order='666-666')
        dispatch.declaration = declaration.key
        dispatch.store()

        _url = "/api/dispatch/create/%d" % dispatch.id

        resp = self.testapp.put_json(_url, dto)

    def test_numerate(self):
        dto = {
            'dam': '1234512-12',
            'expire_date_RO': 'Vigencia de 5.',
            'uif_last_day': 'Ultimo Dia.',
            'ammount_soles': '123.12',
            'exchange_rate': '3.00'
        }

        dispatch = Dispatch(order='123-123')
        dispatch.store()

        _url = ("/api/dispatch/%s/numerate" % dispatch.id)

        resp = self.testapp.post_json(_url, dto)

     def test_pending_and_accepting(self):
        #creando despachos
        # TODO(gcca)
        pass


# vim: et:ts=4:sw=4
