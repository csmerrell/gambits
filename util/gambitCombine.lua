function gambitCombine(gambitSets)
    result = {}
    for i, gambitSet in pairs(gambitSets) do
        if gambitSet.type then
            table.insert(result, gambitSet)
        else
            for i, gambit in pairs(gambitSet) do
                table.insert(result, gambit)
            end
        end
    end
    return result
end

return gambitCombine