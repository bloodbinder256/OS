term.clear()
local fs = require("filesystem")
print("Tiny Editor")
io.write("Open file: ")
local filename = io.read()
if not filename or filename == "" then return end
local content = ""
if fs.exists(filename) then
  local f = io.open(filename,"r")
  content = f:read("*a")
  f:close()
end
print("----- Current content -----")
print(content)
print("Enter new content. End with a single '.' on its own line.")
local lines = {}
while true do
  local l = io.read()
  if l == "." then break end
  table.insert(lines, l)
end
local new = table.concat(lines, "\n")
local f = io.open(filename, "w")
f:write(new)
f:close()
print("Saved. Press any key to return.")
os.pullEvent("key")
