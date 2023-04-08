targeting = {}

function targeting.angularSweepFit(focusTarget, targets, r)
    if #targets == 0 then
        return {
            targetPoint = { x = focusTarget.x, y = focusTarget.y },
            numInRange = 1
        }
    elseif #targets == 1 then
        if math.abs(targeting.dist(targets[1], focusTarget)) < (2 * r) then
            return {
                targetPoint = {
                    x = (targets[1].x + focusTarget.x) / 2,
                    y = (targets[1].y + focusTarget.y) / 2    
                },
                numInRange = 2 -- target, focusTarget
            }
        else
            return {
                targetPoint = { x = focusTarget.x, y = focusTarget.y },
                numInRange = 1
            }
        end
    end
    -- Define the angular resolution of the sweep
    local resolution = math.pi / 4 -- 45deg sweep in radians
    
    -- Sweep through all angles, finding the centroid with the most targets within radius r
    local bestCentroid = { x = focusTarget.x, y = focusTarget.y }
    local targetsInBest = {}
    for angle = 0, 2 * math.pi, resolution do -- maximum of 8 iterations
        -- Calculate the centroid for the current angle
        local centroid = targeting.centroidProjection(focusTarget, r, angle)
        local fittedTargets = {}
        for i, target in ipairs(targets) do -- Maximum of 4 iterations (won't include focus target, won't include self)
            if math.abs(targeting.dist(centroid, target)) <= r then
                table.insert(fittedTargets, target)
            end
        end
        if #fittedTargets > #targetsInBest then
            targetsInBest = fittedTargets

            if #targetsInBest == #targets then break end
        end
    end
    
    -- Unnormalize the best centroid and return it
    for i = 1, #targetsInBest do
        bestCentroid.x = bestCentroid.x + targetsInBest[i].x
        bestCentroid.y = bestCentroid.y + targetsInBest[i].y
    end

    bestCentroid.x = bestCentroid.x / (#targetsInBest + 1)
    bestCentroid.y = bestCentroid.y / (#targetsInBest + 1)
    
    return {
        targetPoint = bestCentroid,
        numInRange = #targetsInBest + 1 -- packedTargets + focus target
    }
end

function targeting.centroidProjection(origin, radius, theta)
    local new_x = origin.x + radius * math.cos(theta)
    local new_y = origin.y + radius * math.sin(theta)

    return { x = new_x, y = new_y }
end

function targeting.getFocusTarget(gambit)
    party = windower.ffxi.get_party()
    local validFocus = L{"p1","p2","p3","p4","p5"}

    focusTarget = nil
    if state.gambitLeaderId and not gambit.focus or gambit.focus == "leader" then
        focusTarget = windower.ffxi.get_mob_by_id(state.gambitLeaderId)
    elseif validFocus:contains(gambit.focus) then
        focusTarget = party[gambit.focus].mob
    else
        for i, p in ipairs(party) do
            if p.mob and p.name == gambit.focus then
                out.msg("hello")
                focusTarget = p.mob
            end
        end
    end

    if not focusTarget then
        focusTarget = windower.ffxi.get_mob_by_target("p0")
    end

    return focusTarget
end

function targeting.getPartyTableTargets(gambit, skipIds)
    targetIndices = L{0,1,2,3,4,5}
    if gambit.target and type(gambit.target) == "table" then
        targetIndices = L{unpack(gambit.target)}
    end

    targets = {}
    party = windower.ffxi.get_party()
    for key,p in pairs(party) do
        if type(p) == "table" and p.mob and targetIndices:contains(tonumber(key:sub(2,2))) and (not skipIds or not skipIds:contains(p.mob.id)) then
            table.insert(targets, p.mob)
        end
    end

    return targets
end

function targeting.targetsInRange(origin, targets, r)
    count = 0
    for i = 1, #targets do
        if math.abs(targeting.dist(targets[i], origin)) < r then
            count = count + 1
        end
    end

    return count
end

function targeting.dist(target_a, target_b)
    diffX = target_a.x - target_b.x
    diffY = target_a.y - target_b.y
    squared = (diffX * diffX) + (diffY * diffY)
    return math.sqrt(math.abs(squared))
end

return targeting