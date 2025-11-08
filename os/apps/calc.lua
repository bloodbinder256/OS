term.clear()
print("Calculator")
print("Enter an expression (e.g. 2+2) or 'q' to quit.")
while true do
  io.write("> ")
  local s = io.read()
  if not s or s == "q" then break end
  local ok, res = pcall(function() return load("return "..s)() end)
  if ok then print("= " .. tostring(res)) else print("Invalid expression") end
end
print("Press any key to return...")
os.pullEvent("key")

