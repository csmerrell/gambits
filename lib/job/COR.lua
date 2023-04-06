rolls = require("lib/provided/roll")
rollAliases = require("lib/alias/roll")

COR = {}
COR.rolls = rolls
COR.rollAliases = rollAliases

COR.doubleUpBuffId = 308
COR.bustBuffId = 309
COR.snakeEyeBuffId = 357

COR.rollRecastId = 193
COR.doubleUpRecastId = 194
COR.snakeEyeRecastId = 197
COR.foldRecastId = 198

COR.rollRange = 8
do
    local equippable_bags = {'Inventory','Wardrobe','Wardrobe2','Wardrobe3','Wardrobe4'}

    for _, bag in ipairs(equippable_bags) do
        local items = windower.ffxi.get_items(bag)
        if items.enabled then
            for i,v in ipairs(items) do
                if v.id == 15810 then
                    COR.rollRange = 16
                end
            end
        end
    end
end

return COR