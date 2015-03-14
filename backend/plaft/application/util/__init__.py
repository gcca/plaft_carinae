"""
.. module:: plaft.application.util
   :synopsis: Various utilities.

.. moduleauthor:: Gonzales Castillo, Cristhian A. <cristhian.gz@aol.com>


"""

import abc
import json


class JSONEncoder(json.JSONEncoder):
    """JSON encoder base.

    Need to override ``_default`` method.

    """

    __metaclass__ = abc.ABCMeta

    def __init__(self, **kwargs):
        super(JSONEncoder, self).__init__(**kwargs)
        self.default = self._default

    @abc.abstractmethod
    def _default(self, o):
        """Implement this method in a subclass such that it returns
        a serializable object for ``o``, or calls the base implementation
        (to raise a ``TypeError``).

        For example, to support arbitrary iterators, you could
        implement default like this::

        >>> def default(self, o):
        ...     try:
        ...         iterable = iter(o)
        ...     except TypeError:
        ...         pass
        ...     else:
        ...         return list(iterable)
        ...     # Let the base class default method raise the TypeError
        ...     return JSONEncoder.default(self, o)

        """
        return JSONEncoder.default(self, o)

    @classmethod
    def dumps(cls, obj):
        """Serialize ``obj`` to a JSON formatted ``str``."""
        return unicode(json.dumps(obj,
                                  cls=cls,
                                  # separators=(',', ':'),
                                  sort_keys=True,
                                  indent=4,
                                  separators=(',', ': '),
                                  check_circular=False)).decode('utf-8')

    @classmethod
    def loads(cls, s):
        """Deserialize ``s`` (a ``str`` or ``unicode`` instance containing
        a JSON document) to a Python object."""
        return json.loads(s, 'utf-8')


# vim: et:ts=4:sw=4
