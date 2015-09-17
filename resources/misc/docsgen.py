#!/usr/bin/env python2
# encoding: utf8

from __future__ import unicode_literals
import os
import codecs
import pickle


document = {}
docpath = '../../backend/plaft/application/util/data_generator/documents.py'


for dirname, dirnames, filenames in os.walk('docs'):
    for filename in filenames:
        path = os.path.join(dirname, filename)
        name = filename[:-4]
        if name not in document:
            document[name] = {
                'html': None,
                'pdf': None
            }
        extension = filename[-3:]

        if extension == 'htm':
            with codecs.open(path, 'r', 'cp1252') as doc:
                content = doc.read()
                document[name]['html'] = content

        if extension == 'pdf':
            with open(path, 'rb') as src:
                document[name]['pdf'] = src.read()

with codecs.open(docpath, 'w', 'utf8') as docpy:
    docpy.write('# encoding: utf8\n\ndocument = {\n')
    for name in document:
        content = document[name]['html']
        content = content.replace('\r\n', ' ')
        content = content.replace('\'', '\\\'')

        source = document[name]['pdf']
        source = repr(pickle.dumps(source))
        # source = source.replace('\'', '\\\'')

        docpy.write(('    \'%s\': '
                     '{\n        \'html\': \'%s\',\n'
                     '        \'pdf\': %s\n    },\n')
                    % (name, content, source))
    docpy.write('}\n\n# vim: et:ts=4:sw=4\n')


# vim: et:ts=4:sw=4
