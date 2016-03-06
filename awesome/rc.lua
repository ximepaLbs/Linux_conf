--{{{ License
--
-- Awesome configuration, using awesome 3.5 on Arch GNU/Linux
--   * Inspired by Adrian C. <anrxc@sysphere.org>
--   * kinda heavily modified to suit my needs
--   * credits to http://awesome.naquadah.org/wiki/Davids_volume_widget
--   * credits to Dad` for inspiration
--	 * I don't claim author rights, just a simple user

-- This work is licensed under the Creative Commons Attribution-Share
-- Alike License: http://creativecommons.org/licenses/by-sa/3.0/
-- }}}



-- {{{ Libraries
awful = require("awful")
awful.rules = require("awful.rules")
awful.autofocus = require("awful.autofocus")

-- User libraries
vicious = require("vicious")
vicious.contrib = require("vicious.contrib")
scratch = require("scratch")

--special for volume with pulseaudio
require("volume")

-- Theme handling library
beautiful = require("beautiful")
naughty = require("naughty")

-- Wibox
wibox = require("wibox")
-- }}}

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
naughty.notify({ preset = naughty.config.presets.critical,
title = "Oops, there were errors during startup!",
text = awesome.startup_errors })
end
-- end
-- }}}

-- {{{ Variable definitions
local altkey = "Mod4"
local modkey = "Mod4"

local home   = os.getenv("HOME")
local exec   = awful.util.spawn
local sexec  = awful.util.spawn_with_shell

-- Beautiful theme
beautiful.init(home .. "/.config/awesome/acidburn.lua")

-- This is used later as the default terminal and editor to run.
-- Increase default font size for all terminals
terminal = "xterm -fg white -bg black -fn -*-fixed-medium-*-*-*-15-*"

-- Editor, currently sublime-text-dev
editor = os.getenv("EDITOR") or "subl3"
editor_cmd = terminal .. " -e " .. editor

-- Window management layouts
layouts = {
  awful.layout.suit.tile,        -- 1
  awful.layout.suit.tile.bottom, -- 2
  awful.layout.suit.fair,        -- 3
  awful.layout.suit.max,         -- 4
  awful.layout.suit.magnifier,   -- 5
  awful.layout.suit.floating     -- 6
}
-- }}}

-- {{{ Tags
tags = {
  names  = { "1.term", "2.dev", "3.web", "4.mail", "5.hide","6.misc","7.monitor"},
  layout = { layouts[1], layouts[2], layouts[2], layouts[1], layouts[1], layouts[1],layouts[1]}
}

tags2 = {
  names  = { "21.terms","22.dev2","23.web", "24.VM", "25.Hyp","26.IRC//IM","27.Media","28.Skype"},
  layout = { layouts[1], layouts[1], layouts[1], layouts[1], layouts[1],layouts[1], layouts[1], layouts[1]}
}

-- screen Mgt, 1 to 2 screens
--for s = 1, screen.count() do
for s=1,1 do
    tags[s] = awful.tag(tags.names, s, tags.layout)
    --patch hiding desktop 7
    awful.tag.setproperty(tags[s][5], "hide",   true)
end

for s=2,screen.count() do
  tags[s] = awful.tag(tags2.names, s, tags2.layout)
end
-- }}}


-- {{{ Wibox
--- {{{ Widgets configuration
--
-- {{{ Reusable separator
separator = wibox.widget.imagebox()
separator:set_image(beautiful.widget_sep)
-- }}}

-- {{{ Define gradient to be used
local colour1, colour2
colour1 = beautiful.fg_widget
colour2 = beautiful.fg_end_widget
gradient_colour = {type="linear", from={0, 0}, to={0, 10},
                   stops={{1, colour1}, {0.5, beautiful.fg_center_widget}, {0, colour2}}}
--- }}}

-- {{{ CPU usage and temperature
cpuicon = wibox.widget.imagebox()
cpuicon:set_image(beautiful.widget_cpu)
-- Initialize widgets
cpugraph  = awful.widget.graph()
-- tzswidget = wibox.widget.textbox()
-- Graph properties
cpugraph:set_width(60):set_height(14)
cpugraph:set_background_color(beautiful.fg_off_widget)
cpugraph:set_color(gradient_colour)
-- Register widgets
vicious.register(cpugraph,  vicious.widgets.cpu,      "$1")
-- vicious.register(tzswidget, vicious.widgets.thermal, " $1C", 19, {"coretemp.0", "core"})
-- }}}


-- ---{{{ Keyboard layout click to change
-- Keyboard map indicator and changer
kbdcfg = {}
kbdcfg.cmd = "setxkbmap"
kbdcfg.layout = {{ "us", "intl" , "INTL" },{"ru","","Russian"} } 
kbdcfg.current = 1  -- us is our default layout : us alternative international
kbdcfg.widget = wibox.widget.textbox()
kbdcfg.widget:set_text(" " .. kbdcfg.layout[kbdcfg.current][3] .. " ")
kbdcfg.switch = function ()
  kbdcfg.current = kbdcfg.current % #(kbdcfg.layout) + 1
  local t = kbdcfg.layout[kbdcfg.current]
  kbdcfg.widget:set_text(" " .. t[3] .. " ")
  os.execute( kbdcfg.cmd .. " " .. t[1] .. " " .. t[2] )
end

 -- Mouse bindings
kbdcfg.widget:buttons(
 awful.util.table.join(awful.button({ }, 1, function () kbdcfg.switch() end))
)

--   --we add the keyboard widget to the layout after its definition further in this file
-- right_layout:add(kbdcfg.widget)
--     }}} End Keyboard stuff

-- My keybindings
globalkeys = awful.util.table.join(globalkeys,
    awful.key({ modkey, "Mod1"    }, "1",     function () os.execute(kbd_dbus_sw_cmd .. "0") end),
    awful.key({ modkey, "Mod1"    }, "2",     function () os.execute(kbd_dbus_sw_cmd .. "1") end),
    awful.key({ modkey, "Mod1"    }, "3",     function () os.execute(kbd_dbus_sw_cmd .. "2") end),
    awful.key({ modkey, "Mod1"    }, "4",     function () os.execute(kbd_dbus_sw_cmd .. "3") end),
    awful.key({  "Control"  }, "ISO_Level3_Shift",     function () os.execute(kbd_dbus_prev_cmd) end),
        -- all minimized clients are restored 
    awful.key({ modkey, "Shift"   }, "n", 
        function()
            local tag = awful.tag.selected()
                for i=1, #tag:clients() do
                    tag:clients()[i].minimized=false
                    tag:clients()[i]:redraw()
              end
          end
    )
)


-- {{{ Network usage widget, configure according to your interface name
dnicon = wibox.widget.imagebox()
upicon = wibox.widget.imagebox()
dnicon:set_image(beautiful.widget_net)
upicon:set_image(beautiful.widget_netup)
-- Initialize widget
netwidget = wibox.widget.textbox()
-- Register widget
vicious.register(netwidget, vicious.widgets.net, '<span color="'
  -- .. beautiful.fg_netdn_widget ..'">${enp0s25 down_kb}</span> <span color="'
  -- .. beautiful.fg_netup_widget ..'">${enp0s25 up_kb}</span>', 3)
  .. beautiful.fg_netdn_widget ..'">${wlp3s0 down_kb} KB </span> <span color="'
  .. beautiful.fg_netup_widget ..'">${wlp3s0 up_kb} KB </span>', 3)
-- }}}


-- {{{ Volume widget via Pulseaudio (external volume.lua file)
volume_widget = create_volume_widget()

-- {{{ Date and time
dateicon = wibox.widget.imagebox()
dateicon:set_image(beautiful.widget_tape)
-- Initialize widget
datewidget = wibox.widget.textbox()
-- Register widget
vicious.register(datewidget, vicious.widgets.date, " %A %d %B - %R", 61)

--Simple RAM usage in MB, refreshed every 2secs
-- Initialize widget
memicon = wibox.widget.imagebox()
memicon:set_image(beautiful.widget_mem)
memwidget = wibox.widget.textbox()

-- Register widget
vicious.register(memwidget, vicious.widgets.mem, "$1% ($2MB/$3MB)", 2)


-- Simple CPU Usage
-- Initialize widget
cpuwidget = wibox.widget.textbox()
-- Register widget
vicious.register(cpuwidget, vicious.widgets.cpu, "$1%")

-- }}}

-- {{{
-- File System Usage Widget with tooltip for detailed info
fsicon = wibox.widget.imagebox()
fsicon:set_image(beautiful.widget_fs)
fs = {
r = awful.widget.progressbar(), h = awful.widget.progressbar()
}
for _, w in pairs(fs) do
w:set_vertical(true):set_ticks(true)
w:set_height(18):set_width(7):set_ticks_size(2)
w:set_background_color('#494B4F')
w:set_color('#AECF96')
w:set_color({ type = "linear", from = { 0, 0 }, to = { 10,0 }, stops = { {0, "#AECF96"}, {0.5, "#88A175"},
{1, "#FF5656"}}})
end
fs_t = awful.tooltip({ objects = { fs.r, fs.h, fsicon }})
-- Register File System Widget
vicious.cache(vicious.widgets.fs)
vicious.register(fs.r, vicious.widgets.fs,
function (widget, args)
fs_t:set_text("root: " .. args["{/ used_gb}"] .. "GB/" .. args["{/ size_gb}"] .. "GB (" .. args["{/ used_p}"] .. "%)\n/home: " .. args["{/home used_gb}"] .. "GB/" .. args["{/home size_gb}"] .. "GB (" .. args["{/home used_p}"] .. "%)")
return args["{/ used_p}"]
end, 599)
vicious.register(fs.h, vicious.widgets.fs, "${/home used_p}", 599)

---}}}

-- {{{ Wibox initialisation
mywibox     = {}
promptbox = {}
layoutbox = {}
taglist   = {}
taglist.buttons = awful.util.table.join(
    awful.button({ },        1, awful.tag.viewonly),
    awful.button({ modkey }, 1, awful.client.movetotag),
    awful.button({ },        3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, awful.client.toggletag),
    awful.button({ },        4, awful.tag.viewnext),
    awful.button({ },        5, awful.tag.viewprev
))


--- Screen 1 
s=1
-- Create a promptbox
promptbox[s] = awful.widget.prompt()
-- Create a layoutbox
layoutbox[s] = awful.widget.layoutbox(s)
layoutbox[s]:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.layout.inc(layouts,  1) end),
    awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
    awful.button({ }, 4, function () awful.layout.inc(layouts,  1) end),
    awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)
))

-- Create the taglist
taglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist.buttons)

--Create the wibox
mywibox[s] = awful.wibox({      screen = s,
    -- Wibox size and position information
    fg = beautiful.fg_normal, height = 22,
    bg = beautiful.bg_normal, position = "top",
    border_color = beautiful.border_focus,
    border_width = beautiful.border_width
})

-- Widgets that are aligned to the left
local left_layout = wibox.layout.fixed.horizontal()
left_layout:add(taglist[s])
left_layout:add(layoutbox[s])
left_layout:add(separator)
left_layout:add(promptbox[s])


local custom_widgets =
{ 
    cpuicon, cpugraph, cpuwidget, separator,fsicon,fs.h,separator,fs.r,separator,memicon, memwidget, separator,
    dnicon, netwidget, upicon, separator,
    volume_widget, separator,
    dateicon, datewidget, separator
}

local right_layout = wibox.layout.fixed.horizontal()
if s == 1 then right_layout:add(wibox.widget.systray()) end
for _, wdgt in pairs(custom_widgets) do
    right_layout:add(wdgt)
end
  --we add the keyboard widget to the layout
right_layout:add(kbdcfg.widget)


--adding raminfo module from "activeram" by naqqadah


-- Now bring it all together (with the tasklist in the middle)
local layout = wibox.layout.align.horizontal()
layout:set_left(left_layout)
--layout:set_middle(mytasklist[s])
layout:set_right(right_layout)

-- mywibox[s]:set_widget(layout)
mywibox[s]:set_widget(layout)

-- }}}
-- }}}


--- Screen 2
if(screen.count()>1)then 
  s=2
  -- Create a promptbox
  promptbox[s] = awful.widget.prompt()
  -- Create a layoutbox
  layoutbox[s] = awful.widget.layoutbox(s)
  layoutbox[s]:buttons(awful.util.table.join(
      awful.button({ }, 1, function () awful.layout.inc(layouts,  1) end),
      awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
      awful.button({ }, 4, function () awful.layout.inc(layouts,  1) end),
      awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)
  ))

  -- Create the taglist
  taglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist.buttons)

  --Create the wibox
  mywibox[s] = awful.wibox({      screen = s,
      --I like big bars
      fg = beautiful.fg_normal, height = 20,
      bg = beautiful.bg_normal, position = "top",
      border_color = beautiful.border_focus,
      border_width = beautiful.border_width
  })
  mywibox[s] = awful.wibox({      screen = s,
      fg = beautiful.fg_normal, height = 20,
      bg = beautiful.bg_normal, position = "top",
      border_color = beautiful.border_focus,
      border_width = beautiful.border_width
  })

  -- Widgets that are aligned to the left
  local left_layout = wibox.layout.fixed.horizontal()
  left_layout:add(taglist[s])
  left_layout:add(layoutbox[s])
  left_layout:add(separator)
  left_layout:add(promptbox[s])

  -- Widgets that are aligned to the right
  local custom_widgets =
  { 
      memicon, memwidget, separator,fsicon,fs.h,separator,fs.r,separator,separator, dnicon, netwidget, upicon, separator,
     volume_widget
  }

  local right_layout = wibox.layout.fixed.horizontal()
  if s == 1 then right_layout:add(wibox.widget.systray()) end
  for _, wdgt in pairs(custom_widgets) do
      right_layout:add(wdgt)
  end

  -- Now bring it all together (with the tasklist in the middle)
  local layout = wibox.layout.align.horizontal()
  layout:set_left(left_layout)
  --layout:set_middle(mytasklist[s])
  layout:set_right(right_layout)

  -- mywibox[s]:set_widget(layout)
  mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))

-- Client bindings
clientbuttons = awful.util.table.join(
    awful.button({ },        1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize)
)
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key( -- restore minimized windows
        {modkey, "Shift"}, "n",
        function ()
            local allclients = client.get(mouse.screen)

            for _,c in ipairs(allclients) do
                if c.minimized and c:tags()[mouse.screen] ==
                    awful.tag.selected(mouse.screen) then
                    c.minimized = false
                    client.focus = c
                    c:raise()
                    return
                end
            end
        end
    ),

    -- Command Prompt with Mod+r 
    awful.key({ modkey },            "r",     function () promptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  promptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    -- awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",      function (c) c.minimized = not c.minimized    end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end),

    -- Volume Keys : react to keyboard media keys
    awful.key({ }, "XF86AudioRaiseVolume", function () inc_volume(volume_widget) end),
    awful.key({ }, "XF86AudioLowerVolume", function () dec_volume(volume_widget) end)

)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, 1 do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end


clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}


-- {{{ Rules : windows sent to specific screens by default, format [screen][tag]
awful.rules.rules = {
    { rule = { }, properties = {
      focus = true,      size_hints_honor = false,
      keys = clientkeys, buttons = clientbuttons,
      border_width = beautiful.border_width,
      border_color = beautiful.border_normal }
    },
    { rule = {class = "htop"}, properties = {tag = tags[1][7]}},
    { rule = {class = "bmon"}, properties = {tag = tags[1][7]}},
    { rule = { class = "pcmanfm" },
      properties = { floating = true } },
    { rule = { class = "VirtualBox" },
    except = { name = "Oracle VM VirtualBox properties" }},
    { rule = { class = "Vim",    instance = "vim" },
      properties = { tag = tags[screen.count()][2] } },
    { rule = { class = "Vim",    instance = "_Remember_" },
      properties = { floating = true }, callback = awful.titlebar.add  },
    { rule = { instance = "firefox-bin" },
      properties = { floating = true }, callback = awful.titlebar.add  },
}
-- }}}


-- {{{ Signals handlers
--
-- {{{ Manage signal handler
client.connect_signal("manage", function (c, startup)
    -- Add titlebar to floaters, but remove those from rule callback
    if awful.client.floating.get(c)
    or awful.layout.get(c.screen) == awful.layout.suit.floating then
        if   c.titlebar then awful.titlebar.remove(c)
        else awful.titlebar.add(c, {modkey = modkey}) end
    end

    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function (c)
        if  awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    -- Client placement
    if not startup then
        awful.client.setslave(c)

        if  not c.size_hints.program_position
        and not c.size_hints.user_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)
-- }}}

-- {{{ Focus signal handlers
-- client.connect_signal("focus",   function (c) c.border_color = beautiful.border_focus  end)
-- client.connect_signal("unfocus", function (c) c.border_color = beautiful.border_normal end)
client.connect_signal("focus", function(c)
                              c.border_color = beautiful.border_focus
                              c.opacity = 1
                           end)
client.connect_signal("unfocus", function(c)
                                c.border_color = beautiful.border_normal
                                c.opacity = 0.7
                             end)
-- }}}

-- {{{ Arrange signal handler
for s = 1, screen.count() do screen[s]:connect_signal("arrange", function ()
    local clients = awful.client.visible(s)
    local layout = awful.layout.getname(awful.layout.get(s))

    for _, c in pairs(clients) do -- Floaters are always on top
        if   awful.client.floating.get(c) or layout == "floating"
        then if not c.fullscreen then c.above       =  true  end
        else                          c.above       =  false end
    end
  end)
end
-- }}}
-- }}}

-- Autorun programs
autorun = true
autorunApps =
{
    "autocutsel -selection CLIPBOARD -fork", --clipboard
    "autocutsel -selection PRIMARY -fork",
    "batterymon", -- Im on a laptop and like this widget
    "nitrogen --restore"--desktop background
}

if autorun then
        for _, app in pairs(autorunApps) do
                awful.util.spawn(app)
        end
end

-- Autostart
-- at startup, run commands from ~/config/autostart
function autostart(dir)
    if not dir then
        do return nil end
    end
    local fd = io.popen("ls -1 -F " .. dir)
    if not fd then
        do return nil end
    end
    for file in fd:lines() do
        local c= string.sub(file,-1)   -- last char
        if c=='*' then  -- executables
            executable = string.sub( file, 1,-2 )
            print("Awesome Autostart: Executing: " .. executable)
            awful.util.spawn_with_shell(dir .. "/" .. executable .. "") -- launch in bg
        elseif c=='@' then  -- symbolic links
            print("Awesome Autostart: Not handling symbolic links: " .. file)
        else
            print ("Awesome Autostart: Skipping file " .. file .. " not executable.")
        end
    end
    io.close(fd)
end

autostart_dir = os.getenv("HOME") .. "/.config/autostart"
autostart(autostart_dir)


--exemple notification by libnotify


-- naughty.notify({
--     text = "notification",
--     title = "alert",
--     position = "top_right",
--     timeout = 7,
--     fg="#62E7C4",
--     --bg="#bbggcc",
--     screen = 1,
--     font = "Profont 13",
--     ontop = true, 
--     --run = function () awful.util.spawn("wicd-client") end
-- })

-- naughty.notify({
--   naughty.config.defaults.timeout          = 5
--   naughty.config.defaults.screen           = 1
--   naughty.config.defaults.position         = "top_right"
--   naughty.config.defaults.margin           = 4
--   naughty.config.defaults.height           = 25
--   naughty.config.defaults.width            = 300
--   naughty.config.defaults.gap              = 2
--   naughty.config.defaults.ontop            = true
--   naughty.config.defaults.font             = beautiful.font or "Profont 8"
--   naughty.config.defaults.icon             = nil
--   naughty.config.defaults.icon_size        = 16
--   naughty.config.defaults.fg               = beautiful.fg_focus or '#ffffff'
--   naughty.config.defaults.bg               = beautiful.bg_focus or '#535d6c'
--   naughty.config.presetss.border_color     = beautiful.border_focus or '#535d6c'
--   naughty.config.defaults.border_width     = 1
--   naughty.config.defaults.hover_timeout    = nil)}


--{{{
-- Unused modules at the moment, kept for references

-- -- {{{ Volume level for alsa driver
-- volicon = wibox.widget.imagebox()
-- volicon:set_image(beautiful.widget_vol)
-- -- Initialize widgets
-- volbar    = awful.widget.progressbar()
-- volwidget = wibox.widget.textbox()
-- -- Progressbar properties
-- volbar:set_vertical(true):set_ticks(true)
-- volbar:set_height(12):set_width(8):set_ticks_size(1)
-- volbar:set_background_color(beautiful.fg_off_widget)
-- volbar:set_color(gradient_colour)
-- vicious.cache(vicious.widgets.volume)
-- -- Register widgets
-- vicious.register(volbar,    vicious.widgets.volume,  "$1",  2, "PCM")
-- vicious.register(volwidget, vicious.widgets.volume, " $1%", 2, "PCM")

-- -- Register buttons 1 onclick, 4 on mouse wheel up, 5 on mouse wheel down
-- volbar:buttons(awful.util.table.join(
--    awful.button({ }, 1, function () exec("pavucontrol") end),
--    awful.button({ }, 4, function () exec("amixer -q set PCM 0.5dB+", false) end),
--    awful.button({ }, 5, function () exec("amixer -q set PCM 0.5dB-", false) end)
-- )) -- Register assigned buttons
-- volwidget:buttons(volbar:buttons())
-- -- }}}

-- -- {{{ Battery state
-- baticon = wibox.widget.imagebox()
-- baticon:set_image(beautiful.widget_bat)
-- -- Initialize widget
-- batwidget = wibox.widget.textbox()
-- -- Register widget
-- -- vicious.register(batwidget, vicious.widgets.bat, "$1$2%", 61, "BAT0")
-- vicious.register(batwidget, vicious.contrib.batproc, "$1$2%", 61, "BAT0")
-- -- }}}

--in case you use alsa mixer (i use pulseaudio)
--Multimedia keys
    -- awful.key({ }, "XF86AudioRaiseVolume", function () awful.util.spawn("amixer -q set PCM 0.5dB+", false) end),
    -- awful.key({ }, "XF86AudioLowerVolume", function () awful.util.spawn("amixer -q set PCM 0.5dB-", false) end)

--More widget stuff
-- Widgets that are aligned to the right
-- local custom_widgets =
-- { 
--     cpuicon, cpugraph, tzswidget, separator,
--     baticon, batwidget, separator,
--     memicon, membar, separator,
--     fsicon, fs.r, fs.h, fs.s, fs.b, separator,
--     dnicon, netwidget, upicon, separator,
--     volicon, volbar, volwidget, separator,
--     dateicon, datewidget
-- }

-- -- {{{ Memory usage
-- memicon = wibox.widget.imagebox()
-- memicon:set_image(beautiful.widget_mem)
-- -- Initialize widget
-- membar = awful.widget.progressbar()
-- -- Progressbar properties
-- membar:set_vertical(true):set_ticks(true)
-- membar:set_height(12):set_width(20):set_ticks_size(1)
-- membar:set_background_color(beautiful.fg_off_widget)
-- membar:set_color(gradient_colour)
-- -- Register widget
-- vicious.register(membar, vicious.widgets.mem, "$1", 13)
-- -- }}}

-- -- {{{ File system usage
-- fsicon = wibox.widget.imagebox()
-- fsicon:set_image(beautiful.widget_fs)
-- -- Initialize widgets
-- fs = {
--   r = awful.widget.progressbar(), h = awful.widget.progressbar(),
--   s = awful.widget.progressbar(), b = awful.widget.progressbar()
-- -- }
-- -- Progressbar properties
-- for _, w in pairs(fs) do
--   w:set_vertical(true):set_ticks(true)
--   w:set_height(14):set_width(5):set_ticks_size(2)
--   w:set_border_color(beautiful.border_widget)
--   w:set_background_color(beautiful.fg_off_widget)
--   w:set_color(gradient_colour)
--   --w.widget:buttons(awful.util.table.join(
--   --  awful.button({ }, 1, function () exec("rox", false) end)
--   --))
-- end -- Enable caching
-- vicious.cache(vicious.widgets.fs)
-- -- Register widgets
-- vicious.register(fs.r, vicious.widgets.fs, "${/ used_p}",            599)
-- vicious.register(fs.h, vicious.widgets.fs, "${/home used_p}",        599)
-- vicious.register(fs.s, vicious.widgets.fs, "${/var used_p}", 599)
-- vicious.register(fs.b, vicious.widgets.fs, "${/tmp used_p}",  599)
-- -- }}}