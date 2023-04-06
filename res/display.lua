texts = require("texts")

display = {}

function display.getText(displayGambits)    
    if settings.windowVisible ~= nil and settings.windowVisible == false then return end

    if not displayGambits then
        displayGambits = activeGambits
    end

    on = "Off"
    if tick.on then on = "On" end
    text = string.format("== Gambits: [%s] ==\n", on)

    if state.gambitLeader then
        text = text.."== Gambit Leader ==\n"
    end

    if pos.followEntity then
        if pos.followEntity.mob then
            if pos.isFollowing then
                text = text.."Following:  "..pos.followEntity.name..'\n' 
            else
                text = text.."[x] Following (inactive):  "..pos.followEntity.name..'\n' 
            end
        else            
            text = text.."[x] Follow:  @"..pos.followEntity.name.." not in zone.\n"
        end
    else
        text = text.."[x] Follow target not found.\n"
    end

    text = text.."\n"

    for i, gambit in ipairs(displayGambits) do
        targetText = gambit.target
        if targetText == "t" then
            targetText = "Current target"
        end

        if type(gambit.target) == "table" then
            targetText = out.stringifyTableLite(gambit.target)
        end
        if gambit.displayFull then
            text = text..""..string.format('[%s]:   %s\n', i, gambit.displayFull)
        else
            text = text..""..string.format('[%s]:   %s   >   %s\n', i, gambit.displayName, targetText)
        end
    end
    return text
end

display.box = texts.new(display.getText(), settings)
display.box:show()

override = {}
override.settings = settings
override.settings.pos.x = settings.pos.x - 150
override.box = texts.new(nil, settings)

function display.showOverride(overrideSet)
    if (settings.windowVisible ~= nil and not settings.windowVisible) or not overrideSet then 
        override.box:text(nil, override.settings) 
        return
    end

    override.box:text(display.getText(gambitOverride), override.settings)
    override.box:show()
end

return display