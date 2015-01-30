# -*- coding: utf-8 -*-

import sys, os

SRCDIR = os.path.dirname(__file__)
sys.path.append(os.path.join(SRCDIR, '../..'))
sys.path.append(os.path.join(SRCDIR, '../../../backend'))

extensions = ['sphinx.ext.autodoc', 'sphinx.ext.doctest', 'sphinx.ext.todo', 'sphinx.ext.coverage', 'sphinx.ext.pngmath', 'sphinx.ext.viewcode', 'sphinx.ext.inheritance_diagram']

templates_path = ['_templates']

source_suffix = '.rst'

master_doc = 'index'
project = u'lac'
copyright = u'2014, cristHian Gz. (gcca)'
version = '1'
release = '1'
language = 'es'
exclude_patterns = []
show_authors = 'True'
pygments_style = 'sphinx'

html_theme = 'gcca'
html_theme_path = '.'
#html_static_path = ['_static']
htmlhelp_basename = 'lacdoc'

latex_documents = [
  ('index', 'lac.tex', u'lac Documentation',
   u'cristHian Gz. (gcca)', 'manual'),
]

man_pages = [
    ('index', 'lac', u'lac Documentation',
     [u'cristHian Gz. (gcca)'], 1)
]
texinfo_documents = [
  ('index', 'lac', u'lac Documentation',
   u'cristHian Gz. (gcca)', 'lac', 'One line description of project.',
   'Miscellaneous'),
]
