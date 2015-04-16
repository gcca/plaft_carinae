import testplaft
import plaft.application.operation
from plaft.domain.model import Dispatch, Business, CustomsAgency, Datastore


class ApplicationOperationTest(testplaft.TestCase):

    def test_accept_dispatch(self):
        customs_agency = CustomsAgency()
        customs_agency.store()

        datastore = Datastore(customs_agency=customs_agency.key)
        datastore.store()

        customer = Business()
        customer.store()

        dispatch = Dispatch(order='666-666', customer=customer.key)
        dispatch.store()

        operation = plaft.application.operation.accept(dispatch)

        self.assertIsNotNone(operation)



# vim: et:ts=4:sw=4
