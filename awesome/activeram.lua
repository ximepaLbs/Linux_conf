  --  local wibox = require("wibox")
  --  local awful = require("awful")
   
  --  activeram_widget = wibox.widget.textbox()
  --  activeram_widget:set_align("right")
   
  --  function update_activeram(widget)
  --      local active, total
 	-- for line in io.lines('/proc/meminfo') do
 	-- 	for key, value in string.gmatch(line, "(%w+):\ +(%d+).+") do
 	-- 		if key == "Active" then active = tonumber(value)
 	-- 		elseif key == "MemTotal" then total = tonumber(value) end
 	-- 	end
 	-- end
   
  --      widget:set_markup(string.format("%.2fMB",(active/1024)))
  --  end
   
  --  update_activeram(activeram_widget)
   
  --  memtimer = timer({ timeout = 10 })
  --  memtimer:connect_signal("timeout", function () update_activeram(activeram_widget) end)
  --  memtimer:start()

local wibox = require("wibox")
local awful = require("awful")

helper={}

activeram_widget = wibox.widget.textbox()
activeram_widget:set_align("right")

--helpers
---- {{{ Split by whitespace
function helper.splitbywhitespace(str)
    values = {}
    start = 1
    splitstart, splitend = string.find(str, ' ', start)
    
    while splitstart do
        m = string.sub(str, start, splitstart-1)
        if m:gsub(' ','') ~= '' then
            table.insert(values, m)
        end

        start = splitend+1
        splitstart, splitend = string.find(str, ' ', start)
    end

    m = string.sub(str, start)
    if m:gsub(' ','') ~= '' then
        table.insert(values, m)
    end

    return values
end
-- }}}

function update_activeram(widget)
	-- Return memory usage 
	local f = io.open('/proc/meminfo')
	for line in f.lines() do
		line = helper.splitbywhitespace(line)
		if line[1] == 'MemTotal:' then
            mem_total = math.floor(line[2]/1024)
        elseif line[1] == 'MemFree:' then
            free = math.floor(line[2]/1024)
        elseif line[1] == 'Buffers:' then
            buffers = math.floor(line[2]/1024)
        elseif line[1] == 'Cached:' then
            cached = math.floor(line[2]/1024)
        end --end if
    end --end for
    f:close()
   widget:set_markup(string.format("%.2fMB",(active/1024)))
end -- 

update_activeram(activeram_widget)

memtimer = timer({ timeout = 10 })
memtimer:connect_signal("timeout", function () update_activeram(activeram_widget) end)
memtimer:start()