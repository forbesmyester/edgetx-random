local GV_TO_RECORD_CHANGE=8 -- Base 0


local function run()
    print("run()")
    local flightMode = getFlightMode()
    local toReadGvar = model.getGlobalVariable(GV_TO_RECORD_CHANGE, flightMode)
    local gvarValue = model.getGlobalVariable(toReadGvar, flightMode)
    playNumber(gvarValue, 0)
end

local function background()
end

local function init()
end

return { run=run, background=background, init=init }
