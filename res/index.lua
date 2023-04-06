require('lib/global')

-- Core enabling Components
state = require('res/state')
require('res/zone')

-- Helpers
require('util/index')
gambitAdjust = require('util/gambitAdjust')
gambitCombine = require('util/gambitCombine')
gambitError = require('util/error')
gambitCopy = require('util/gambitCopy')
out = require('util/out')

settings = {}

pos = {}
buffUtil = {}
commands = {}

gambits = {}
activeGambits = {}
gambitOverride = nil

ipc = {}
action = {}

tick = {}

display = {}

function init()
    state.loggedIn = true

    -- User settings (if they exist for current job)
    player_job = windower.ffxi.get_player().main_job
    player_name = string.lower(windower.ffxi.get_player().name)

    settingsPath = "_user/"..player_name.."/"..player_job.."/settings"
    if windower.file_exists(windower.addon_path..settingsPath..".lua") then
        require(settingsPath)
    end
    if settings.gambitLeader ~= nil and settings.gambitLeader then
        state.gambitLeader = true
        state.gambitLeaderId = windower.ffxi.get_mob_by_target("me").id
    end

    -- Core Components
    pos = require('res/pos')
    buffUtil = require('res/buffUtil')
    commands = require('res/commands/index')

    -- Init gambits
    require('gambits/def/index')

    gambits.default = {}
    gambits.subsets = {}

    gambitsPath = "_user/"..player_name.."/"..player_job.."/gambits" 
    require(gambitsPath)
    initGambits()

    -- Register action event & ipc handlers
    ipc = require('res/ipc')
    action = require('res/action')

    -- Begin the tick execution
    tick = require('res/tick')

    -- Set up the display
    display = require("res/display")

    -- Track AFK & Control switching between accounts
    control = require("res/playerControl")
end

if windower.ffxi.get_info().logged_in then
    init()
end