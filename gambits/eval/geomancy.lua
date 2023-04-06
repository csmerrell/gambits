GEO = require("lib/job/GEO")
cd = require("util/cooldown")

typeEval.geomancy = {}

function typeEval.geomancy.eval(gambit)
    return typeEval.geomancy[gambit.geoType](gambit)
end

function typeEval.geomancy.debuff(gambit)
    if typeEval.geomancy.shouldDebuff(gambit, engagedMob) then
        windower.chat.input(gambit.activation.." "..engagedMob.index)
        return tick.spellcastBufferDelay + gambit.val.cast_time
    end

    return 0
end

function typeEval.geomancy.shouldDebuff(gambit, engagedMob)
    if pos.moving then return false end
    if not state.engagedTargetId then return false end

    engagedMob = windower.ffxi.get_mob_by_id(state.engagedTargetId)
    if not engagedMob then return false end

    if typeEval.geomancy.lastMobPos == nil then
        typeEval.geomancy.lastMobPos = { x = engagedMob.x, y = engagedMob.y }
        return false
    end

    mobPositioned = true
    if engagedMob.x ~= typeEval.geomancy.lastMobPos.x or engagedMob.y ~= typeEval.geomancy.lastMobPos.y then
        typeEval.geomancy.lastMobPos.x = engagedMob.x
        typeEval.geomancy.lastMobPos.y = engagedMob.y
        mobPositioned = false
    end

    pet = windower.ffxi.get_mob_by_target("pet")
    if pet then
        if mobPositioned and cd.spellReady(gambit.val.recast_id) then
            if cd.abilityReady(GEO.jaRecast.fullCircle) and pos.dist(engagedMob, pet) > GEO.bubbleRange then
                windower.chat.input('/ja "Full Circle" <me>')
            end
        end
        return false
    end

    if mobPositioned and cd.spellReady(gambit.val.recast_id) then
        return true
    end

    return false
end

function typeEval.geomancy.buff(gambit)
    if typeEval.geomancy.shouldBuff(gambit) then
        windower.chat.input(gambit.activation.." <me>")
        return tick.spellcastBufferDelay + gambit.val.cast_time
    end

    return 0
end

function typeEval.geomancy.shouldBuff(gambit)
    if pos.moving then return false end

    if not state.engagedTargetId and gambit.name ~= "refresh" and gambit.name ~= "regen" then return false end

    pet = windower.ffxi.get_mob_by_target("pet")

    if gambit.target == "any" then
        return pet == nil
    elseif gambit.target == "all" or type(gambit.target) == "table" then
        targets = GEO.getTargetMobs(gambit)

        if pet then
            pos.cancelPointMove()

            if cd.abilityReady(GEO.jaRecast.fullCircle) and pos.targetsInRadius(pet, targets, GEO.bubbleRange) < gambit.minTargets then
                windower.chat.input('/ja "Full Circle" <me>')
            end
            return false
        else
            selfMob = windower.ffxi.get_mob_by_target("me")
            if pos.maxNumInRadius and pos.targetsInRadius(selfMob, targets, GEO.bubbleRange) >= pos.maxNumInRadius then
                return true
            else 
                return pos.moveToCenter(targets, GEO.bubbleRange) > 0
            end
        end
    end

    return false
end