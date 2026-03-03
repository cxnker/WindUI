local Creator = require("../Creator")
local New = Creator.New
local Tween = Creator.Tween

local Element = {
    UICorner = 8,
    UIPadding = 8,
}


local UIComponent = require("../Components/UI")
local CreateButton = UIComponent.Button
local CreateInput = UIComponent.Input 

function Element:New(Config)
    local Input = {
        __type = "Input",
        Title = Config.Title or "Input",
        Desc = Config.Desc or nil,
        Locked = Config.Locked or false,
        InputIcon = Config.InputIcon or false,
        PlaceholderText = Config.Placeholder or "Enter Text...",
        Value = Config.Value or "",
        Callback = Config.Callback or function() end,
        ClearTextOnFocus = Config.ClearTextOnFocus or false,
        UIElements = {},
    }
    
    local CanCallback = true

    Input.InputFrame = require("../Components/Element")({
        Title = Input.Title,
        Desc = Input.Desc,
        Parent = Config.Parent,
        TextOffset = (30*6)+10,
        Hover = false,
    })
    
    local InputComponent = CreateInput(Input.PlaceholderText, Input.InputIcon, Input.InputFrame.UIElements.Main, function(v)
        Input:Set(v)
    end)
    InputComponent.Size = UDim2.new(0,30*6,0,42)
    InputComponent.AnchorPoint = Vector2.new(1,0.5)
    InputComponent.Position = UDim2.new(1,-Input.InputFrame.UIPadding/2,0.5,0)
    
    New("UIScale", {
        Parent = InputComponent,
        Scale = .85,
    })
    
    function Input:Lock()
        CanCallback = false
        return Input.InputFrame:Lock()
    end
    function Input:Unlock()
        CanCallback = true
        return Input.InputFrame:Unlock()
    end
    
    
    function Input:Set(v)
        if CanCallback then
            Input.Callback(v)
            
            InputComponent.Frame.Frame.TextBox.Text = v
            Input.Value = v
        end
    end
    
    Input:Set(Input.Value)
    
    if Input.Locked then
        Input:Lock()
    end

    return Input.__type, Input
end

return Element