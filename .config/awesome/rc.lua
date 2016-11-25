-- Requirements {{{
------------------------------------------------------------------------------

local gears       = require("gears")        -- for wallpaper
local awful       = require("awful")
      awful.rules = require("awful.rules")
                    require("awful.autofocus")
local wibox       = require("wibox")
local beautiful   = require("beautiful")    -- theme
local naughty     = require("naughty")      -- errors
local drop        = require("scratchdrop")  -- drop-down clients
local lain        = require("lain")         -- additional widgets
local menubar     = require("menubar")      -- dmenu
local nlay        = require("nlay")         -- my layout

-- }}}
-- Aliases {{{
------------------------------------------------------------------------------

modkey      = "Mod4"
altkey      = "Mod3"
shift       = "Shift"
alt         = "Alt"
ctrl        = "Control"

terminal    = "konsole -e zsh"
yarminal    = "urxvt"
tmux        = "konsole -e tmux"
bash        = "konsole -e bash"
ranger      = "konsole -e ranger"
browser     = "chromium"
browser2    = "firefox-beta"
kiosked     = "chromium --kiosk"
pronmode    = "firefox-beta --private-window"
filemgr     = ranger
filemgr2    = "thunar"
gvim        = "konsole -e nvim"
atom        = "atom"
touchenable = "touchpad_ctrl"

-- }}}
-- Error Handling {{{
------------------------------------------------------------------------------

if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = "Oops, you're out of luck, buddy!",
        text = awesome.startup_errors
    })
end

do
    local in_error = false
    awesome.connect_signal(
        "debug::error",
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
        end
    )
end

-- }}}
-- Autostart applications {{{
------------------------------------------------------------------------------

function run_once(cmd)
      findme = cmd
      firstspace = cmd:find(" ")
      if firstspace then
          findme = cmd:sub(0, firstspace-1)
      end
      awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end

-- Environment / Settings {{{

run_once("compton -b")
run_once("export QT_QPA_PLATFORMTHEME='qt5ct'")
run_once("unclutter -idle 1")
run_once("xrdb -merge /home/$USER/.Xresources && xrdb ~/.Xresources")
run_once("xmodmap /home/$USER/.Xmodmap")
run_once("xset s off && xset -dpms && xset r rate 200 60")
run_once("xscreensaver -nosplash &")
beautiful.init(os.getenv("HOME") .. "/.config/awesome/theme.lua")

-- }}}
-- User Applications {{{

run_once(browser)
run_once(terminal)

-- }}}
-- }}}
-- Layouts & Tags Table {{{
------------------------------------------------------------------------------
-- Create {{{

local layouts = {
    nlay,
    awful.layout.suit.tile,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top
    -- awful.layout.suit.fair,fair
    -- awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.spiral.dwindle,
}

tags = {
    name = { "1", "2", "3", "4", "5", "6", "7", "8", "9" },
    layout = {
        layouts[4], layouts[1], layouts[1], layouts[1], layouts[1],
        layouts[2], layouts[2], layouts[2], layouts[3]
    }
}

for s = 1, screen.count() do
    tags[s] = awful.tag(tags.name, s, tags.layout)
end

-- }}}
-- Config {{{

-- primary screen
-- tag 1
awful.tag.setnmaster(1, tags[1][1])
awful.tag.setncol(1, tags[1][1])
awful.tag.setmwfact(0.85, tags[1][1])

-- tags 2-8
for t = 2, 8 do
    awful.tag.setnmaster(1, tags[1][t])
    awful.tag.setncol(1, tags[1][t])
    awful.tag.setmwfact(0.625, tags[1][t])
end

-- tag 9
awful.tag.setnmaster(3, tags[1][9])
awful.tag.setncol(1, tags[1][9])
awful.tag.setmwfact(0.5, tags[1][9])

-- secondary screens
for s = 2, screen.count() do
    for t = 1, 9 do
        awful.tag.setnmaster(1, tags[s][t])
        awful.tag.setncol(1, tags[s][t])
        awful.tag.setmwfact(0.625, tags[s][t])
    end
end

-- }}}
-- }}}
-- Wallpaper {{{
------------------------------------------------------------------------------

if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end

-- }}}
-- Batttery Warning {{{
------------------------------------------------------------------------------

local function trim(s)
    return s:find'^%s*$' and '' or s:match'^%s*(.*%S)'
end

local function bat_notification()
    local f_capacity = assert(io.open("/sys/class/power_supply/BAT1/capacity", "r"))
    local f_status = assert(io.open("/sys/class/power_supply/BAT1/status", "r"))
    local bat_capacity = tonumber(f_capacity:read("*all"))
    local bat_status = trim(f_status:read("*all"))

    if (bat_capacity <= 20 and bat_status == "Discharging") then
        naughty.notify({
            title = "Battery Warning",
            text = "Battery low! " .. bat_capacity .."%" .. " left!",
            fg = beautiful.bg,
            bg = beautiful.danger,
            timeout= 59,
            position   = "top_right"
        })
    end
end

battimer = timer({timeout = 60})
battimer:connect_signal("timeout", bat_notification)
battimer:start()

-- }}}
-- Wibox Widgets {{{
------------------------------------------------------------------------------
-- memory {{{

memwidget = lain.widgets.mem({
    settings = function()
        if mem_now.used < 1000 then
            widget:set_text(' ' .. mem_now.used)
        else
            widget:set_text(mem_now.used)
        end
    end
})

memwidget_margin = wibox.layout.margin()
    memwidget_margin:set_widget(memwidget)
    memwidget_margin:set_bottom(1)
    memwidget_margin:set_left(3)

memwidget_wrap = wibox.widget.background()
    memwidget_wrap:set_widget(memwidget_margin)
    memwidget_wrap:set_bg(beautiful.midgray_0)
--    memwidget_wrap:set_bgimage(beautiful.powerline_left_gray)
    memwidget_wrap:set_fg(beautiful.fg)

-- }}}
-- cpu {{{

cpuwidget = lain.widgets.cpu({
    settings = function()
        widget:set_text(":" .. cpu_now.usage)
    end
})

cpuwidget_margin = wibox.layout.margin()
    cpuwidget_margin:set_widget(cpuwidget)
    cpuwidget_margin:set_right(4)
    cpuwidget_margin:set_bottom(1)

cpuwidget_wrap = wibox.widget.background()
    cpuwidget_wrap:set_widget(cpuwidget_margin)
    cpuwidget_wrap:set_bg(beautiful.midgray_0)
    --cpuwidget_wrap:set_bgimage(beautiful.powerline_left_gray)
    cpuwidget_wrap:set_fg(beautiful.primary)


-- }}}
-- alsa volume {{{

volumewidget = lain.widgets.alsa({
    settings = function()
        if volume_now.status == "off" then
            volume_now.level = volume_now.level .. "M"
        end
        widget:set_text(volume_now.level .. "%")
    end
})


-- volicon_img = wibox.widget.imagebox(beautiful.widget_vol)
-- volicon_bg = wibox.widget.background()
--     volicon_bg:set_widget(volicon_img)
--     volicon_bg:set_bg(beautiful.midgray_1)
-- volicon_wrap = wibox.layout.margin()
--     volicon_wrap:set_widget(volicon_bg)
--     volicon_wrap:set_top(-2)
--     volicon_wrap:set_right(-2)
--     volicon_wrap:set_bottom(-1)
--     volicon_wrap:set_left(-2)

volumewidget_margin = wibox.layout.margin()
    volumewidget_margin:set_widget(volumewidget)
    volumewidget_margin:set_right(4)
    volumewidget_margin:set_bottom(1)
    volumewidget_margin:set_left(2)
volumewidget_wrap = wibox.widget.background()
    volumewidget_wrap:set_widget(volumewidget_margin)
    volumewidget_wrap:set_bg(beautiful.midgray_1)
    --volumewidget_wrap:set_bgimage(beautiful.powerline_left_gray)
    volumewidget_wrap:set_fg(beautiful.fg)

-- }}}
-- battery {{{

batwidget = lain.widgets.bat({
    settings = function()
        if bat_now.perc == "N/A" then
            bat_now.perc = bat_now.perc .. "C"
        else
            bat_now.perc = bat_now.perc .. "%"
        end
        widget:set_text(bat_now.perc)
    end
})

batwidget_margin = wibox.layout.margin()
    batwidget_margin:set_widget(batwidget)
    batwidget_margin:set_right(4)
    batwidget_margin:set_bottom(1)
    batwidget_margin:set_left(2)

batwidget_wrap = wibox.widget.background()
    batwidget_wrap:set_widget(batwidget_margin)
    batwidget_wrap:set_bg(beautiful.midgray_0)
    batwidget_wrap:set_fg(beautiful.primary)

-- baticon_img = wibox.widget.imagebox(beautiful.widget_batt)
-- baticon_bg = wibox.widget.background()
--     baticon_bg:set_widget(baticon_img)
--     baticon_bg:set_bg(beautiful.midgray_0)
-- baticon_wrap = wibox.layout.margin()
--     baticon_wrap:set_widget(baticon_bg)
--     baticon_wrap:set_top(-1)
--     baticon_wrap:set_right(-2)
--     baticon_wrap:set_bottom(-1)
--     baticon_wrap:set_left(-2)

-- }}}
-- date {{{

datewidget = awful.widget.textclock(
    '<span>' ..  tostring("%d-%a") ..  '</span>',
    100
)
datewidget_margin = wibox.layout.margin()
    datewidget_margin:set_widget(datewidget)
    datewidget_margin:set_right(4)
    datewidget_margin:set_bottom(1)
    datewidget_margin:set_left(3)

datewidget_wrap = wibox.widget.background()
    datewidget_wrap:set_widget(datewidget_margin)
    datewidget_wrap:set_bg(beautiful.midgray_1)
    --datewidget_wrap:set_bgimage(beautiful.powerline_left_gray_long)
    datewidget_wrap:set_fg(beautiful.fg)

-- }}}
-- clock {{{

clockwidget = awful.widget.textclock(
    '<span>' ..  tostring("%H:%M") ..  '</span>',
    10
)

clockwidget_margin = wibox.layout.margin()
    clockwidget_margin:set_widget(clockwidget)
    clockwidget_margin:set_right(4)
    clockwidget_margin:set_bottom(2)
    clockwidget_margin:set_left(3)

clockwidget_wrap = wibox.widget.background()
    clockwidget_wrap:set_widget(clockwidget_margin)
    clockwidget_wrap:set_bg(beautiful.primary)
    --clockwidget_wrap:set_bgimage(beautiful.powerline_left_orange_long)
    clockwidget_wrap:set_fg(beautiful.black)

-- }}}
-- arrows {{{

midgray1_to_primary_img  = wibox.widget.imagebox(beautiful.midgray1_to_primary)
midgray1_to_primary = wibox.layout.margin()
    midgray1_to_primary:set_widget(midgray1_to_primary_img)
    midgray1_to_primary:set_margins(-1)

midgray1_to_midgray0_img = wibox.widget.imagebox(beautiful.midgray1_to_midgray0)
midgray1_to_midgray0 = wibox.layout.margin()
    midgray1_to_midgray0:set_widget(midgray1_to_midgray0_img)
    midgray1_to_midgray0:set_margins(-1)

midgray0_to_midgray1_img = wibox.widget.imagebox(beautiful.midgray0_to_midgray1)
midgray0_to_midgray1 = wibox.layout.margin()
    midgray0_to_midgray1:set_widget(midgray0_to_midgray1_img)
    midgray0_to_midgray1:set_margins(-1)

black_to_midgray0_img    = wibox.widget.imagebox(beautiful.black_to_midgray0)
black_to_midgray0 = wibox.layout.margin()
    black_to_midgray0:set_widget(black_to_midgray0_img)
    black_to_midgray0:set_margins(-1)

midgray0_to_black_right_img = wibox.widget.imagebox(beautiful.midgray0_to_black_right)
midgray0_to_black_right = wibox.layout.margin()
    midgray0_to_black_right:set_widget(midgray0_to_black_right_img)
    midgray0_to_black_right:set_margins(-1)

volicon_img = wibox.widget.imagebox(beautiful.widget_vol)
volicon = wibox.layout.margin()
    volicon:set_widget(volicon_img)
    volicon:set_margins(-1)

baticon_img = wibox.widget.imagebox(beautiful.widget_bat)
baticon = wibox.layout.margin()
    baticon:set_widget(baticon_img)
    baticon:set_margins(-1)

loadicon_img = wibox.widget.imagebox(beautiful.widget_load)
loadicon = wibox.layout.margin()
    loadicon:set_widget(loadicon_img)
    loadicon:set_margins(-1)

-- }}}

-- }}}
-- Wibox {{{
------------------------------------------------------------------------------

mywibox = {}

mytaglist = {}
mypromptbox = {}
mytasklist = {}

-- buttons {{{

mytaglist.buttons = awful.util.table.join(
    awful.button({},       1, awful.tag.viewonly),
    awful.button({},       3, awful.tag.viewtoggle),
    awful.button({modkey}, 1, awful.client.movetotag),
    awful.button({modkey}, 3, awful.client.toggletag)
)


mytasklist.buttons = awful.util.table.join(
    awful.button({}, 1,
        function (c)
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
        end
    )
)

-- }}}

for s = 1, screen.count() do

    mytaglist[s] = awful.widget.taglist(
        s,
        awful.widget.taglist.filter.all,
        mytaglist.buttons
    )

    local taglist_margin = wibox.layout.margin()
          taglist_margin:set_widget(mytaglist[s])
          taglist_margin:set_margins(0)

    local taglist_wrap = wibox.widget.background()
          taglist_wrap:set_widget(taglist_margin)
          taglist_wrap:set_bg(beautiful.midgray_0)

    mypromptbox[s] = awful.widget.prompt()

    mytasklist[s] = awful.widget.tasklist(
        s,
        awful.widget.tasklist.filter.currenttags,
        mytasklist.buttons
    )

    mywibox[s] = awful.wibox({
        position = "top",
        screen = s,
        height = 16
    })
    -- Left {{{

    local promptbox_margin = wibox.layout.margin()
          promptbox_margin:set_widget(mypromptbox[s])
          promptbox_margin:set_margins(0)

    local promptbox_wrap = wibox.widget.background()
          promptbox_wrap:set_widget(promptbox_margin)
          promptbox_wrap:set_bg(beautiful.midgray_0)

    local left_layout = wibox.layout.fixed.horizontal()
          left_layout:add(taglist_wrap)
          left_layout:add(promptbox_wrap)
          left_layout:add(midgray0_to_black_right)

    -- }}}
    -- Right {{{

    local right_layout = wibox.layout.fixed.horizontal()


    if s == 1 then
        right_layout:add(wibox.widget.systray())
    end
    right_layout:add(black_to_midgray0)
    right_layout:add(loadicon)
    right_layout:add(memwidget_wrap)
    right_layout:add(cpuwidget_wrap)

    right_layout:add(midgray0_to_midgray1)
    right_layout:add(volicon)
    right_layout:add(volumewidget_wrap)

    right_layout:add(midgray1_to_midgray0)
    right_layout:add(baticon)
    right_layout:add(batwidget_wrap)

    right_layout:add(midgray0_to_midgray1)
    right_layout:add(datewidget_wrap)

    right_layout:add(midgray1_to_primary)
    right_layout:add(clockwidget_wrap)




    -- }}}
    -- Bring it all together {{{

    local layout = wibox.layout.align.horizontal()
    local layout_margin = wibox.layout.margin()
    layout_margin:set_widget(layout)
    layout_margin:set_margins(0)

    local left_layout_margin = wibox.layout.margin()
          left_layout_margin:set_widget(left_layout)
          left_layout_margin:set_margins(0)

    local right_layout_margin = wibox.layout.margin()
          right_layout_margin:set_widget(right_layout)
          right_layout_margin:set_margins(0)

    layout:set_left(   left_layout_margin  )
    layout:set_middle( mytasklist[s])
    layout:set_right(  right_layout_margin )

    mywibox[s]:set_widget(layout)

    -- }}}

end

-- }}}
-- Keybindings {{{
------------------------------------------------------------------------------
-- Global keybindings {{{
------------------------------------------------------------------------------
globalkeys = awful.util.table.join(
    -- focus clients {{{

    awful.key(
        {modkey}, "j",
        function()
            awful.client.focus.global_bydirection("down")
            if client.focus
                then client.focus:raise()
            end
        end
    ),

    awful.key(
        {modkey}, "k",
        function()
            awful.client.focus.global_bydirection("up")
            if client.focus
                then client.focus:raise()
            end
        end
    ),

    awful.key(
        {modkey}, "h",
        function()
            awful.client.focus.global_bydirection("left")
            if client.focus
                then client.focus:raise()
            end
        end
    ),

    awful.key(
        {modkey}, "l",
        function()
            awful.client.focus.global_bydirection("right")
            if client.focus
                then client.focus:raise()
            end
        end
    ),

    awful.key(
        {modkey}, "w",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus
                then client.focus:raise()
            end
        end
    ),

    awful.key(
        {modkey}, "b",
        function ()
            awful.client.focus.history.previous()
            if client.focus
                then client.focus:raise()
            end
        end
    ),

    --}}}
  -- swap clients {{{

    awful.key(
        {modkey, shift}, "j",
        function () awful.client.swap.global_bydirection("down") end
    ),

    awful.key(
        {modkey, shift}, "k",
        function () awful.client.swap.global_bydirection("up") end
    ),

    awful.key(
        {modkey, shift}, "h",
        function () awful.client.swap.global_bydirection("left") end
    ),

    awful.key(
        {modkey, shift}, "l",
        function () awful.client.swap.global_bydirection("right") end
    ),

    --}}}
    -- restore minimized {{{

    awful.key(
        {modkey}, "a",
        function () awful.client.restore() end
    ),

    -- }}}
    -- manual layout manipulation {{{

    awful.key(
        {modkey}, "space",
        function () awful.layout.inc(layouts,  1) end
    ),

    awful.key(
        {modkey}, "period",
        function () awful.tag.incncol(1) end
    ),

    awful.key(
        {modkey}, "comma",
        function () awful.tag.incncol(-1) end
    ),

    awful.key(
        {modkey}, "Down",
        function () awful.tag.incnmaster(-1) end
    ),

    awful.key(
        {modkey}, "Up",
        function () awful.tag.incnmaster(1) end
    ),

    awful.key(
        {modkey}, "Right",
        function () awful.tag.incmwfact(0.01) end
    ),

    awful.key(
        {modkey}, "Left",
        function () awful.tag.incmwfact(-0.01) end
    ),

    awful.key(
        {modkey, shift}, "Right",
        function () awful.tag.incmwfact(0.05) end
    ),

    awful.key(
        {modkey, shift}, "Left",
        function () awful.tag.incmwfact(-0.05) end
    ),

    -- }}}
    -- focus (nonempty) tags {{{

    awful.key(
        {modkey}, "Next",
        function () lain.util.tag_view_nonempty(1) end
    ),

    awful.key(
        {modkey}, "Prior",
        function () lain.util.tag_view_nonempty(-1) end
    ),

    -- }}}
    -- focus screens {{{

    awful.key(
        {modkey}, "F1",
        function () awful.screen.focus(1) end
    ),

    awful.key(
        {modkey}, "F2",
        function () awful.screen.focus(2) end
    ),

    awful.key(
        {modkey}, "F3",
        function () awful.screen.focus(3) end
    ),

    -- }}}
    -- menus and similar {{{

    awful.key(
        {modkey}, "z",
        function () menubar.show() end
    ),

    awful.key(
        {modkey}, "x",
        function () mypromptbox[mouse.screen]:run() end
    ),

    -- }}}
    -- applications {{{

    awful.key(
        {modkey}, "Return",
        function () awful.util.spawn(terminal) end
    ),

    awful.key(
        {modkey}, "KP_Enter",
        function () awful.util.spawn_with_shell(yarminal) end
    ),

    awful.key(
        {altkey}, "grave",
        function () awful.util.spawn(gvim) end
    ),

    awful.key(
        {altkey}, "1",
        function () awful.util.spawn(browser) end
    ),

    awful.key(
        {altkey, ctrl}, "1",
        function () awful.util.spawn("tor-browser-en") end
    ),

    awful.key(
        {altkey}, "2",
        function () awful.util.spawn(browser2) end
    ),

    awful.key(
        {altkey, ctrl}, "2",
        function () awful.util.spawn(kiosked) end
    ),

    awful.key(
        {altkey}, "3",
        function () awful.util.spawn(atom) end
    ),

    awful.key(
        {altkey}, "4",
        function () awful.util.spawn("inkscape") end
    ),

    awful.key(
        {altkey}, "5",
        function () awful.util.spawn("gimp") end
    ),

    awful.key(
        {altkey}, "6",
        function () awful.util.spawn(bash) end
    ),

    awful.key(
        {altkey}, "7",
        function () awful.util.spawn(arandr) end
    ),

    awful.key(
        {altkey}, "8",
        function () awful.util.spawn("transset-df 1") end
    ),

    awful.key(
        {altkey, ctrl}, "8",
        function () awful.util.spawn("transset-df .8") end
    ),

    awful.key(
        {altkey}, "9",
        function () awful.util.spawn("transset-df .65") end
    ),

    awful.key(
        {altkey, ctrl}, "9",
        function () awful.util.spawn("transset-df .4") end
    ),

    -- }}}
    -- scratchdrop applications {{{

    awful.key(
        {modkey}, "grave",
        function () drop(terminal) end
    ),

    awful.key(
        {modkey}, "Tab" ,
        function () drop(ranger) end
    ),

    awful.key(
        {modkey}, "KP_Subtract",
        function () drop(pronmode) end
    ),

    awful.key(
        {modkey}, "KP_Divide",
        function () drop(gvim) end
    ),

    awful.key(
        {modkey}, "KP_Multiply",
        function () drop(tmux) end
    ),

    -- }}}
    -- actions {{{

    awful.key(
        {modkey, ctrl}, "r",
        awesome.restart
    ),


    awful.key(
        {modkey, ctrl}, "q",
        awesome.quit
    ),


    awful.key(
        {modkey}, "F10",
        function () awful.util.spawn(touchenable) end
    ),


    awful.key(
        {modkey}, "F12",
        function () awful.util.spawn("xscreensaver-command -lock") end
    ),


    awful.key(
        {modkey}, "c",
        function () os.execute("xsel -p -o | xsel -i -b") end
    ),


    awful.key(
        {}, "XF86AudioRaiseVolume",
        function ()
            awful.util.spawn("amixer -q set Master 5%+")
            volumewidget.update()
        end
    ),


    awful.key(
        {}, "XF86AudioLowerVolume",
        function ()
            awful.util.spawn("amixer -q set Master 5%-")
            volumewidget.update()
        end
    ),


    awful.key(
        {}, "XF86AudioMute",
        function ()
            awful.util.spawn("amixer -q set Master playback toggle")
            volumewidget.update()
        end
    )

    -- }}}
)
-- }}}
-- Client keybindings {{{
------------------------------------------------------------------------------
clientkeys = awful.util.table.join(

    awful.key(
        {modkey, shift}, "F1",
        function(c) awful.client.movetoscreen(c, 1) end
    ),

    awful.key(
        {modkey, shift}, "F2",
        function(c) awful.client.movetoscreen(c, 2) end
    ),

    awful.key(
        {modkey, shift}, "F3",
        function(c) awful.client.movetoscreen(c, 3) end
    ),

    awful.key(
        {modkey}, "slash",
        function (c) c:swap(awful.client.getmaster()) end
    ),

    awful.key(
        {modkey}, "Escape",
        function (c) c:kill() end
    ),

    awful.key(
        {modkey}, "n",
        function (c) c.minimized = true end
    ),

    awful.key(
        {modkey}, "y",
        function (c) c.sticky = not c.sticky end
    ),

    awful.key(
        {modkey}, "g",
        function (c) awful.client.floating.toggle() end
    ),

    awful.key(
        {modkey}, "t",
        function (c) c.ontop = not c.ontop end
    ),

    awful.key(
        {modkey}, "u",
        function (c) c.below = not c.below end
    ),

    awful.key(
        {modkey}, "d",
        function (c) c.size_hints_honor = not c.size_hints_honor end
    ),

    awful.key(
        {modkey}, "i",
        function (c) c.above = not c.above end
    ),

    awful.key(
        {modkey}, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end
    ),

    awful.key(
        {modkey}, "minus",
        function (c) c.maximized_horizontal = not c.maximized_horizontal end
    ),

    awful.key(
        {modkey}, "backslash",
        function (c) c.maximized_vertical = not c.maximized_vertical end
    )
)
-- }}}
-- Tags manipulation {{{
------------------------------------------------------------------------------

for i = 1, 9 do
    globalkeys = awful.util.table.join(
        globalkeys,

        awful.key(
            {modkey}, "#"..i + 9,
            function ()
                for s = 1, screen.count() do
                    local ss = screen.count() + 1 - s
                    local tag = awful.tag.gettags(ss)[i]

                    if tag then
                        awful.tag.viewonly(tag)
                    end
                end
            end
        ),

        awful.key(
            {modkey, shift}, "#"..i + 9,
            function ()
                local tag = awful.tag.gettags(client.focus.screen)[i]

                if client.focus and tag then
                    awful.client.toggletag(tag)
                end
            end
        )
    )
end

-- }}}
-- Mouse buttons {{{
------------------------------------------------------------------------------

clientbuttons = awful.util.table.join(

    awful.button(
        {}, 1,
        function (c)
            client.focus = c; c:raise()
        end
    ),

    awful.button(
        {modkey}, 1,
        awful.mouse.client.move
    ),

    awful.button(
        {modkey}, 3,
        awful.mouse.client.resize
    )
)

-- }}}
root.keys(globalkeys)
-- }}}
-- Rules {{{
------------------------------------------------------------------------------
awful.rules.rules = {
    { rule = {},
      callback = awful.client.setslave
    },
    { rule = {},
      properties = {
          border_width = beautiful.border_width,
          focus = awful.client.focus.filter,
          keys = clientkeys,
          buttons = clientbuttons,
          size_hints_honor = true,
      },
    },

    { rule = { name = "Page(s) Unresponsive" },
      properties = { floating = true }
    },
    { rule = { name = "Firefox Preferences" },
      properties = { floating = true }
    },
    { rule = { name = "Adblock Plus Filter Preferences"},
      properties = { floating = true }
    },
    { rule = { class = "Chromium" },
      properties = {
          floating = false,
          maximized_horizontal = false,
          maximized_vertical = false,
          tag=tags[1][1]
      }
    },
    { rule = {
        class = "Chromium",
        name = "Task Manager - Chromium"
      },
      properties = { floating = true }
    },
    { rule = {class = "konsole"},
      properties = { opacity = 0.85 }
    },
    { rule = {class = "URxvt"},
      properties = {
          opacity = 0.90,
          size_hints_honor = false
      }
    },
    { rule = {class = "Zathura"},
      properties = { opacity = 0.90}
    },
    { rule = {class = "feh"},
      properties = { floating = true}
    },
    { rule = { role = "gimp-image-window"},
      properties = {
          tag = tags[1][5],
          maximized_horizontal = true,
          maximized_vertical = true
      }
    },
    { rule = {class = "Inkscape"},
      properties = { tag = tags[1][4]}
    },
    { rule = {class = "Tor Browser"},
      properties = { tag = tags[1][6]}
    },
    { rule = {class = "Arandr"},
      properties = { tag = tags[1][8]}
    },
    { rule = {class = "Vlc"},
      properties = { floating = true}
    }
}
-- }}}
-- Signals {{{
------------------------------------------------------------------------------
-- signal function to execute when a new client appears {{{

client.connect_signal(
    "manage",
    function (c, startup)
        if not startup and
           not c.size_hints.user_position and
           not c.size_hints.program_position then
              awful.placement.no_overlap(c)
              awful.placement.no_offscreen(c)
        end
       -- sloppy focus {{{
       --[[ c:connect_signal("mouse::enter", function(c)
           if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
               and awful.client.focus.filter(c) then
               client.focus = c
           end
       end) ]]
       -- }}}
    end
)

--}}}
-- no border for maximized clients {{{

client.connect_signal(
    "focus",
    function(c)
        if c.maximized_horizontal == true and
           c.maximized_vertical == true then
               c.border_color = beautiful.border_normal
        else
            c.border_color = beautiful.border_focus
        end
    end
)

client.connect_signal(
    "unfocus",
    function(c)
        c.border_color = beautiful.border_normal
    end
)

-- }}}
-- signal handler {{{

for s = 1, screen.count() do
    screen[s]:connect_signal(
        "arrange",
        function ()
            local clients = awful.client.visible(s)
            local layout  = awful.layout.getname(awful.layout.get(s))

            if #clients > 0 then
                for _, c in pairs(clients) do

                    -- disable fullscreen
                    if c.fullscreen == true then
                        c.fullscreen = false
                    end

                    -- borders
                    if awful.client.floating.get(c) or layout == "floating" then
                        c.border_width = beautiful.border_width -- floaters always have a boarder
                    elseif #clients == 1 then
                        clients[1].border_width = 0 -- no border for the only client
                    else
                        c.border_width = beautiful.border_width
                    end
                end
            end
        end
    )
end

-- }}}
-- }}}

-- vim:foldmethod=marker:foldlevel=0
