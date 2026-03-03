-- Cargar WindUI con manejo de errores
local WindUI
local success, result = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/cxnker/WindUI/main/WindUI_1.6.1/dist/main.lua"))()
end)

if success and result then
    WindUI = result
    print("✅ WindUI cargado correctamente")
else
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Error",
        Text = "No se pudo cargar WindUI",
        Duration = 5
    })
    return
end

-- Función gradient (sin cambios)
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

-- Popup sin iconos
WindUI:Popup({
    Title = "Welcome! Popup Example",
    Content = "This is an Example UI for the " .. gradient("WindUI", Color3.fromHex("#00FF87"), Color3.fromHex("#60EFFF")) .. " Lib",
    Buttons = {
        {
            Title = "Cancel",
            Callback = function() 
                print("Cancel clicked")
            end,
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
print("✅ Confirmado, creando ventana...")

-- Ventana principal SIN KEY SYSTEM
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
    SideBarWidth = 200,
    HasOutline = true,
    -- KEY SYSTEM ELIMINADO COMPLETAMENTE
})

-- Botón de apertura sin icono
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

-- Crear pestañas sin iconos
local Tabs = {
    ButtonTab = Window:Tab({ Title = "Button", Desc = "Interactive buttons" }),
    ToggleTab = Window:Tab({ Title = "Toggle", Desc = "Switch settings" }),
    SliderTab = Window:Tab({ Title = "Slider", Desc = "Adjust values" }),
    InputTab = Window:Tab({ Title = "Input", Desc = "Text input" }),
}

Window:SelectTab(1)

-- Agregar algunos elementos básicos para probar
Tabs.ButtonTab:Button({
    Title = "Test Button",
    Desc = "This is a test button",
    Callback = function() 
        print("Button clicked!")
        WindUI:Notify({
            Title = "Test",
            Content = "Button worked!",
            Duration = 3,
        })
    end
})

Tabs.ToggleTab:Toggle({
    Title = "Enable Test",
    Value = false,
    Callback = function(state) 
        print("Toggle:", state)
    end
})

Tabs.SliderTab:Slider({
    Title = "Test Slider",
    Value = {
        Min = 0,
        Max = 100,
        Default = 50,
    },
    Callback = function(value) 
        print("Slider:", value)
    end
})

Tabs.InputTab:Input({
    Title = "Test Input",
    Placeholder = "Type something...",
    Callback = function(input) 
        print("Input:", input)
    end
})

print("✅ Script ejecutado correctamente")
