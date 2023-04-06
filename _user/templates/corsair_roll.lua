-- Roll Priorities --
gambits.default = {}
gambits.default[0] = {
    type = "roll",
    name = "samurai",   -- "First word of any roll's name"
    priority = 1        -- 1|2, lower number will take priority in the event of a bust
    target = "all",     -- OPTIONAL 
                            -- values:  "all", [0,1,2,3,4,5] (any subset of party indices)
                            -- default: "all"
    crooked = true      -- OPTIONAL
                            -- default: false
}
gambits.default[1] = {
    type = "roll",
    name = "chaos",
    priority = 2,
    target = [0,1,4]
}

return gambits