#!/usr/bin/python2

"""Module for generating <plaft> build files.

Note that this is emphatically not a required piece of PLAFT; it's
just a helpful utility for build-file-generation systems that already
use auto-building."""

import sys
import os
import fnmatch
import argparse
import tempfile
import textwrap


def escape_path(word):
    """."""
    return word.replace('$ ', '$$ ').replace(' ', '$ ').replace(':', '$:')

class Writer(object):
    """."""

    def __init__(self, output, width=78):
        """."""
        self.output = output
        self.width = width

    def newline(self):
        """."""
        self.output.write('\n')

    def comment(self, text):
        """."""
        for line in textwrap.wrap(text, self.width - 2):
            self.output.write('# ' + line + '\n')

    def variable(self, key, value, indent=0):
        """."""
        if value is None:
            return
        if isinstance(value, list):
            value = ' '.join(s for s in value if s)  # Filter out empty str's.
        self._line('%s = %s' % (key, value), indent)

    def pool(self, name, depth):
        """Pool."""
        self._line('pool %s' % name)
        self.variable('depth', depth, indent=1)

    # pylint: disable=I0011, R0913
    def rule(self, name, command, description=None, depfile=None,
             generator=False, pool=None, restat=False, rspfile=None,
             rspfile_content=None, deps=None):
        """Rule."""
        self._line('rule %s' % name)
        self.variable('command', command, indent=1)
        if description:
            self.variable('description', description, indent=1)
        if depfile:
            self.variable('depfile', depfile, indent=1)
        if generator:
            self.variable('generator', '1', indent=1)
        if pool:
            self.variable('pool', pool, indent=1)
        if restat:
            self.variable('restat', '1', indent=1)
        if rspfile:
            self.variable('rspfile', rspfile, indent=1)
        if rspfile_content:
            self.variable('rspfile_content', rspfile_content, indent=1)
        if deps:
            self.variable('deps', deps, indent=1)

    # pylint: disable=I0011, R0913
    def build(self, outputs, rule, inputs=None, implicit=None,
              order_only=None, variables=None):
        """Build."""
        outputs = self._as_list(outputs)
        out_outputs = [escape_path(x) for x in outputs]
        all_inputs = [escape_path(x) for x in self._as_list(inputs)]

        if implicit:
            implicit = [escape_path(x) for x in self._as_list(implicit)]
            all_inputs.append('|')
            all_inputs.extend(implicit)
        if order_only:
            order_only = [escape_path(x) for x in self._as_list(order_only)]
            all_inputs.append('||')
            all_inputs.extend(order_only)

        self._line('build %s: %s' % (' '.join(out_outputs),
                                     ' '.join([rule] + all_inputs)))

        if variables:
            if isinstance(variables, dict):
                iterator = iter(variables.items())
            else:
                iterator = iter(variables)

            for key, val in iterator:
                self.variable(key, val, indent=1)

        return outputs

    def include(self, path):
        """Include."""
        self._line('include %s' % path)

    def subninja(self, path):
        """Subninja."""
        self._line('subninja %s' % path)

    def default(self, paths):
        """Default."""
        self._line('default %s' % ' '.join(self._as_list(paths)))

    @staticmethod
    def _count_dollars_before_index(s_list, i):
        """Returns the number of '$' characters right in front of s[i]."""
        dollar_count = 0
        dollar_index = i - 1
        while dollar_index > 0 and s_list[dollar_index] == '$':
            dollar_count += 1
            dollar_index -= 1
        return dollar_count

    def _line(self, text, indent=0):
        """Write 'text' word-wrapped at self.width characters."""
        leading_space = '  ' * indent
        while len(leading_space) + len(text) > self.width:
            # The text is too wide; wrap if possible.

            # Find the rightmost space that would obey our width constraint
            # and that's not an escaped space.
            available_space = self.width - len(leading_space) - len(' $')
            space = available_space
            while True:
                space = text.rfind(' ', 0, space)
                if (space < 0
                        or self._count_dollars_before_index(text,
                                                            space) % 2 == 0):
                    break

            if space < 0:
                # No such space; just use the first unescaped space
                # we can find.
                space = available_space - 1
                while True:
                    space = text.find(' ', space + 1)
                    if (space < 0
                            or self._count_dollars_before_index(
                                text, space) % 2 == 0):
                        break
            if space < 0:
                # Give up on breaking.
                break

            self.output.write(leading_space + text[0:space] + ' $\n')
            text = text[space+1:]

            # Subsequent lines are continuations, so indent them.
            leading_space = '  ' * (indent+2)

        self.output.write(leading_space + text + '\n')

    @staticmethod
    def _as_list(input_p):
        """."""
        if input_p is None:
            return []
        if isinstance(input_p, list):
            return input_p
        return [input_p]


def escape(string):
    """Escape a string such that it can be embedded into a Ninja file without
    further interpretation."""
    assert '\n' not in string, 'Ninja syntax does not allow newlines'
    # We only have one special metacharacter: '$'.
    return string.replace('$', '$$')


class Build(object):
    """."""

    @staticmethod
    def dependencies(base):
        """."""
        matches = []
        for root, _, filenames in os.walk(base):
            for filename in fnmatch.filter(filenames, '*.ls'):
                matches.append(os.path.join(root, filename))
        return matches

    def __init__(self, args):
        """."""
        fpd = sys.stdout if args.gen else  tempfile.NamedTemporaryFile()
        self.pbu = Writer(fpd)
        self.args = args

        if 'posix' == os.name:
            self.pbu.variable('builddir', '/dev/shm')
        self.pbu.variable('din', '../../frontend')
        self.pbu.variable('dout', '../../backend/webapp/controllers')
        self.pbu.variable('thirdparty', '$din/3rdparty')
        self.pbu.variable('int3', 'bootstrap')
        self.pbu.variable('ext3',
                          'zepto,underscore,backbone,bootstrap,typeahead')
        self.pbu.variable('cssc', 'cssc.jar')
        self.pbu.variable('jsc', 'jsc.jar')
        self.pbu.variable('pext', '--externas $ext3')
        if args.optimize:
            self.pbu.variable('opt', '-O')
        self.pbu.newline()

        self.pbu.rule('less',
                      'python2 -O setup.pyo $in $opt --salida $dout'
                      ' --internas $int3 --3rdparty $thirdparty'
                      ' --compresor_css $cssc',
                     'Compiling $in')
        self.pbu.newline()
        self.pbu.rule('ls',
                      'python2 -O setup.pyo $in $opt --salida $dout'
                      ' $pext $opt --3rdparty $thirdparty'
                      ' --compresor_js $jsc',
                      'Compiling $in')
        self.pbu.newline()

        self.pbu.build('$dout/dashboard.css', 'less', '$din/dashboard.less')
        self.pbu.build('$dout/customer.css', 'less', '$din/customer.less')
        self.pbu.build('$dout/signin.css', 'less', '$din/signin.less')
        self.pbu.newline()

        pbu.build('$dout/dashboard.js', 'ls', '$din/dashboard.ls',
                  order_only=(['$dout/dashboard.css']
                              if args.optimize else None))
        pbu.build('$dout/customer.js', 'ls', '$din/customer.ls',
                  order_only=('$dout/customer.css'
                              if args.optimize else None))
        pbu.build('$dout/signin.js', 'ls', '$din/signin.ls',
                  variables={'pext': ''})

        add_build(pbu, 'dashboard', args)

        self.pbu.newline()
        self.pbu.newline()
        self.pbu.comment('vim: et:ts=2:sw=2')

        if not args.gen:
            fpd.flush()
            os.fsync(fpd.fileno())
            os.system('ninja -f ' + os.path.join(tempfile.tempdir, fpd.name))


    def add_build(self, name):
        """."""
        self.pbu.build(('$dout/%s.js' % name), 'ls', ('$din/%s.ls' % name),
                       order_only=([('$dout/%s.css' % name)]
                                   if self.args.optimize else None))




def build():
    """Generate PLAFT build file."""
    parser = argparse.ArgumentParser(description='PLAFT build system.',
                                     epilog='By cristHian Gz. (gcca)'
                                            ' <gcca@gcca.tk> http://gcca.tk')

    parser.add_argument('-O', action='store_true',
                        help='optimize generated code slightly.',
                        dest='optimize')
    parser.add_argument('-m', help='specific build.', dest='module')
    parser.add_argument('--gen', action='store_true',
                        help='generate file.')

    args = parser.parse_args()
    Build(args)


if '__main__' == __name__:
    build()


# vim: ts=4:sw=4:sts=4:et
