eval = require("gambits/eval/index")

tick = {}

-- Tick Timer values
tick.on = false
tick.nextTickTime = os.clock()
tick.microTickDelay = .1
tick.globalTickDelay = 0.5
tick.tickDelay = tick.globalTickDelay
tick.spellcastBufferDelay = 2.75
tick.jaDelay = 1
tick.wsDelay = 2
tick.cooldown = 0

-- Check if it's time to activate a gambit tick on every windower prerender tick
windower.register_event('prerender',function ()
    local currentTime = os.clock()
    if tick.nextTickTime + tick.microTickDelay <= currentTime then
        -- Micro ticks ONLY assess stopping criteria for movement, that way movement can be halted at more precise intervals.
        -- This prevents awkward habits of over-stepping a goal point, then doubling back.
        pos.halt()
    end
    if tick.nextTickTime + tick.tickDelay <= currentTime then
        tick.nextTickTime = currentTime

        -- Remove any dead targets from considerations; Pop any weapons skills no longer in their SC window
        state.prune()

        if windower.ffxi.get_player().vitals.hpp == 0 then return end
        -- Handle positioning (based on a follow target)
        pos.move()

        -- state.log()

        pl = windower.ffxi.get_player()
        if tick.on and pl.vitals.hpp > 0 then
            tick.cooldown = tick.cooldown - tick.tickDelay
            if tick.cooldown <= 0 then
                if gambitOverride then
                    for i, gambit in ipairs(gambitOverride) do
                        tick.cooldown = eval(gambit)  
                        
                        if tick.cooldown > 0 then break end
                    end
                else
                    for i, gambit in ipairs(activeGambits) do
                        tick.cooldown = eval(gambit) 
                        if tick.cooldown > 0 then break end
                    end
                end
            end
        end
    end
end)

return tick