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

    -- if gambit.target == "any" then
        return 0
    -- else
    --     return typeEval.indicolure.assessMovement(gambit)
    -- end
end

function typeEval.indicolure.assessMovement(gambit)
    targets = GEO.getTargetMobs(gambit)

    selfMob = windower.ffxi.get_mob_by_target("me")

    if not pos.maxNumInRadius or pos.targetsInRadius(selfMob, targets, GEO.bubbleRange) < pos.maxNumInRadius then
        pos.moveToCenter(targets, GEO.bubbleRange)
        out.msg(pos.maxNumInRadius)
        return .5
    end

    return 0
end