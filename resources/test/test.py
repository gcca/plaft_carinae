import sys
import unittest2


def main(sdk_path, test_path):
    sys.path.insert(0, sdk_path)
    import dev_appserver
    dev_appserver.fix_sys_path()
    sys.path.insert(0, '../../backend')
    suite = unittest2.loader.TestLoader().discover(test_path)
    unittest2.TextTestRunner(verbosity=2).run(suite)


def gprint(fmt):
    print('\n\033[32m%s\033[0m\n' % ('='*70))
    from pprint import pprint
    pprint(fmt)
    print('\n\033[32m%s\033[0m\n' % ('='*70))


if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])


# vim: et:ts=4:sw=4
