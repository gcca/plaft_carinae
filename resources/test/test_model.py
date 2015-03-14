from unittest2 import TestCase
from google.appengine.ext import ndb
from google.appengine.ext import testbed

from plaft.domain.model import Customer
from plaft.application.util.sample_data_generator import create_customers


class CustomerTest(TestCase):

    def setUp(self):
        self.testbed = testbed.Testbed()
        self.testbed.activate()
        self.testbed.init_datastore_v3_stub()
        self.testbed.init_memcache_stub()
        create_customers()

    def tearDown(self):
        self.testbed.deactivate()

    def test_create_single(self):
        customer = Customer(name='abc',
                            document_number='123456456')


# vim: et:ts=4:sw=4
