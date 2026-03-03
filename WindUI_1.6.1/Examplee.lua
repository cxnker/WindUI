local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/cxnker/WindUI/main/WindUI_1.6.1/dist/main.lua"))()

if not WindUI then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Error",
        Text = "No se pudo cargar WindUI",
        Duration = 5
    })
    return
end

print("✅ WindUI cargado correctamente")

-- Función gradient (opcional, para el popup)
function gradient(text, startColor, endColor)
    local result = ""
    local length = #text

    for i = 1, length do
        local t = (i - 1) / math.max(length - 1, 1)
        local r = math.floor((startColor.R + (endColor.R - startColor.R) * t) * 255)
        local g = math.floor((startColor.G + (endColor.G - startColor.G) * t) * 255)
        local b = math.floor((startColor.B + (endColor.B - startColor.B) * t) * 255)

        local char = text:sub(i, i)
        result = result .. "<font color=\"rgb(" .. r ..", " .. g .. ", " .. b .. ")\">" .. char .. "</font>"
    end

    return result
end

local Confirmed = false

-- Popup sin íconos problemáticos
WindUI:Popup({
    Title = "Welcome!",
    Content = "This is an Example UI for the " .. gradient("WindUI", Color3.fromHex("#00FF87"), Color3.fromHex("#60EFFF")) .. " Lib",
    Buttons = {
        {
            Title = "Cancel",
            Callback = function() print("Cancel") end,
            Variant = "Secondary",
        },
        {
            Title = "Continue",
            Callback = function() 
                print("Continue clicked")
                Confirmed = true 
            end,
            Variant = "Primary",
        }
    }
})

-- Esperar confirmación
repeat task.wait() until Confirmed

-- CREAR VENTANA - SIN PARÁMETROS INCORRECTOS
local Window = WindUI:CreateWindow({
    Title = "WindUI Library",
    Author = "Example UI",
    Folder = "CloudHub",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    User = {
        Enabled = true,
        Callback = function() print("User clicked") end,
        Anonymous = true
    },
    HasOutline = true,  -- Este parámetro SÍ existe
})

-- Botón de apertura (opcional)
Window:EditOpenButton({
    Title = "Open Example UI",
    CornerRadius = UDim.new(0,16),
    StrokeThickness = 2,
    Color = ColorSequence.new(
        Color3.fromHex("FF0F7B"), 
        Color3.fromHex("F89B29")
    ),
    Draggable = true,
})

print("✅ Ventana creada correctamente")

-- Crear pestañas
local Tabs = {
    Main = Window:Tab({ Title = "Main" }),
    Settings = Window:Tab({ Title = "Settings" }),
}

Window:SelectTab(1)

-- Botón de prueba
Tabs.Main:Button({
    Title = "Test Button",
    Desc = "Click me!",
    Callback = function()
        print("Button clicked!")
        WindUI:Notify({
            Title = "Success",
            Content = "Button worked!",
            Duration = 3,
        })
    end
})
