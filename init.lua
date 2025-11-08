local component = component
local gpu = component.gpu
local screen = component.screen
gpu.bind(screen)
gpu.setResolution(80, 25)
gpu.fill(1, 1, 80, 25, " ")
gpu.set(2, 2, "Booting WinOC...")

local ok, err = pcall(dofile, "/os/core.lua")
if not ok then
  gpu.set(2, 4, "Boot error: " .. tostring(err))
end
