stringExt = require("util/string")

spells = require("lib/provided/spell")
spellAliases = require("lib/alias/spell")
buffs = require("lib/provided/buff")

GEO = {}
GEO.buffs = {
    regen = 539,
    refresh = 541,
    haste = 580,
    str = 542,
    dex = 543,
    vit = 544,
    agi = 545,
    int = 546,
    mnd = 547,
    chr = 548,
    fury = 549,
    barrier = 550,
    acumen = 551,
    fend = 552,
    precision = 553,
    voidance = 554,
    focus = 555,
    attunement = 556
}

GEO.debuffs = {
    poison = 540,
    wilt = 557,
    frailty = 558,
    fade = 559,
    malaise = 560,
    slip = 561,
    torpor = 562,
    vex = 563,
    languour = 564,
    slow = 565,
    paralysis = 566,
    gravity = 567
}

GEO.geoSpells = {}
for i=798, 827 do
    postfix = stringExt.split(spells[i].en, "-")[2]:lower()
    GEO.geoSpells[postfix] = {
        spellId = i,
        spell = spells[i],
        name = spells[i].en,
        shortname = postfix,
        recastId = spells[i].recast_id
    }
    if GEO.buffs[postfix] then
        GEO.geoSpells[postfix].isBuff = true
        GEO.geoSpells[postfix].buffId = GEO.buffs[postfix] 
    else
        GEO.geoSpells[postfix].isBuff = false
        GEO.geoSpells[postfix].debuffId = GEO.debuffs[postfix] 
    end
end


GEO.indiSpells = {}
for i=768, 797 do
    postfix = stringExt.split(spells[i].en, "-")[2]:lower()
    GEO.indiSpells[postfix] = {
        spellId = i,
        spell = spells[i],
        name = spells[i].en,
        shortname = postfix,
        recastId = spells[i].recast_id
    }
    if GEO.buffs[postfix] then
        GEO.indiSpells[postfix].isBuff = true
        GEO.indiSpells[postfix].buffId = GEO.buffs[postfix] 
    else
        GEO.indiSpells[postfix].isBuff = false
        GEO.indiSpells[postfix].debuffId = GEO.debuffs[postfix] 
    end        
end

GEO.jaBuffs = {
    bolster = 513,
    lastingEmanation = 515,
    eclipticAttrition = 516,
    dematerialize = 517,
    blazeOfGlory = 569,
    entrust = 584
}

GEO.jaRecast = {
    fullCircle = 345,
    lastingEmanation = 346,
    eclipticAttrition = 347,
    lifeCycle = 349,
    blazeOfGlory = 350,
    dematerialize = 351,
    mendingHalation = 352,
    radialArcana = 353
}

GEO.indiActiveId = 612
GEO.bubbleRange = 6

require('lists')
function GEO.getTargetMobs(gambit)
    targetIndices = L{0,1,2,3,4,5}
    if type(gambit.target) == "table" then
        targetIndices = L{unpack(gambit.target)}
    end

    targets = {}
    party = windower.ffxi.get_party()
    for key,p in pairs(party) do
        if type(p) == "table" and p.mob and targetIndices:contains(tonumber(key:sub(2,2))) then
            table.insert(targets, p.mob)
        end
    end

    return targets
end

return GEO