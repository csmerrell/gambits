pos = {}

pos.moving = false
pos.lockFollowing = false
pos.isFollowing = true
if settings.autoFollow ~= nill and not settings.autoFollow then
    pos.isFollowing = false
end
pos.moveDestination = nil
pos.moveRegistry = {}
pos.followTarget = nil
pos.followDistance = 2
if settings.followDistance then
    pos.followDistance = settings.followDistance
end
pos.castFollowDistance = 8
pos.maxThreshold = 35
pos.validFollowTargets = {'p1', 'p2', 'p3', 'p4', 'p5',}
pos.foundNewFollow = false
pos.heading = nil
pos.snapshot = {}

pos.lastMovementTime = os.clock()
local m = windower.ffxi.get_mob_by_target("me")
pos.lastPos = { 
    x = m.x, 
    y = m.y,
    x2 = m.x, 
    y2 = m.y 
}

function pos.move()
    -- pos.checkPlayerControl()

    if #pos.moveRegistry == 0 then
        pos.moveDestination = nil
    end

    if state.engagedTargetId and windower.ffxi.get_player().status == 1 then  -- engaged
        pos.stayEngaged()
    elseif pos.moveDestination then
        pos.moveToPoint()
    elseif pos.isFollowing and not state.gambitLeader then 
        pos.follow()
    end
end

function pos.halt()
    pos.handleLeaderSwaps()
    pos.isIdle()

    if state.engagedTargetId and windower.ffxi.get_player().status == 1 then  -- engaged
        pos.haltEngaged()
    elseif pos.moveDestination then
        pos.haltOnPoint()
    elseif pos.isFollowing and not state.gambitLeader then 
        pos.haltFollow()
    end
end

function pos.handleLeaderSwaps()
    if pos.lockFollowing and not pos.isFollowing then return end
    
    if state.gambitLeader and not pos.snapshot.gambitLeader then
        pos.snapshot = {
            gambitLeader = true,
            isFollowing = pos.isFollowing
        }
        pos.isFollowing = false
        pos.moveDestination = false
        display.box:text(display.getText())
    elseif not state.gambitLeader and pos.snapshot.gambitLeader then
        pos.isFollowing = pos.snapshot.isFollowing
        pos.snapshot = {}
        display.box:text(display.getText())
    end
end

pos.restoreTick = false
function pos.isIdle()
    selfMob = windower.ffxi.get_mob_by_target("me")
    if not selfMob then return end
    if pos.lastPos.x == selfMob.x and pos.lastPos.y == selfMob.y then
        pos.heading = nil
        pos.moving = false
        if os.clock() - pos.lastMovementTime > 900 then
            if tick.on then
                pos.restoreTick = true
                tick.on = false
                out.msg("[Gambits]: No movement in 15 minutes. Disabling Gambits. Will resume automatically when returning.")
                display.box:text(display.getText())
            end
        end
    else
        if pos.restoreTick then
            tick.on = true
            pos.restoreTick = false
            out.msg("[Gambits]: No longer AFK. Resuming execution.")
            display.box:text(display.getText())
        end
        pos.lastPos.x = selfMob.x
        pos.lastPos.y = selfMob.y
        pos.lastMovementTime = os.clock()
    end
end

function pos.checkPlayerControl()
    local selfMob = windower.ffxi.get_mob_by_target("me")
    if pos.lastPos.x2 == selfMob.x and pos.lastPos.y2 == selfMob.y then return end
    pos.lastPos.x2 = selfMob.x
    pos.lastPos.y2 = selfMob.y

    out.msg("checking")
    if not state.gambitLeader and pos.heading == nil or pos.heading ~= selfMob.facing then
        if pos.heading then
            out.msg(pos.heading)
        end
        out.msg(selfMob.facing)
        out.msg("Taking Leader")
    end
end

function pos.follow()
    followMob = pos.getFollowMob()
    selfMob = windower.ffxi.get_mob_by_target("me")
    if selfMob == nil or followMob == nil then return end

    if not pos.foundNewFollow then -- update the text box once each time a new follow target is assigned
        pos.foundNewFollow = true
        display.box:text(display.getText())
    end

    if followMob.status == 85 and selfMob.status == 0 then
        mount = "Raptor"
        if settings.mount then
            mount = settings.mount
        end
        windower.chat.input("/mount "..mount)
    elseif followMob.status ~= 85 and selfMob.status == 85 then
        windower.chat.input("/dismount")
    end

    distThreshold = pos.followDistance + 3
    dist = pos.dist(selfMob, followMob)
    if dist > distThreshold and dist < pos.maxThreshold then
        pos.moving = true
        pos.heading = pos.getHeadingRadian(selfMob, followMob)
        windower.ffxi.turn(pos.heading)
        windower.ffxi.run(pos.heading)
    elseif pos.moving and settings.followFanRadian and dist < distThreshold + 1 and dist < pos.maxThreshold then
        pos.heading = pos.getHeadingRadian(selfMob, followMob) + settings.followFanRadian
        if pos.heading > math.pi then 
            pos.heading = pos.heading - 2 * math.pi
        elseif pos.heading < -1 * math.pi then 
            pos.heading = pos.heading + 2 * math.pi 
        end
        windower.ffxi.turn(pos.heading)
        windower.ffxi.run(pos.heading)
    elseif settings.followFanRadian then
        pos.fanParty(followMob)
    end
end

function pos.getFollowMob()
    pos.followEntity = nil
    if pos.followTarget then
        pos.followEntity = windower.ffxi.get_party()[pos.followTarget]
    else
        party = windower.ffxi.get_party()
        for key, p in pairs(party) do
            if type(p) == "table" and p.mob and p.mob.id == state.gambitLeaderId then
                name = ""
                if pos.followEntity then
                    name = pos.followEntity.name
                end

                pos.followEntity = p
                if p.name ~= name then
                    display.box:text(display.getText())
                end
            end
        end
    end

    if not (pos.followEntity and pos.followEntity.mob) then return end

    return pos.followEntity.mob
end

function pos.fanParty(followTarget)
    party = windower.ffxi.get_party()
    selfMob = party["p0"].mob
    for key, p in pairs(party) do
        if type(p) == "table" and p.mob and p.mob.id ~= selfMob.id then
            if pos.dist(selfMob, p.mob) < 1.25 then
                followRadian = pos.getHeadingRadian(selfMob, followTarget)
                spreadRadian = pos.getHeadingRadian(p.mob, selfMob)
                avgRadian = math.atan2(math.sin(followRadian) + math.sin(spreadRadian), math.cos(followRadian) + math.cos(spreadRadian))
                avgRadian2 = math.atan2(math.sin(avgRadian) + math.sin(spreadRadian), math.cos(avgRadian) + math.cos(spreadRadian))
                pos.heading = avgRadian2
                pos.moving = true
                windower.ffxi.turn(pos.heading)
                windower.ffxi.run(pos.heading)
            end
        end
    end
end

function pos.haltFollow()
    selfEnt = windower.ffxi.get_party()['p0']
    if pos.followEntity == nil or pos.followEntity.zone ~= selfEnt.zone then return end

    followMob = pos.followEntity.mob
    selfMob = selfEnt.mob
    if selfMob == nil or followMob == nil then
        pos.foundNewFollow = false
        windower.ffxi.run(false)
        return 
    end

    distThreshold = pos.followDistance
    dist = pos.dist(selfMob, followMob)
    if dist < distThreshold or dist > pos.maxThreshold then
        fanComplete = true
        party = windower.ffxi.get_party()
        selfMob = party["p0"].mob
        for key, p in pairs(party) do
            if type(p) == "table" and p.mob and p.mob.id ~= selfMob.id then
                if pos.dist(selfMob, p.mob) < 1.25 then
                    fanComplete = false
                end
            end
        end
        
        if fanComplete then
            pos.heading = pos.getHeadingRadian(selfMob,followMob)
            windower.ffxi.turn(pos.heading)
            windower.ffxi.run(false)
        end
    end
end

function pos.stayEngaged()
    target = windower.ffxi.get_mob_by_target("t")
    selfMob = windower.ffxi.get_party()['p0'].mob
    dist = pos.dist(selfMob, target)
    if not state.gambitLeader and dist > 1.8 then
        pos.moving = true
        pos.heading = pos.getHeadingRadian(selfMob, target)
        windower.ffxi.turn(pos.heading)
        windower.ffxi.run(pos.heading)
    end
end

function pos.haltEngaged()
    target = windower.ffxi.get_mob_by_target("t")
    selfMob = windower.ffxi.get_party()['p0'].mob
    dist = pos.dist(selfMob, target)
    if dist <= 1.8 then
        windower.ffxi.run(false)
        pos.faceTarget(selfMob, target)
    end
end

function pos.faceTarget(mob_a, mob_b)
    pos.heading = pos.getHeadingRadian(mob_a, mob_b)
    windower.ffxi.turn(pos.heading)
end

function pos.moveToPoint()
    selfMob = windower.ffxi.get_mob_by_target("me")
    if not state.gambitLeader and pos.dist(pos.moveDestination, selfMob) > .5 then
        pos.moving = true
        pos.heading = pos.getHeadingRadian(selfMob, pos.moveDestination)
        windower.ffxi.turn(pos.heading)
        windower.ffxi.run(pos.heading)
    end
end

function pos.haltOnPoint()
    selfMob = windower.ffxi.get_mob_by_target("me")
    if pos.dist(pos.moveDestination, selfMob) < .5 then
        windower.ffxi.run(false)
    end
end

function pos.getHeadingRadian(mob_a, mob_b)
    return -1*math.atan2((mob_b.y - mob_a.y),(mob_b.x - mob_a.x))
end

function pos.dist(mob_a, mob_b)
    diffX = mob_a.x - mob_b.x
    diffY = mob_a.y - mob_b.y
    squared = (diffX * diffX) + (diffY * diffY)
    return math.sqrt(math.abs(squared))
end

function pos.registerPointMove(key)
    found = false
    for i, k in ipairs(pos.moveRegistry) do
        if k == key then 
            found = true
            break
        end 
    end
    if not found then
        table.insert(pos.moveRegistry, key)
    end
end

function pos.unregisterPointMove(key)
    for i, k in ipairs(pos.moveRegistry) do
        if k == key then 
            table.remove(pos.moveRegistry, i)
            break
        end 
    end
end

return pos