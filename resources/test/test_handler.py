import testplaft

from plaft.domain.model import Customer


class HandlerTest(testplaft.TestCase):

    def setUp(self):
        self.bed_activate()
        self.app_initialize()

    def test_query_no_match(self):
        uri = '/api/customer?document_number=!@#$%^&*()_+'
        # response = self.testapp.get(uri, status=404)
        # self.assertEqual(response.status_int, 404)
        self.testapp.get(uri, status=404)

    def test_create_single(self):
        customer_request = Customer(name='abc', document_number='123')
        response = self.testapp.post_json('/api/customer',
                                          customer_request.dict)

        customer_response = Customer.find(response.json['id'])

        self.assertEqual(customer_request.name,
                         customer_response.name)

        self.assertEqual(customer_request.document_number,
                         customer_response.document_number)

    def test_create_batch(self):

        customers_request = [Customer(name='abc_'+i,
                                      document_number='123_'+i).dict
                             for i in (str(n) for n in range(1, 11))]


        response = self.testapp.post_json('/api/customer',
                                          customers_request)

        customers_response = [Customer.find(id).dict for id in response.json]

        filter_request = [c['name'] + c['document_number']
                          for c in customers_request]
        filter_response = [c['name'] + c['document_number']
                           for c in customers_response]

        self.assertListEqual(filter_request, filter_response)

    def test_update_single(self):
        customer = Customer(name='Nina Sharp')
        customer.store()

        uri = '/api/customer/' + str(customer.id)
        dto = {
            'document_number': '789',
            'document_type': 'dni'
        }
        self.testapp.put_json(uri, dto)

        test_customer = Customer.find(customer.id)
        dto['name'] = 'Nina Sharp'

        self.assertEqual(dto['document_number'],
                         test_customer.document_number)
        self.assertEqual(dto['document_type'],
                         test_customer.document_type)

    def test_update_single2(self):
        customer = Customer(name='Nina Sharp')
        customer.store()

        customer = list(Customer.all())[0]

        uri = '/api/customer/' + str(customer.id)
        dto = {
            'document_number': '789',
            'document_type': 'dni'
        }
        self.testapp.put_json(uri, dto)

        test_customer = Customer.find(customer.id)

        self.assertEqual(test_customer.document_number, '789')
        self.assertEqual(test_customer.document_type, 'dni')

    def test_delete_single(self):
        customer = Customer(name='Nina Sharp')
        customer.store()

        customer = list(Customer.all())[0]

        uri = '/api/customer/' + str(customer.id)
        response = self.testapp.delete(uri)

        query = Customer.find(document_number=customer.document_number)

        self.assertIsNone(query)


# vim: et:ts=4:sw=4
