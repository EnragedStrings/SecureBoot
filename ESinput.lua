local component = require("component")
local event = require("event")
local term = require("term")
local gpu = require("component").gpu
local screen = require("component").screen

inputs = {}

function createInput(x, y, w, name, placeholder, background, foreground, mid)
    for i = 1, #inputs do
        if inputs[i].name == name then
            table.remove(inputs, i)
        end
    end
    table.insert(inputs, 
        {
            x = x*2,
            y = y,
            w = w*2,
            name = name,
            placeholder = placeholder,
            background = background,
            foreground = foreground,
            mid = mid,
            inputText = "",
            active = true,
            selected = false,
            type = "text"
        }
    )
    return #inputs
end
function loadInput(pos)
    if inputs[pos].active then
        local prevBkgnd = gpu.getBackground()
        local prevFrgnd = gpu.getForeground()
        inputs[pos].active = true
        gpu.setBackground(inputs[pos].background)
        gpu.fill(inputs[pos].x, inputs[pos].y, inputs[pos].w, 1, " ")

        if inputs[pos].inputText == "" and activeInput ~= pos then

            gpu.setForeground(inputs[pos].mid)
            gpu.set(inputs[pos].x+1, inputs[pos].y, string.sub(inputs[pos].placeholder, 1, inputs[pos].w-2))

        elseif activeInput == pos then

            gpu.setForeground(inputs[pos].foreground)
            if string.lower(inputs[pos].type) == "password" then
                local hiddenText = ""
                for i = 1, #inputs[pos].inputText do
                    hiddenText = hiddenText.."*"
                end
                gpu.set(inputs[pos].x+1, inputs[pos].y, string.sub(hiddenText, 1, inputs[pos].w-3))
            else
                gpu.set(inputs[pos].x+1, inputs[pos].y, string.sub(inputs[pos].inputText, 1, inputs[pos].w-3))
            end
            gpu.setForeground(inputs[pos].mid)
            gpu.set(inputs[pos].x+1 + #string.sub(inputs[pos].inputText, 0, inputs[pos].w-3), inputs[pos].y, "|")

        elseif activeInput ~= pos and inputs[pos].inputText ~= "" then

            gpu.setForeground(inputs[pos].foreground)
            if string.lower(inputs[pos].type) == "password" then
                local hiddenText = ""
                for i = 1, #inputs[pos].inputText do
                    hiddenText = hiddenText.."*"
                end
                gpu.set(inputs[pos].x+1, inputs[pos].y, string.sub(hiddenText, 1, inputs[pos].w-3))
            else
                gpu.set(inputs[pos].x+1, inputs[pos].y, string.sub(inputs[pos].inputText, 1, inputs[pos].w-3))
            end

        end
        
        gpu.setBackground(prevBkgnd)
        gpu.setForeground(prevFrgnd)
    end
end
function typing(_, address, char, code, player)
    if activeInput ~= nil and inputs[activeInput].active then
        if 60 > code and code ~= 14 and code ~= 28 and code ~= 15 and code ~= 58 and code ~= 42 and code ~= 29 and code ~= 54 then
            inputs[activeInput].inputText = inputs[activeInput].inputText..string.char(char)
        elseif code == 14 then
            inputs[activeInput].inputText = string.sub(inputs[activeInput].inputText, 1, #inputs[activeInput].inputText-1)
        elseif code == 28 then
            local inp = activeInput 
            activeInput = nil
            loadInput(inp)
        end
        loadInput(activeInput)
    end
end
function selectInput(event, address, x, y, button, name)
    local found = false
    for i = 1, #inputs do
        if x >= inputs[i].x and inputs[i].x + inputs[i].w > x and math.ceil(y) == inputs[i].y and inputs[i].active then
            activeInput = i
            found = true
            loadInput(i)
        end
    end
    if found == false then
        activeInput = nil
        for i = 1, #inputs do
            if inputs[i].active then
                loadInput(i)
            end
        end
    end
    for i = 1, #inputs do
        if activeInput ~= i and inputs[i].active then
            loadInput(i)
        end
    end
end
function ESIListen()
    event.listen("touch", selectInput)
    event.listen("key_down", typing)
end
function getInput(pos)
    return(inputs[pos].inputText)
end