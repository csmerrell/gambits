pos = {}

pos.moving = false
pos.playerMoving = false
pos.isFollowing = true
if settings.autoFollow ~= nill and not settings.autoFollow then
    pos.isFollowing = false
end
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
pos.lastPos = { x = m.x, y = m.y }

function pos.move()
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
    elseif pos.isFollowing then 
        pos.haltFollow()
    end
end

function pos.handleLeaderSwaps()
    if state.gambitLeader and not pos.snapshot.gambitLeader then
        pos.snapshot = {
            gambitLeader = true,
            isFollowing = pos.isFollowing
        }
        pos.isFollowing = false
        pos.moveDestination = false
    elseif not state.gambitLeader and pos.snapshot.gambitLeader then
        pos.isFollowing = pos.snapshot.isFollowing
        pos.snapshot = {}
    end
end

pos.restoreTick = false
function pos.isIdle()
    selfMob = windower.ffxi.get_mob_by_target("me")
    if not selfMob then return end
    if pos.lastPos.x == selfMob.x and pos.lastPos.y == selfMob.y then
        pos.moving = false
        pos.playerMoving = false
        if os.clock() - pos.lastMovementTime > 900 then
            if tick.on then
                pos.restoreTick = true
                tick.on = false
                out.msg("[Gambits]: No movement in 15 minutes. Disabling Gambits. Will resume automatically when returning.")
                display.box:text(display.getText())
            end
        end
    else
        pos.moving = true
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

function pos.follow()
    pos.followEntity = nil
    if pos.followTarget then
        pos.followEntity = windower.ffxi.get_party()[pos.followTarget]
    else
        party = windower.ffxi.get_party()
        for key, p in pairs(party) do
            if type(p) == "table" and p.mob and p.mob.id == state.gambitLeaderId then
                pos.followEntity = p
            end
        end
    end

    selfEnt = windower.ffxi.get_party()['p0']
    if pos.followEntity == nil or pos.followEntity.zone ~= selfEnt.zone then return end

    followMob = pos.followEntity.mob
    selfMob = selfEnt.mob
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
        windower.ffxi.run(pos.heading)
    elseif pos.moving and settings.followFanRadian and dist < distThreshold + 1 and dist < pos.maxThreshold then
        pos.heading = pos.getHeadingRadian(selfMob, followMob) + settings.followFanRadian
        if pos.heading > math.pi then 
            pos.heading = pos.heading - 2 * math.pi
        elseif pos.heading < -1 * math.pi then 
            pos.heading = pos.heading + 2 * math.pi 
        end
        windower.ffxi.run(pos.heading)
    elseif settings.followFanRadian then
        pos.fanParty(followMob)
    end
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
    if not pos.playerMoving and (dist < distThreshold or dist > pos.maxThreshold) then
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
            windower.ffxi.turn(pos.getHeadingRadian(selfMob,followMob))
            windower.ffxi.run(false)
        end
    end
end

function pos.targetOffsetPoint(target, dist, offset)
    local a = math.atan2(target.y, target.x)

    a = a + (target.facing - math.pi)

    local new_x = target.x - dist * math.cos(a + offset)
    local new_y = target.y - dist * math.sin(a + offset)

    return { x = new_x, y = new_y }
end

function pos.stayEngaged()
    target = windower.ffxi.get_mob_by_target("t")
    selfMob = windower.ffxi.get_party()['p0'].mob
    dist = pos.dist(selfMob, target)
    if not pos.playerMoving and dist > 1.8 then
        pos.moving = true
        pos.heading = pos.getHeadingRadian(selfMob, target)
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

function pos.moveToPoint()
    selfMob = windower.ffxi.get_mob_by_target("me")
    if not pos.playerMoving and pos.dist(pos.moveDestination, selfMob) > .5 then
        pos.moving = true
        pos.heading = pos.getHeadingRadian(selfMob, pos.moveDestination)
        windower.ffxi.run(pos.heading)
    end
end

function pos.haltOnPoint()
    selfMob = windower.ffxi.get_mob_by_target("me")
    if pos.dist(pos.moveDestination, selfMob) < .5 then
        windower.ffxi.run(false)
    end
end

function pos.faceTarget(mob_a, mob_b)
    windower.ffxi.turn(pos.getHeadingRadian(mob_a, mob_b))
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

pos.moveDestination = nil
pos.maxNumInRadius = nil
function pos.moveToCenter(targets, targetRadius)
    if not pos.moveDestination or pos.dist(pos.moveDestination, selfMob) > 2 then
        bestCenter = pos.findCenter(targets, targetRadius)
        pos.moveDestination = bestCenter.center
        pos.maxNumInRadius = bestCenter.numInRadius
        out.logTable(pos.moveDestination)
        return 0
    else
        return pos.maxNumInRadius
    end
end

function pos.cancelPointMove()
    pos.moveDestination = nil
end

function pos.findCenter(targets, radius)
    local maxInRadius = 0
    local centerPoint = nil
    
    if #targets == 1 then
        return { center = { x = targets[1].x, y = targets[1].y }, numInRadius = 1 }
    end

    for i = 1, #targets do
        for j = i+1, #targets do
            -- Calculate the center point between points[i] and points[j]
            local center_x = (targets[i].x + targets[j].x) / 2
            local center_y = (targets[i].y + targets[j].y) / 2
            localCenter = {x = center_x, y = center_y}

            -- Count the number of points within the radius
            local numInRadius = pos.targetsInRadius(localCenter, targets, radius)
            
            -- Update the max_points_within_radius and center_point if necessary
            if numInRadius > maxInRadius then
                maxInRadius = numInRadius
                centerPoint = localCenter
            end
        end
    end
    out.logTable(centerPoint)
    return { center = centerPoint, numInRadius = maxInRadius }
end

function pos.targetsInRadius(center, targets, radius)
    num = 0
    for k = 1, #targets do
        local distance = math.sqrt((targets[k].x - center.x)^2 + (targets[k].y - center.y)^2)
        if distance <= radius then
            num = num + 1
        end
    end
    return num
end

return pos