--util.lua

local Util = setmetatable({}, nil)

local doTypeCheck = true


function Util.DeepCopy(object)
    if type(object) ~= "table" then
        return object
    end
    local new_table = {}
    for index, value in pairs(object) do
        new_table[Util.DeepCopy(index)] = Util.DeepCopy(value)
    end
    return setmetatable(new_table, getmetatable(object))
end



-- override print() function to improve performance when running on device
-- and print out file and line number for each print
local original_print = print
if ( system.getInfo("environment") == "device" ) then
	print("Print now going silent. With Love, util.lua")
   print = function() end
else
	print = function(message)
		local info = debug.getinfo(2)
		local source_file = info.source
		--original_print(source_file)
		local debug_path = source_file:match('%a+.lua')
        if debug_path then 
            debug_path = debug_path  ..' ['.. info.currentline ..']'
        end
		original_print(((debug_path and (debug_path..": ")) or "")..tostring(message))
	end
end

--Returns true if checkMe is one of the types passed in to arg
-- Ex multiTypeCheck({1,2,3}, "string", "number") == false
local function multiTypeCheck(checkMe, ...)
    for i, v in ipairs(arg) do
        if type(checkMe) == v then
            return true
        end
    end
    return false
end

--For performance, turn off typechecking at top of Util
Util.typechk = doTypeCheck and multiTypeCheck or function(...) return true end



function Util.url_encode(str)
  if (str) then
    str = string.gsub (str, "\n", "\r\n")
    str = string.gsub (str, "([^%w %-%_%.%~])",
        function (c) return string.format ("%%%02X", string.byte(c)) end)
    str = string.gsub (str, " ", "+")
  end
  return str	
end


return Util