local toolName = "TNS|FltChk|TNE"


local function init()
    lcd.clear()
end

function process_worker(str)
    local tab = {}
    local line
    while #str > 0 do
        line, str = to_char("\n", str)
        local k, v = to_char("=", skip_first_spaces(line))
        if skip_first_spaces(k) == "END" then
            return tab, str
        elseif skip_first_spaces(v) == "" then
            v, str = process_worker(str)
        end
        if string.match(k, '^[0-9]+$') then
            k = tonumber(k)
        end
        if type(v) == "table" then
            tab[k] = v
        else
            tab[k] = typeify(v)
        end
    end
    return tab, str
end


local function get_start_contents(filename)
    local f = io.open(filename, "r")
    local s = ""
    read_data = io.read(f, 255)
    s = s .. read_data
    io.close(f)
    return s
end


function to_char(c, str)
    local i
    i = string.find(str, c, 1, true)
    if i == nil then
        return str, ""
    end
    return string.sub(str, 1, i-1), string.sub(str, i+1)
end

local function get_name(str)
    local tab = {}
    local line
    local start = false
    local found = ""
    local quote = ""
    while #str > 0 do
        line, str = to_char("\n", str)
        found = string.match(line, "[\t  ]*name:[\t ]*")
        if (found ~= nil) then
            found = string.sub(line, #found + 1)
            return string.match(found,"[A-Za-z0-9].*[A-Za-z0-9]")
        end
    end
    return ""
end

function write_str(filename, str)
    local f = io.open(filename, "w")
    io.write(f, str)
    io.close(f)
    return true
end

local function run(event)

    local contents = ""

    for fname in dir("/MODELS") do
        if string.match(string.lower(fname), '^model[0-9]+.yml$') then
            name = get_name(get_start_contents("/MODELS/" .. fname))
            if (name ~= nil) then
                contents = name .. "\n\nRemember to set FLIGHT MODE"
                print("NAME: " .. name)
                write_str("/MODELS/" .. name .. ".txt", contents)
            end
        end
    end

    return 1
end

run()

return {init = init, run = run}



