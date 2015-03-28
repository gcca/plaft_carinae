#!/usr/bin/python
import sys
import unittest2


class TestCase(unittest2.TestCase):

    def __init__(self, *args):
        super(TestCase, self).__init__(*args)
        self.testbed = None

    def bed_activate(self):
        from google.appengine.ext import testbed
        self.testbed = testbed.Testbed()
        self.testbed.activate()
        self.testbed.init_datastore_v3_stub()
        self.testbed.init_memcache_stub()

    def app_initialize(self):
        import webtest
        from webapp.main import app
        self.testapp = webtest.TestApp(app)

    def setUp(self):
        self.bed_activate()
        self.app_initialize()

    def tearDown(self):
        if self.testbed:
            self.testbed.deactivate()


def main(sdk_path, test_path):
    sys.path.insert(0, sdk_path)
    import dev_appserver
    dev_appserver.fix_sys_path()
    sys.path.insert(0, '../../backend')
    suite = unittest2.loader.TestLoader().discover(test_path)
    unittest2.TextTestRunner(verbosity=2).run(suite)


def gprint(fmt):
    print('\n\033[32m%s\033[0m\n' % ('='*70))
    print(fmt)
    print('\n\033[32m%s\033[0m\n' % ('='*70))


if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])


# vim: et:ts=4:sw=4
