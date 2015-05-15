# -*- coding: utf-8 -*-

import sys, os

SRCDIR = os.path.dirname(__file__)
sys.path.append(os.path.join(SRCDIR, '../..'))
sys.path.append(os.path.join(SRCDIR, '../../../backend'))

extensions = [
    'sphinx.ext.autodoc',
    'sphinx.ext.doctest',
    'sphinx.ext.todo',
    'sphinx.ext.coverage',
    'sphinx.ext.pngmath',
    'sphinx.ext.viewcode',
    'sphinx.ext.inheritance_diagram'
]

templates_path = ['_templates']

source_suffix = '.rst'

master_doc = 'index'
project = u'PLAFTsw'
copyright = u'2014, cristHian Gz. (gcca)'
version = '0.7.0'
release = '1.0.0'
language = 'es'
exclude_patterns = []
show_authors = True
pygments_style = 'sphinx'

html_theme = 'gcca'
html_theme_path = ['.']
#html_static_path = ['_static']
htmlhelp_basename = 'PLAFTswDOC'

latex_documents = [
  ('index', 'plaftsw.tex', u'PLAFTsw Documentation',
   u'cristHian Gz. (gcca)', 'manual'),
]

man_pages = [
    ('index', 'plaftsw', u'plaftsw Documentation',
     [u'cristHian Gz. (gcca)'], 1)
]

texinfo_documents = [
  ('index', 'plftsw', u'PLAFTsw Documentation',
   u'cristHian Gz. (gcca)', 'plaft', 'One line description of project.',
   'Miscellaneous'),
]
