-- core.lua -- simple desktop + launcher
local component = require("component")
local event = require("event")
local term = require("term")
local filesystem = require("filesystem")
local gpu = component.gpu

-- resolution setup (adjust as you like)
local w,h = gpu.getResolution()
if w < 60 then
  gpu.setResolution(80,25)
  w,h = gpu.getResolution()
end

-- Colors
local bg = 0x1E1E1E
local taskbg = 0x2D2D2D
local fg = 0xFFFFFF
local accent = 0x4CAF50

local function clearScreen()
  gpu.setBackground(bg)
  gpu.fill(1,1,w,h," ")
  gpu.setForeground(fg)
end

local apps = {
  {name="Calculator", file="/os/apps/calc.lua"},
  {name="Files", file="/os/apps/files.lua"},
  {name="Terminal", file="/init.lua"}, -- fallback to shell
}

-- draw desktop background and icons
local function drawDesktop()
  clearScreen()
  -- title
  gpu.setBackground(bg)
  gpu.setForeground(fg)
  gpu.set(2,1,"OpenWinOS - simple desktop")
  -- icons (left column)
  for i,app in ipairs(apps) do
    gpu.set(2, 2 + (i-1)*2, "[" .. i .. "] " .. app.name)
  end
  -- taskbar
  gpu.setBackground(taskbg)
  gpu.fill(1, h-2, w, 3, " ")
  gpu.setForeground(fg)
  gpu.set(2, h-1, "Start")
end

-- open app by launching its file in a new shell
local function openApp(index)
  local app = apps[index]
  if not app then return end
  term.clear()
  term.setCursor(1,1)
  if filesystem.exists(app.file) then
    -- run app file
    dofile(app.file)
  else
    print("App not found: " .. tostring(app.file))
    print("Press any key to return to desktop.")
    os.pullEvent("key")
  end
  drawDesktop()
end

-- mouse click handling: icons and start button
local function handleClick(x,y)
  -- icon area: x from 2 to 30, y 2..(2 + (#apps-1)*2)
  for i=1,#apps do
    local ax, ay = 2, 2 + (i-1)*2
    if x >= ax and x <= ax+30 and y == ay then
      openApp(i)
      return
    end
  end
  -- Start button area
  if y >= h-1 and x >= 2 and x <= 7 then
    -- very simple start menu: show list
    term.clear()
    print("Start Menu:")
    for i,app in ipairs(apps) do
      print(i .. ". " .. app.name)
    end
    print("Press number to open, any other key to cancel.")
    local ev, p1 = os.pullEvent("key")
    local key = p1
    local num = nil
    -- map keys 2..11 to numbers 1..10 (keyboard code mapping)
    -- easiest: read line
    term.write("> ")
    local line = io.read()
    num = tonumber(line)
    if num then openApp(num) end
    drawDesktop()
  end
end

-- start
drawDesktop()
while true do
  local ev, a, b, c = os.pullEvent()
  if ev == "touch" or ev == "mouse_click" then
    local x,y = a,b
    handleClick(x,y)
  elseif ev == "key" then
    local key = a
    -- Quit with Ctrl+Q? (not implemented inline)
  end
end
