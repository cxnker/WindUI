local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/cxnker/WindUI/main/windlib.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Prueba",
    Size = UDim2.fromOffset(500, 400)
})
    
local Tab = Window:Tab({ Title = "Test" })
    Tab:Button({ Title = "Click", Callback = function() print("Funciona!") end })
else
    warn("❌ Error al cargar la librería")
end
