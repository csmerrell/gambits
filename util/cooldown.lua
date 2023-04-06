cd = {}

function cd.spellReady(spellCooldownId)
    return windower.ffxi.get_spell_recasts()[spellCooldownId] == 0
end

function cd.abilityReady(abilityCooldownId)
    return windower.ffxi.get_ability_recasts()[abilityCooldownId] == 0
end

function cd.stratagemReady()
    pl = windower.ffxi.get_player()
    if pl.main_job == "SCH" and pl.main_job_level < 10 then
        return false
    elseif pl.sub_job ~= "SCH" or pl.sub_job_level < 10 then 
        return false
    end

    stratagemRecastId = 231
    chargeTime = 240
    maxCooldown = chargeTime
    sch_job = "main_job"
    if pl.sub_job == "SCH" then
        sch_job = "sub_job"
    end
    
    if pl.main_job == "SCH" and pl.job_points.sch.jp_spent > 550 then
        chargeTime = 33
        maxCooldown = chargeTime * 5
    elseif pl[sch_job.."_level"] > 90 then
        chargeTime = 48
        maxCooldown = chargeTime * 5
    elseif pl[sch_job.."_level"] > 70 then
        chargeTime = 60
        maxCooldown = chargeTime * 4
    elseif pl[sch_job.."_level"] > 50 then
        chargeTime = 80
        maxCooldown = chargeTime * 3
    elseif pl[sch_job.."_level"] > 30 then
        chargeTime = 120
        maxCooldown = chargeTime * 2
    end

    return windower.ffxi.get_ability_recasts()[stratagemRecastId] < maxCooldown - chargeTime
end

return cd