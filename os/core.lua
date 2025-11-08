-- os/core.lua  -- WinOC desktop + lightweight window manager
local component = component
local event = require("event")
local fs = require("filesystem")
local term = require("term")
local gpu = component.gpu

-- resolution and colors
local w,h = gpu.getResolution()
if w < 60 then
  pcall(gpu.setResolution, 80, 25)
  w,h = gpu.getResolution()
end

local colors = {
  bg = 0x1E1E1E,
  task = 0x111111,
  fg = 0xFFFFFF,
  window = 0x2D2D2D,
  title = 0x3333AA,
  highlight = 0x4CAF50
}

-- simple UI helper loader
local ui = nil
if fs.exists("/os/ui.lua") then
  ui = dofile("/os/ui.lua")
else
  -- fallback minimal drawing helpers
  ui = {
    rect = function(x,y,ww,hh,c) gpu.setBackground(c); gpu.fill(x,y,ww,hh," ") end,
    text = function(x,y,s,cfg) gpu.setBackground(cfg.bg or colors.bg); gpu.setForeground(cfg.fg or colors.fg); gpu.set(x,y,s) end
  }
end

-- app list (edit to add apps)
local apps = {
  {name="Calculator", file="/os/apps/calc.lua"},
  {name="Files", file="/os/apps/files.lua"},
  {name="Editor", file="/os/apps/editor.lua"},
}

-- draw desktop background and icons
local function drawDesktop()
  ui.rect(1,1,w,h, colors.bg)
  ui.text(2,1,"WinOC - OpenComputers Desktop",{bg=colors.bg,fg=colors.fg})
  for i,app in ipairs(apps) do
    ui.text(2, 2 + (i-1)*2, "["..i.."] "..app.name, {bg=colors.bg, fg=colors.fg})
  end
  -- taskbar
  ui.rect(1, h-2, w, 3, colors.task)
  ui.text(2, h-1, "[ Start ]", {bg=colors.task, fg=colors.fg})
end

-- open an app: runs the file in the same environment (simple)
local function openApp(idx)
  local app = apps[idx]
  if not app then return end
  term.clear()
  term.setCursor(1,1)
  if fs.exists(app.file) then
    local ok, err = pcall(dofile, app.file)
    if not ok then
      print("App error: "..tostring(err))
    end
  else
    print("App not found: ".. tostring(app.file))
  end
  print("\nPress any key to return to desktop...")
  os.pullEvent("key")
  drawDesktop()
end

-- Start menu: text list
local function showStartMenu()
  term.clear()
  print("Start Menu")
  for i,app in ipairs(apps) do
    print(i .. ". " .. app.name)
  end
  print("\nType number to open or press any other key to cancel.")
  io.write("> ")
  local inp = io.read()
  local n = tonumber(inp)
  if n then openApp(n) end
  drawDesktop()
end

-- handle clicks: icons and start button
local function handleClick(x,y)
  -- icons area
  for i=1,#apps do
    local ax, ay = 2, 2 + (i-1)*2
    if x >= ax and x <= ax+30 and y == ay then
      openApp(i)
      return
    end
  end
  -- start button
  if y >= h-1 and x >= 2 and x <= 10 then
    showStartMenu()
  end
end

-- initial draw
drawDesktop()

-- main event loop
while true do
  local ev, addr, x, y = event.pull()
  if ev == "touch" or ev == "mouse_click" then
    handleClick(x,y)
  elseif ev == "key" then
    -- quick keys
    local k = addr
    -- q to quit to shell (Ctrl+Q in some configs may be different); keep minimal
    -- no-op here
  end
end
