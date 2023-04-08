texts = require("texts")

display = {}

function display.getText(displayGambits)    
    if settings.windowVisible ~= nil and settings.windowVisible == false then return end

    if not displayGambits then
        displayGambits = activeGambits
    end

    on = "Off"
    if tick.on then on = "On" end

    text = ""
    if state.gambitLeader then
        text = string.format("== Gambits (Leader): [%s] ==\n", on)
    else
        text = string.format("== Gambits: [%s] ==\n", on)
    end

    if pos.followEntity then
        if pos.isFollowing then
            if pos.followEntity.mob then
                text = text.."Following:  "..pos.followEntity.name..'\n' 
            else            
                text = text.."[x] Follow:  @"..pos.followEntity.name.." not in zone.\n"
            end
        end
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
override.box = texts.new(nil, override.settings)

function display.showOverride(overrideSet)
    if (settings.windowVisible ~= nil and not settings.windowVisible) or not overrideSet then 
        override.box:text(nil, override.settings) 
        return
    end

    override.box:text(display.getText(gambitOverride), override.settings)
    override.box:show()
end

return display