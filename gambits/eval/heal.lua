spells = require("lib/provided/spell")
validTargets = require("lib/misc/validTargets")
cd = require("util/cooldown")
stringExt = require("util/string")
accessionEval = require("gambits/eval/misc/accession")
spellEvals = require("gambits/eval/misc/spells")

typeEval.heal = {}

local function findTarget(gambit)
    if type(gambit.target) == "table" then
        focusMember = nil
        lowestHpp = nil

        for k,i in pairs(gambit.target) do
            partyMember = windower.ffxi.get_party()['p'..i]
            failed = false
            if not partyMember then failed = true end
            if not failed and not partyMember.mob then failed = true end
            if not failed and not validTargets.isValid(gambit.val.targets, partyMember.mob) then failed = true end
            if not failed and not typeEval.heal.checkHp(gambit, partyMember) then failed = true end
            if not failed and pos.dist(player.mob, partyMember.mob) > gambit.val.range then failed = true end

            if not failed and (lowestHpp == nil or partyMember.hpp < lowestHpp - 5) then
                lowestHpp = partyMember.hpp
                focusMember = partyMember
            end
        end
        return focusMember
    elseif gambit.target == "any" then
        focusMember = nil
        lowestHpp = nil

        for i=0,5 do
            partyMember = windower.ffxi.get_party()['p'..i]
            failed = false
            if not partyMember then failed = true end
            if not failed and not partyMember.mob then failed = true end
            if not failed and not validTargets.isValid(gambit.val.targets, partyMember.mob) then failed = true end
            if not failed and not typeEval.heal.checkHp(gambit, partyMember) then failed = true end
            if not failed and pos.dist(player.mob, partyMember.mob) > gambit.val.range then failed = true end

            if not failed and (lowestHpp == nil or partyMember.hpp < lowestHpp) then
                lowestHpp = partyMember.hpp
                focusMember = partyMember
            end
        end
        return focusMember
    elseif gambit.target == "self" then
        self = windower.ffxi.get_party()['p0']
        if typeEval.heal.checkHp(gambit, self) then return self end 
        return nil
    end
end

local function findTargetMulti(gambit)
    thresholdMembers = {}
    party = windower.ffxi.get_party()
    for i=0,5 do
        partyMember = party['p'..i]
        failed = false
        if not partyMember then failed = true end
        if not failed and not partyMember.mob then failed = true end
        if not failed and not validTargets.isValid(gambit.val.targets, partyMember.mob) then failed = true end
        if not failed and not typeEval.heal.checkHp(gambit, partyMember) then failed = true end
        if not failed and pos.dist(player.mob, partyMember.mob) > gambit.val.range then failed = true end

        if not failed then
            table.insert(thresholdMembers, partyMember)
        end
    end

    if not gambit.minTargets then gambit.minTargets = 3 end

    if #thresholdMembers >= gambit.minTargets then
        if gambit.val.targets == 1 then 
            return player
        else
            centerTarget = nil
            min_MaxDist = nil
            for i,p_prime in ipairs(thresholdMembers) do
                localMax = nil
                for n,p_sub in ipairs(thresholdMembers) do
                    if p_sub.id == p_prime.id then
                        dist = pos.dist(p_prime.mob, p_sub.mob)
                        if localMax == nil or dist > localMax then localMax = dist end
                    end
                end
                if min_MaxDist == nil or localMax < min_MaxDist then
                    centerTarget = p_prime
                    min_MaxDist = localMax
                end
            end
            return centerTarget
        end
    end
end

function typeEval.heal.checkHp(gambit, target)
    targetMaxHp = (target.hp / target.hpp) * 100
    targetMissingHp = target.hp - targetMaxHp

    if gambit.missingHpThreshold ~= nil and gambit.hppThreshold ~= nil then
        return target.hpp <= gambit.hppThreshold and targetMissingHp <= gambit.missingHpThreshold
    elseif gambit.missingHpThreshold ~= nil then
        return targetMissingHp <= gambit.missingHpThreshold
    elseif gambit.hppThreshold ~= nil then
        return target.hpp <= gambit.hppThreshold
    else
        return target.hpp <= 66
    end
end

function typeEval.heal.isAoE(spell)
    --ToDo - Add support for AoE heals that don't end in 'ga' (Blue Magic & Cura)
    spellNameSplit = stringExt.split(string.lower(spell.en))
    return spellNameSplit[1]:sub(-2) == "ga"
end

player = nil
function typeEval.heal.eval(gambit)
    if pos.moving then return 0 end

    player = windower.ffxi.get_party()['p0']
    if not spellEvals.canCast(gambit.val) then return 0 end
    if not spellEvals.checkMp(gambit) then return 0 end

    target = nil
    if gambit.focus == "single" then
        target = findTarget(gambit)
    elseif gambit.focus == "multiple" then
        target = findTargetMulti(gambit)
        if target ~= nil then
            selfBuffs = buffUtil.getBuffs()[player.mob.index]
            if not typeEval.heal.isAoE(gambit.val) then
                accessionResult = tryAccession()
                if not accessionResult.hasBuff then
                    target = nil
                end

                if accessionResult.cooldown ~= 0 then 
                    return accessionResult.cooldown 
                end
            end
        end
    end

    if target then
        windower.chat.input(gambit.activation.." "..target.mob.id)
        return tick.spellcastBufferDelay + gambit.val.cast_time
    end

    return 0
end

return eval