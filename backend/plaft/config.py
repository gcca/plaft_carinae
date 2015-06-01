import sys
import os

sys.path.insert(
  0,
  os.path.join(
    os.path.join(
      os.path.dirname(
        os.path.abspath(__file__)),
      'infrastructure'),
    'support'))


DEBUG = os.environ.get('SERVER_SOFTWARE', '').startswith('Development')
if DEBUG:
    import logging
    logging.getLogger().setLevel(logging.DEBUG)


# vim: ts=4:sw=4:sts=4:et
