local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/cxnker/WindUI/refs/heads/main/WindUI_Nova/windlib.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Prueba",
    -- Author = "Yo",
    Size = UDim2.fromOffset(500, 400)
})
    
local Tab = Window:Tab({ Title = "Test" })
Tab:Button({ Title = "Click", Callback = function() print("Funciona!") end })
