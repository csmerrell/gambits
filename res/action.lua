tableExt = require("util/table")
validTargets = require("lib/misc/validTargets")
weaponSkills = require("lib/provided/ws")
action = {}

function action.handler(act)
    aggroActionIds = T{1,2,3}
    conditionalAggroActionIds = T{4,6}
    meleeId = 1
    weaponSkillId = 3

    if tableExt.contains(aggroActionIds, act.category) then
        action.assessAggro(act)
    end

    if tableExt.contains(conditionalAggroActionIds, act.category) then
        action.assessConditionalAggro(act)
    end

    if act.category == meleeId and act.actor_id == windower.ffxi.get_player().id then
        state.engagedTargetId = act.targets[1].id
        ipc.sendEngagedTarget(state.engagedTargetId)
    end

    if act.category == weaponSkillId then
        action.assessWeaponSkill(act)
    end
end

pMobs = {}
function action.partyMobMapper(partyMember)
    if partyMember.mob then
        return { ["key"] = partyMember.mob.id, ["val"] = partyMember.mob }
    end
end

function action.assessAggro(act)
    partyMembers = windower.ffxi.get_party()
    if #partyMembers == 0 then
        partyMembers = {
            [1] = {
                ["mob"] = windower.ffxi.get_mob_by_id(windower.ffxi.get_player().id)
            }
        }
    end
    pMobs = tableExt.map(partyMembers, action.partyMobMapper)

    if pMobs[act.actor_id] then
        action.handleClaimedTargets(act.targets)
    else
        for i,target in ipairs(act.targets) do
            if pMobs[target.id] and not pMobs[act.actor_id] then
                actorMob = windower.ffxi.get_mob_by_id(act.actor_id);
                if validTargets.mobType(actorMob) == "MONSTER" then
                    state.aggroTargets[act.actor_id] = true
                    ipc.sendAggroTarget(act.actor_id)
                end
            end
        end
    end
end

aggressiveActionMsgs = require("lib/misc/aggressiveActionMsgs")
function action.assessConditionalAggro(act)
    -- Spells and job abilities are not always aggressive, so we need to check if the action message is in a table of aggressive actions
    for i, target in ipairs(act.targets) do
        if aggressiveActionMsgs[target.actions[1].message] then
            action.assessAggro(act)
            return
        end
    end
end

function action.assessWeaponSkill(act)
    if act.param < 0 then return end

    if pMobs[act.actor_id] then
        for i, target in ipairs(act.targets) do
            if target.id == state.engagedTargetId and target.actions[1].param > 0 then
                ws = weaponSkills[act.param]
                wsRecord = {}
                wsRecord.time = os.clock()
                wsRecord.name = ws.en
                wsRecord.target = target.id
                state.WSStack:append(wsRecord)
                if state.WSStack.size > 5 then
                    state.WSStack:popFront()
                end
                ipc.sendWeaponSkill(wsRecord)
            end
        end
    end
end

function action.handleClaimedTargets(targets)
    for i, target in ipairs(targets) do
        targetMob = windower.ffxi.get_mob_by_id(target.id)
        if not pMobs[target.id] and validTargets.mobType(targetMob) == "MONSTER" then
            state.claimedTargets[target.id] = true
            ipc.sendClaimedTarget(target.id )
        end
    end
end

-- Register listener
if settings.gambitLeader then
    state.actionEventId = windower.register_event('action', action.handler)
end

return action