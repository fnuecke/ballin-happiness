local component = require("component")
local event = require("event")
local tunnel = component.tunnel
local sbx = require('ubersandbox')

require("term").clear()
print("Starting sandbox runner...")

local public = false
local users = {Sangar = true, Kilobyte = true }

local pubsbx
if public then
    pubsbx = sbx.Sandbox.new('public.cfg')
end
local trustsbx = sbx.Sandbox.new('trusted.cfg')

local function respond(c,n,msg)
    tunnel.send(c, n, msg)
end

while true do
    local _, _, _, _, _, c, n, cmd = event.pull("modem_message")
    print("["..c.."] "..n..": "..cmd)
    if cmd:sub(1, 1) == '=' then
        cmd = 'return '..cmd:sub(2)
    end
    cmd = "local target, sender = ...; "..cmd
    if users[n] then
        local status, retval = trustsbx:eval(cmd, c, n)
        if not status then
            retval = string.char(3)..'04'
        end
        respond(c, n, tostring(retval))
    elseif public then
        local status, retval = pubsbx:eval(cmd, c, n)
        if not status then
            retval = string.char(3)..'04'
        end
        respond(c, n, tostring(retval))
    else
        respond(c, n, "nope.")
    end
end
