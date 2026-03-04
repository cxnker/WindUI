local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/cxnker/WindUI/main/WindUI_Nova/dist/main.lua"))()

WindUI:Popup({
    Title = "WindUI Demo",
    Content = "loc:LIB_DESC",
    Buttons = {
        {
            Title = "Get Started",
            Variant = "Primary",
            Callback = function() end
        }
    }
})

local Window = WindUI:CreateWindow({
    Title = "WINDUI_EXAMPLE",
    Author = "loc:WELCOME",
    Folder = "WindUI_Example",
    Size = UDim2.fromOffset(580, 450),
    Theme = "Dark",
    -- Background = WindUI:Gradient({
    --     ["0"] = { Color = Color3.fromHex("#0f0c29"), Transparency = 1 },
    --     ["100"] = { Color = Color3.fromHex("#302b63"), Transparency = 0.9 },
    -- }, {
    --     Rotation = 45,
    -- }),
    --Background = "video:https://cdn.discordapp.com/attachments/1337368451865645096/1402703845657673878/VID_20250616_180732_158.webm?ex=68958a01&is=68943881&hm=164c5b04d1076308b38055075f7eb0653c1d73bec9bcee08e918a31321fe3058&",
    User = {
        Enabled = true,
        Anonymous = true,
        Callback = function()
            WindUI:Notify({
                Title = "User Profile",
                Content = "User profile clicked!",
                Duration = 3
            })
        end
    },
    SideBarWidth = 220,
    ScrollBarEnabled = true
})

Window:Tag({
    Title = "v1.6.4",
    Color = Color3.fromHex("#30ff6a")
})
