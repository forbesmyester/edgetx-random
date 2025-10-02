-- GvByTr - Originally Global Variable By Trim, now works with any input
--
-- Create inputs called GVnl where where n is the number of a Global
-- Variable to alter and l is an arbitrary letter, for example GV6a
-- to alter GV6 on input.
--
-- It will alter the global variable by the amount of the input. For 3POS
-- you should set a weight of of the switch to the amount you wish to
-- change the global variable by (use a negative weight to reverse the
-- switch
--
-- You also need to trigger the function somehow, I use a mix which
-- includes all the inputs what I want to use with multiplex set to ADD
-- and then use a Logical Switch attached to a Special Function to run
-- the script


local find_global_variable = loadScript("/SCRIPTS/LIB/find_global_variable.lua")()

local function roundToBoundary(boundary, n)
    return n
    -- if n > 0 then
    --     r = math.ceil(n/boundary) * boundary;
    --     print("B=" .. boundary .. ", N=" .. n .. ", R=" .. r)
    --     return r
    -- end
    -- if n < 0 then
    --     r = math.floor(n/boundary) * boundary;
    --     print("B=" .. boundary .. ", N=" .. n .. ", R=" .. r)
    --     return r
    -- end
    -- return 0;
end

local function abs(n)
    if n < 0 then
        return 0 - n
    end
    return n
end



local function run()
    print("run()")
    print(find_global_variable("NTF"))
    local sourceIndex = 0
    local flightMode = getFlightMode()
    model.setGlobalVariable(find_global_variable("NTF", true), flightMode, -99)
    while sourceIndex < 64 do
        local name = ""
        local rawname = getSourceName(sourceIndex)
        if (rawname ~= nil) then
            name = string.gsub(string.upper(rawname), '%W', '')
        end
        local value = getSourceValue(sourceIndex)
        if (name ~= nil) and (value ~= nil) and (string.sub(string.upper(name),1,2) == "GV") and (string.len(name) >= 3) and (string.len(name) <= 4) and (tonumber(string.sub(name,3,3))) then
            local gvarIndex = tonumber(string.sub(name,3,3)) - 1
            local gvarDetails = model.getGlobalVariableDetails(gvarIndex)
            local gvarValue = model.getGlobalVariable(gvarIndex, flightMode)
            local oldGvarValue = gvarValue
            local controlValue = math.floor((value / 10) + 0.5)
            local newValue = gvarValue + controlValue
            if (newValue < gvarDetails.min) then
                newValue = gvarDetails.min
            end
            if (newValue > gvarDetails.max) then
                newValue = gvarDetails.max
            end
            model.setGlobalVariable(gvarIndex, flightMode, newValue)

            local gvarName = ""
            local gvarDetails = model.getGlobalVariableDetails(gvarIndex)
            if gvarDetails ~= nil then
                gvarName = gvarDetails.name
            end

            if oldGvarValue ~= newValue then
                print("SGV" .. "-" .. find_global_variable("NTF", true) .. "/" .. flightMode .. "/" ..  gvarIndex)
                model.setGlobalVariable(find_global_variable("NTF", true), flightMode, gvarIndex)
            end
        end
        sourceIndex = sourceIndex + 1
    end
    print ("DONE")
end

local function background()
end

local function init()
end

return { run=run, background=background, init=init }
