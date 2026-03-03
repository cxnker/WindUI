local Creator = require("../Creator")
local New = Creator.New
local Tween = Creator.Tween

local Element = {}

local HoldingSlider = false

function Element:New(Config)
    local Slider = {
        __type = "Slider",
        Title = Config.Title or "Slider",
        Desc = Config.Desc or nil,
        Locked = Config.Locked or nil,
        Value = Config.Value or {},
        Step = Config.Step or 1,
        Callback = Config.Callback or function() end,
        UIElements = {},
        IsFocusing = false,
    }
    local isTouch
    local moveconnection
    local releaseconnection
    local Value = Slider.Value.Default or Slider.Value.Min or 0
    
    local LastValue = Value
    local delta = (Value - (Slider.Value.Min or 0)) / ((Slider.Value.Max or 100) - (Slider.Value.Min or 0))
    
    local CanCallback = true
    
    Slider.SliderFrame = require("../Components/Element")({
        Title = Slider.Title,
        Desc = Slider.Desc,
        Parent = Config.Parent,
        TextOffset = 160,
        Hover = false,
    })
    
    Slider.UIElements.SliderIcon = Creator.NewRoundFrame(99, "Squircle", {
        ImageTransparency = .95,
        Size = UDim2.new(0, 126, 0, 4),
        Name = "Frame",
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ThemeTag = {
            ImageColor3 = "Text",
        },
    }, {
        Creator.NewRoundFrame(99, "Squircle", {
            Name = "Frame",
            Size = UDim2.new(delta, 0, 1, 0),
            ImageTransparency = .1,
            ThemeTag = {
                ImageColor3 = "Button",
            },
        }, {
            Creator.NewRoundFrame(99, "Squircle", {
                Size = UDim2.new(0, 13, 0, 13),
                Position = UDim2.new(1, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                ThemeTag = {
                    ImageColor3 = "Text",
                },
            })
        })
    })
    
    Slider.UIElements.SliderContainer = New("Frame", {
        Size = UDim2.new(0, 0, 0, 0),
        AutomaticSize = "XY",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -Slider.SliderFrame.UIPadding/2, 0.5, 0),
        BackgroundTransparency = 1,
        Parent = Slider.SliderFrame.UIElements.Main,
    }, {
        New("UIListLayout", {
            Padding = UDim.new(0, 8),
            FillDirection = "Horizontal",
            VerticalAlignment = "Center",
        }),
        Slider.UIElements.SliderIcon,
        New("TextBox", {
            Size = UDim2.new(0,60,0,0),
            TextXAlignment = "Right",
            Text = tostring(Value),
            ThemeTag = {
                TextColor3 = "Text"
            },
            TextTransparency = .4,
            AutomaticSize = "Y",
            TextSize = 15,
            FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
            BackgroundTransparency = 1,
            LayoutOrder = -1,
        })
    })

    function Slider:Lock()
        CanCallback = false
        return Slider.SliderFrame:Lock()
    end
    function Slider:Unlock()
        CanCallback = true
        return Slider.SliderFrame:Unlock()
    end
    
    if Slider.Locked then
        Slider:Lock()
    end
    
    function Slider:Set(Value, input)
        if CanCallback then
            if not Slider.IsFocusing and not HoldingSlider and (not input or (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch)) then
                Value = math.clamp(Value, Slider.Value.Min or 0, Slider.Value.Max or 100)
                
                local delta = math.clamp((Value - (Slider.Value.Min or 0)) / ((Slider.Value.Max or 100) - (Slider.Value.Min or 0)), 0, 1)
                Value = math.floor((Slider.Value.Min + delta * (Slider.Value.Max - Slider.Value.Min)) / Slider.Step + 0.5) * Slider.Step
    
                if Value ~= LastValue then
                    Tween(Slider.UIElements.SliderIcon.Frame, 0.08, {Size = UDim2.new(delta,0,1,0)}):Play()
                    --Slider.UIElements.SliderIcon.Frame.Size = UDim2.new(delta, 0, 1, 0)
                    Slider.UIElements.SliderContainer.TextBox.Text = tostring(Value)
                    LastValue = Value
                    Slider.Callback(Value)
                end
    
                if input then
                    isTouch = (input.UserInputType == Enum.UserInputType.Touch)
                    Slider.SliderFrame.UIElements.Main.Parent.Parent.ScrollingEnabled = false
                    HoldingSlider = true
                    moveconnection = game:GetService("RunService").RenderStepped:Connect(function()
                        local inputPosition = isTouch and input.Position.X or game:GetService("UserInputService"):GetMouseLocation().X
                        local delta = math.clamp((inputPosition - Slider.UIElements.SliderIcon.AbsolutePosition.X) / Slider.UIElements.SliderIcon.Size.X.Offset, 0, 1)
                        Value = math.floor((Slider.Value.Min + delta * (Slider.Value.Max - Slider.Value.Min)) / Slider.Step + 0.5) * Slider.Step
    
                        if Value ~= LastValue then
                            Tween(Slider.UIElements.SliderIcon.Frame, 0.08, {Size = UDim2.new(delta,0,1,0)}):Play()
                            --Slider.UIElements.SliderIcon.Frame.Size = UDim2.new(delta, 0, 1, 0)
                            Slider.UIElements.SliderContainer.TextBox.Text = tostring(Value)
                            LastValue = Value
                            Slider.Callback(Value)
                        end
                    end)
                    releaseconnection = game:GetService("UserInputService").InputEnded:Connect(function(endInput)
                        if (endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch) and input == endInput then
                            moveconnection:Disconnect()
                            releaseconnection:Disconnect()
                            HoldingSlider = false
                            Slider.SliderFrame.UIElements.Main.Parent.Parent.ScrollingEnabled = true
                        end
                    end)
                end
            end
        end
    end
    
    Slider.UIElements.SliderContainer.TextBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local newValue = tonumber(Slider.UIElements.SliderContainer.TextBox.Text)
            if newValue then
                Slider:Set(newValue)
            else
                Slider.UIElements.SliderContainer.TextBox.Text = tostring(LastValue)
            end
        end
    end)
    
    Slider.UIElements.SliderContainer.InputBegan:Connect(function(input)
        Slider:Set(Value, input)
    end)
    
    return Slider.__type, Slider
end

return Element