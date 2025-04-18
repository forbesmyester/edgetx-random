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


local GV_TO_RECORD_CHANGE=8 -- Base 0

local function find_global_variable(to_find)

    if to_find == "NTF" then
        return 2
    end

    local index = 0
    while index < 64 do
        local gvd = model.getGlobalVariableDetails(index)
        if gvd ~= nil then
            if gvd.name == to_find then
                return index
            end
        end
        index = index + 1
    end
    return -1
end


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
    local index = 0
    local flightMode = getFlightMode()
    local done = false
    while index < 64 do
        local name = ""
        local rawname = getSourceName(index)
        if (rawname ~= nil) then
            name = string.gsub(string.upper(rawname), '%W', '')
        end
        local value = getSourceValue(index)
        if (name ~= nil) and (value ~= nil) and (string.sub(string.upper(name),1,2) == "GV") and (string.len(name) >= 3) and (string.len(name) <= 4) and (tonumber(string.sub(name,3,3))) then
            local gvarNumber = tonumber(string.sub(name,3,3)) - 1
            local gvarValue = model.getGlobalVariable(gvarNumber, flightMode)
            local oldGvarValue = gvarValue
            local controlValue = math.floor((value / 10) + 0.5)
            local gvarValue = roundToBoundary(abs(controlValue), gvarValue)
            local newValue = gvarValue + controlValue
            model.setGlobalVariable(gvarNumber, flightMode, newValue)
            local gvarSetValue = model.getGlobalVariable(gvarNumber, flightMode)
            print("CURRENT GVAR = " .. gvarNumber + 1 .. ", ROUNDED = " .. gvarValue .. ", CONTROL = " .. controlValue .. " : " .. oldGvarValue.. " -> " .. newValue .. " = " .. gvarSetValue)

            if oldGvarValue ~= gvarValue then
                -- playNumber(gvarValue, 0)
                model.setGlobalVariable(GV_TO_RECORD_CHANGE, flightMode, gvarNumber)
            end
            done = true
        end
        index = index + 1
    end
    print ("DONE")
    -- if done == true then
    --     local gv = find_global_variable("NTF")
    --     if (gv == -1) then
    --         print("Could not find global variable NTF")
    --         print("GvByTr: NTF Not Found")
    --         return true
    --     end
    --     local ls = model.getGlobalVariable(gv, flightMode)
    --     setSticky(ls, true)
    -- end
end

local function background()
end

local function init()
end

return { run=run, background=background, init=init }
