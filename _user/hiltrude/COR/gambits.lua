-- Common Roll Settings --
gambits.samurai = {
    type = "roll",      -- Required
    name = "samurai",   -- "First word of any roll's name"
    target = "any",     -- OPTIONAL 
                            -- valid values:  
                                -- "any" - Use rolls anytime the corsair loses them, regardless if allies are in range or not.
                                -- "all" - Only use rolls when all party members are in range.
                                -- {0,1,2,3,4,5} (any subset of party indices) - Wait for the specified party members to be in range.
                            -- default: "any"
}
gambits.chaos = {
    type = "roll",
    name = "chaos",
    target = "any"
}
gambits.wizard = {
    type = "roll",
    name = "wizard",
}
gambits.bolter = {
    type = "roll",
    name = "bolter",
}
gambits.dancer = {
    type = "roll",
    name = "dancer",
}
gambits.corsair = {
    type = "roll",
    name = "corsair"
}
gambits.attack = {
    type = "special",
    name = "attack",
    target = "leader_target"
}
gambits.sb = {
    type = "ws",
    name = "savage_blade",
    tpThreshold = 1000,
    behavior = "burn"
}
gambits.ls = {
    type = "ws",
    name = "leaden_salute",
    tpThreshold = 1000,
    behavior = "burn"
}


-- Common Roll Combos --
gambits.subsets.sam_chaos = {}
gambits.subsets.sam_chaos[1] = gambitAdjust(gambits.samurai, {
    crooked = true
})
gambits.subsets.sam_chaos[2] = gambits.chaos

gambits.subsets.bolter_dancer = {}
gambits.subsets.bolter_dancer[1] = gambitAdjust(gambits.bolter, {
    crooked = true
})
gambits.subsets.bolter_dancer[2] = gambits.dancer

gambits.default = gambitCombine({
    gambits.samurai,
    gambits.chaos,
    gambits.attack,
    gambits.sb
})