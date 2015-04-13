import testplaft
import plaft.application.dispatch
from plaft.domain.model import Dispatch, Customer, CustomsAgency, Datastore


class ApplicationDispatchTest(testplaft.TestCase):

    def test_create_with_customer(self):
        # premises
        customs_agency = CustomsAgency()
        customs_agency.store()

        datastore = Datastore(customs_agency=customs_agency.key)
        datastore.store()

        # use case
        customer = Customer()
        customer.store()

        dispatch = Dispatch(order='666-666')

        plaft.application.dispatch.create(dispatch,
                                          customer,
                                          customs_agency)

        # test creation
        dispatch_test = Dispatch.find(order='666-666')
        self.assertIsNotNone(dispatch_test)

        # test pending
        datastore_test = customs_agency.datastore
        self.assertIn(dispatch_test.key, datastore_test.pending)

        customs_agency.delete()
        datastore.delete()
        customer.delete()
        dispatch.delete()


# vim: et:ts=4:sw=4
