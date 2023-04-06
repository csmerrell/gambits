texts = require('texts')

cor_status = texts.new(display_box(),settings.text,setting)
cor_status:show()

function display_box()
    local str = '\n AoE:'
    for slot in party_slots:it() do
        local name = (windower.ffxi.get_mob_by_target(slot) or {name=''}).name

        str = str..'\n <%s> [%s] %s':format(slot, settings.aoe[slot] and 'On' or 'Off', name)
    end
    return 'AutoCOR [O%s]\nRoll 1 [%s]\nRoll 2 [%s]':format(actions and 'n' or 'ff',settings.roll[1],settings.roll[2]) .. str
end

