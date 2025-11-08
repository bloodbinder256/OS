-- os/ui.lua -- small UI helpers (windows, buttons, text)
local component = component
local gpu = component.gpu
local fs = require("filesystem")

local M = {}

local function setColors(bg, fg)
  gpu.setBackground(bg)
  gpu.setForeground(fg)
end

function M.rect(x,y,w,h, color)
  setColors(color or 0x000000, 0xFFFFFF)
  gpu.fill(x,y,w,h," ")
end

function M.text(x,y,txt, opts)
  opts = opts or {}
  local bg = opts.bg or 0x000000
  local fg = opts.fg or 0xFFFFFF
  setColors(bg, fg)
  gpu.set(x,y,txt)
end

function M.window(x,y,w,h, title)
  M.rect(x,y,w,h, 0x2D2D2D)
  M.rect(x, y, w, 1, 0x3333AA)
  M.text(x+1, y, " "..(title or "Window").." ", {bg=0x3333AA, fg=0xFFFFFF})
end

return M
