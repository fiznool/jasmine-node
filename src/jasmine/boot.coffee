growlReporter  = require 'jasmine-growl-reporter'
nodeReporters  = require '../reporter'
junitReporter  = require '../junit-reporter'

# Node Translation of the Jasmine boot.js file. Seems to work quite well
boot = (jasmineRequire, clockCallback) ->
    jasmine = jasmineRequire.core jasmineRequire

    ###
    Create the Jasmine environment. This is used to run all specs in a project.
    ###
    env = jasmine.getEnv()

    # Attach our reporters
    jasmine.TerminalReporter = nodeReporters.TerminalReporter
    jasmine.JUnitReporter    = junitReporter.JUnitReporter
    jasmine.GrowlReporter    = growlReporter

    ###
    Obtain the public Jasmine API.
    ###
    jasmineInterface = jasmineRequire.interface jasmine, env

    ###
    Add all of the Jasmine global/public interface to the proper global, so a project can use the public interface directly. For example, calling `describe` in specs instead of `jasmine.getEnv().describe`.
    ###
    for property of jasmineInterface
        global[property] = jasmineInterface[property] if jasmineInterface.hasOwnProperty property

    global.jasmine = jasmine

    clockInstaller = jasmine.currentEnv_.clock.install
    clockUninstaller = jasmine.currentEnv_.clock.uninstall
    jasmine.currentEnv_.clock.install = ->
        clockCallback(true, env.clock)
        return clockInstaller()
    jasmine.currentEnv_.clock.uninstall = ->
        clockCallback(false, env.clock)
        return clockUninstaller()

    ###
    Expose the mock interface for the JavaScript timeout functions
    ###
    jasmine.clock = ->
        return env.clock

    return jasmine

module.exports = {boot}
