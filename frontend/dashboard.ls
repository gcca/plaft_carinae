

App = require './app'


BETAS =
  TestII   = require './test/test-moduleII'
  TestIII    = require './test/test-moduleIII'
  TestIV    = require './test/test-moduleIV'

SETTINGS =
  TestI    = require './test/test-module'
  TestVI    = require './test/test-moduleVI'

App.MODULES = BETAS
App.SETTINGS = SETTINGS

WorkspaceNew = require './workspace-new'

(new WorkspaceNew).render!
