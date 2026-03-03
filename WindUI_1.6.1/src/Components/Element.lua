local Creator = require("../Creator")
local New = Creator.New
local NewRoundFrame = Creator.NewRoundFrame
local Tween = Creator.Tween

local UserInputService = game:GetService("UserInputService")

-- fuck
-- i need to rewrite this

return function(Config)
    local Element = {
        Title = Config.Title,
        Desc = Config.Desc or nil,
        Hover = Config.Hover,
        Thumbnail = Config.Thumbnail,
        ThumbnailSize = Config.ThumbnailSize or 80,
        Image = Config.Image,
        ImageSize = Config.ImageSize or 22,
        Color = Config.Color,
        Scalable = Config.Scalable,
        UIPadding = 12,
        UICorner = 12,
        UIElements = {}
    }
    
    local ImageSize = Element.ImageSize
    local ThumbnailSize = Element.ThumbnailSize
    local CanHover = true
    local Hovering = false
    
    local ThumbnailFrame
    local ImageFrame
    if Element.Thumbnail then
        ThumbnailFrame = Creator.Image(
            Element.Thumbnail, 
            Element.Title, 
            Element.UICorner-5, 
            Config.Window.Folder,
            "Thumbnail",
            false
        )
        ThumbnailFrame.Size = UDim2.new(1,0,0,ThumbnailSize)
    end
    if Element.Image then
        ImageFrame = Creator.Image(
            Element.Image, 
            Element.Title, 
            Element.UICorner-5, 
            Config.Window.Folder,
            "Image",
            Element.Color ~= "White"
        )
        if Element.Color == "White" then
            ImageFrame.ImageLabel.ImageColor3 = Color3.new(0,0,0)
        end
        ImageFrame.Size = UDim2.new(0,ImageSize,0,ImageSize)
        ImageFrame.Position = UDim2.new(
            0,
            Element.UIPadding/2,
            0,
            ThumbnailFrame and ThumbnailSize+(Element.UIPadding*1.5) or Element.UIPadding/2)
    end
    
    Element.UIElements.Main = New("TextButton", {
        Size = UDim2.new(1,0,0,0),
        AutomaticSize = "Y",
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = UDim2.new(0.5,0,0.5,0),
        Visible = false, -- true
        BackgroundTransparency = 1,
    }, {
        New("UIScale", {
            Scale = .98, -- 1
        }),
        ImageFrame,
        ThumbnailFrame,
        New("Frame", {
            Size = UDim2.new(1,Element.Image and -(ImageSize+Element.UIPadding),0,0),
            AutomaticSize = "Y",
            AnchorPoint = Vector2.new(0,0),
            Position = UDim2.new(
                0,
                ImageFrame and ImageSize+Element.UIPadding or 0,
                0,
                ThumbnailFrame and ThumbnailSize+Element.UIPadding or 0
            ),
            BackgroundTransparency = 1,
            Name = "Title"
        }, {
            New("UIListLayout", {
                Padding = UDim.new(0,7),
                --VerticalAlignment = "Left",
            }),
            New("TextLabel", {
                Text = Element.Title,
                ThemeTag = {
                    TextColor3 = not Element.Color and "Text" or nil
                },
                TextColor3 = Element.Color and ( Element.Color == "White" and Color3.new(0,0,0) or Color3.new(1,1,1) ),
                TextSize = 16, 
                TextWrapped = true,
                RichText = true,
                LayoutOrder = 0,
                Name = "Title",
                TextXAlignment = "Left",
                Size = UDim2.new(1,-Config.TextOffset,0,0),
                FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
                BackgroundTransparency = 1,
                AutomaticSize = "Y"
            }),
            New("UIPadding", {
                PaddingTop = UDim.new(0,(Element.UIPadding/2)+2),
                PaddingLeft = UDim.new(0,Element.UIPadding/2),
                PaddingRight = UDim.new(0,Element.UIPadding/2),
                PaddingBottom = UDim.new(0,(Element.UIPadding/2)+2),
            }),
        }),
        NewRoundFrame(Element.UICorner, "Squircle", {
            Size = UDim2.new(1,Element.UIPadding,1,Element.UIPadding),
            Position = UDim2.new(0.5,0,0.5,0),
            AnchorPoint = Vector2.new(0.5,0.5),
            Name = "MainBG",
            ThemeTag = {
                ImageColor3 = not Element.Color and "Text" or nil
            },
            ImageTransparency = not Element.Color and 0.95 or 0.1,
            ImageColor3 = Element.Color and Color3.fromHex(Creator.Colors[Element.Color]),
            ZIndex = -1,
        }),
        NewRoundFrame(Element.UICorner, "Squircle", {
            Size = UDim2.new(1,Element.UIPadding,1,Element.UIPadding),
            ThemeTag = {
                ImageColor3 = "Text"
            },
            Position = UDim2.new(0.5,0,0.5,0),
            AnchorPoint = Vector2.new(0.5,0.5),
            ImageTransparency = 1, -- .95
            Name = "Highlight",
            ZIndex = -1,
        }),
        NewRoundFrame(Element.UICorner, "SquircleOutline", {
            Size = UDim2.new(1,Element.UIPadding,1,Element.UIPadding),
            ThemeTag = {
                ImageColor3 = "Text"
            },
            Position = UDim2.new(0.5,0,0.5,0),
            AnchorPoint = Vector2.new(0.5,0.5),
            ImageTransparency = Element.Color == "White" and 0 or .95,
            Name = "Outline",
            ZIndex = -1,
        }, {
            New("UIGradient", {
                Rotation = 90,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1),
                })
            })
        }),
        New("Frame", {
            Size = UDim2.new(1,Element.UIPadding,1,Element.UIPadding),
            BackgroundColor3 = Color3.new(0,0,0),
            Position = UDim2.new(0.5,0,0.5,0),
            AnchorPoint = Vector2.new(0.5,0.5),
            BackgroundTransparency = 1,
            ZIndex = 999999,
            Name = "Lock"
        }, {
            New("UICorner", {
                CornerRadius = UDim.new(0,11),
            }),
            New("ImageLabel", {
                Image = Creator.Icon("lock")[1],
                ImageRectOffset = Creator.Icon("lock")[2].ImageRectPosition,
                ImageRectSize = Creator.Icon("lock")[2].ImageRectSize,
                --AnchorPoint = Vector2.new(0.5,0.5),
                --Position = UDim2.new(0.5,0,0.5,0),
                Size = UDim2.new(0,22,0,22),
                ImageTransparency = 1,
                BackgroundTransparency = 1,
                Active = false,
            }),
            New("TextLabel", {
                BackgroundTransparency = 1,
                Text = "Locked",
                TextTransparency = 1,
                AutomaticSize = "XY",
                FontFace = Font.new(Creator.Font, Enum.FontWeight.SemiBold),
                TextSize = 16,
                Active = false,
                TextColor3 = Color3.new(1,1,1),
            }),
            New("UIListLayout", {
                Padding = UDim.new(0, Element.UIPadding),
                FillDirection = "Horizontal",
                VerticalAlignment = "Center",
                HorizontalAlignment = "Center",
            })
        }),
        New("UIPadding", {
            PaddingTop = UDim.new(0,Element.UIPadding/2),
            PaddingLeft = UDim.new(0,Element.UIPadding/2),
            PaddingRight = UDim.new(0,Element.UIPadding/2),
            PaddingBottom = UDim.new(0,Element.UIPadding/2),
        }),
    })

    Element.UIElements.MainContainer = New("Frame", {
        Size = UDim2.new(1,0,0,Element.UIElements.Main.AbsoluteSize.Y),
        --AutomaticSize = "Y",
        BackgroundTransparency = 1,
        Parent = Config.Parent,
        --GroupTransparency = 1,
    }, {
        Element.UIElements.Main,
    })
    
    local Desc = New("TextLabel", {
        Text = Element.Desc,
        ThemeTag = {
            TextColor3 = not Element.Color and "Text" or nil
        },
        TextColor3 = Element.Color and ( Element.Color == "White" and Color3.new(0,0,0) or Color3.new(1,1,1) ),
        TextTransparency = 0.2,
        TextSize = 15,
        TextWrapped = true,
        LayoutOrder = 9999,
        Name = "Desc",
        TextXAlignment = "Left",
        Size = UDim2.new(1,-Config.TextOffset,0,0),
        FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
        BackgroundTransparency = 1,
        AutomaticSize = "Y",
    })
    
    if Element.Desc then
        Desc.Parent = Element.UIElements.Main.Title
    else
        -- Element.UIElements.Main.Title.AnchorPoint = Vector2.new(0,Config.IsButtons and 0 or 0.5)
        -- Element.UIElements.Main.Title.Size = UDim2.new(1,Element.Image and -(ImageSize+Element.UIPadding),0,0)
        -- Element.UIElements.Main.Title.Position = UDim2.new(0,Element.Image and ImageSize+Element.UIPadding or 0,Config.IsButtons and 0 or 0.5,0)
    end
    
    if Element.Hover then
        Element.UIElements.Main.MouseEnter:Connect(function()
            if CanHover then
                Tween(Element.UIElements.Main.Highlight, 0.047, {ImageTransparency = 0.975}):Play()
            end
        end)
        
        Element.UIElements.Main.MouseButton1Down:Connect(function()
            if CanHover then
                Hovering = true
                if Element.Scalable then
                    Tween(Element.UIElements.Main.UIScale, 0.07, {Scale = .985}, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out):Play()
                end
            end
        end)
        
        Element.UIElements.Main.InputEnded:Connect(function()
            if CanHover then
                Tween(Element.UIElements.Main.Highlight, 0.066, {ImageTransparency = 1}):Play()
                if Element.Scalable then
                    Tween(Element.UIElements.Main.UIScale, 0.175, {Scale = 1}, Enum.EasingStyle.Back, Enum.EasingDirection.Out):Play()
                end
                task.wait(.16)
                Hovering = false
            end
        end)
    end
    
    local ElementSizing = Element.UIElements.Main:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        if not Hovering then
            Element.UIElements.MainContainer.Size = UDim2.new(1,0,0,Element.UIElements.Main.AbsoluteSize.Y)
        end
    end)
    
    function Element:SetTitle(Title)
        Element.UIElements.Main.Title.Title.Text = Title
    end
    function Element:SetDesc(Title)
        Desc.Text = Title
        Element.Desc = Title
        if not Desc.Parent then
            Desc.Parent = Element.UIElements.Main.Title
            -- Element.UIElements.Main.Title.AnchorPoint = Vector2.new(0,0)
            -- Element.UIElements.Main.Title.Size = UDim2.new(1,Element.Image and -(ImageSize+Element.UIPadding),0,0)
            -- Element.UIElements.Main.Title.Position = UDim2.new(0,Element.Image and ImageSize+Element.UIPadding or 0,0,0)
        end
    end
    
    function Element:Show()
        Element.UIElements.Main.Visible = true
        Tween(Element.UIElements.Main.UIScale, .1, {Scale= 1}):Play()
    end
    function Element:Destroy()
        Tween(Element.UIElements.Main.UIScale, .15, {Scale = .98}):Play()
        
        ElementSizing:Disconnect()
        Element.UIElements.MainContainer.AutomaticSize = "None"
        task.wait(.1)
        Element.UIElements.Main.Visible = false
        Tween(Element.UIElements.MainContainer, .18, {Size = UDim2.new(1,0,0,-6)}, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut):Play()
        task.wait(.23)
        Element.UIElements.MainContainer:Destroy()
    end
    
    function Element:Lock()
        Tween(Element.UIElements.Main.Lock, .08, {BackgroundTransparency = .6}):Play()
        Tween(Element.UIElements.Main.Lock.ImageLabel, .08, {ImageTransparency = 0}):Play()
        Tween(Element.UIElements.Main.Lock.TextLabel, .08, {TextTransparency = 0}):Play()
        Element.UIElements.Main.Lock.Active = true
        CanHover = false
    end
    function Element:Unlock()
        Tween(Element.UIElements.Main.Lock, .08, {BackgroundTransparency = 1}):Play()
        Tween(Element.UIElements.Main.Lock.ImageLabel, .08, {ImageTransparency = 1}):Play()
        Tween(Element.UIElements.Main.Lock.TextLabel, .08, {TextTransparency = 1}):Play()
        Element.UIElements.Main.Lock.Active = false
        CanHover = true
    end
    
    --task.wait(.015)
    
    Element:Show()
    
    return Element
end