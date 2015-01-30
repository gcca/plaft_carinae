#!/usr/bin/python2

"""Module for generating <plaft> build files.

Note that this is emphatically not a required piece of PLAFT; it's
just a helpful utility for build-file-generation systems that already
use auto-building.


Copyright (c) <2015>, <Gonzales Castillo Cristhian A.>
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.

3. All advertising materials mentioning features or use of this software
   must display the following acknowledgement:
   This product includes software developed by cristHian Gz. (gcca).

4. Neither the name of cristHian Gz. (gcca) nor the
   names of its contributors may be used to endorse or promote products
   derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY CRISTHIAN GZ. (GCCA) ''AS IS'' AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL CRISTHIAN GZ. (GCCA) BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
"""

import os
import re
import argparse


PYTHON = 'python2' if 'posix' == os.name else 'C:\\Python27\\python.exe'
LESS_C = (PYTHON + ' -O setup.pyo %(in)s --salida %(out)s --internas'
          ' %(int3)s --3rdparty %(3rdparty)s --compresor_css %(opt)s')
LS_C = (PYTHON + ' -O setup.pyo %(in)s --salida %(out)s %(ext)s'
        ' --3rdparty %(3rdparty)s --compresor_js %(opt)s')

SRC_DIR = '../../frontend'
DST_DIR = '../../backend/webapp/controllers'

K_LESS = '.less'
K_LS = '.ls'
K_O = ' -O'

MAP_EXT = {
    K_LESS: '.css',
    K_LS: '.js'
}

MAP_C = {
    K_LESS: LESS_C,
    K_LS: LS_C
}

RE_DEP = {
    K_LESS: re.compile('import [\'"](.*)[\'"]'),
    K_LS: re.compile('require [\'"](.*)[\'"]')
}


def make(args, ctx, kind):
    """Make building."""
    src_fn = os.path.join(SRC_DIR, args.module + kind)
    dst_fn = os.path.join(DST_DIR, args.module + MAP_EXT[kind])

    if args.debug:
        args.optimize = args.debug

    if args.optimize:
        MAP_C[kind] += K_O
    ctx['in'] = src_fn
    cmd = MAP_C[kind] % ctx

    if args.debug:
        cmd += ' --depurar'

    stat = os.stat(dst_fn).st_mtime
    mods = [src_fn] + check(src_fn, kind)

    if ((not os.path.exists(dst_fn))
            or any(stat <= os.stat(mod).st_mtime for mod in mods)
            or args.force):
        print 'Compilando %s%s' % (args.module, kind)
        os.system(cmd)


def check(path, kind):
    """Get dependencies."""
    with open(path) as src:
        mods = RE_DEP[kind].findall(src.read())

    sdir = os.path.dirname(path)
    deps = [get_paths(name, sdir, kind) for name in mods]
    subs = (check(sub, kind) for sub in deps)

    return deps + reduce(lambda x, y: x+y, subs, [])


def get_paths(name, sdir, kind):
    """Get paths from dependency."""
    mod = os.path.join(sdir, name)
    chunks = [mod]

    if os.path.isdir(mod):
        chunks.append(os.path.sep)
        chunks.append('index')

    chunks.append(kind)
    return ''.join(chunks)


def build():
    """Generate PLAFT build file."""
    parser = argparse.ArgumentParser(description='PLAFT build system.',
                                     epilog='By cristHian Gz. (gcca)'
                                            ' <gcca@gcca.tk> http://gcca.tk')

    parser.add_argument('--force', '-f', nargs='?', const='',
                        choices=['ls', 'less', ''],
                        help='force compilation')
    parser.add_argument('--less', action='store_const', const='less',
                        help='compile lesscss file', dest='force')
    parser.add_argument('--ls', action='store_const', const='ls',
                        help='compile livescript file', dest='force')
    parser.add_argument('--optimize', '-O', action='store_true',
                        help='optimize generated code slightly')
    parser.add_argument('--debug', '-D', action='store_true',
                        help='debug optimized code')
    parser.add_argument('--version', '-v', action='version',
                        version='%(prog)s 2.0')
    parser.add_argument('module', nargs='?', help='to compile')

    args = parser.parse_args()

    ctx_less = {
        'out': DST_DIR,
        'int3': 'bootstrap',
        '3rdparty': os.path.join(SRC_DIR, '3rdparty'),
        'opt': 'cssc.jar'
    }

    ctx_ls = {
        'out': DST_DIR,
        'ext': '',
        '3rdparty': os.path.join(SRC_DIR, '3rdparty'),
        'opt': 'jsc.jar'
    }

    if 'signin' != args.module:
        ctx_ls['ext'] = ('--externas'
                         ' zepto,underscore,backbone,bootstrap,typeahead')

    if not args.module:
        for mod in (ls_src[:-3] for ls_src in os.listdir(SRC_DIR)
                    if ls_src.endswith('.ls')):
            args.module = mod
            make(args, ctx_less, K_LESS)
            make(args, ctx_ls, K_LS)
    else:
        if args.force:
            kind = '.' + args.force
            make(args, {K_LESS: ctx_less, K_LS: ctx_ls}[kind], kind)
        else:
            if type(args.force) is str:
                args.force = True
            make(args, ctx_less, K_LESS)
            make(args, ctx_ls, K_LS)


if '__main__' == __name__:
    build()


# vim: ts=4:sw=4:sts=4:et
