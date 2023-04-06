require("util/list")

state = {}

state.loggedIn = false
state.engaged = false
state.casting = false
state.gambitLeaderId = nil
state.engagedTargetId = nil
state.aggroTargets = {}
state.claimedTargets = {}
state.focusTargets = {}

state.WSStack = List.create()

function state.prune()
    if state.engagedTargetId then
        engagedMob = windower.ffxi.get_mob_by_id(state.engagedTargetId)
        if not engagedMob or engagedMob.hpp == 0 then
            state.engagedTargetId = nil
        elseif settings.gambitLeader and windower.ffxi.get_player().status ~= 1 then
            ipc.sendDisengage()
        end
    end

    for targetId,bool in pairs(state.aggroTargets) do
        mob = windower.ffxi.get_mob_by_id(targetId)
        if not mob or mob.hpp == 0 then
            state.aggroTargets[targetId] = nil
        end
    end

    for targetId,bool in pairs(state.claimedTargets) do
        mob = windower.ffxi.get_mob_by_id(targetId)
        if not mob or mob.hpp == 0 then
            state.claimedTargets[targetId] = nil
        end
    end

    for targetId,bool in pairs(state.focusTargets) do
        mob = windower.ffxi.get_mob_by_id(targetId)
        if not mob or mob.hpp == 0 then
            state.focusTargets[targetId] = nil
        end
    end

    if state.WSStack:last() then
        local currentTime = os.clock()
        lastWS = state.WSStack:last()
        lastWSTarget = windower.ffxi.get_mob_by_id(lastWS.target) 
        if not lastWSTarget or lastWSTarget.hpp == 0 or currentTime - lastWS.time > 10 then
            state.WSStack:destroy()
            state.WSStack = List.create()
        end
    end
end

gambitLeaderIdx = nil
function state.getLeaderIdx()
    if not state.gambitLeaderId then return nil end

    party = windower.ffxi.get_party()
    if gambitLeaderIdx then
        memberAtLastIdx = party[gambitLeaderIdx]
        if memberAtLastIdx.mob and state.gambitLeaderId == memberAtLastIdx.mob.id then
            return gambitLeaderIdx
        end
    end

    for i=1,5 do
        p = party['p'..i]
        if p and p.mob then
            if p.mob.id == state.gambitLeaderId then
                gambitLeaderIdx = 'p'..i
                return gambitLeaderIdx
            end
        end
    end

    return nil
end

function state.log()
    msgs = {}
    if state.engagedTargetId then
        msgs.engaged = state.engagedTargetId
    end

    if next(state.aggroTargets) ~= nil then
        msgs.aggroed = state.aggroTargets
    end

    if next(state.claimedTargets) ~= nil then
        msgs.claimed = state.claimedTargets
    end

    if next(state.focusTargets) ~= nil then
        msgs.focused = state.focusTargets
    end

    if state.WSStack.head then
        msgs.last_ws = state.WSStack:last().name
    end

    if next(msgs) ~= nil then
        out.logTable(msgs)
    end
end

return state