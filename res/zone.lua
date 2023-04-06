zones = require("lib/provided/zone")

zone = {}
zone.reactivateGambits = false
zone.gambitSnapshot = {}

function zone.onChange(newZoneId, oldZoneId)
    if not state.loggedIn and windower.ffxi.get_info().logged_in then
        init()
    end

    if state.loggedIn then
        zone.setZone(newZoneId)
        if state.currentZone.safe then
            if tick.on then
                if gambits.city then
                    gambitOverride = gambitCopy(gambits.city)
                    display.showOverride(gambitOverride)
                    out.msg("[Gambits]: Using city gambits while in safe zone.")
                else 
                    zone.reactivateGambits = true
                    tick.on = false
                    display.box:text(display.getText())
                    out.msg("[Gambits]: Disabled execution in safe zone. Gambits will resume automatically when zoning into a non-safe zone.")
                end
            end
        else
            gambitOverride = nil
            display.showOverride(false)
            if zone.reactivateGambits then
                tick.on = zone.reactivateGambits
                zone.reactivateGambits = false
                out.msg("[Gambits]: In a non-safe zone. Resuming Gambits.")
                display.box:text(display.getText())
            end
        end
    end
end

function zone.setZone(zoneId)
    state.currentZone = zones[zoneId]
    state.currentZone.safe = not state.currentZone.can_pet
end

windower.register_event("zone change", zone.onChange)

return zone