-- # BldBrk - Builds a braking curve based on global variables
--
-- stepped curve in the negative based on global-- --
--
-- Creates a curve something like
--
-- =======================
-- |                     |
-- |                     |
-- |                     |
-- |       ------------- 0
-- |       |             |
-- |   ----              |
-- |   |                 |
-- |---                  |
-- |                     |
-- ========-5=0===========

local find_global_variable = loadScript("/SCRIPTS/LIB/find_global_variable.lua")()

local CRV_TO_FIND = "Br"
local BRAKE_LRG = "BrL"
local BRAKE_CNG = "BrT"
local BRAKE_SML = "BrS"
local BRAKE_DED = -5

local function all_nil_curve(crv)
    for k,v in pairs(crv["y"]) do
        if (v ~= 0) then
            return false
        end
    end
    return true
end

local function find_curve_index(to_find)
    local index = 0
    local first_nil = -1
    while index < 64 do
        local crv = model.getCurve(index)
        if (first_nil == -1) and ((crv == nil) or all_nil_curve(crv)) then
            first_nil = index
        end
        if crv ~= nil then
            if crv.name == to_find then
                return index
            end
        end
        index = index + 1
    end
    return first_nil
end

local function write(curve_name, found_curve_index, found_lrg_index, found_cng_index, found_sml_index)
    print("write(" .. curve_name .. ", " .. found_curve_index .. ", " .. found_lrg_index .. ", " .. found_cng_index .. ", " .. found_sml_index .. ")")
    local flight_mode = getFlightMode()
    local lrg = model.getGlobalVariable(found_lrg_index, flight_mode)
    local sml = model.getGlobalVariable(found_sml_index, flight_mode)
    local cng = model.getGlobalVariable(found_cng_index, flight_mode)
    local crv = {}
    print("lrg=" .. lrg .. ", cng=" .. cng .. ", sml=" .. sml)
    crv["x"] = { -100, cng, cng, BRAKE_DED, BRAKE_DED, 100 }
    crv["y"] = { lrg, lrg, sml, sml, 0, 0 }
    crv["smooth"] = false
    crv["type"] = 1
    crv["name"] = curve_name
    local ret = model.setCurve(found_curve_index, crv)
    -- print("ret = " .. ret)
end

local function build_curve(crv_to_find, brake_lrg, brake_cng, brake_sml)
    local found_curve_index = find_curve_index(crv_to_find)
    if (found_curve_index == -1) then
        return
    end
    local found_min_index = find_global_variable(brake_lrg)
    if (found_min_index == -1) then
        return
    end
    local found_cng_index = find_global_variable(brake_cng)
    if (found_cng_index == -1) then
        return
    end
    local found_max_index = find_global_variable(brake_sml)
    if (found_max_index == -1) then
        return
    end
    write(crv_to_find, found_curve_index, found_min_index, found_cng_index, found_max_index)
end

local function run()
    build_curve(CRV_TO_FIND, BRAKE_LRG, BRAKE_CNG, BRAKE_SML)
end

local function background()
end

local function init()
run()
end

return { run=run, background=background, init=init }
