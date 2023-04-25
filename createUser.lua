local process = require("process")
local component = require("component")
local term = require("term")
local computer = require("computer")
local gpu = require("component").gpu
local event = require("event")
local internet = require("internet")
local serialization = require("serialization")
local shell = require("shell")
local fs = require("filesystem")
local data = require("component").data

print("Input Username")
local username = io.read()
print("Input Password")
local password = io.read()
print("Verify Password")
local vpassword = io.read()

if password ~= vpassword then
    while password ~= vpassword do
        print("Passwords do not match")
        print("Input Password")
        password = io.read()
        print("Verify Password")
        vpassword = io.read()
    end
end

local key = data.md5(password)
local IV = data.md5(computer.address())
local encrypted = data.encrypt(username, key, IV)
print(encrypted)
local decrypted = data.decrypt(encrypted, key, IV)
if username == decrypted then
    print("Encryption Successful!")
    local file = assert(io.open("/etc/users", "w"))
    local data = file:read(100000)
    if data == nil then
        data = ""
    end
    file:write(data..encrypted.."\n")
    file:close()
    term.clear()
end
