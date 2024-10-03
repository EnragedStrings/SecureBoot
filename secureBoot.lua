local process = require("process")
local component = require("component")
local term = require("term")
local computer = require("computer")
local event = require("event")
local gpu = require("component").gpu
local fs = require("filesystem")
local data = require("component").data
require("ESinput")
require("ESbuttons")

local shown = false
while not (component.isAvailable("gpu") and component.isAvailable("data") do
  if shown == false then 
    term.clear()
    print("Key components not found.") 
    shown = true
  end
  os.sleep(1)
end

function split(s, delimiter)
    if s ~= nil then
      result = {};
      for match in (s..delimiter):gmatch("(.-)"..delimiter) do
          if match ~= nil then
            table.insert(result, match);
          end
          if result == nil then
            result[1] = s
            result[2] = nil
          end
      end
    end
    return result;
end

local authorization = false

local file = assert(io.open("/etc/authorized", "r"))
local fdata = file:read(1000)
file:close()
print("Boot:", fdata)
os.sleep(0.5)
if fdata ~= "denied" and fdata ~= nil and fdata ~= "" then
    print("Checking...")
    os.sleep(0.5)
    authorization = false
    local file = assert(io.open("/etc/users", "r"))
    local filedata = file:read(100000)
    file:close()
    local users = split(filedata, "\n")
    for _, user in pairs(users) do
        if user ~= "" and user ~= nil and fdata == user then 
            print("accessing...")
            authorization = true
        end
    end
else
    process.info().data.signal = function() end
    authorization = false
end

while not (component.isAvailable("data") and component.isAvailable("gpu")) and fs.isDirectory("/etc/authorized") and fs.isDirectory("/etc/Users") do
    if shown == false then 
      term.clear()
      print("Key components not found.") 
      shown = true
    end
    os.sleep(1)
end

sW, sH = gpu.getResolution()

function logo(time, color)
    term.clear()
    if color == true then
        gpu.setForeground(0x00FF00)
    end
    term.setCursor((sW/2)-33,(sH/2)-3)
    print(" ██████╗███╗   ███╗ █████╗ ██████╗        ██╗███╗  ██╗ █████╗    ")
    os.sleep(time)
    if color == true then
        gpu.setForeground(0xFFB640)
    end
    term.setCursor((sW/2)-33,(sH/2)-2)
    print("██╔════╝████╗ ████║██╔══██╗██╔══██╗       ██║████╗ ██║██╔══██╗   ")
    os.sleep(time)
    if color == true then
        gpu.setForeground(0xFF6D00)
    end
    term.setCursor((sW/2)-33,(sH/2)-1)
    print("╚█████╗ ██╔████╔██║██║  ╚═╝██████╔╝       ██║██╔██╗██║██║  ╚═╝   ")
    os.sleep(time)
    if color == true then
        gpu.setForeground(0xFF2400)
    end
    term.setCursor((sW/2)-33,(sH/2))
    print(" ╚═══██╗██║╚██╔╝██║██║  ██╗██╔═══╝        ██║██║╚████║██║  ██╗   ")
    os.sleep(time)
    if color == true then
        gpu.setForeground(0x9924C0)
    end
    term.setCursor((sW/2)-33,(sH/2)+1)
    print("██████╔╝██║ ╚═╝ ██║╚█████╔╝██║            ██║██║ ╚███║╚█████╔╝██╗")
    os.sleep(time)
    if color == true then
        gpu.setForeground(0x0092FF)
    end
    term.setCursor((sW/2)-33,(sH/2)+2)
    print("╚═════╝ ╚═╝     ╚═╝ ╚════╝ ╚═╝            ╚═╝╚═╝  ╚══╝ ╚════╝ ╚═╝")
    gpu.setForeground(0xFFFFFF)
    gpu.fill((sW/2)-35, (sH/2)-3, 1, 6, "║")
    gpu.fill((sW/2)+33, (sH/2)-3, 1, 6, "║")
    gpu.set((sW/2)-35, (sH/2)-4, "╔═══════════════════════════════════════════════════════════════════╗")
    gpu.set((sW/2)-35, (sH/2)+3, "╚═══════════════════════════════════════════════════════════════════╝")
    if color == true then
        gpu.setForeground(0xFF0000)
    end
    term.setCursor((sW/2)-33,(sH/2)+3)
    print(" Please Login ")
    if color == true then
        gpu.setForeground(0xFFFFFF)
    end
    gpu.set(1, sH, "Created By EnragedStrings")
end

function boot()
    local accessGranted = false
    logo(0.1, true)
    local Username = createInput((sW/4)-5, (sH/2)+5, 10, "Username", "Username", 0xFFFFFF, 0xFF0000, 0x5A5A5A)
    local Password = createInput((sW/4)-5, (sH/2)+7, 10, "Password", "Password", 0xFFFFFF, 0xFF0000, 0x5A5A5A)
    local submit = createButton((sW/4)-5, (sH/2)+9, 10, 1, 0xFFFFFF, "Submit", true, true, 0x000000, function()
        local file = assert(io.open("/etc/users", "r"))
        local filedata = file:read(100000)
        local users = split(filedata, "\n")
        for _, user in pairs(users) do
            local key = data.md5(getInput(Password))
            local IV = data.md5(computer.address())
            local decrypted = data.decrypt(user, key, IV)
            if decrypted == getInput(Username) then
                print("Accessing...")
                inputs[Username].active = false
                inputs[Password].active = false
                table.remove(inputs, Username)
                table.remove(inputs, Password)
                deleteButton(submit)
                event.ignore("touch", function() end)
                event.ignore("key_down", function() end)
                os.sleep(1)
                accessGranted = true
                local file = assert(io.open("/etc/authorized", "w"))
                file:write(user)
                file:close()
                computer.shutdown(true)
            end
        end
    end
    )
    inputs[Password].type = "Password"
    loadInput(Username)
    loadInput(Password)
    refreshButton(submit)
    ESIListen()
    ESBListen()
    while accessGranted == false do
        os.sleep(0)
    end
end

if authorization == true then
    local file = assert(io.open("/etc/authorized", "w"))
    file:write("denied")
    file:close()
    term.clear()
else
    boot()
end
