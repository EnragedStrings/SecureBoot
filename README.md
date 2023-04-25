# SecureBoot
OpenComputers Secure Boot system with AES256


you must have a '.install' file on the floppy drive. The code inside the file is the following:

local computer = require("computer")
local shell = require("shell")
local fs = require("filesystem")
local term = require("term")

--Ensure that the home variable has the current floppy disk address. a20 is the example.

local home = '/mnt/a20/'

local bootLocation = home..'secureBoot.lua'
local bootDest = '/etc/secureBoot.lua'

local userLocation = home..'createUser.lua'
local userDest = '/home/createUser.lua'

local buttonLocation = home..'ESbuttons.lua'
local buttonDest = '/lib/ESbuttons.lua'

local inputLocation = home..'ESinput.lua'
local inputDest = '/lib/ESinput.lua'

local authLocation = home..'authorized'
local authDest = '/etc/authorized'

fs.copy(bootLocation, bootDest)
fs.copy(userLocation, userDest)
fs.copy(buttonLocation, buttonDest)
fs.copy(inputLocation, inputDest)
fs.copy(authLocation, authDest)

local file = assert(io.open("/home/.shrc", "w"))
file:write("/etc/secureBoot.lua")
file:close()
term.clear()
shell.execute("createUser")
