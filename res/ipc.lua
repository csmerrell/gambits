ipc = {}

-- Receiving messages
pl = windower.ffxi.get_player()
function ipc.handler(...)
    args = splitArgs(...)

    local subArgs = {}
    if args[1] == "linePos" then
        for i=2,#args do
            subArgs[i - 1] = args[i]
        end
        return ipc.linePos(subArgs)
    else
        for i=3,#args do
            subArgs[i - 2] = args[i]
        end

        state.gambitLeaderId = tonumber(args[1])
    end

    if ipc[args[2]] then
        return ipc[args[2]](subArgs)
    end
end
windower.register_event("ipc message", ipc.handler)

function ipc.changeLeader(args)
    if state.gambitLeader then
        state.gambitLeader = false
        windower.unregister_event(state.actionEventId)
        pos.isFollowing = true
        if args[1] then
            settings.followFanRadian = tonumber(args[1])
        end
    end
    display.box:text(display.getText())
end

function ipc.engagedTarget(args)
    state.engagedTargetId = tonumber(args[1])
end

function ipc.disengage(args)
    state.engagedTargetId = nil
end

function ipc.claimedTarget(args)
    state.claimedTargets[tonumber(args[1])] = true;
end

function ipc.aggroTarget(args)
    state.aggroTargets[tonumber(args[1])] = true;
end

function ipc.focusTarget(args)
    if args[1] == "add" then
        if not state.focusTargets[args[1]] then 
            state.focusTargets[args[1]] = {} 
        end
        state.focusTargets[args[1]][args[2]] = true
    elseif args[1] == "remove" then
        if state.focusTargets[args[1]] then
            state.focusTargets[args[1]][args[2]] = nil
            if #state.focusTargets[args[1]] == 0 then
                state.focusTargets[args[1]] = nil
            end
        end
    elseif args[1] == "removeAll" then
        state.focusTargets[args[1]] = nil
    elseif args[1] == "toggle" then
        if not state.focusTargets[args[1]] then 
            state.focusTargets[args[1]] = {}
        end
        if state.focusTargets[args[1]][args[2]] then
            state.focusTargets[args[1]][args[2]] = nil
            if #state.focusTargets[args[1]] == 0 then
                state.focusTargets[args[1]] = nil
            end
        else
            state.focusTargets[args[1]][args[2]] = true
        end        
    end
end

function ipc.weaponSkill(args)
    wsRecord = {}
    wsRecord.name = args[1]
    wsRecord.time = tonumber(args[2])
    wsRecord.target = tonumber(args[3])
    state.WSStack:append(wsRecord)
    if state.WSStack.size > 5 then
        state.WSStack:popFront()
    end    
end

-- Sending messages
function ipc.takeLeader(followFanRadian)
    if followFanRadian then
        windower.send_ipc_message(pl.id.." changeLeader "..followFanRadian)
    else
        windower.send_ipc_message(pl.id.." changeLeader")
    end
    state.gambitLeader = true
    state.actionEventId = windower.register_event('action', action.handler)
end

function ipc.sendEngagedTarget(targetId)
    windower.send_ipc_message(pl.id.." engagedTarget "..targetId)    
end

function ipc.sendDisengage()
    windower.send_ipc_message(pl.id.." disengage")
end

function ipc.sendClaimedTarget(targetId)
    windower.send_ipc_message(pl.id.." claimedTarget "..targetId)    
end

function ipc.sendAggroTarget(targetId)
    windower.send_ipc_message(pl.id.." aggroTarget "..targetId)    
end

function ipc.sendFocusTarget(targetId, focusKey)
    windower.send_ipc_message(pl.id.." focusTarget "..targetId.." "..focusKey)    
end

function ipc.sendWeaponSkill(wsRecord)
    windower.send_ipc_message(pl.id.." weaponSkill \""..wsRecord.name.."\" "..wsRecord.time.." "..wsRecord.target)    
end

return ipc