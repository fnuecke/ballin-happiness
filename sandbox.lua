local component=require("component")
local event=require("event")
local tunnel=component.tunnel

require("term").clear()
print("Starting sandbox runner...")

local users = {Sangar=true, Kilobyte=true}

local function optrequire(...)
  local success, module = pcall(require, ...)
  if success then
    return module
  end
end

local function sandbox(f)
  return load(f,"=cmd",nil,setmetatable({},{__index=function(_,k)
    return _ENV[k] or optrequire(k)
  end}))
end

local function respond(c,n,msg)
  tunnel.send(c,n,msg)
end

while true do
  local _,_,_,_,_,c,n,cmd=event.pull("modem_message")
  print("["..c.."] "..n..": "..cmd)
  if users[n] then
    local f,e=sandbox("return "..cmd)
    if not f then
      f,e=sandbox(cmd)
    end
    if not f then
      respond(c,n,msg)
    else
      local _,res=coroutine.resume(coroutine.create(f))
      respond(c,n,res and tostring(res) or "done.")
    end
  else
    respond(c,n,"nope.")
  end
end
