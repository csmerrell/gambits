require('lists')

rollGambits = require("gambits/def/roll")
spellGambits = require("gambits/def/spell")
geoGambits = require("gambits/def/geomancy")
indiGambits = require("gambits/def/indicolure")
jaGambits = require("gambits/def/ja")
wsGambits = require("gambits/def/ws")

function commands.setGambits(setName)
    if not jobGambits[setName] then
        gambitErrorsetNotFound(setName);
        return
    end

    activeGambits = {}
    for i,gambit in ipairs(jobGambits[setName]) do
        gambit = expandGambit(gambit)
        table.insert(activeGambits, gambit)
    end
end
commands.set = commands.setGambits

function initGambits()
    if not gambits.default then
        gambitError.defaultSetNotFound();
        return
    end

    for i,gambit in ipairs(gambits.default) do
        gambit = expandGambit(gambit)
        if gambit then
            table.insert(activeGambits, gambit)
        end
    end
end

spellCats = L{ "heal", "buff_enhancing", "black_magic" }
function expandGambit(gambit)
    if gambit.type == "buff_ja" then
        return jaGambits.expand(gambit)
    elseif gambit.type == "roll" then
        return rollGambits.expand(gambit)
    elseif gambit.type == "ws" then
        return wsGambits.expand(gambit)
    elseif gambit.type == "special" then
        return expandSpecial(gambit)
    elseif gambit.type == "geomancy" then
        return geoGambits.expand(gambit)
    elseif gambit.type == "indicolure" then
        return indiGambits.expand(gambit)
    elseif spellCats:contains(gambit.type) then
        return spellGambits.expand(gambit)
    else
        error.unknownGambitType(gambit)
        return nil
    end
end

function expandSpecial(gambit)
    if gambit.name == "attack" then
        gambit.displayName = "Attack"
        gambit.val = {}
        if not gambit.target then
            gambit.target = "leader_engaged"
        end
        targetText = "Leader's target"
        --Add other target options

        gambit.displayFull = "Attack   >   "..targetText
        return gambit
    elseif gambit.name == "sublimation" then
        gam = jaGambits.expand(gambit)
        gam.validTargets = T{"self"}
        return gam
    end
end