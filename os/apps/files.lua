term.clear()
local fs = require("filesystem")
print("File Explorer")
local function listDir(path)
  path = path or "/"
  for name in fs.list(path) do
    print(name)
  end
end
listDir("/")
print("\nPress any key to return...")
os.pullEvent("key")
