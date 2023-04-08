GEO = require("lib/job/GEO")
cd = require("util/cooldown")
targeting = require("util/targeting")

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
        if gambit.target == "leader" then
            leader = windower.ffxi.get_mob_by_id(state.gambitLeaderId)
            if leader then
                windower.chat.input(gambit.activation.." "..leader.index)
            else
                windower.chat.input(gambit.activation.." <me>")
            end
        else
            windower.chat.input(gambit.activation.." <me>")
        end
        return tick.spellcastBufferDelay + gambit.val.cast_time
    end

    return 0
end

require ("lists")
function typeEval.geomancy.shouldBuff(gambit)
    if pos.moving then return false end

    if not state.engagedTargetId and gambit.name ~= "refresh" and gambit.name ~= "regen" then return false end

    pet = windower.ffxi.get_mob_by_target("pet")
    party = windower.ffxi.get_party()

    if gambit.target == "any" then
        if pet == nil then
            return true
        else
            if math.abs(dist(party["p0"].mob, pet)) > GEO.bubbleRange then
                windower.chat.input('/ja "Full Circle" <me>')
            end
            return false
        end
    elseif gambit.target == "leader" then
        if pet == nil then
            return true
        else
            leader = windower.ffxi.get_mob_by_id(state.gambitLeaderId)
            if leader and math.abs(dist(party["p0"].mob, pet)) > GEO.bubbleRange then
                windower.chat.input('/ja "Full Circle" <me>')
            end
            return false
        end
    elseif gambit.target == "all" or type(gambit.target) == "table" then

        if pet then
            pos.unregisterPointMove("geo")
            if cd.abilityReady(GEO.jaRecast.fullCircle) then
                local allTargets = targeting.getPartyTableTargets(gambit)
                local focusTarget = targeting.getFocusTarget(gambit)
                local skipIds = L{windower.ffxi.get_mob_by_target("me").id, focusTarget.id}
                local targets = targeting.getPartyTableTargets(gambit, skipIds)
                local currentNumInRange = targeting.targetsInRange(pet, allTargets, GEO.bubbleRange)
                local sweepFit = targeting.angularSweepFit(focusTarget, targets, GEO.bubbleRange)
                if currentNumInRange < sweepFit.numInRange then
                    windower.chat.input('/ja "Full Circle" <me>')                    
                end
            end
        elseif gambit.name:lower() == "regen" or gambit.name:lower() == "refresh" or state.engagedTargetId ~= nil then
            if not typeEval.geomancy.movingToCenter then
                local focusTarget = targeting.getFocusTarget(gambit)
                local skipIds = L{windower.ffxi.get_mob_by_target("me").id, focusTarget.id}
                local targets = targeting.getPartyTableTargets(gambit, skipIds)
                local sweepFit = targeting.angularSweepFit(focusTarget, targets, GEO.bubbleRange)
                pos.moveDestination = sweepFit.targetPoint
                pos.registerPointMove("geo")
                typeEval.geomancy.movingToCenter = true
            elseif not pos.moving then
                typeEval.geomancy.movingToCenter = false
                windower.chat.input(gambit.activation.." <me>")
                return true
            end
        end
    end

    return false
end