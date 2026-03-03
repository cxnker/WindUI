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
    -- Icon = "info",
    Content = "This is an Example UI for the " .. gradient("WindUI", Color3.fromHex("#00FF87"), Color3.fromHex("#60EFFF")) .. " Lib",
    Buttons = {
        {
            Title = "Cancel",
            --Icon = "",
            Callback = function() end,
            Variant = "Secondary", -- Primary, Secondary, Tertiary
        },
        {
            Title = "Continue",
            -- Icon = "arrow-right",
            Callback = function() Confirmed = true end,
            Variant = "Primary", -- Primary, Secondary, Tertiary
        }
    }
})


repeat wait() until Confirmed

--

local Window = WindUI:CreateWindow({
    Title = "WindUI Library",
    -- Icon = "door-open",
    Author = "Example UI",
    Folder = "CloudHub",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    User = {
        Enabled = true, -- <- or false
        Callback = function() print("clicked") end, -- <- optional
        Anonymous = true -- <- or true
    },
    SideBarWidth = 200,
    --Background = "rbxassetid://13511292247", -- rbxassetid only
    HasOutline = true,
    -- remove it below if you don't want to use the key system in your script.
    --[[KeySystem = { -- <- keysystem enabled
        Key = { "1234", "5678" },
        Note = "Example Key System. \n\nThe Key is '1234' or '5678",
        -- Thumbnail = {
        --     Image = "rbxassetid://18220445082", -- rbxassetid only
        --     Title = "Thumbnail"
        -- },
        URL = "https://github.com/Footagesus/WindUI", -- remove this if the key is not obtained from the link.
        SaveKey = true, -- optional
    },]]
})


--Window:SetBackgroundImage("rbxassetid://13511292247")


Window:EditOpenButton({
    Title = "Open Example UI",
    -- Icon = "monitor",
    CornerRadius = UDim.new(0,16),
    StrokeThickness = 2,
    Color = ColorSequence.new( -- gradient
        Color3.fromHex("FF0F7B"), 
        Color3.fromHex("F89B29")
    ),
    --Enabled = false,
    Draggable = true,
})


local Tabs = {
    ParagraphTab = Window:Tab({ Title = "Paragraph" }),
    divider1 = Window:Divider(),
    --
    WindowTab = Window:Tab({ 
        Title = "Window and File Configuration", 
        Icon = "settings", 
        Desc = "Manage window settings and file configurations.", 
        ShowTabTitle = true
    }),

    CreateThemeTab = Window:Tab({ Title = "Create Theme", --[[Icon = "palette",]] Desc = "Design and apply custom themes." }),
    be = Window:Divider(),
    LongTab = Window:Tab({ Title = "Long and empty tab. Looong and empty.. tab.", --[[Icon = "frown",]] Desc = "Long Description" }),
    LockedTab = Window:Tab({ Title = "Locked Tab", --[[Icon = "lock",]] Desc = "This tab is locked", Locked = true }),
    TabWithoutIcon = Window:Tab({ Title = "Tab Without icon", ShowTabTitle = true }),
    Tests = Window:Tab({ Title = "Tests", --[[Icon = "settings",]] ShowTabTitle = true }),
}

Window:SelectTab(1)

Tabs.ParagraphTab:Paragraph({
    Title = "Paragraph with Image & Thumbnail",
    Desc = "Test Paragraph",
    Image = "https://play-lh.googleusercontent.com/7cIIPlWm4m7AGqVpEsIfyL-HW4cQla4ucXnfalMft1TMIYQIlf2vqgmthlZgbNAQoaQ",
    ImageSize = 34, -- default 30
    Thumbnail = "https://tr.rbxcdn.com/180DAY-59af3523ad8898216dbe1043788837bf/768/432/Image/Webp/noFilter",
    ThumbnailSize = 120 -- Thumbnail height
})
Tabs.ParagraphTab:Paragraph({
    Title = "Paragraph with Image & Thumbnail & Buttons",
    Desc = "Test Paragraph",
    Image = "https://play-lh.googleusercontent.com/7cIIPlWm4m7AGqVpEsIfyL-HW4cQla4ucXnfalMft1TMIYQIlf2vqgmthlZgbNAQoaQ",
    ImageSize = 34, -- default 30
    Thumbnail = "https://tr.rbxcdn.com/180DAY-59af3523ad8898216dbe1043788837bf/768/432/Image/Webp/noFilter",
    ThumbnailSize = 120, -- Thumbnail height
    Buttons = {
        {
            Title = "Button 1",
            Variant = "Primary",
            Callback = function() print("1 Button") end,
        },
        {
            Title = "Button 2",
            Variant = "Primary",
            Callback = function() print("2 Button") end,
        },
        {
            Title = "Button 3",
            Variant = "Primary",
            Callback = function() print("3 Button") end,
            -- Icon = "bird",
        },
    }
})

for _,i in next, { "Default", "Red", "Orange", "Green", "Blue", "Grey", "White" } do
    Tabs.ParagraphTab:Paragraph({
        Title = i,
        Desc = "Paragraph with color",
        -- Image = "bird",
        Color = i ~= "Default" and i or nil,
        Buttons = {
            {
                Title = "Button 1",
                Variant = "Primary",
                Callback = function() print("1 Button") end,
                -- Icon = "bird",
            },
            {
                Title = "Button 2",
                Variant = "Primary",
                Callback = function() print("2 Button") end,
                -- Icon = "bird",
            },
            {
                Title = "Button 3",
                Variant = "Primary",
                Callback = function() print("3 Button") end,
                -- Icon = "bird",
            },
        }
    })
end
