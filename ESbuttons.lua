local component = require("component")
local event = require("event")
local term = require("term")
local gpu = require("component").gpu

buttons = {}
local functions = {}

function deleteButton(name)
    for i = 1, #buttons do
      if buttons[i].name == name then
        table.remove(buttons, i)
      end
    end
end
function createButton(xpos, ypos, width, height, bColor, bName, bShow, bDispName, bNameColor, bCode)
    xpos = xpos*2
    width = width*2
    for i = 1, #buttons do
        if buttons[i].name == bName then
            table.remove(buttons, i)
        end
    end
    table.insert(buttons, 
        {
            x = xpos,
            y = ypos,
            w = width,
            h = height,
            name = bName,
            color = bColor,
            code = bCode,
            show = bShow,
            dispName = bDispName,
            nameColor = bNameColor
        }
    )
    if bShow == true or bShow == nil then
        local prevBkgnd = gpu.getBackground()
        local prevFrgnd = gpu.getForeground()
        gpu.setBackground(bColor)
        gpu.fill(xpos, ypos, width, height, " ")
        if bDispName == true then
            gpu.setForeground(bNameColor)
            gpu.set(xpos+((width/2)-(#bName)/2), ypos+(height/2), bName)
        end
        gpu.setBackground(prevBkgnd)
        gpu.setForeground(prevFrgnd)
    end
    functions[bName] = bCode
    return bName
end
function refreshButtons(exceptions)
    local prevBkgnd = gpu.getBackground()
    local prevFrgnd = gpu.getForeground()
    for i = 1, #buttons do
        found = false
        if exceptions ~= nil then
            for j = 1, #exceptions do
                if buttons[i].name == exceptions[j] then
                    found = true
                end
            end
        end
        if found == false then
            gpu.setBackground(buttons[i].color)
            gpu.fill(buttons[i].x, buttons[i].y, buttons[i].w, buttons[i].h, " ")
            if buttons[i].dispName == true then
                gpu.setForeground(buttons[i].nameColor)
                gpu.set(buttons[i].x+((buttons[i].w/2)-(#buttons[i].name)/2), buttons[i].y+(buttons[i].h/2), buttons[i].name)
            end
        end
    end
    gpu.setBackground(prevBkgnd)
    gpu.setForeground(prevFrgnd)
end
function refreshButton(name)
    local prevBkgnd = gpu.getBackground()
    local prevFrgnd = gpu.getForeground()
    for i = 1, #buttons do
        if buttons[i].name == name then
            gpu.setBackground(buttons[i].color)
            gpu.fill(buttons[i].x, buttons[i].y, buttons[i].w, buttons[i].h, " ")
            if buttons[i].dispName == true then
                gpu.setForeground(buttons[i].nameColor)
                gpu.set(buttons[i].x+((buttons[i].w/2)-(#buttons[i].name)/2), buttons[i].y+(buttons[i].h/2), buttons[i].name)
            end
        end
    end
    gpu.setBackground(prevBkgnd)
    gpu.setForeground(prevFrgnd)
end
function selectButtons(_, address, x, y, button, name)
    for i = 1, #buttons do
        if x >= buttons[i].x and buttons[i].x + buttons[i].w > x and math.ceil(y) >= buttons[i].y and buttons[i].y + buttons[i].h > math.ceil(y) and buttons[i].show then
          buttonClicked = buttons[i].name
          functions[buttons[i].name]()
        end
    end
end
function ESBListen()
    event.listen("touch", selectButtons)
end