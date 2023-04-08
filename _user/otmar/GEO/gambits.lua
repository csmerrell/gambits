gambits.lightArts = {
    type = "buff_ja",
    name = "light_arts",
    buffId = 358, -- Check lib/provided/buff to find the buff id.
    target = "self"
}
gambits.darkArts = {
    type = "buff_ja",
    name = "dark_arts",
    buffId = 359, -- Check lib/provided/buff to find the buff id.
    target = "self"
}

gambits.sublimation = {
    type = "special",
    name = "sublimation",
    missingMpThreshold = -1040
}

gambits.protect = {
    type = "buff_enhancing",
    name = "protect3",
    buffId = 40,
    target = "any",
    focus = "either",
    minTargets = 2
}
gambits.shell = {
    type = "buff_enhancing",
    name = "shell2",
    buffId = 41,
    target = "any",
    focus = "either",
    minTargets = 3
}

gambits.cure3 = {
    type = "heal",
    name = "cure3",
    hppThreshold = 45,
    focus = "single",
    target = "any"
}
gambits.cure4 = {
    type = "heal",
    name = "cure4",
    hppThreshold = 68,
    missingHpThreshold = -700,
    focus = "single",
    target = {1,5,4,0,2,3}
}
gambits.accCure4 = {
    type = "heal",
    name = "cure4",
    hppThreshold = 60,
    focus = "multiple",
    minTargets = 3,
    target = "any"
}
gambits.engage = {
    type = "special",
    name = "attack",
    target = "leader_engaged"
}
gambits.exudation = {
    type = "ws",
    name = "exudation"
}
gambits.blizz = {
    type = "black_magic",
    name = "blizzard",
    target = "leader_engaged"
}
gambits.geoRegen = {
    type = "geomancy",
    name = "regen",
    focus = "p2",
    target = {0,2},
    minTargets = 3
}
gambits.geoWilt = {
    type = "geomancy",
    name = "wilt"
}
gambits.geoFrailty = {
    type = "geomancy",
    name = "frailty"
}
gambits.indiRefresh = {
    type = "indicolure",
    name = "refresh",
    target = "all",
    minTargets = 3
}
gambits.indiBarrier = {
    type = "indicolure",
    name = "barrier",
    target = "all",
    minTargets = 3
}
gambits.indiFury = {
    type = "indicolure",
    name = "fury",
    target = "all",
    minTargets = 3
}


gambits.subsets.prot_shell = gambitCombine({
    gambits.protect,
    gambits.shell
})

gambits.default = gambitCombine({
    gambits.lightArts,
    -- gambits.darkArts,
    gambits.sublimation,
    gambits.accCure4,
    gambits.cure4,
    gambits.cure3,
    -- gambits.blizz,
    gambits.geoRegen,
    gambits.indiRefresh
    -- gambits.protect,
    -- gambits.shell,
})