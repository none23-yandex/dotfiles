-- Requirements {{{
local gears       = require("gears")
local awful       = require("awful")
      awful.rules = require("awful.rules")
local wibox       = require("wibox")
local beautiful   = require("beautiful")
local naughty     = require("naughty")
local drop        = require("scratchdrop")
local lain        = require("lain")
local menubar     = require("menubar")
local scratch     = require("scratchdrop")
local nlay        = require("nlay") -- my own awesome layout
-- }}}
-- Error handling {{{
if awesome.startup_errors then
    naughty.notify({
                    preset = naughty.config.presets.critical,
                    title = "Oops, you're out of luck, buddy!",
                    text = awesome.startup_errors
                    })
end

do
    local in_error = false
    awesome.connect_signal("debug::error",
        function (err)
            if in_error then
                return
            end
            in_error = true
            naughty.notify({
                           preset = naughty.config.presets.critical,
                           title = "Oops, an error happened!",
                           text = err
                           })
            in_error = false
        end)
end
-- }}}
-- Autostart applications {{{
function run_once(cmd)
      findme = cmd
      firstspace = cmd:find(" ")
      if firstspace then
          findme = cmd:sub(0, firstspace-1)
      end
      awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end

os.setlocale(os.getenv("LANG"))
run_once("xcompmgr &")
awful.util.spawn_with_shell("xscreensaver -nosplash &")
awful.util.spawn_with_shell("unclutter -idle 1 &")
awful.util.spawn_with_shell("xrdb -merge /home/$USER/.Xresources")
awful.util.spawn_with_shell("xmodmap /home/$USER/.Xmodmap")
awful.util.spawn_with_shell("xset s off")
awful.util.spawn_with_shell("xset -dpms")
awful.util.spawn_with_shell("xset r rate 200 60")
awful.util.spawn_with_shell("source /home/$USER/.aliases")
beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/multicolor/theme.lua")
-- }}}
-- Aliases {{{
modkey     = "Mod4"
altkey     = "Mod3"
shift      = "Shift"
alt        = "Alt"
ctrl       = "Control"

terminal   = "konsole"
yarminal   = "urxvt"
tmux       = "konsole -e tmux"
bash       = "konsole -e bash"
ranger     = "konsole -e ranger"
browser    = "chromium"
browser2   = "firefox"
kiosked    = "chromium --kiosk"
pronmode   = "firefox --private-window"
filemgr    = ranger
filemgr2   = "thunar"
gvim       = "konsole -e nvim"
atom       = "atom"

-- }}}
-- Layouts and tags table {{{
local layouts = {
                 nlay,
                 awful.layout.suit.tile,
                 awful.layout.suit.tile.bottom,
                 awful.layout.suit.tile.top
                 --awful.layout.suit.fair,fair
                 --awful.layout.suit.fair.horizontal,
                 --awful.layout.suit.spiral,
                 --awful.layout.suit.spiral.dwindle,
                 --awful.layout.suit.max,
                 --lain.layout.uselesstile,
                 --lain.layout.uselesstile.bottom
                 }
tags = {
        name = {"1", "2", "3", "4", "5", "6", "7", "8", "9"},
        layout = {
                  layouts[4],
                  layouts[1], layouts[1], layouts[1], layouts[1],
                  layouts[2], layouts[2], layouts[2],
                  layouts[3]
                  }
       }
for s = 1, screen.count() do
    tags[s] = awful.tag(tags.name, s, tags.layout)
end
-- Primary Screen layouts finetuning {{{
-- tag 1
awful.tag.setnmaster(1, tags[1][1])
awful.tag.setncol(1, tags[1][1])
awful.tag.setmwfact(0.85, tags[1][1])
-- tags 2-5
for t = 2, 5 do
    awful.tag.setnmaster(1, tags[1][t])
    awful.tag.setncol(1, tags[1][t])
    awful.tag.setmwfact(0.625, tags[1][t])
end
-- tags 6-8
for t = 6, 8 do
    awful.tag.setnmaster(1, tags[1][t])
    awful.tag.setncol(1, tags[1][t])
    awful.tag.setmwfact(0.625, tags[1][t])
end
-- tag 9
awful.tag.setnmaster(3, tags[1][9])
awful.tag.setncol(1, tags[1][9])
awful.tag.setmwfact(0.5, tags[1][9])
-- }}}
-- Secondary screens finetuning{{{
for s = 2, screen.count() do
    for t = 1, 9 do
        awful.tag.setnmaster(1, tags[s][t])
        awful.tag.setncol(1, tags[s][t])
        awful.tag.setmwfact(0.5, tags[s][t])
    end
end
-- }}}
require("awful.autofocus")
-- }}}
-- Wallpaper {{{
for s = 1, screen.count() do
    if beautiful.wallpaper then
        --gears.wallpaper.fit(beautiful.wallpaper, s) end end
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}
-- Freedesktop menu {{{
mymainmenu = awful.menu.new({
                             items = require("menugen").build_menu(),
                             theme = {height = 12,
                                      width = 130}
                             })
-- }}}
-- Batttery warning {{{
local function trim(s)
          return s:find'^%s*$' and '' or s:match'^%s*(.*%S)'
      end
local function bat_notification()
          local f_capacity = assert(io.open("/sys/class/power_supply/BAT1/capacity", "r"))
          local f_status = assert(io.open("/sys/class/power_supply/BAT1/status", "r"))
          local bat_capacity = tonumber(f_capacity:read("*all"))
          local bat_status = trim(f_status:read("*all"))
          if (bat_capacity <= 10 and bat_status == "Discharging") then
              naughty.notify({
                              title = "Battery Warning",
                              text = "Battery low! " .. bat_capacity .."%" .. " left!",
                              fg="#010101",
                              bg="#FF0000",
                              timeout= 59,
                              position   = "top_right"
                              })
          end
      end
battimer = timer({timeout = 60})
battimer:connect_signal("timeout", bat_notification)
battimer:start()
-- }}}
-- Widgets for wibox {{{
-- define widgets {{{
markup = lain.util.markup
-- textclock {{{
mytextclock = awful.widget.textclock(markup("#999999", "%d-%a") ..
                                     markup("#cccccc", ">") ..
                                     markup("#de5e1e", " %H:%M "))
-- }}}
-- cpu {{{
cpuwidget = lain.widgets.cpu({
    settings = function()
                   widget:set_markup(markup("#999999",
                                            cpu_now.usage .. "> "))
               end
    })
-- }}}
-- battery {{{
batwidget = lain.widgets.bat({
    settings = function()
                   if bat_now.perc == "N/A" then
                       bat_now.perc = bat_now.perc .. "C "
                   else
                       bat_now.perc = bat_now.perc .. "% "
                   end
                   widget:set_markup(markup("#de5e1e", bat_now.perc))
               end
    })
-- }}}
-- alsa volume {{{
volumewidget = lain.widgets.alsa({
    settings = function()
                   if volume_now.status == "off" then
                       volume_now.level = volume_now.level .. "M"
                   end
                   widget:set_markup(markup("#999999",
                                            volume_now.level .. "% "))
               end
    })
-- }}}
-- memory {{{
memwidget = lain.widgets.mem({
    settings = function()
                   widget:set_markup(markup("#999999", mem_now.used .. "-"))
               end
    })
-- }}}
-- spacers {{{
spacer = wibox.widget.textbox(" ")
yapacer = wibox.widget.textbox(">")
-- }}}
-- }}}
-- create a wibox for each screen and add it {{{
mywibox = {}
mypromptbox = {}
mytaglist = {}
-- }}}
-- Taglist click action {{{
mytaglist.buttons = awful.util.table.join(
    awful.button({}, 1, awful.tag.viewonly),
    awful.button({modkey}, 1, awful.client.movetotag),
    awful.button({}, 3, awful.tag.viewtoggle),
    awful.button({modkey}, 3, awful.client.toggletag))
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
    awful.button({}, 1, function (c)
                            if c == client.focus then
                                c.minimized = true
                            else
                                c.minimized = false
                                if not c:isvisible() then
                                    awful.tag.viewonly(c:tags()[1])
                                end

                                client.focus = c
                                c:raise()
                            end
                        end),

    awful.button({}, 3, function ()
                            if instance
                                then instance:hide()
                                instance = nil
                            else
                                instance = awful.menu.clients({width=250})
                            end
                        end))
-- }}}
-- }}}
-- Wibox {{{
for s = 1, screen.count() do
    mypromptbox[s] = awful.widget.prompt()
    mytaglist[s] = awful.widget.taglist(s,
                                        awful.widget.taglist.filter.all,
                                        mytaglist.buttons)
    mytasklist[s] = awful.widget.tasklist(s,
                                        awful.widget.tasklist.filter.currenttags,
                                        mytasklist.buttons)
    mywibox[s] = awful.wibox({
                              position = "top",
                              screen = s,
                              height = 16
                              })
    -- Left side {{{
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])
    left_layout:add(yapacer)
    -- }}}
    -- Right side {{{
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then
        right_layout:add(wibox.widget.systray())
        right_layout:add(volumewidget)
        right_layout:add(memwidget)
        right_layout:add(cpuwidget)
        right_layout:add(batwidget)
        right_layout:add(mytextclock)
        --right_layout:add(volicon)
        --right_layout:add(yapacer)
        --right_layout:add(memicon)
        --right_layout:add(yaparacer)
        --right_layout:add(cpuicon)
        --right_layout:add(baticon)
    end
    -- }}}
    -- Bring it all together {{{
    local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_middle(mytasklist[s])
        layout:set_right(right_layout)
        mywibox[s]:set_widget(layout)
    -- }}}
end
-- }}}
-- Keybindings {{{
-- Global keybindings {{{
globalkeys = awful.util.table.join(
    -- focus clients {{{
    awful.key({modkey}, "j",
        function()
            awful.client.focus.global_bydirection("down")
            if client.focus
                then client.focus:raise()
            end
        end),

    awful.key({modkey}, "k",
        function()
            awful.client.focus.global_bydirection("up")
            if client.focus
                then client.focus:raise()
            end
        end),

    awful.key({modkey}, "h",
        function()
            awful.client.focus.global_bydirection("left")
            if client.focus
                then client.focus:raise()
            end
        end),

    awful.key({modkey}, "l",
        function()
            awful.client.focus.global_bydirection("right")
            if client.focus
                then client.focus:raise()
            end
        end),

    awful.key({modkey}, "w",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus
                then client.focus:raise()
            end
        end),

    awful.key({modkey}, "b",
        function ()
            awful.client.focus.history.previous()
            if client.focus
                then client.focus:raise()
            end
        end),
    --}}}
  -- swap clients {{{
    awful.key({modkey, shift}, "j" ,
              function ()
                  awful.client.swap.global_bydirection("down" )
              end),

    awful.key({modkey, shift}, "k",
              function ()
                  awful.client.swap.global_bydirection("up"   )
              end),

    awful.key({modkey, shift   }, "h",
              function ()
                  awful.client.swap.global_bydirection("left" )
              end),

    awful.key({modkey, shift   }, "l",
              function ()
                  awful.client.swap.global_bydirection("right")
              end),
    --}}}
    -- restore minimized {{{
    awful.key({modkey}, "a",
              awful.client.restore),
    -- }}}
    -- manual layout manipulation {{{
    awful.key({modkey}, "space",
              function ()
                  awful.layout.inc(layouts,  1)
              end),
    awful.key({modkey}, "period",
              function ()
                  awful.tag.incncol(1)
              end),
    awful.key({modkey}, "comma",
              function () awful.tag.incncol(-1) end),
    awful.key({modkey}, "Down",
              function ()
                  awful.tag.incnmaster(-1)
              end),
    awful.key({modkey}, "Up",
              function ()
                  awful.tag.incnmaster(1)
              end),
    awful.key({modkey}, "Right",
              function ()
                  awful.tag.incmwfact(0.01)
              end),
    awful.key({modkey}, "Left",
              function ()
                  awful.tag.incmwfact(-0.01)
              end),
    awful.key({modkey, shift}, "Right",
              function ()
                  awful.tag.incmwfact(0.05)
              end),
    awful.key({modkey, shift}, "Left",
              function ()
                  awful.tag.incmwfact(-0.05)
              end),
    -- useless gaps change {{{
    awful.key({ modkey}, "bracketleft",
              function ()
                  lain.util.useless_gaps_resize(-0.1)
              end),
    awful.key({ modkey}, "bracketright",
              function ()
                  lain.util.useless_gaps_resize(0.1)
              end),
    -- }}}
    -- }}}
    -- focus (nonempty) tags {{{
    awful.key({modkey}, "Next",
              function ()
                  lain.util.tag_view_nonempty(1)
              end),
    awful.key({modkey}, "Prior",
              function ()
                  lain.util.tag_view_nonempty(-1)
              end),
    -- }}}
    -- focus screens {{{
    awful.key({modkey}, "F1",
              function ()
                  awful.screen.focus(1)
              end),
    awful.key({modkey}, "F2",
              function ()
                  awful.screen.focus(2)
              end),
    awful.key({modkey}, "F3",
              function ()
                  awful.screen.focus(3)
              end),
    -- }}}
    -- menus and similar {{{
    awful.key({modkey}, "z",
              function()
                  menubar.show()
              end),

    awful.key({modkey}, "x",
              function ()
                  mypromptbox[mouse.screen]:run()
              end),

    awful.key({modkey}, "s",
              function ()
                  awful.util.spawn("gksu")
              end),

    awful.key({modkey}, "v",
              function ()
                  mymainmenu:show({ keygrabber = true })
              end),

    awful.key({modkey, ctrl}, "x",
              function ()
                  awful.prompt.run(
                       {prompt = "Run Lua: "},
                       mypromptbox[mouse.screen].widget,
                       awful.util.eval, nil,
                       awful.util.getdir("cache") .. "/history_eval")
              end),
    -- }}}
    -- applications {{{
    awful.key({modkey}, "Return",
              function ()
                  awful.util.spawn(terminal)
              end),
    awful.key({modkey}, "KP_Enter",
              function ()
                  awful.util.spawn_with_shell(yarminal)
              end),
    awful.key({altkey}, "grave",
              function ()
                  awful.util.spawn(gvim)
              end),
    awful.key({altkey}, "1",
              function ()
                  awful.util.spawn(browser)
              end),
    awful.key({altkey, ctrl}, "1",
              function ()
                  awful.util.spawn("tor-browser-en")
              end),
    awful.key({altkey}, "2",
              function ()
                  awful.util.spawn(browser2)
              end),
    awful.key({altkey, ctrl}, "2",
              function ()
                  awful.util.spawn(kiosked)
              end),

    awful.key({altkey}, "3",
              function ()
                  awful.util.spawn(atom)
              end),

    awful.key({altkey}, "4",
              function ()
                  awful.util.spawn(filemgr)
              end),
    awful.key({altkey, ctrl}, "4",
              function ()
                  awful.util.spawn(filemgr2)
              end),
    awful.key({altkey}, "dollar",
              function ()
                  awful.util.spawn_with_shell("gksudo" ..filemgr)
              end),
    awful.key({altkey, ctrl}, "dollar",
              function ()
                  awful.util.spawn_with_shell("gksudo" .. filemgr2)
              end),

    awful.key({altkey}, "5",
              function ()
                  awful.util.spawn("zathura")
              end),

    awful.key({altkey}, "6",
              function ()
                  awful.util.spawn(bash)
              end),

    awful.key({altkey}, "7",
              function ()
                  awful.util.spawn(arandr)
              end),

    -- changing transparency quickly
    awful.key({altkey}, "8",
              function ()
                  awful.util.spawn("transset-df 1")
              end),
    awful.key({altkey, ctrl}, "8",
              function ()
                  awful.util.spawn("transset-df .8")
              end),
    awful.key({altkey}, "9",
              function ()
                  awful.util.spawn("transset-df .65")
              end),
    awful.key({altkey, ctrl}, "9",
              function ()
                  awful.util.spawn("transset-df .4")
              end),
    -- }}}
    -- scratchdrop applications {{{
    awful.key({modkey}, "grave",
              function ()
                  drop(terminal)
              end),
    awful.key({modkey}, "Tab" ,
              function ()
                  drop(ranger)
              end),
    awful.key({modkey}, "KP_Subtract",
              function ()
                  drop(pronmode)
              end),
    awful.key({modkey}, "KP_Divide",
              function ()
                  drop(gvim)
              end),
    awful.key({modkey}, "KP_Multiply",
              function ()
                  drop(tmux)
              end),
    -- }}}
    -- actions {{{
    awful.key({modkey, ctrl}, "r",
              awesome.restart),

    awful.key({modkey, ctrl}, "q",
              awesome.quit),

    awful.key({modkey}, "F12",
              function()
                  awful.util.spawn("xscreensaver-command -lock")
              end),

    awful.key({modkey}, "c",
              function()
                  os.execute("xsel -p -o | xsel -i -b")
              end),

    awful.key({}, "XF86AudioRaiseVolume",
              function()
                  awful.util.spawn("amixer -q set Master 5%+")
                  volumewidget.update()
              end),

    awful.key({}, "XF86AudioLowerVolume",
              function()
                  awful.util.spawn("amixer -q set Master 5%-")
                  volumewidget.update()
              end),

    awful.key({}, "XF86AudioMute",
              function()
                  awful.util.spawn("amixer -q set Master playback toggle")
                  volumewidget.update()
              end)
    -- }}}
)
-- }}}
-- Client keybindings {{{
clientkeys = awful.util.table.join(
    awful.key({modkey, shift}, "F1",
                function(c) awful.client.movetoscreen(c, 1)
                end),

    awful.key({modkey, shift}, "F2",
                function(c) awful.client.movetoscreen(c, 2)
                end),

    awful.key({modkey, shift}, "F3",
                function(c) awful.client.movetoscreen(c, 3)
                end),

    awful.key({modkey}, "slash",
                function (c) c:swap(awful.client.getmaster())
                end),

    awful.key({modkey}, "Escape",
                function (c) c:kill()
                end),

    awful.key({modkey}, "n",
                function (c) c.minimized = true
                end),

    awful.key({modkey}, "y",
                function (c) c.sticky = not c.sticky
                end),

    awful.key({modkey}, "g",
                function (c) awful.client.floating.toggle()
                end),

    --[[awful.key({modkey}, "f",
                function (c) c.fullscreen = not c.fullscreen
                end),]] -- fullscreen is disabled globally (see signals)

    awful.key({modkey}, "t",
                function (c) c.ontop = not c.ontop
                end),

    awful.key({modkey}, "u",
                function (c) c.below = not c.below
                end),

    awful.key({modkey}, "d",
                function (c) c.size_hints_honor = not c.size_hints_honor
                end),

    awful.key({modkey}, "i",
                function (c) c.above = not c.above
                end),

    awful.key({modkey}, "m",
                function (c) c.maximized_horizontal = not c.maximized_horizontal
                    c.maximized_vertical   = not c.maximized_vertical
                end),

    awful.key({modkey}, "minus",
                function (c) c.maximized_horizontal = not c.maximized_horizontal
                end),

    awful.key({modkey}, "backslash",
                function (c) c.maximized_vertical = not c.maximized_vertical
                end)
)
-- }}}
-- Tags manipulation {{{
for i = 1, 9 do
    globalkeys = awful.util.table.join(
        globalkeys,
        awful.key({modkey}, "#"..i + 9,
                  function ()
                      for s = 1, screen.count() do
                          local tag = awful.tag.gettags(s)[i]
                          if tag
                              then awful.tag.viewonly(tag)
                          end
                      end
                  end),

        awful.key({modkey, shift}, "#"..i + 9,
                    function ()
                        local tag = awful.tag.gettags(client.focus.screen)[i]
                        if client.focus and tag
                            then awful.client.toggletag(tag)
                        end
                     end)
        --[[
        awful.key({modkey, shift}, "#"..i + 9,
                  function ()
                      local tag = awful.tag.gettags(client.focus.screen)[i]
                      if client.focus and tag
                          then awful.client.toggletag(tag)
                      end
                  end)
        --]]
        )
end
-- }}}
-- }}}
-- Mouse buttons {{{
clientbuttons = awful.util.table.join(
    awful.button({}, 1,
                 function (c) client.focus = c; c:raise() end),
    awful.button({modkey}, 1,
                 awful.mouse.client.move),
    awful.button({modkey}, 3,
                 awful.mouse.client.resize))
root.keys(globalkeys)
-- }}}
-- Rules {{{
awful.rules.rules = {
    {rule = {}, callback = awful.client.setslave},
    {rule = {}, properties = {
                             border_width = beautiful.border_width,
                             focus = awful.client.focus.filter,
                             keys = clientkeys,
                             buttons = clientbuttons,
                             size_hints_honor = true,
                             },
    },

    {rule = {name = "Page(s) Unresponsive"},
        properties = {floating = true}},
    {rule = {name = "Firefox Preferences"},
        properties = {floating = true}},
    {rule = {name = "Adblock Plus Filter Preferences"},
        properties = {floating = true}},
    {rule = {name = "Install user style"},
        properties = {floating = true}},
    {rule = {class = "chromium"},
        properties = {maximized_horizontal = false,
                      maximized_vertical = false,
                      floating = false}},

    {rule = {class = "Atom"},
        properties = {maximized_horizontal = false,
                      maximized_vertical = false,
                      floating = false,
                      opacity = 0.90}},
    {rule = {class = "Atom"},
        properties = {opacity = 0.90}},
    {rule = {class = "nvim-qt"},
        properties = {opacity = 0.90}},
    {rule = {class = "konsole"},
        properties = {opacity = 0.90}},
    {rule = {class = "URxvt"},
        properties = {opacity = 0.90}},
    {rule = {class = "Lxterminal"},
        properties = {opacity = 0.90}},
    {rule = {class = "Gnome-terminal"},
        properties = {opacity = 0.90}},
    {rule = {class = "URxvt"},
        properties = {size_hints_honor = false}},
    {rule = {class = "Lxterminal"},
        properties = {size_hints_honor = false}},
    {rule = {class = "Gnome-terminal"},
        properties = {size_hints_honor = false}},
    {rule = {class = "feh"},
        properties = {floating = true}},
    {rule = {class = "Gretl_x11"},
        properties = {floating = true}},
    {rule = {class = "Tor Browser"},
        properties = {tag = tags[1][6]}},
    {rule = {class = "Arandr"},
        properties = {tag = tags[1][8]}},
    {rule = {class = "chromium"},
        properties = {tag = tags[1][2]}},
    {rule = {class = "Zathura"},
        properties = {opacity = 0.90}},
    {rule = {class = "TexMaker"},
        properties = {opacity = 0.90}},
    {rule = {class = "Vlc"},
        properties = {floating = true}},
    {rule = {class = "Vinagre"},
        properties = {floating = true}},
    {rule = {role = "gimp-image-window"},
        properties = {tag = tags[1][5],
                      maximized_horizontal = true,
                      maximized_vertical = true}}
}
-- }}}
-- Signals {{{
-- signal function to execute when a new client appears {{{
client.connect_signal("manage",
    function (c, startup)
       -- sloppy focus {{{
       --[[ c:connect_signal("mouse::enter", function(c)
           if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
               and awful.client.focus.filter(c) then
               client.focus = c
           end
       end) ]]
       -- }}}
        if not startup and not c.size_hints.user_position and
           not c.size_hints.program_position then
              awful.placement.no_overlap(c)
              awful.placement.no_offscreen(c)
        end
    end)
--}}}
-- no border for maximized clients {{{
client.connect_signal("focus",
    function(c)
        if c.maximized_horizontal == true and c.maximized_vertical == true then
            c.border_color = beautiful.border_normal
        else
            c.border_color = beautiful.border_focus
        end
    end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
-- {{{ Signal handler
for s = 1, screen.count() do
    screen[s]:connect_signal("arrange",
        function ()
            local clients = awful.client.visible(s)
            local layout  = awful.layout.getname(awful.layout.get(s))

            if #clients > 0 then
                for _, c in pairs(clients) do

                    -- Disable fullscreen {{{
                    if c.fullscreen == true then
                        c.fullscreen = false
                    end
                    -- }}}

                    -- Borders {{{
                    -- floaters always have a boarder
                    if awful.client.floating.get(c) or layout == "floating" then
                        c.border_width = beautiful.border_width

                    -- no border for the only client
                    elseif #clients == 1 then
                        clients[1].border_width = 0
                    else
                        c.border_width = beautiful.border_width
                    end
                    -- }}}
                end
            end
        end)
end
-- }}}
-- }}}

-- vim:foldmethod=marker:foldlevel=0
