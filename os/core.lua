local component = component
local event = require("event")
local gpu = component.gpu
local w, h = gpu.getResolution()

gpu.fill(1, 1, w, h, " ")
gpu.setForeground(0xFFFFFF)
gpu.setBackground(0x0000AA)
gpu.fill(1, h, w, 1, " ") -- taskbar
gpu.set(2, h, "[ Start ]")

while true do
  local e, _, x, y = event.pull()
  if e == "touch" then
    if y == h and x >= 2 and x <= 10 then
      gpu.setForeground(0xFFFFFF)
      gpu.setBackground(0x333333)
      gpu.fill(1, h - 5, 20, 5, " ")
      gpu.set(2, h - 5, "Calculator")
      gpu.set(2, h - 4, "Text Editor")
      gpu.set(2, h - 3, "Terminal")
    end
  end
end
