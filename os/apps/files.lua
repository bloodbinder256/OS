term.clear()
local fs = require("filesystem")
local cur = "/"
local function list(path)
  print("Listing: " .. path)
  for name in fs.list(path) do
    print(name)
  end
end
list(cur)
print("\nType 'cd <dir>' to change, 'q' to quit.")
while true do
  io.write("> ")
  local line = io.read()
  if not line or line == "q" then break end
  local cmd, arg = line:match("^(%S+)%s*(.*)$")
  if cmd == "cd" and arg and arg ~= "" then
    if fs.exists(arg) then cur = arg; list(cur) else print("Not found: "..arg) end
  else
    print("Unknown command")
  end
end
print("Press any key to return...")
os.pullEvent("key")
