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


DEBUG = True


# vim: ts=4:sw=4:sts=4:et
