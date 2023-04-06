spellEvals = {}

function spellEvals.canCast(spell)
    if pos.moving then return false end

    knownSpells = windower.ffxi.get_spells()
    if not knownSpells[spell.id] then return false end

    if spell.mp_cost > player.mp then return false end

    if not cd.spellReady(spell.recast_id) then return false end

    return true
end

function spellEvals.checkMp(gambit)
    if gambit.mppThreshold and gambit.mppThreshold > player.mpp then return false end

    if gambit.mpThreshold and gambit.mpThreshold > player.mp then return false end

    return true
end

return spellEvals