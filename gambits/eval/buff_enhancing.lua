spells = require("lib/provided/spell")
validTargets = require("lib/misc/validTargets")
cd = require("util/cooldown")
stringExt = require("util/string")
accessionEval = require("gambits/eval/misc/accession")
spellEvals = require("gambits/eval/misc/spells")

typeEval.buff_enhancing = {}
typeEval.buff_enhancing.indexTriedBuffs = {}

local function findTarget(gambit)
    if type(gambit.target) == "table" or gambit.target == "any" then
        indexes = {0,1,2,3,4,5}
        if type(gambit.target) == "table" then
            indexes = gambit.target
        end

        for k,i in pairs(indexes) do
            partyMember = windower.ffxi.get_party()['p'..i]
            failed = false
            if not partyMember then failed = true end
            if not failed and not partyMember.mob then failed = true end
            if not failed and not validTargets.isValid(gambit.val.targets, partyMember.mob) then failed = true end
            if not failed and typeEval.buff_enhancing.hasBuff(gambit, partyMember.mob.index) then failed = true end
            if not failed and not typeEval.buff_enhancing.checkHp(gambit, partyMember) then failed = true end
            if not failed and pos.dist(player.mob, partyMember.mob) > gambit.val.range then failed = true end

            if not failed then
                return partyMember
            end
        end
    elseif gambit.target == "self" then
        if typeEval.buff_enhancing.checkHp(gambit, player) and not typeEval.buff_enhancing.hasBuff(gambit, windower.ffxi.get_player().index) then return player end 
        return nil
    end
end

local function findTargetMulti(gambit)
    bufflessMembers = {}
    party = windower.ffxi.get_party()
    for i=0,5 do
        partyMember = party['p'..i]
        failed = false
        if not partyMember then failed = true end
        if not failed and not partyMember.mob then failed = true end
        if not gambit.blue_magic then
            if not failed and not validTargets.isValid(gambit.val.targets, partyMember.mob) then failed = true end
        end
        if not failed and typeEval.buff_enhancing.hasBuff(gambit, partyMember.mob.index) then failed = true end
        if not failed and not typeEval.buff_enhancing.checkHp(gambit, partyMember) then failed = true end
        if not gambit.blue_magic then
            if not failed and pos.dist(player.mob, partyMember.mob) > gambit.val.range then failed = true end
        end

        if not failed then
            table.insert(bufflessMembers, partyMember)
        end
    end

    if not gambit.minTargets then gambit.minTargets = 3 end
    if #bufflessMembers >= gambit.minTargets then
        if gambit.val.targets == 1 then
            return player
        else
            centerTarget = nil
            min_MaxDist = nil
            for i,p_prime in ipairs(bufflessMembers) do
                localMax = nil
                for n,p_sub in ipairs(bufflessMembers) do
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

function typeEval.buff_enhancing.hasBuff(gambit, targetPartyIdx)
    partyBuffs = buffUtil.getBuffs()

    attemptedBuffs = typeEval.buff_enhancing.indexTriedBuffs[targetPartyIdx]
    if partyBuffs[targetPartyIdx] then 
        return partyBuffs[targetPartyIdx][gambit.buffId]
    elseif attemptedBuffs and attemptedBuffs[gambit.buffId] then
        return true
    end
    return false
end

function typeEval.buff_enhancing.checkHp(gambit, target)
    targetMaxHp = (target.hp / target.hpp) * 100
    targetMissingHp = target.hp - targetMaxHp

    if gambit.missingHpThreshold ~= nil and gambit.hppThreshold ~= nil then
        return target.hpp <= gambit.hppThreshold and targetMissingHp <= gambit.missingHpThreshold
    elseif gambit.missingHpThreshold ~= nil then
        return targetMissingHp <= gambit.missingHpThreshold
    elseif gambit.hppThreshold ~= nil then
        return target.hpp <= gambit.hppThreshold
    else
        return target.hpp <= 100
    end
end

function typeEval.buff_enhancing.isAoE(spell)
    --ToDo - Add support for AoE buffs that don't end in 'ga' (Blue Magic & Cura)
    spellNameSplit = stringExt.split(string.lower(spell.en))
    return spellNameSplit[1]:sub(-2) == "ra"
end

player = nil
function typeEval.buff_enhancing.eval(gambit)
    if pos.moving then return 0 end

    player = windower.ffxi.get_party()['p0']
    if not spellEvals.canCast(gambit.val) then return 0 end
    if not spellEvals.checkMp(gambit) then return 0 end

    target = nil
    if gambit.focus == "single" then
        target = findTarget(gambit)
    else
        if gambit.focus == "multiple" then
            target = findTargetMulti(gambit)
        elseif gambit.focus == "either" then
            target = findTargetMulti(gambit)

            if target then
                selfBuffs = buffUtil.getBuffs()[player.mob.index]
                if gambit.blue_magic then
                    diffusionRecastId = 184
                    if cd.abilityReady(diffusionRecastId) then
                        windower.chat.input("/ja Diffusion <me>")
                        return tick.jaDelay
                    else
                        target = nil
                    end
                elseif not typeEval.buff_enhancing.isAoE(gambit.val) then
                    accessionResult = tryAccession()
                    if not accessionResult.hasBuff then
                        target = nil
                    end

                    if accessionResult.cooldown ~= 0 then 
                        return accessionResult.cooldown 
                    end
                end

                if not target then
                    target = findTarget(gambit)
                end
            else
                target = findTarget(gambit)
            end
        end
    end

    if target and target.mob then
        if not typeEval.buff_enhancing.indexTriedBuffs[target.mob.index] then
            typeEval.buff_enhancing.indexTriedBuffs[target.mob.index] = {}
        end
        typeEval.buff_enhancing.indexTriedBuffs[target.mob.index][gambit.buffId] = true
        windower.chat.input(gambit.activation.." "..target.mob.id)
        return tick.spellcastBufferDelay + gambit.val.cast_time
    end

    return 0
end

return eval