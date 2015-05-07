import testplaft
import plaft.application.dispatch
from plaft.domain.model import Dispatch, Customer, CustomsAgency, \
                               Datastore, Declaration


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

        dispatch_dto = {
            'order': '666-666',
            'declaration': {
                'customer': {
                    'document_number': '12312312',
                    'document_type': 'dni'
                }
            }
        }

        plaft.application.dispatch.create(dispatch_dto,
                                          customs_agency,
                                          customer)

        # test creation
        dispatch_test = Dispatch.find(order='666-666')
        self.assertIsNotNone(dispatch_test)

        # test pending
        datastore_test = customs_agency.datastore
        self.assertIn(dispatch_test.key, datastore_test.pending)

    def test_create_without_customer(self):
        # premises
        customs_agency = CustomsAgency()
        customs_agency.store()

        datastore = Datastore(customs_agency=customs_agency.key)
        datastore.store()

        # use case
        dispatch_dto = {
            'order': '666-666',
            'declaration': {
                'customer': {
                    'document_number': '12312312',
                    'document_type': 'dni'
                }
            }
        }

        plaft.application.dispatch.create(dispatch_dto, customs_agency)

        # test creation
        customer = Customer.find(document_number='12312312')
        self.assertIsNotNone(customer)

    def test_update(self):
        # premises

        customer = Customer(document_number='12312312',document_type='dni')
        customer.store()

        declaration = Declaration()
        declaration.customer = customer
        declaration.store()

        dispatch2 = Dispatch(order='456-456')
        dispatch2.declaration = declaration.key
        dispatch2.store()

        # use case
        dispatch_dto = {
            'order': '456-456',
            'declaration': {
                'customer': {
                    'document_number': '12312312',
                    'document_type': 'dni'
                },
            },
        }

        dispatch1 = plaft.application.dispatch.update(dispatch2, dispatch_dto)
        d_dto = dispatch1.dict

        customer = Customer.find(document_number='12312312')
        self.assertEqual(customer.key, dispatch1.customer)

    def test_numerate(self):
        # premises
        dispatch = Dispatch(order='123-123')
        dispatch.store()
        # use case
        plaft.application.dispatch.numerate(dispatch, dam='201561-12')

        # test
        dispatch_test = Dispatch.find(order='123-123')
        self.assertEqual(dispatch_test.dam, '201561-12')

        dispatch.delete()

    def test_pending_and_accepting(self):
        # premises
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

        # use case
        dispatch = plaft.application.dispatch
        dispatches = dispatch.pending_and_accepting(customs_agency)

        # test
        self.assertDictEqual({
            'pending': [dispatch1, dispatch2],
            'accepting': [dispatch3]
        }, dispatches)

        dispatch1.delete()
        dispatch2.delete()
        customs_agency.delete()

    def test_register(self):
        # premises
        dispatch = Dispatch(order='123-123')
        dispatch.store()

        country_source = 'PERU'
        country_target = 'CHILE'

        # use case
        plaft.application.dispatch.register(dispatch,
                                            country_source,
                                            country_target)

        # test
        dispatch_test = Dispatch.find(order='123-123')

        self.assertEqual(dispatch_test.country_source, country_source)
        self.assertEqual(dispatch_test.country_target, country_target)

        dispatch.delete()

    def test_register2(self):
        dispatch = Dispatch(order='111')
        dispatch.store()

        # use case
        country_source = 'Peru'
        country_target = 'Colombia'

        plaft.application.dispatch.register(dispatch,
                                            country_source,
                                            country_target)

        # test
        dispatch_test = Dispatch.find(order='111')
        self.assertEqual(dispatch_test.country_source, country_source)
        self.assertEqual(dispatch_test.country_target, country_target)

        dispatch.delete()

    # def test_no_unique_order(self):
    #     customs_agency = CustomsAgency()
    #     customs_agency.store()

    #     datastore = Datastore(customs_agency=customs_agency.key)
    #     datastore.store()

    #     # use case
    #     dispatch_dto = {
    #         'order': '666-666',
    #         'declaration': {
    #             'customer': {
    #                 'document_number': '12312312',
    #                 'document_type': 'dni'
    #             }
    #         }
    #     }

    #     plaft.application.dispatch.create(dispatch_dto, customs_agency)
    #     plaft.application.dispatch.create(dispatch_dto, customs_agency)


# vim: et:ts=4:sw=4
