local function find_global_variable(to_find, should_create)
    local index = 0
    local last_unnamed = -1
    while index <= 8 do
        local gvd = model.getGlobalVariableDetails(index)
        if gvd ~= nil then
            if gvd.name == to_find then
                return index
            end
            if gvd.name == "" then
                last_unnamed = index
            end
        else
            last_unnamed = index
        end
        index = index + 1
    end
    if should_create then
        model.setGlobalVariableDetails(last_unnamed, { name=to_find })
    end
    return -1
end

return find_global_variable

