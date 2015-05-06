# pre-store

from plaft.domain.model import Dispatch


class UniqueSpecification(object):

    error = AttributeError('No order unique')

    def is_satisfied_by(self, payload):
        return Dispatch.find(order=payload['order']) is None


# vim: et:ts=4:sw=4
