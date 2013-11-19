-------------------------------------------------------
--    furious.lua , lua lib for Awesome Window Manager. 
--    Copyright (C) 2013 vlamy (vlamy@vlamy.fr) 
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 2 of the License, or
--    any later version.
--
--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--
--    You should have received a copy of the GNU General Public License
--    along with this program.  If not, see <http://www.gnu.org/licenses/>.
---------------------------------------------------------------------------

------------
-- Furious modal keybing library
-- @release 1.0
-- (tested with awesome 3.5)
---------------------------------
--
-- Lua environment
local pairs     =   pairs
local awful = require("awful")
local root      =   root
local naughty   =   require("naughty")
local tostring = tostring

-- Custom keys variables
local modkey = "Mod1"
local ror_key = "t"
local catch_key = "s"
local drop_key = "r"
local client_key = "c"
local general_key = "'"

----------
-- Custom application definition
--------------------------------
--- key = hotkey
--- cmd = application launch command
--- tag = default tag
--- screen = default screen
--- match = string to match
--- match_type = match client on "instance" or "name" X window property. 
myappz = {}
myappz["f"] = { info="firefox", cmd="firefox", tag="1", screen=1, match="Firefox", match_type="instance" }
myappz["g"] = { info="chrome", cmd="chromium", tag="1", screen=2, match="Chrome", match_type="instance" }
myappz["c"] = { info="mailer", cmd="thunderbird", tag="4", screen=2, match="Thunderbird", match_type="instance" }
myappz["i"] = { info="im", cmd="pidgin", tag="4", screen=2, match="Pidgin", match_type="instance" }
myappz["e"] = { info="editor", cmd="gvim", tag="2", screen=2, match="Gvim", match_type="instance" }
myappz["t"] = { info="terminal", cmd="urxvt", tag="3", screen=2, match="terminal", match_type="instance" }

--------------
-- commands for "client mode"
-----------------------------
myclients = {}
myclients["r"] = { info = "redraw" , func = function(c) c:redraw() end }
myclients["n"] = { info = "minimize" , func = function(c) c.minimized = true end }
myclients["q"] = { info = "kill" , func = function(c) c:kill() end }
myclients["m"] = { info = "maximize" , func = function (c)
  c.maximized_horizontal = not c.maximized_horizontal
  c.maximized_vertical   = not c.maximized_vertical
end}
myclients["o"] = { info = "move to screen" , func = awful.client.movetoscreen }
myclients["f"] = { info = "toggle floating" , func = awful.client.floating.toggle }
myclients["c"] = { info = "resize" , func =  function () resize() end }

--------------
-- global mode
---------------------------------------
myglobals = {}
myglobals["r"] = { info="restart", func = awesome.restart }
myglobals["s"] = { info="shuffle", func = function() shuffle() end }
--myglobals["h"] = { info="halt", func = function() --poweroff computer-- end }
--myglobals["m"] = { info="mute", func = function() --mute soundcard-- end }

--{{{ functionnal stuff
--
-- constants
ROR = 0
CATCH = 1
DROP = 2
PLACE = 3

local teardrop = nil 


--{{{ public functions
--
---------
-- Returns client key entry for client mode
-------------------------------------------
function get_furious_clientkeys()
  local clients = {}
  clients = awful.util.table.join(clients, awful.key({modkey},client_key, function(c) clients_graber(c) end))
  return clients
end

---------
-- places all matching clients
-- to their default place (screen + tag)
----------------------------------------
function shuffle()
  for k, table in pairs(myappz) do
    grab(myappz[k], PLACE, true)
  end
end

---------
-- Initializes global keys
--------------------------
function furious_init_global(globalkeys)
  local ror_table = {}
  local catch_table = {}
  local drop_table = {}
  local glob = {}

  for k, table in pairs(myappz) do
    ror_table[k] = {info = myappz[k].info, func = function() grab(myappz[k], ROR, false) end}
    catch_table[k] = {info = myappz[k].info, func = function() grab(myappz[k], CATCH, false) end}
    drop_table[k] = {info = myappz[k].info, func = function() grab(myappz[k], DROP, false) end}
    drop_table[","] = {info = "release teardrop", func = function() release_teardrop() end}
  end

  glob = awful.util.table.join(glob, awful.key({modkey,},ror_key, function() global_keygraber("ROR", ror_table) end),
  awful.key({modkey,},catch_key, function() global_keygraber("Catch", catch_table) end),
  awful.key({modkey,},general_key, function() global_keygraber("Genaral", myglobals) end),
  awful.key({modkey,},drop_key, function() global_keygraber("drop", drop_table) end))

  root.keys(awful.util.table.join(globalkeys,glob))
end

-- public functions }}}
--
--------------
--  Defines the clients' keygrabber
-----------------------------------
function clients_graber(c)
  local menu = ""   
  for k, ta in pairs(myclients) do
    menu = menu..'\n['..k..'] --> '..ta.info
  end
  infos = naughty.notify({title = "clients", text= menu})

  --run keygrabber
  keygrabber.run(function(mod, key, event)
    if event == "release" then return end 
    if key == "Escape" then
      keygrabber.stop()
      naughty.destroy(infos)
    end
    for k, ta in pairs(myclients) do
      if key == k then
        keygrabber.stop()
        naughty.destroy(infos)
        ta.func(c)
      end 
    end
    keygrabber.stop()
  end)
end

----------
-- Prints menu and runs keygrabber
-- run_table.key (key is table key)
-- run_table.func
-------------------------------------------
function global_keygraber(title, run_table)
  --print menu
  local menu = ''   
  for k, ta in pairs(run_table) do
    menu = menu..'\n['..k..'] --> '..ta.info
  end
  infos = naughty.notify({title = title, text= menu})

  --run keygrabber
  keygrabber.run(function(mod, key, event)
    if event == "release" then return end 
    if key == "Escape" then
      keygrabber.stop()
      naughty.destroy(infos)
    end
    for k, ta in pairs(run_table) do
      if key == k then
        naughty.destroy(infos)
        ta.func()
      end 
    end
    keygrabber.stop()
  end)
end

--------
-- Returns true if all pairs in
-- table1 are present in table2
--------------------------------
function match (table1, table2)
  for k, v in pairs(table1) do
    if table2[k] ~= v and not table2[k]:find(v) then
      return false
    end
  end
  return true
end

--------
-- Releases the teardrop client.
--------------------------------
function release_teardrop()
  if teardrop ~= nil then
    local c = teardrop.client
    naughty.notify({title = "info", text= "release teardrop"})
    c:geometry({ x = x, y = y, width = width, height = height })
    c.ontop = false 
    c.above = false 
    c.skip_taskbar = false
    c.sticky = false
    awful.client.movetotag(teardrop.screen, c)
    for k,tag in pairs(awful.tag.gettags(teardrop.screen)) do
      if tag.name == teardrop.tag then
        awful.client.movetotag(tag, c)
      end
    end
    awful.client.floating.set(c, false)
    teardrop = nil
  end
end

----------
-- Grab function allows to grab any application following
-- three different modes : classic run_or_raise, catch or teardrop.
-- The application is spawned if no matching client exists.
-- Parameters :
--     -app : table that contains at least the five following fields :
--          -match : the string to use, so as to match the requested application
--          -match_type : the WM field to match again (class or name)
--          -cmd : the command to run to spawm the application
--          -tag : the default tag for the given application
--          -screen : the default screen for the given application
--     -mode : the grab mode
--          -ROR : classic run or raise will focus the requested
--          application if some matching exists. Else it will spawn
--          that application on its default tag and screen.
--          -CATCH : this mode will move the requested application
--          , if some matching client exists, to the current tag and screen.
--          Else it will spawm the application to the current tag and screen.
--          -DROP : is a teardrop like mode that spawn or move application,
--          if matching client exists, makes the client sticky (vible on all tags),
--          floating, at a given geometry (static for now).
--      -rec : indicates if the call is recursive
--           (used to ease the prevention of infinite recursion)
------------------------------------------------------------------------------------
function grab(app, mode, rec)
  local clients = client.get()
  local focused = awful.client.next(0)
  local findex = 0
  local matched_clients = {}
  local n = 0

  local properties = {}
  if app.match_type == "instance" then
    properties = {class = app.match}
  else
    properties = {name = app.match}
  end

  --look for existing match
  for i, c in pairs(clients) do
    --make an array of matched clients
    if match(properties, c) then
      n = n + 1
      matched_clients[n] = c
      if c == focused then
        findex = n
      end
    end
  end

  -- if match exist, treat the first matching clients
  if n > 0 then
    local c = matched_clients[1]
    -- if the focused window matched switch focus to next in list
    if 0 < findex and findex < n then
      c = matched_clients[findex+1]
    end

    if mode == ROR then
      local ctags = c:tags()
      if #ctags == 0 then
        -- ctags is empty, show client on current tag
        local curtag = awful.tag.selected()
        awful.client.movetotag(curtag, c)
      else
        -- Otherwise, pop to first tag client is visible on
        awful.tag.viewonly(ctags[1])
      end

    elseif mode == CATCH then
      --move client to current tag
      local curtag = awful.tag.selected()
      awful.client.movetotag(curtag, c)

    elseif mode == DROP then
      release_teardrop()
      teardrop = {client = c, tag = app.tag, screen = app.screen }
      awful.client.floating.set(c, true)
      c:geometry({ x = 300, y = 200, width = 1200, height = 600})
      c.ontop = true 
      c.above = true 
      c.skip_taskbar = true
      c.sticky = true
      awful.client.movetotag(awful.tag.selected(), c)
    elseif mode == PLACE then
      awful.client.movetoscreen(c, app.screen)
      for k,tag in pairs(awful.tag.gettags(app.screen)) do
        if tag.name == app.tag then
          awful.client.movetotag(tag, c)
        end
      end
    else
      naughty.notify({ preset = naughty.config.presets.critical,
      title = "Error in Furious lib :",
      text = "unknown grab mode :"..tostring(mode) })
    end
    -- And then focus the client
    client.focus = c
    c:raise()
  else
    --spawn and grab again
    if not rec then
      naughty.notify({title = "info", text= "spawning :"..app.info})
      awful.util.spawn(app.cmd)
      grab(app, mode, true)
    end
  end
end
-- functionnal stuff }}}
