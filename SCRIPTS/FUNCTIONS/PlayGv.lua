local GV_TO_RECORD_CHANGE="NTF" -- Base 0
local find_global_variable = loadScript("/SCRIPTS/LIB/find_global_variable.lua")()


local function run()
    print("run()")
    local flightMode = getFlightMode()
    local toReadGvar = model.getGlobalVariable(find_global_variable(GV_TO_RECORD_CHANGE, true), flightMode)
    if toReadGvar ~= -99 then
        local gvarValue = model.getGlobalVariable(toReadGvar, flightMode)
        playNumber(gvarValue, 0)
    else
        playTone(550, 50, 20, 0, -10, 4)
    end
end

local function background()
end

local function init()
end

return { run=run, background=background, init=init }
