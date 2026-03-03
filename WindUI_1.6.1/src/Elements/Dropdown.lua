local UserInputService = game:GetService("UserInputService")
local Mouse = game:GetService("Players").LocalPlayer:GetMouse()
local Camera = game:GetService("Workspace").CurrentCamera

local Creator = require("../Creator")
local New = Creator.New
local Tween = Creator.Tween

local UIComponent = require("../Components/UI")
local CreateLabel = UIComponent.Label 

local Element = {
    UICorner = 10,
    UIPadding = 12,
    MenuCorner = 14,
    MenuPadding = 5,
    TabPadding = 6,
}

function Element:New(Config)
    local Dropdown = {
        __type = "Dropdown",
        Title = Config.Title or "Dropdown",
        Desc = Config.Desc or nil,
        Locked = Config.Locked or false,
        Values = Config.Values or {},
        Value = Config.Value,
        AllowNone = Config.AllowNone,
        Multi = Config.Multi,
        Callback = Config.Callback or function() end,
        
        UIElements = {},
        
        Opened = false,
        Tabs = {}
    }
    
    local CanCallback = true
    
    Dropdown.DropdownFrame = require("../Components/Element")({
        Title = Dropdown.Title,
        Desc = Dropdown.Desc,
        Parent = Config.Parent,
        TextOffset = (30*6)+10,
        Hover = false,
    })
    
    
    Dropdown.UIElements.Dropdown = CreateLabel("", nil, Dropdown.DropdownFrame.UIElements.Main)
    
    Dropdown.UIElements.Dropdown.Frame.Frame.TextLabel.TextTruncate = "AtEnd"
    Dropdown.UIElements.Dropdown.Frame.Frame.TextLabel.Size = UDim2.new(1, Dropdown.UIElements.Dropdown.Frame.Frame.TextLabel.Size.X.Offset - 18 - 12 - 12,0,0)
    
    Dropdown.UIElements.Dropdown.Size = UDim2.new(0,30*6,0,42)
    Dropdown.UIElements.Dropdown.AnchorPoint = Vector2.new(1,0.5)
    Dropdown.UIElements.Dropdown.Position = UDim2.new(1,-Dropdown.DropdownFrame.UIPadding/2,0.5,0)
    
    New("UIScale", {
        Parent = Dropdown.UIElements.Dropdown,
        Scale = .85,
    })
    
    local DropdownIcon = New("ImageLabel", {
        Image = Creator.Icon("chevron-down")[1],
        ImageRectOffset = Creator.Icon("chevron-down")[2].ImageRectPosition,
        ImageRectSize = Creator.Icon("chevron-down")[2].ImageRectSize,
        Size = UDim2.new(0,18,0,18),
        Position = UDim2.new(1,-12,0.5,0),
        ThemeTag = {
            ImageColor3 = "Text"
        },
        AnchorPoint = Vector2.new(1,0.5),
        Parent = Dropdown.UIElements.Dropdown.Frame
    })

    Dropdown.UIElements.UIListLayout = New("UIListLayout", {
        Padding = UDim.new(0,Element.MenuPadding/1.5),
        FillDirection = "Vertical"
    })

    Dropdown.UIElements.Menu = New("Frame", {
        ThemeTag = {
            BackgroundColor3 = "Accent",
        },
        BackgroundTransparency = 0.15,
        Size = UDim2.new(1,0,1,0)
    }, {
--         New("UISizeConstraint", {
--			MinSize = Vector2.new(190, 0),
--		}),
        New("UICorner", {
            CornerRadius = UDim.new(0,Element.MenuCorner)
        }),
        New("UIStroke", {
            Thickness = 1,
            Transparency = 1, -- .93
            ThemeTag = {
                Color = "Text"
            }
        }),
		New("Frame", {
		    BackgroundTransparency = 1,
		    Size = UDim2.new(1,0,1,0),
		    Name = "CanvasGroup",
		    ClipsDescendants = true
		}, {
            New("UIPadding", {
                PaddingTop = UDim.new(0, Element.MenuPadding),
                PaddingLeft = UDim.new(0, Element.MenuPadding),
                PaddingRight = UDim.new(0, Element.MenuPadding),
                PaddingBottom = UDim.new(0, Element.MenuPadding),
            }),
            New("ScrollingFrame", {
                Size = UDim2.new(1,0,1,0),
                ScrollBarThickness = 0,
                ScrollingDirection = "Y",
                AutomaticCanvasSize = "Y",
                CanvasSize = UDim2.new(0,0,0,0),
                BackgroundTransparency = 1,
            }, {
                Dropdown.UIElements.UIListLayout,
            })
		})
    })

    Dropdown.UIElements.MenuCanvas = New("CanvasGroup", {
        Size = UDim2.new(0,190,0,300),
        BackgroundTransparency = 1,
        Position = UDim2.new(-10,0,-10,0),
        Visible = false,
        Active = false,
        GroupTransparency = 1, -- 0
        Parent = Config.Window.SuperParent.Parent.Dropdowns,
        AnchorPoint = Vector2.new(1,0),
    }, {
        Dropdown.UIElements.Menu,
        New("UIPadding", {
            PaddingTop = UDim.new(0,1),
            PaddingLeft = UDim.new(0,1),
            PaddingRight = UDim.new(0,1),
            PaddingBottom = UDim.new(0,1),
        }),
        New("UISizeConstraint", {
            MinSize = Vector2.new(190,0)
        })
    })
    
    function Dropdown:Lock()
        CanCallback = false
        return Dropdown.DropdownFrame:Lock()
    end
    function Dropdown:Unlock()
        CanCallback = true
        return Dropdown.DropdownFrame:Unlock()
    end
    
    if Dropdown.Locked then
        Dropdown:Lock()
    end
    
    local function RecalculateCanvasSize()
		Dropdown.UIElements.Menu.CanvasGroup.ScrollingFrame.CanvasSize = UDim2.fromOffset(0, Dropdown.UIElements.UIListLayout.AbsoluteContentSize.Y)
    end

    local function RecalculateListSize()
		if #Dropdown.Values > 10 then
			Dropdown.UIElements.MenuCanvas.Size = UDim2.fromOffset(Dropdown.UIElements.UIListLayout.AbsoluteContentSize.X, 392)
		else
			Dropdown.UIElements.MenuCanvas.Size = UDim2.fromOffset(Dropdown.UIElements.UIListLayout.AbsoluteContentSize.X, Dropdown.UIElements.UIListLayout.AbsoluteContentSize.Y + Element.MenuPadding*2 + 2)
		end
	end
    
    function UpdatePosition()
        local Add = - Dropdown.UIElements.Dropdown.AbsoluteSize.Y
        if Camera.ViewportSize.Y - Dropdown.UIElements.Dropdown.AbsolutePosition.Y - Dropdown.UIElements.Dropdown.AbsoluteSize.Y + Add < Dropdown.UIElements.MenuCanvas.AbsoluteSize.Y + 10 then
            Add = Dropdown.UIElements.MenuCanvas.AbsoluteSize.Y
                - (Camera.ViewportSize.Y - Dropdown.UIElements.Dropdown.AbsolutePosition.Y)
                + 10
        end
        Dropdown.UIElements.MenuCanvas.Position = UDim2.new(0, Dropdown.UIElements.Dropdown.AbsolutePosition.X + Dropdown.UIElements.Dropdown.AbsoluteSize.X + 1, 0, Dropdown.UIElements.Dropdown.AbsolutePosition.Y + Dropdown.UIElements.Dropdown.AbsoluteSize.Y - Add)
    end
    
    function Dropdown:Display()
		local Values = Dropdown.Values
		local Str = ""

		if Dropdown.Multi then
			for Idx, Value in next, Values do
				if table.find(Dropdown.Value, Value) then
					Str = Str .. Value .. ", "
				end
			end
			Str = Str:sub(1, #Str - 2)
		else
			Str = Dropdown.Value or ""
		end

		Dropdown.UIElements.Dropdown.Frame.Frame.TextLabel.Text = (Str == "" and "--" or Str)
	end
    
    function Dropdown:Refresh(Values)
        for _, Elementt in next, Dropdown.UIElements.Menu.CanvasGroup.ScrollingFrame:GetChildren() do
            if not Elementt:IsA("UIListLayout") then
                Elementt:Destroy()
            end
        end
        
        Dropdown.Tabs = {}
        
        for Index,Tab in next, Values do
            --task.wait(0.012)
            local TabMain = {
                Name = Tab,
                Selected = false,
                UIElements = {},
            }
            TabMain.UIElements.TabItem = New("TextButton", {
                Size = UDim2.new(1,0,0,34),
                --AutomaticSize = "Y",
                BackgroundTransparency = 1,
                Parent = Dropdown.UIElements.Menu.CanvasGroup.ScrollingFrame,
                Text = "",
                
            }, {
                New("UIPadding", {
                    PaddingTop = UDim.new(0,Element.TabPadding),
                    PaddingLeft = UDim.new(0,Element.TabPadding),
                    PaddingRight = UDim.new(0,Element.TabPadding),
                    PaddingBottom = UDim.new(0,Element.TabPadding),
                }),
                New("UICorner", {
                    CornerRadius = UDim.new(0,Element.MenuCorner - Element.MenuPadding)
                }),
                New("ImageLabel", {
                    Image = Creator.Icon("check")[1],
                    ImageRectSize = Creator.Icon("check")[2].ImageRectSize,
                    ImageRectOffset = Creator.Icon("check")[2].ImageRectPosition,
                    ThemeTag = {
                        ImageColor3 = "Text",
                    },
                    ImageTransparency = 1, -- .1
                    Size = UDim2.new(0,18,0,18),
                    AnchorPoint = Vector2.new(0,0.5),
                    Position = UDim2.new(0,0,0.5,0),
                    BackgroundTransparency = 1,
                }),
                New("TextLabel", {
                    Text = Tab,
                    TextXAlignment = "Left",
                    FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
                    ThemeTag = {
                        TextColor3 = "Text",
                        BackgroundColor3 = "Text"
                    },
                    TextSize = 15,
                    BackgroundTransparency = 1,
                    TextTransparency = .4,
                    AutomaticSize = "Y",
                    TextTruncate = "AtEnd",
                    Size = UDim2.new(1,-18-Element.TabPadding*3,0,0),
                    AnchorPoint = Vector2.new(0,0.5),
                    Position = UDim2.new(0,0,0.5,0), -- 0,18+Element.TabPadding,0.5,0
                })
            })
        
        
            if Dropdown.Multi then
                TabMain.Selected = table.find(Dropdown.Value or {}, TabMain.Name)
            else
                TabMain.Selected = Dropdown.Value == TabMain.Name
            end
            
            if TabMain.Selected then
                TabMain.UIElements.TabItem.BackgroundTransparency = .93
                TabMain.UIElements.TabItem.ImageLabel.ImageTransparency = .1
                TabMain.UIElements.TabItem.TextLabel.Position = UDim2.new(0,18+Element.TabPadding,0.5,0)
                TabMain.UIElements.TabItem.TextLabel.TextTransparency = 0
            end
            
            Dropdown.Tabs[Index] = TabMain
            
            Dropdown:Display()
            
            local function Callback()
                Dropdown:Display()
                task.spawn(function()
                    Dropdown.Callback(Dropdown.Value)
                end)
            end
            
            TabMain.UIElements.TabItem.MouseButton1Click:Connect(function()
                if Dropdown.Multi then
                    if not TabMain.Selected then
                        TabMain.Selected = true
                        Tween(TabMain.UIElements.TabItem, 0.1, {BackgroundTransparency = .93}):Play()
                        Tween(TabMain.UIElements.TabItem.ImageLabel, 0.1, {ImageTransparency = .1}):Play()
                        Tween(TabMain.UIElements.TabItem.TextLabel, 0.1, {Position = UDim2.new(0,18+Element.TabPadding,0.5,0), TextTransparency = 0}):Play()
                        table.insert(Dropdown.Value, TabMain.Name)
                    else
                        if not Dropdown.AllowNone and #Dropdown.Value == 1 then
                            return
                        end
                        TabMain.Selected = false
                        Tween(TabMain.UIElements.TabItem, 0.1, {BackgroundTransparency = 1}):Play()
                        Tween(TabMain.UIElements.TabItem.ImageLabel, 0.1, {ImageTransparency = 1}):Play()
                        Tween(TabMain.UIElements.TabItem.TextLabel, 0.1, {Position = UDim2.new(0,0,0.5,0), TextTransparency = .4}):Play()
                        for i, v in ipairs(Dropdown.Value) do
                            if v == TabMain.Name then
                                table.remove(Dropdown.Value, i)
                                break
                            end
                        end
                    end
                else
                    for Index, TabPisun in next, Dropdown.Tabs do
                        -- pisun
                        Tween(TabPisun.UIElements.TabItem, 0.1, {BackgroundTransparency = 1}):Play()
                        Tween(TabPisun.UIElements.TabItem.ImageLabel, 0.1, {ImageTransparency = 1}):Play()
                        Tween(TabPisun.UIElements.TabItem.TextLabel, 0.1, {Position = UDim2.new(0,0,0.5,0), TextTransparency = .4}):Play()
                        TabPisun.Selected = false
                    end
                    TabMain.Selected = true
                    Tween(TabMain.UIElements.TabItem, 0.1, {BackgroundTransparency = .93}):Play()
                    Tween(TabMain.UIElements.TabItem.ImageLabel, 0.1, {ImageTransparency = .1}):Play()
                    Tween(TabMain.UIElements.TabItem.TextLabel, 0.1, {Position = UDim2.new(0,18+Element.TabPadding,0.5,0), TextTransparency = 0}):Play()
                    Dropdown.Value = TabMain.Name
                end
                Callback()
            end)
            
            RecalculateCanvasSize()
            RecalculateListSize()
        end
    end
    
    Dropdown:Refresh(Dropdown.Values)
    
    function Dropdown:Select(Items)
        if Items then
            Dropdown.Value = Items
        end
        Dropdown:Refresh(Dropdown.Values)
    end
    
    --Dropdown:Display()
    RecalculateListSize()
    
    function Dropdown:Open()
        Dropdown.Opened = true
        Dropdown.UIElements.MenuCanvas.Visible = true
        Dropdown.UIElements.MenuCanvas.Active = true
        Dropdown.UIElements.Menu.Size = UDim2.new(
            1, 0,
            0, 0
        )
        Tween(Dropdown.UIElements.Menu, 0.1, {
            Size = UDim2.new(
                1, 0,
                1, 0
            )
        }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out):Play()
        
        Tween(DropdownIcon, .15, {Rotation = 180}):Play()
        Tween(Dropdown.UIElements.MenuCanvas, .15, {GroupTransparency = 0}):Play()
        
        UpdatePosition()
    end
    function Dropdown:Close()
        Dropdown.Opened = false
        
        Tween(Dropdown.UIElements.Menu, 0.1, {
            Size = UDim2.new(
                1, 0,
                0.8, 0
            )
        }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out):Play()
        Tween(DropdownIcon, .15, {Rotation = 0}):Play()
        Tween(Dropdown.UIElements.MenuCanvas, .15, {GroupTransparency = 1}):Play()
        task.wait(.1)
        Dropdown.UIElements.MenuCanvas.Visible = false
        Dropdown.UIElements.MenuCanvas.Active = false
    end
    
    Dropdown.UIElements.Dropdown.MouseButton1Click:Connect(function()
        if CanCallback then
            Dropdown:Open()
        end
    end)
    
    UserInputService.InputBegan:Connect(function(Input)
		if
			Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch
		then
			local AbsPos, AbsSize = Dropdown.UIElements.MenuCanvas.AbsolutePosition, Dropdown.UIElements.MenuCanvas.AbsoluteSize
			if
				Config.Window.CanDropdown
				and (Mouse.X < AbsPos.X
				or Mouse.X > AbsPos.X + AbsSize.X
				or Mouse.Y < (AbsPos.Y - 20 - 1)
				or Mouse.Y > AbsPos.Y + AbsSize.Y)
			then
				Dropdown:Close()
			end
		end
	end)
    
    Dropdown.UIElements.Dropdown:GetPropertyChangedSignal("AbsolutePosition"):Connect(UpdatePosition)
    
    return Dropdown.__type, Dropdown
end

return Element