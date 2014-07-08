-- This is hooked into OpenIRC using `/lua <the following code>`
local component=require("component")
local event=require("event")
if _G.tunnelHandler then event.ignore("modem_message",_G.tunnelHandler) end
_G.tunnelHandler = function(_,_,_,_,_,c,n,s)
  socket:write("PRIVMSG "..c.." :"..n..": "..s:gsub("\r\n", " | "):gsub("\r"," | "):gsub("\n"," | ").."\r\n")
  socket:flush()
end
event.listen("modem_message", _G.tunnelHandler)
local function name(i)
  return i and i:match("^[^!]+")
end
return function(p,c,a,m)
  local n=name(p)
  local t=a and a[1] and name(a[1]) or n
  if c == "PRIVMSG" and (t=="Sangar|Pi" or m:sub(1,11)=="Sangar|Pi, ") then
    if t=="Sangar|Pi" then
      t=n
    else
      m=m:sub(12)
    end
    component.tunnel.send(t,n,m)
  end
end