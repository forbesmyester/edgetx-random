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

local REAL= true
local CRV_TO_FIND = "Br"
local CRV_TO_FIND_LRG = "BrL"
-- Value, Transition, Value, Transition, Value - If string, gets value from gvar of name
local BRAKE_POINTS = { "BrL", "BrT", "BrS", -5, 0 }
local BRAKE_POINTS_LRG = { -100, "BrT", 0 }
local BRAKE_LRG = "BrL"
local BRAKE_CNG = "BrT"
local BRAKE_SML = "BrS"
local BRAKE_DED = -5

function table_length(tab)
    local c = 0
    local _
    for _ in pairs(tab) do c = c + 1 end
    return c
end

function table_insert(tab, line)
    local n = table_length(tab)
    tab[n+1] = line
    return tab
end


local function myGetFlightMode()
    if REAL then
        return getFlightMode()
    end
    return 1
end

local function getGlobalVariable(index, fm)
    if REAL then
        return model.getGlobalVariable(index, fm)
    end
    if index == 2 then
        return 75
    end
    if index == 3 then
        return 95
    end
    if index == 4 then
        return 30
    end
end

local function getGlobalVariableDetails(index)
    if REAL then
        return model.getGlobalVariableDetails(index)
    end
    if index == 1 then
        return { name = "___" }
    end
    if index == 2 then
        return { name = "BrL" }
    end
    if index == 3 then
        return { name = "BrT" }
    end
    if index == 4 then
        return { name = "BrS" }
    end
    return nil
end

local function setGlobalVariableDetails(last_unnamed, x)
    if REAL then
        return model.setGlobalVariableDetails(last_unnamed, x)
    end
    return model.setGlobalVariableDetails(last_unnamed, x)
end

local function getCurve(index)
    if REAL then
        return model.getCurve(index)
    end
    local c = { y = {}, }
    return c
end

local function setCurve(index, crv)
    print("setCurve: " .. index .. ": " .. dump_table(crv))
    if REAL then
        return model.setCurve(index, crv)
    end
end

local function find_global_variable(to_find, should_create)
    if REAL then
        local f = loadScript("/SCRIPTS/LIB/find_global_variable.lua")()
        f(to_find, should_create)
    end
    local index = 0
    local last_unnamed = -1
    while index <= 8 do
        local gvd = getGlobalVariableDetails(index)
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
        setGlobalVariableDetails(last_unnamed, { name=to_find })
    end
    return -1
end



-- ---------------------------------------------

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
        local crv = getCurve(index)
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


function dump_table(o, escSpec, indent)
  if type(o) == 'table' then
     local s = '{ '
     for k,v in pairs(o) do
        if type(k) ~= 'number' then k = '"'..k..'"' end
        local vout = ""
        if type(o) == 'table' then
            vout = dump_table(v, escSpec)
        end
        s = s .. '['..k..'] = ' .. vout .. ','
     end
     return s .. '} '
  else
     return tostring(o)
  end
end

local function write(curve_name, found_curve_index, brake_points)
    -- print("write(" .. curve_name .. ", " .. found_curve_index .. ", " .. found_lrg_index .. ", " .. found_cng_index .. ", " .. found_sml_index .. ")")
    local crv = {}
    -- print("lrg=" .. lrg .. ", cng=" .. cng .. ", sml=" .. sml)
    -- crv["x"] = { -100, cng, cng, BRAKE_DED, BRAKE_DED, 100 }
    -- crv["y"] = { lrg, lrg, sml, sml, 0, 0 }
    crvx = { -100 }
    crvy = {}
    for n, x in pairs(brake_points) do
        if math.fmod(n, 2) == 1 then
            table_insert(crvy, x)
            table_insert(crvy, x)
        else
            table_insert(crvx, x)
            table_insert(crvx, x)
        end
    end
    table_insert(crvx, 100)
    crv["x"] = crvx
    crv["y"] = crvy
    crv["smooth"] = false
    crv["type"] = 1
    crv["name"] = curve_name
    print(curve_name .. ": " .. dump_table(crv, "", " "))
    local ret = setCurve(found_curve_index, crv)
end

local function convert(tab, flight_mode)
    local r = {}
    for _, x in pairs(tab) do
        local t = type(x)
        v = x
        if t == "string" then
            local pos = find_global_variable(x)
            if pos == -1 then
                return {}
            end
            v = getGlobalVariable(pos, flight_mode)
        end
        r = table_insert(r, v)
    end
    return r
end

local function build_curve(crv_to_find, crv_to_find_lrg)
    local flight_mode = myGetFlightMode()
    local found_curve_index = find_curve_index(crv_to_find)
    local found_curve_lrg_index = find_curve_index(crv_to_find_lrg)
    if (found_curve_index == -1) then
        return
    end
    local brake_values = convert(BRAKE_POINTS, flight_mode)
    local brake_values_lrg = convert(BRAKE_POINTS_LRG, flight_mode)
    if table_length(brake_values) == 0 or table_length(brake_values_lrg) == 0 then
        return
    end
    write(crv_to_find, found_curve_index, brake_values)
    write(crv_to_find_lrg, found_curve_lrg_index, brake_values_lrg)
end

local function run()
    build_curve(CRV_TO_FIND, CRV_TO_FIND_LRG)
end


-- -- local expected = { ["x"] = { [1] = -100,[2] = 95,[3] = 95,[4] = -5,[5] = -5,[6] = 100,} ,["name"] = Br,["type"] = 1,["y"] = { [1] = 75,[2] = 75,[3] = 30,[4] = 30,[5] = 0,[6] = 0,} ,["smooth"] = false,}
-- build_curve(CRV_TO_FIND, BRAKE_LRG, BRAKE_CNG, BRAKE_SML)

local function background()
end

local function init()
run()
end


local function build_brake_points()
    local function getGlobalVariableDetails(index)
        if index == 1 then
            return { name = "___" }
        end
        if index == 2 then
            return { name = "Br2" }
        end
        if index == 3 then
            return { name = "Bt1" }
        end
        if index == 4 then
            return { name = "Br1" }
        end
        if index == 5 then
            return { name = "Bt2" }
        end
        return nil
    end

    local function getit(index)
        local gvd = getGlobalVariableDetails(index)
        if gvd == nil then
            return ""
        end
        return gvd.name
    end

    local function remove_last(tab)
        local ret = {}
        local last = ""
        local first = true
        for _, x in pairs(tab) do
            if first == false then
                ret = table_insert(ret, last)
            end
            first = false
            last = x
        end
        return ret
    end

    local tab = {}
    local idx_seek = 0
    local found = false
    local idx_gv = 0
    while idx_seek <= 8 do
        idx_seek = idx_seek + 1
        found = false
        idx_gv = 0
        while idx_gv <= 8 do
            if getit(idx_gv) == "Br" .. idx_seek then
                tab = table_insert(tab, "Br" .. idx_seek)
                found = true
            end
            idx_gv = idx_gv + 1
        end
        if found == false then
            return remove_last(tab)
        end
        found = false
        idx_gv = 0
        while idx_gv <= 8 do
            if getit(idx_gv) == "Bt" .. idx_seek then
                tab = table_insert(tab, "Bt" .. idx_seek)
                found = true
            end
            idx_gv = idx_gv + 1
        end
        if found == false then
            return tab
        end
    end
end

local tab = build_brake_points()
print(dump_table(tab))



return { run=run, background=background, init=init }
