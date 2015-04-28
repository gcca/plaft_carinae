import testplaft
import plaft.application.operation
from plaft.domain.model import Dispatch, Business, CustomsAgency, Datastore


class ApplicationOperationTest(testplaft.TestCase):

    def test_accept_dispatch(self):
        customs_agency = CustomsAgency()
        customs_agency.store()

        dispatch1 = Dispatch(order='123-123')
        dispatch1.customs_agency = customs_agency.key
        dispatch1.store()

        dispatch2 = Dispatch(order='345-345')
        dispatch2.customs_agency = customs_agency.key
        dispatch2.store()

        dispatch3 = Dispatch(order='456-456')
        dispatch3.customs_agency = customs_agency.key
        dispatch3.store()

        datastore = Datastore(customs_agency=customs_agency.key)
        datastore.pending = [dispatch1.key, dispatch2.key]
        datastore.accepting = [dispatch3.key]
        datastore.store()

        customer = Business()
        customer.store()

        operation = plaft.application.operation.accept(dispatch1)

        self.assertIsNotNone(operation)



# vim: et:ts=4:sw=4
