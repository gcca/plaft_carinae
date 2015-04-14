import testplaft
from plaft.domain.model import CustomsAgency, Datastore, Customer, \
                               Dispatch, Officer


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

        resp = self.testapp.post_json('/api/dispatch/create',
                                      dto)

        dispatch_test = Dispatch.find(order='666-666')

        self.assertIsNotNone(dispatch_test)
        self.assertEqual(dispatch_test.id, resp.json['id'])


# vim: et:ts=4:sw=4