local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/cxnker/WindUI/main/WindUI_1.6.1/dist/main.lua"))()

-- Test

-- Set theme:
--WindUI:SetTheme("Light")

--- EXAMPLE !!!

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

WindUI:Popup({
    Title = "Welcome! Popup Example",
    -- Icon removido
    Content = "This is an Example UI for the " .. gradient("WindUI", Color3.fromHex("#00FF87"), Color3.fromHex("#60EFFF")) .. " Lib",
    Buttons = {
        {
            Title = "Cancel",
            Callback = function() end,
            Variant = "Secondary",
        },
        {
            Title = "Continue",
            -- Icon removido
            Callback = function() Confirmed = true end,
            Variant = "Primary",
        }
    }
})

-- Esperar a que Confirmed sea true
repeat task.wait() until Confirmed

-- Crear ventana principal
local Window = WindUI:CreateWindow({
    Title = "WindUI Library",
    -- Icon removido
    Author = "Example UI",
    Folder = "CloudHub",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    User = {
        Enabled = true,
        Callback = function() print("clicked") end,
        Anonymous = true
    },
    SideBarWidth = 200,
    HasOutline = true,
    KeySystem = {
        Key = { "1234", "5678" },
        Note = "Example Key System. \n\nThe Key is '1234' or '5678",
        SaveKey = true,
    },
})

-- Editar botón de apertura (también sin icono)
Window:EditOpenButton({
    Title = "Open Example UI",
    -- Icon removido
    CornerRadius = UDim.new(0,16),
    StrokeThickness = 2,
    Color = ColorSequence.new(
        Color3.fromHex("FF0F7B"), 
        Color3.fromHex("F89B29")
    ),
    Draggable = true,
})

-- Crear pestañas (quitando los iconos)
local Tabs = {
    ParagraphTab = Window:Tab({ Title = "Paragraph" }), -- Icon removido
    ButtonTab = Window:Tab({ Title = "Button", Desc = "Contains interactive buttons for various actions." }),
    CodeTab = Window:Tab({ Title = "Code", Desc = "Displays and manages code snippets." }),
    ColorPickerTab = Window:Tab({ Title = "ColorPicker", Desc = "Choose and customize colors easily." }),
    DialogTab = Window:Tab({ Title = "Dialog", Desc = "Dialog lol" }),
    NotificationTab = Window:Tab({ Title = "Notification", Desc = "Configure and view notifications." }),
    ToggleTab = Window:Tab({ Title = "Toggle", Desc = "Switch settings on and off." }),
    SliderTab = Window:Tab({ Title = "Slider", Desc = "Adjust values smoothly with sliders." }),
    InputTab = Window:Tab({ Title = "Input", Desc = "Accept text and numerical input." }),
    KeybindTab = Window:Tab({ Title = "Keybind" }),
    DropdownTab = Window:Tab({ Title = "Dropdown", Desc = "Select from multiple options." }),
    divider1 = Window:Divider(),
    WindowTab = Window:Tab({ 
        Title = "Window and File Configuration", 
        Desc = "Manage window settings and file configurations.", 
        ShowTabTitle = true
    }),
    CreateThemeTab = Window:Tab({ Title = "Create Theme", Desc = "Design and apply custom themes." }),
    be = Window:Divider(),
    LongTab = Window:Tab({ Title = "Long and empty tab. Looong and empty.. tab.", Desc = "Long Description" }),
    LockedTab = Window:Tab({ Title = "Locked Tab", Desc = "This tab is locked", Locked = true }),
    TabWithoutIcon = Window:Tab({ Title = "Tab Without icon", ShowTabTitle = true }),
    Tests = Window:Tab({ Title = "Tests", ShowTabTitle = true }),
}

Window:SelectTab(1)

-- Resto del código pero quitando TODOS los Icon e Image que causan problemas
-- Por ejemplo, en los Paragraphs, quita los parámetros Image:

Tabs.ParagraphTab:Paragraph({
    Title = "Paragraph with Thumbnail",
    Desc = "Test Paragraph",
    Thumbnail = "https://tr.rbxcdn.com/180DAY-59af3523ad8898216dbe1043788837bf/768/432/Image/Webp/noFilter",
    ThumbnailSize = 120
})

-- Continuar con el resto del script pero eliminando TODAS las referencias a:
-- - Icon
-- - Image (a menos que sea una URL de imagen real)
-- - Cualquier otro parámetro que pueda estar causando problemas
