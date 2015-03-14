from unittest2 import TestCase
from google.appengine.ext import ndb
from google.appengine.ext import testbed

import webtest
import test

from plaft.domain.model import Customer
from plaft.application.util.sample_data_generator import create_customers

from webapp.main import app


class HandlerTest(TestCase):

    def setUp(self):
        self.testbed = testbed.Testbed()
        self.testbed.activate()
        self.testbed.init_datastore_v3_stub()
        self.testbed.init_memcache_stub()
        create_customers()

        self.testapp = webtest.TestApp(app)


    def tearDown(self):
        self.testbed.deactivate()

    def test_create_single(self):
        customer_request = Customer(name='abc', document_number='123')
        response = self.testapp.post_json('/api/customer',
                                          customer_request.dict)

        customer_response = Customer.find(response.json['id'])

        self.assertDictEqual(customer_request.dict,
                             customer_response.dict)


    def test_create_batch(self):

        customers_request = [Customer(name='abc_'+i,
                                      document_number='123_'+i).dict
                             for i in map(str, range(1, 11))]


        response = self.testapp.post_json('/api/customer',
                                           customers_request)

        customers_response = [Customer.find(id).dict for id in response.json]

        self.assertListEqual(customers_request, customers_response)


# vim: et:ts=4:sw=4
