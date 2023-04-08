tableExt = require("util/table")

invalidFollowMsg = [[[Gambits]:
    Follow command `%s` not found.
    Valid options: 
        [p1 | p2 | p3 | p4 | p5]
        [on | off | toggle | t]
        [distance | dist | d] [2-25] ]]

function commands.follow(args)
    passThroughArgs = { unpack(args, 2) }
    if followCmds[args[1]] then return followCmds[args[1]](passThroughArgs) end

    if tableExt.contains(pos.validFollowTargets, args[1]) then return followCmds.target(args[1]) end

    out.msg(string.format(invalidFollowMsg, args[1]))
end
commands.f = commands.follow

followCmds = {}

function followCmds.on()
    target = pos.getFollowMob()
    pos.isFollowing = true
    pos.lockFollowing = false
    if target then
        out.msg("[Gambits]: Following "..target.name..".")
    else
        out.msg([[[Gambits]: Follow enabled, but no target was found.]])
    end
end

function followCmds.off()
    target = pos.getFollowMob()
    pos.isFollowing = false
    pos.lockFollowing = true
    if target then
        out.msg("[Gambits]: Follow ["..target.name.."] paused.")
    else
        out.msg("[Gambits]: Follow paused.")
    end
end

function followCmds.toggle()
    if pos.isFollowing then 
        return followCmds.off()
    else
        return followCmds.on()
    end
end
followCmds.t = followCmds.toggle


function followCmds.target(targetKey)
    target = windower.ffxi.get_party()[targetKey]
    if target then
        pos.followTarget = targetKey
        out.msg("[Gambits]: Follow target set to "..target.name..".")
    else
        pos.followTarget = 'p1'
        out.msg("[Gambits]: Party member not found at that index. Defaulting to p1.")
    end
end


function followCmds.distance(args)
    num = tonumber(args[1])
    if num and num >= 2 and num <= 25 then
        pos.followDistance = num
    elseif num == nil then
        out.msg("[Gambits]: followDistance value was not a number.")
    else
        out.msg("[Gambits]: Please set a followDistance between 2 and 25 (default 4).")
    end
end
followCmds.dist = followCmds.distance
followCmds.d = followCmds.distance
