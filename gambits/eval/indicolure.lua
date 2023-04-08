GEO = require("lib/job/GEO")
cd = require("util/cooldown")

typeEval.indicolure = {}

function typeEval.indicolure.eval(gambit)
    if pos.moving then return 0 end
    
    shouldCast = true
    pl = windower.ffxi.get_player()
    for i,buff in ipairs(pl.buffs) do
        if buff == GEO.buffs[gambit.name] or buff == GEO.debuffs[gambit.name] then
            shouldCast = false
        end
    end

    if shouldCast then
        windower.chat.input(gambit.activation.." <me>")
        return tick.spellcastBufferDelay + gambit.val.cast_time
    end

    typeEval.indicolure.assessMovement(gambit)
    return 0
end

require ("lists")
function typeEval.indicolure.assessMovement(gambit)
    local selfMob = windower.ffxi.get_mob_by_target("me")
    local focusTarget = targeting.getFocusTarget(gambit)
    local skipIds = L{selfMob.id, focusTarget.id}
    local targets = targeting.getPartyTableTargets(gambit, skipIds)
    local sweepFit = targeting.angularSweepFit(focusTarget, targets, GEO.bubbleRange)
    local allTargets = targeting.getPartyTableTargets(gambit)
    local currentNumInRange = targeting.targetsInRange(selfMob, allTargets, GEO.bubbleRange)


    if sweepFit.numInRange < 2 then
        pos.unregisterPointMove("indi")
    elseif pos.moveDestination and sweepFit.numInRange <= currentNumInRange then
        return
    else
        pos.moveDestination = sweepFit.targetPoint
        pos.registerPointMove("indi")
    end
end