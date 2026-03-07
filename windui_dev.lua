local WindUI = {}
WindUI.cache = {}

function WindUI.load(moduleName)
    if not WindUI.cache[moduleName] then
        WindUI.cache[moduleName] = { result = WindUI[moduleName]() }
    end
    return WindUI.cache[moduleName].result
end

do
    function WindUI.core()
        local RunService = game:GetService("RunService")
        local Heartbeat = RunService.Heartbeat
        local UserInputService = game:GetService("UserInputService")
        local TweenService = game:GetService("TweenService")
        local LocalizationService = game:GetService("LocalizationService")

        local IconManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/cxnker/WindUI/refs/heads/main/WindUI_1.6.1/Main_Icon.lua"))()
        IconManager.SetIconsType("lucide")

        local Core = {
            Font = "rbxassetid://12187365364",
            Localization = nil,
            CanDraggable = true,
            Theme = nil,
            Themes = nil,
            WindUI = nil,
            Signals = {},
            ThemeObjects = {},
            LocalizationObjects = {},
            FontObjects = {},
            Language = string.match(LocalizationService.SystemLocaleId, "^[a-z]+"),
            Request = http_request or (syn and syn.request) or request,
            DefaultProperties = {
                ScreenGui = {
                    ResetOnSpawn = false,
                    ZIndexBehavior = "Sibling",
                },
                CanvasGroup = {
                    BorderSizePixel = 0,
                    BackgroundColor3 = Color3.new(1, 1, 1),
                },
                Frame = {
                    BorderSizePixel = 0,
                    BackgroundColor3 = Color3.new(1, 1, 1),
                },
                TextLabel = {
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    Text = "",
                    RichText = true,
                    TextColor3 = Color3.new(1, 1, 1),
                    TextSize = 14,
                },
                TextButton = {
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                    TextColor3 = Color3.new(1, 1, 1),
                    TextSize = 14,
                },
                TextBox = {
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderColor3 = Color3.new(0, 0, 0),
                    ClearTextOnFocus = false,
                    Text = "",
                    TextColor3 = Color3.new(0, 0, 0),
                    TextSize = 14,
                },
                ImageLabel = {
                    BackgroundTransparency = 1,
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                },
                ImageButton = {
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                },
                UIListLayout = {
                    SortOrder = "LayoutOrder",
                },
                ScrollingFrame = {
                    ScrollBarImageTransparency = 1,
                    BorderSizePixel = 0,
                },
                VideoFrame = {
                    BorderSizePixel = 0,
                }
            },
            Colors = {
                Red = "#e53935",
                Orange = "#f57c00",
                Green = "#43a047",
                Blue = "#039be5",
                White = "#ffffff",
                Grey = "#484848",
            },
        }

        function Core.Init(windUI)
            Core.WindUI = windUI
        end

        function Core.AddSignal(signal, callback)
            table.insert(Core.Signals, signal:Connect(callback))
        end

        function Core.DisconnectAll()
            for index, signal in next, Core.Signals do
                local removedSignal = table.remove(Core.Signals, index)
                removedSignal:Disconnect()
            end
        end

        function Core.SafeCallback(callback, ...)
            if not callback then
                return
            end

            local success, errorResult = pcall(callback, ...)
            if not success then
                local startPos, endPos = errorResult:find(":%d+: ")

                warn("[ WindUI: DEBUG Mode ] " .. errorResult)

                return Core.WindUI:Notify({
                    Title = "DEBUG Mode: Error",
                    Content = not endPos and errorResult or errorResult:sub(endPos + 1),
                    Duration = 8,
                })
            end
        end

        function Core.SetTheme(theme)
            Core.Theme = theme
            Core.UpdateTheme(nil, true)
        end

        function Core.AddFontObject(fontObject)
            table.insert(Core.FontObjects, fontObject)
            Core.UpdateFont(Core.Font)
        end

        function Core.UpdateFont(font)
            Core.Font = font
            for _, fontObject in next, Core.FontObjects do
                fontObject.FontFace = Font.new(font, fontObject.FontFace.Weight, fontObject.FontFace.Style)
            end
        end

        function Core.GetThemeProperty(propertyName, theme)
            return theme[propertyName] or Core.Themes.Dark[propertyName]
        end

        function Core.AddThemeObject(object, properties)
            Core.ThemeObjects[object] = { Object = object, Properties = properties }
            Core.UpdateTheme(object, false)
            return object
        end

        function Core.AddLangObject(objectId)
            local langObject = Core.LocalizationObjects[objectId]
            local uiObject = langObject.Object
            local translationId = currentObjTranslationId
            Core.UpdateLang(uiObject, translationId)
            return uiObject
        end

        function Core.UpdateTheme(targetObject, shouldTween)
            local function ApplyTheme(themeObject)
                for propertyName, propertyValue in pairs(themeObject.Properties or {}) do
                    local colorValue = Core.GetThemeProperty(propertyValue, Core.Theme)
                    if colorValue then
                        if not shouldTween then
                            themeObject.Object[propertyName] = Color3.fromHex(colorValue)
                        else
                            Core.Tween(themeObject.Object, 0.08, { [propertyName] = Color3.fromHex(colorValue) }):Play()
                        end
                    end
                end
            end

            if targetObject then
                local themeObject = Core.ThemeObjects[targetObject]
                if themeObject then
                    ApplyTheme(themeObject)
                end
            else
                for _, themeObject in pairs(Core.ThemeObjects) do
                    ApplyTheme(themeObject)
                end
            end
        end

        function Core.SetLangForObject(objectId)
            if Core.Localization and Core.Localization.Enabled then
                local langObject = Core.LocalizationObjects[objectId]
                if not langObject then return end

                local uiObject = langObject.Object
                local translationId = langObject.TranslationId

                local languageTranslations = Core.Localization.Translations[Core.Language]
                if languageTranslations and languageTranslations[translationId] then
                    uiObject.Text = languageTranslations[translationId]
                else
                    local defaultTranslations = Core.Localization and Core.Localization.Translations and Core.Localization.Translations.en or nil
                    if defaultTranslations and defaultTranslations[translationId] then
                        uiObject.Text = defaultTranslations[translationId]
                    else
                        uiObject.Text = "[" .. translationId .. "]"
                    end
                end
            end
        end

        function Core.ChangeTranslationKey(prefix, uiObject, text)
            if Core.Localization and Core.Localization then
                local translationId = string.match(text, "^" .. Core.Localization.Prefix .. "(.+)")
                for index, langObject in ipairs(Core.LocalizationObjects) do
                    if langObject.Object == uiObject then
                        langObject.TranslationId = translationId
                        Core.SetLangForObject(index)
                        return
                    end
                end

                table.insert(Core.LocalizationObjects, {
                    TranslationId = translationId,
                    Object = uiObject
                })
                Core.SetLangForObject(#Core.LocalizationObjects)
            end
        end

        function Core.UpdateLang(language)
            if language then
                Core.Language = language
            end

            for index = 1, #Core.LocalizationObjects do
                local langObject = Core.LocalizationObjects[index]
                if langObject.Object and langObject.Object.Parent ~= nil then
                    Core.SetLangForObject(index)
                else
                    Core.LocalizationObjects[index] = nil
                end
            end
        end

        function Core.SetLanguage(language)
            Core.Language = language
            Core.UpdateLang()
        end

        function Core.Icon(iconName)
            return IconManager.Icon(iconName)
        end

        function Core.New(instanceType, properties, children)
            local newInstance = Instance.new(instanceType)

            for propName, propValue in next, Core.DefaultProperties[instanceType] or {} do
                newInstance[propName] = propValue
            end

            for propName, propValue in next, properties or {} do
                if propName ~= "ThemeTag" then
                    newInstance[propName] = propValue
                end
                if Core.Localization and Core.Localization.Enabled and propName == "Text" then
                    local translationId = string.match(propValue, "^" .. Core.Localization.Prefix .. "(.+)")
                    if translationId then
                        local objectIndex = #Core.LocalizationObjects + 1
                        Core.LocalizationObjects[objectIndex] = { TranslationId = translationId, Object = newInstance }

                        Core.SetLangForObject(objectIndex)
                    end
                end
            end

            for _, child in next, children or {} do
                child.Parent = newInstance
            end

            if properties and properties.ThemeTag then
                Core.AddThemeObject(newInstance, properties.ThemeTag)
            end
            if properties and properties.FontFace then
                Core.AddFontObject(newInstance)
            end
            return newInstance
        end

        function Core.Tween(obj, duration, properties, ...)
            return TweenService:Create(obj, TweenInfo.new(duration, ...), properties)
        end

        function Core.NewRoundFrame(size, shapeType, properties, children, isImageButton)
            local frame = Core.New(isImageButton and "ImageButton" or "ImageLabel", {
                Image = shapeType == "Squircle" and "rbxassetid://80999662900595"
                    or shapeType == "SquircleOutline" and "rbxassetid://117788349049947"
                    or shapeType == "SquircleOutline2" and "rbxassetid://117817408534198"
                    or shapeType == "Shadow-sm" and "rbxassetid://84825982946844"
                    or shapeType == "Squircle-TL-TR" and "rbxassetid://73569156276236",
                ScaleType = "Slice",
                SliceCenter = shapeType ~= "Shadow-sm" and Rect.new(256, 256, 256, 256) or Rect.new(512, 512, 512, 512),
                SliceScale = 1,
                BackgroundTransparency = 1,
                ThemeTag = properties.ThemeTag and properties.ThemeTag
            }, children)

            for propName, propValue in pairs(properties or {}) do
                if propName ~= "ThemeTag" then
                    frame[propName] = propValue
                end
            end

            local function UpdateSliceScale(newSize)
                local scale = shapeType ~= "Shadow-sm" and (newSize / 256) or (newSize / 512)
                frame.SliceScale = scale
            end

            UpdateSliceScale(size)

            return frame
        end

        local CreateInstance = Core.New
        local TweenObject = Core.Tween

        function Core.SetDraggable(enabled)
            Core.CanDraggable = enabled
        end

        function Core.Drag(targetFrame, dragFrames, onDragCallback)
            local isDragging
            local currentDragFrame, dragStartPos, initialPosition
            local dragController = {
                CanDraggable = true
            }

            if not dragFrames or type(dragFrames) ~= "table" then
                dragFrames = { targetFrame }
            end

            local function updatePosition(input)
                local delta = input.Position - dragStartPos
                Core.Tween(targetFrame, 0.02, {
                    Position = UDim2.new(
                        initialPosition.X.Scale, initialPosition.X.Offset + delta.X,
                        initialPosition.Y.Scale, initialPosition.Y.Offset + delta.Y
                    )
                }):Play()
            end

            for _, dragFrame in pairs(dragFrames) do
                dragFrame.InputBegan:Connect(function(input)
                    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and dragController.CanDraggable then
                        if isDragging == nil then
                            currentDragFrame = dragFrame
                            isDragging = true
                            dragStartPos = input.Position
                            initialPosition = targetFrame.Position

                            if onDragCallback and type(onDragCallback) == "function" then
                                onDragCallback(true, currentDragFrame)
                            end

                            input.Changed:Connect(function()
                                if input.UserInputState == Enum.UserInputState.End then
                                    isDragging = false
                                    currentDragFrame = nil

                                    if onDragCallback and type(onDragCallback) == "function" then
                                        onDragCallback(false, currentDragFrame)
                                    end
                                end
                            end)
                        end
                    end
                end)

                dragFrame.InputChanged:Connect(function(input)
                    if currentDragFrame == dragFrame and isDragging then
                        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                            dragStartPos = input
                        end
                    end
                end)
            end

            UserInputService.InputChanged:Connect(function(input)
                if input == dragStartPos and isDragging and currentDragFrame ~= nil then
                    if dragController.CanDraggable then
                        updatePosition(input)
                    end
                end
            end)

            function dragController.Set(_, enabled)
                dragController.CanDraggable = enabled
            end

            return dragController
        end

        function Core.Image(imagePath, fileName, cornerRadius, parent, folderName, isIconThemed, iconColor)
            local function SanitizeFilename(filename)
                filename = filename:gsub("[%s/\\:*?\"<>|]+", "-")
                filename = filename:gsub("[^%w%-_%.]", "")
                return filename
            end

            parent = parent or "Temp"
            fileName = SanitizeFilename(fileName)

            local imageContainer = CreateInstance("Frame", {
                Size = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1,
            }, {
                CreateInstance("ImageLabel", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    ScaleType = "Crop",
                    ThemeTag = (Core.Icon(imagePath) or iconColor) and {
                        ImageColor3 = iconColor and "Icon"
                    } or nil,
                }, {
                    CreateInstance("UICorner", {
                        CornerRadius = UDim.new(0, cornerRadius)
                    })
                })
            })
            
            if Core.Icon(imagePath) then
                imageContainer.ImageLabel.Image = Core.Icon(imagePath)[1]
                imageContainer.ImageLabel.ImageRectOffset = Core.Icon(imagePath)[2].ImageRectPosition
                imageContainer.ImageLabel.ImageRectSize = Core.Icon(imagePath)[2].ImageRectSize
            end
            
            if string.find(imagePath, "http") then
                local filePath = "WindUI/" .. parent .. "/Assets/." .. folderName .. "-" .. fileName .. ".png"
                local success, errorMsg = pcall(function()
                    task.spawn(function()
                        if not isfile(filePath) then
                            local response = Core.Request({
                                Url = imagePath,
                                Method = "GET",
                            }).Body

                            writefile(filePath, response)
                        end
                        imageContainer.ImageLabel.Image = getcustomasset(filePath)
                    end)
                end)
                if not success then
                    warn("[ WindUI.Creator ]  '" .. identifyexecutor() .. "' doesnt support the URL Images. Error: " .. errorMsg)

                    imageContainer:Destroy()
                end
            elseif string.find(imagePath, "rbxassetid") then
                imageContainer.ImageLabel.Image = imagePath
            end

            return imageContainer
        end

        return Core
    end

    function WindUI.localizationModule()
        local Localization = {}

        function Localization.New(_, options, core)
            local localizationData = {
                Enabled = options.Enabled or false,
                Translations = options.Translations or {},
                Prefix = options.Prefix or "loc:",
                DefaultLanguage = options.DefaultLanguage or "en"
            }

            core.Localization = localizationData

            return localizationData
        end

        return Localization
    end

    function WindUI.themes()
        return {
            Dark = {
                Name = "Dark",
                Accent = "#18181b",
                Dialog = "#18181b",
                Outline = "#FFFFFF",
                Text = "#FFFFFF",
                Placeholder = "#999999",
                Background = "#101010",
                Button = "#52525b",
                Icon = "#a1a1aa",
            },
            Light = {
                Name = "Light",
                Accent = "#FFFFFF",
                Dialog = "#f4f4f5",
                Outline = "#09090b",
                Text = "#000000",
                Placeholder = "#777777",
                Background = "#e4e4e7",
                Button = "#18181b",
                Icon = "#52525b",
            },
            Indigoo = {
                Name = "Indigoo",
                Accent = "#3730a3",
                Outline = "#c7d2fe",
                Text = "#f1f5f9",
                Placeholder = "#7078d9",
                Background = "#0f0a2e",
                Button = "#4f46e5",
                Icon = "#6366f1",
            },
            Red = {
                Name = "Red",
                Accent = "#ef4444",
                Outline = "#fee2e2",
                Text = "#ffe4e6",
                Placeholder = "#fca5a5",
                Background = "#7f1d1d",
                Button = "#ef4444",
                Icon = "#fecaca",
            },
            Indigo = {
                Name = "Indigo",
                Accent = "#6366f1",
                Outline = "#e0e7ff",
                Text = "#e0e7ff",
                Placeholder = "#a5b4fc",
                Background = "#312e81",
                Button = "#6366f1",
                Icon = "#c7d2fe",
            },
            Sky = {
                Name = "Sky",
                Accent = "#0ea5e9",
                Outline = "#e0f2fe",
                Text = "#e0f2fe",
                Placeholder = "#7dd3fc",
                Background = "#075985",
                Button = "#0ea5e9",
                Icon = "#bae6fd",
            },
            Violet = {
                Name = "Violet",
                Accent = "#8b5cf6",
                Outline = "#ede9fe",
                Text = "#ede9fe",
                Placeholder = "#c4b5fd",
                Background = "#4c1d95",
                Button = "#8b5cf6",
                Icon = "#ddd6fe",
            },
            Midnight = {
                Name = "Midnight",
                Accent = "#1e3a8a",
                Outline = "#bfdbfe",
                Text = "#dbeafe",
                Placeholder = "#2f74d1",
                Background = "#0a0f1e",
                Button = "#2563eb",
                Icon = "#3b82f6",
            },
            Amber = {
                Name = "Amber",
                Accent = "#f59e0b",
                Outline = "#fef3c7",
                Text = "#fef3c7",
                Placeholder = "#fcd34d",
                Background = "#78350f",
                Button = "#f59e0b",
                Icon = "#fde68a",
            },
            Emerald = {
                Name = "Emerald",
                Accent = "#10b981",
                Outline = "#d1fae5",
                Text = "#d1fae5",
                Placeholder = "#6ee7b7",
                Background = "#064e3b",
                Button = "#10b981",
                Icon = "#a7f3d0",
            },
        }
    end

    function WindUI.buttonModule()
        local ButtonModule = {}

        local Core = WindUI.load('core')
        local CreateInstance = Core.New
        local TweenObject = Core.Tween

        function ButtonModule.New(text, icon, callback, variant, parent, popupManager, isSpecial)
            variant = variant or "Primary"
            local cornerSize = not isSpecial and 10 or 99
            local iconLabel
            
            if icon and icon ~= "" then
                iconLabel = CreateInstance("ImageLabel", {
                    Image = Core.Icon(icon)[1],
                    ImageRectSize = Core.Icon(icon)[2].ImageRectSize,
                    ImageRectOffset = Core.Icon(icon)[2].ImageRectPosition,
                    Size = UDim2.new(0, 21, 0, 21),
                    BackgroundTransparency = 1,
                    ThemeTag = {
                        ImageColor3 = "Icon",
                    }
                })
            end

            local button = CreateInstance("TextButton", {
                Size = UDim2.new(0, 0, 1, 0),
                AutomaticSize = "X",
                Parent = parent,
                BackgroundTransparency = 1
            }, {
                Core.NewRoundFrame(cornerSize, "Squircle", {
                    ThemeTag = {
                        ImageColor3 = variant ~= "White" and "Button" or nil,
                    },
                    ImageColor3 = variant == "White" and Color3.new(1, 1, 1) or nil,
                    Size = UDim2.new(1, 0, 1, 0),
                    Name = "Squircle",
                    ImageTransparency = variant == "Primary" and 0 or variant == "White" and 0 or 1
                }),

                Core.NewRoundFrame(cornerSize, "Squircle", {
                    ImageColor3 = Color3.new(1, 1, 1),
                    Size = UDim2.new(1, 0, 1, 0),
                    Name = "Special",
                    ImageTransparency = variant == "Secondary" and 0.95 or 1
                }),

                Core.NewRoundFrame(cornerSize, "Shadow-sm", {
                    ImageColor3 = Color3.new(0, 0, 0),
                    Size = UDim2.new(1, 3, 1, 3),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    Name = "Shadow",
                    ImageTransparency = variant == "Secondary" and 0 or 1,
                    Visible = not isSpecial
                }),

                Core.NewRoundFrame(cornerSize, not isSpecial and "SquircleOutline" or "SquircleOutline2", {
                    ThemeTag = {
                        ImageColor3 = variant ~= "White" and "Outline" or nil,
                    },
                    Size = UDim2.new(1, 0, 1, 0),
                    ImageColor3 = variant == "White" and Color3.new(0, 0, 0) or nil,
                    ImageTransparency = variant == "Primary" and 0.95 or 0.85,
                    Name = "SquircleOutline",
                }),

                Core.NewRoundFrame(cornerSize, "Squircle", {
                    Size = UDim2.new(1, 0, 1, 0),
                    Name = "Frame",
                    ThemeTag = {
                        ImageColor3 = variant ~= "White" and "Text" or nil
                    },
                    ImageColor3 = variant == "White" and Color3.new(0, 0, 0) or nil,
                    ImageTransparency = 1
                }, {
                    CreateInstance("UIPadding", {
                        PaddingLeft = UDim.new(0, 16),
                        PaddingRight = UDim.new(0, 16),
                    }),
                    CreateInstance("UIListLayout", {
                        FillDirection = "Horizontal",
                        Padding = UDim.new(0, 8),
                        VerticalAlignment = "Center",
                        HorizontalAlignment = "Center",
                    }),
                    iconLabel,
                    CreateInstance("TextLabel", {
                        BackgroundTransparency = 1,
                        FontFace = Font.new(Core.Font, Enum.FontWeight.SemiBold),
                        Text = text or "Button",
                        ThemeTag = {
                            TextColor3 = (variant ~= "Primary" and variant ~= "White") and "Text",
                        },
                        TextColor3 = variant == "Primary" and Color3.new(1, 1, 1) or variant == "White" and Color3.new(0, 0, 0) or nil,
                        AutomaticSize = "XY",
                        TextSize = 18,
                    })
                })
            })

            Core.AddSignal(button.MouseEnter, function()
                TweenObject(button.Frame, 0.047, { ImageTransparency = 0.95 }):Play()
            end)
            
            Core.AddSignal(button.MouseLeave, function()
                TweenObject(button.Frame, 0.047, { ImageTransparency = 1 }):Play()
            end)
            
            Core.AddSignal(button.MouseButton1Up, function()
                if popupManager then
                    popupManager:Close()()
                end
                if callback then
                    Core.SafeCallback(callback)
                end
            end)

            return button
        end

        return ButtonModule
    end

    function WindUI.inputModule()
        local InputModule = {}

        local Core = WindUI.load('core')
        local CreateInstance = Core.New
        local TweenObject = Core.Tween

        function InputModule.New(placeholder, icon, parent, inputType, callback)
            inputType = inputType or "Input"
            local cornerSize = 10
            local iconLabel
            
            if icon and icon ~= "" then
                iconLabel = CreateInstance("ImageLabel", {
                    Image = Core.Icon(icon)[1],
                    ImageRectSize = Core.Icon(icon)[2].ImageRectSize,
                    ImageRectOffset = Core.Icon(icon)[2].ImageRectPosition,
                    Size = UDim2.new(0, 21, 0, 21),
                    BackgroundTransparency = 1,
                    ThemeTag = {
                        ImageColor3 = "Icon",
                    }
                })
            end

            local isMultiline = inputType ~= "Input"

            local textBox = CreateInstance("TextBox", {
                BackgroundTransparency = 1,
                TextSize = 16,
                FontFace = Font.new(Core.Font, Enum.FontWeight.Regular),
                Size = UDim2.new(1, iconLabel and -29 or 0, 1, 0),
                PlaceholderText = placeholder,
                ClearTextOnFocus = false,
                ClipsDescendants = true,
                TextWrapped = isMultiline,
                MultiLine = isMultiline,
                TextXAlignment = "Left",
                TextYAlignment = inputType == "Input" and "Center" or "Top",
                ThemeTag = {
                    PlaceholderColor3 = "PlaceholderText",
                    TextColor3 = "Text",
                },
            })

            local container = CreateInstance("Frame", {
                Size = UDim2.new(1, 0, 0, 42),
                Parent = parent,
                BackgroundTransparency = 1
            }, {
                CreateInstance("Frame", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                }, {
                    Core.NewRoundFrame(cornerSize, "Squircle", {
                        ThemeTag = {
                            ImageColor3 = "Accent",
                        },
                        Size = UDim2.new(1, 0, 1, 0),
                        ImageTransparency = 0.85,
                    }),
                    Core.NewRoundFrame(cornerSize, "SquircleOutline", {
                        ThemeTag = {
                            ImageColor3 = "Outline",
                        },
                        Size = UDim2.new(1, 0, 1, 0),
                        ImageTransparency = 0.9,
                    }),
                    Core.NewRoundFrame(cornerSize, "Squircle", {
                        Size = UDim2.new(1, 0, 1, 0),
                        Name = "Frame",
                        ImageColor3 = Color3.new(1, 1, 1),
                        ImageTransparency = 0.95
                    }, {
                        CreateInstance("UIPadding", {
                            PaddingTop = UDim.new(0, inputType == "Input" and 0 or 12),
                            PaddingLeft = UDim.new(0, 12),
                            PaddingRight = UDim.new(0, 12),
                            PaddingBottom = UDim.new(0, inputType == "Input" and 0 or 12),
                        }),
                        CreateInstance("UIListLayout", {
                            FillDirection = "Horizontal",
                            Padding = UDim.new(0, 8),
                            VerticalAlignment = inputType == "Input" and "Center" or "Top",
                            HorizontalAlignment = "Left",
                        }),
                        iconLabel,
                        textBox,
                    })
                })
            })

            Core.AddSignal(textBox.FocusLost, function()
                if callback then
                    Core.SafeCallback(callback, textBox.Text)
                end
            end)

            return container
        end

        return InputModule
    end

    function WindUI.popupModule()
        local PopupModule = {}

        local Core = WindUI.load('core')
        local CreateInstance = Core.New
        local TweenObject = Core.Tween

        local PopupDefaults = {
            Holder = nil,
            Window = nil,
            Parent = nil,
        }

        function PopupDefaults.Init(window, parent)
            PopupDefaults.Window = window
            PopupDefaults.Parent = parent
            return PopupDefaults
        end

        function PopupDefaults.Create(isTooltip)
            local popup = {
                UICorner = 32,
                UIPadding = 12,
                UIElements = {}
            }

            if isTooltip then popup.UIPadding = 0 end
            if isTooltip then popup.UICorner = 26 end

            if not isTooltip then
                popup.UIElements.FullScreen = CreateInstance("Frame", {
                    ZIndex = 999,
                    BackgroundTransparency = 1,
                    BackgroundColor3 = Color3.fromHex("#000000"),
                    Size = UDim2.new(1, 0, 1, 0),
                    Active = false,
                    Visible = false,
                    Parent = PopupDefaults.Parent or (PopupDefaults.Window and PopupDefaults.Window.UIElements and PopupDefaults.Window.UIElements.Main and PopupDefaults.Window.UIElements.Main.Main)
                }, {
                    CreateInstance("UICorner", {
                        CornerRadius = UDim.new(0, PopupDefaults.Window.UICorner)
                    })
                })
            end

            popup.UIElements.Main = CreateInstance("Frame", {
                Size = UDim2.new(0, 280, 0, 0),
                ThemeTag = {
                    BackgroundColor3 = "Dialog",
                },
                AutomaticSize = "Y",
                BackgroundTransparency = 1,
                Visible = false,
                ZIndex = 99999,
            }, {
                CreateInstance("UIPadding", {
                    PaddingTop = UDim.new(0, popup.UIPadding),
                    PaddingLeft = UDim.new(0, popup.UIPadding),
                    PaddingRight = UDim.new(0, popup.UIPadding),
                    PaddingBottom = UDim.new(0, popup.UIPadding),
                })
            })

            popup.UIElements.MainContainer = Core.NewRoundFrame(popup.UICorner, "Squircle", {
                Visible = false,
                ImageTransparency = isTooltip and 0.15 or 0,
                Parent = isTooltip and PopupDefaults.Parent or popup.UIElements.FullScreen,
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                AutomaticSize = "XY",
                ThemeTag = {
                    ImageColor3 = "Dialog"
                },
                ZIndex = 9999,
            }, {
                popup.UIElements.Main,
                Core.NewRoundFrame(popup.UICorner, "SquircleOutline2", {
                    Size = UDim2.new(1, 0, 1, 0),
                    ImageTransparency = 0.85,
                    ThemeTag = {
                        ImageColor3 = "Outline",
                    },
                }, {
                    CreateInstance("UIGradient", {
                        Rotation = 45,
                        Transparency = NumberSequence.new{
                            NumberSequenceKeypoint.new(0, 0.55),
                            NumberSequenceKeypoint.new(0.5, 0.8),
                            NumberSequenceKeypoint.new(1, 0.6)
                        }
                    })
                })
            })

            function popup.Open()
                if not isTooltip then
                    popup.UIElements.FullScreen.Visible = true
                    popup.UIElements.FullScreen.Active = true
                end

                task.spawn(function()
                    popup.UIElements.MainContainer.Visible = true

                    if not isTooltip then
                        TweenObject(popup.UIElements.FullScreen, 0.1, { BackgroundTransparency = 0.3 }):Play()
                    end
                    TweenObject(popup.UIElements.MainContainer, 0.1, { ImageTransparency = 0 }):Play()

                    task.spawn(function()
                        task.wait(0.05)
                        popup.UIElements.Main.Visible = true
                    end)
                end)
            end
            
            function popup.Close()
                if not isTooltip then
                    TweenObject(popup.UIElements.FullScreen, 0.1, { BackgroundTransparency = 1 }):Play()
                    popup.UIElements.FullScreen.Active = false
                    task.spawn(function()
                        task.wait(0.1)
                        popup.UIElements.FullScreen.Visible = false
                    end)
                end
                popup.UIElements.Main.Visible = false

                TweenObject(popup.UIElements.MainContainer, 0.1, { ImageTransparency = 1 }):Play()

                task.spawn(function()
                    task.wait(0.1)
                    if not isTooltip then
                        popup.UIElements.FullScreen:Destroy()
                    else
                        popup.UIElements.MainContainer:Destroy()
                    end
                end)

                return function() end
            end

            return popup
        end

        return PopupDefaults
    end

    function WindUI.keySystemModule()
        local KeySystemModule = {}

        local Core = WindUI.load('core')
        local CreateInstance = Core.New
        local TweenObject = Core.Tween

        local ButtonCreator = WindUI.load('buttonModule').New
        local InputCreator = WindUI.load('inputModule').New

        function KeySystemModule.new(window, keyData, onSuccess)
            local PopupManager = WindUI.load('popupModule').Init(nil, window.WindUI.ScreenGui.KeySystem)
            local popup = PopupManager.Create(true)

            local enteredKey

            local thumbSize = 200
            local popupWidth = 430
            if keyData.KeySystem.Thumbnail and keyData.KeySystem.Thumbnail.Image then
                popupWidth = 430 + (thumbSize / 2)
            end

            popup.UIElements.Main.AutomaticSize = "Y"
            popup.UIElements.Main.Size = UDim2.new(0, popupWidth, 0, 0)

            local iconImage

            if keyData.Icon then
                iconImage = Core.Image(
                    keyData.Icon,
                    keyData.Title .. ":" .. keyData.Icon,
                    0,
                    keyData.WindUI.Window,
                    "KeySystem",
                    keyData.IconThemed
                )
                iconImage.Size = UDim2.new(0, 24, 0, 24)
                iconImage.LayoutOrder = -1
            end

            local titleLabel = CreateInstance("TextLabel", {
                AutomaticSize = "XY",
                BackgroundTransparency = 1,
                Text = keyData.Title,
                FontFace = Font.new(Core.Font, Enum.FontWeight.SemiBold),
                ThemeTag = {
                    TextColor3 = "Text",
                },
                TextSize = 20
            })
            
            local keySystemLabel = CreateInstance("TextLabel", {
                AutomaticSize = "XY",
                BackgroundTransparency = 1,
                Text = "Key System",
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, 0, 0.5, 0),
                TextTransparency = 1,
                FontFace = Font.new(Core.Font, Enum.FontWeight.Medium),
                ThemeTag = {
                    TextColor3 = "Text",
                },
                TextSize = 16
            })

            local titleContainer = CreateInstance("Frame", {
                BackgroundTransparency = 1,
                AutomaticSize = "XY",
            }, {
                CreateInstance("UIListLayout", {
                    Padding = UDim.new(0, 14),
                    FillDirection = "Horizontal",
                    VerticalAlignment = "Center"
                }),
                iconImage,
                titleLabel
            })

            local headerContainer = CreateInstance("Frame", {
                AutomaticSize = "Y",
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1,
            }, {
                titleContainer,
                keySystemLabel,
            })

            local noteLabel
            if keyData.KeySystem.Note and keyData.KeySystem.Note ~= "" then
                noteLabel = CreateInstance("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = "Y",
                    FontFace = Font.new(Core.Font, Enum.FontWeight.Medium),
                    TextXAlignment = "Left",
                    Text = keyData.KeySystem.Note,
                    TextSize = 18,
                    TextTransparency = 0.4,
                    ThemeTag = {
                        TextColor3 = "Text",
                    },
                    BackgroundTransparency = 1,
                    RichText = true
                })
            end

            local keyInput = InputCreator("Enter Key", "key", nil, "Input", function(inputText)
                enteredKey = inputText
            end)

            local buttonContainer = CreateInstance("Frame", {
                Size = UDim2.new(1, 0, 0, 42),
                BackgroundTransparency = 1,
            }, {
                CreateInstance("Frame", {
                    BackgroundTransparency = 1,
                    AutomaticSize = "X",
                    Size = UDim2.new(0, 0, 1, 0),
                }, {
                    CreateInstance("UIListLayout", {
                        Padding = UDim.new(0, 9),
                        FillDirection = "Horizontal",
                    })
                })
            })

            local thumbnail
            if keyData.KeySystem.Thumbnail and keyData.KeySystem.Thumbnail.Image then
                local thumbnailTitle
                if keyData.KeySystem.Thumbnail.Title then
                    thumbnailTitle = CreateInstance("TextLabel", {
                        Text = keyData.KeySystem.Thumbnail.Title,
                        ThemeTag = {
                            TextColor3 = "Text",
                        },
                        TextSize = 18,
                        FontFace = Font.new(Core.Font, Enum.FontWeight.Medium),
                        BackgroundTransparency = 1,
                        AutomaticSize = "XY",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.new(0.5, 0, 0.5, 0),
                    })
                end
                
                thumbnail = CreateInstance("ImageLabel", {
                    Image = keyData.KeySystem.Thumbnail.Image,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, thumbSize, 1, 0),
                    Parent = popup.UIElements.Main,
                    ScaleType = "Crop"
                }, {
                    thumbnailTitle,
                    CreateInstance("UICorner", {
                        CornerRadius = UDim.new(0, 0),
                    })
                })
            end

            CreateInstance("Frame", {
                Size = UDim2.new(1, thumbnail and -thumbSize or 0, 1, 0),
                Position = UDim2.new(0, thumbnail and thumbSize or 0, 0, 0),
                BackgroundTransparency = 1,
                Parent = popup.UIElements.Main
            }, {
                CreateInstance("Frame", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                }, {
                    CreateInstance("UIListLayout", {
                        Padding = UDim.new(0, 18),
                        FillDirection = "Vertical",
                    }),
                    headerContainer,
                    noteLabel,
                    keyInput,
                    buttonContainer,
                    CreateInstance("UIPadding", {
                        PaddingTop = UDim.new(0, 16),
                        PaddingLeft = UDim.new(0, 16),
                        PaddingRight = UDim.new(0, 16),
                        PaddingBottom = UDim.new(0, 16),
                    })
                }),
            })

            local exitButton = ButtonCreator("Exit", "log-out", function()
                popup:Close()()
            end, "Tertiary", buttonContainer.Frame)

            if thumbnail then
                exitButton.Parent = thumbnail
                exitButton.Size = UDim2.new(0, 0, 0, 42)
                exitButton.Position = UDim2.new(0, 16, 1, -16)
                exitButton.AnchorPoint = Vector2.new(0, 1)
            end

            if keyData.KeySystem.URL then
                ButtonCreator("Get key", "key", function()
                    setclipboard(keyData.KeySystem.URL)
                end, "Secondary", buttonContainer.Frame)
            end

            local submitButton = ButtonCreator("Submit", "arrow-right", function()
                local inputKey = enteredKey
                local isValid
                
                if type(keyData.KeySystem.Key) == "table" then
                    isValid = table.find(keyData.KeySystem.Key, tostring(inputKey))
                else
                    isValid = tostring(keyData.KeySystem.Key) == tostring(inputKey)
                end

                if isValid then
                    popup:Close()()

                    if keyData.KeySystem.SaveKey then
                        local saveFolder = keyData.Folder or keyData.Title
                        writefile(saveFolder .. "/" .. keyData .. ".key", tostring(inputKey))
                    end

                    task.wait(0.4)
                    onSuccess(true)
                end
            end, "Primary", buttonContainer)

            submitButton.AnchorPoint = Vector2.new(1, 0.5)
            submitButton.Position = UDim2.new(1, 0, 0.5, 0)

            popup:Open()
        end

        return KeySystemModule
    end

    function WindUI.notificationModule()
        local NotificationModule = {}

        local Core = WindUI.load('core')
        local CreateInstance = Core.New
        local TweenObject = Core.Tween

        local Defaults = {
            Size = UDim2.new(0, 300, 1, -156),
            SizeLower = UDim2.new(0, 300, 1, -56),
            UICorner = 16,
            UIPadding = 14,
            ButtonPadding = 9,
            Holder = nil,
            NotificationIndex = 0,
            Notifications = {}
        }

        function Defaults.Init(parent)
            local container = {
                Lower = false
            }

            function container.SetLower(state)
                container.Lower = state
                container.Frame.Size = state and Defaults.SizeLower or Defaults.Size
            end

            container.Frame = CreateInstance("Frame", {
                Position = UDim2.new(1, -29, 0, 56),
                AnchorPoint = Vector2.new(1, 0),
                Size = Defaults.Size,
                Parent = parent,
                BackgroundTransparency = 1,
            }, {
                CreateInstance("UIListLayout", {
                    HorizontalAlignment = "Center",
                    SortOrder = "LayoutOrder",
                    VerticalAlignment = "Bottom",
                    Padding = UDim.new(0, 8),
                }),
                CreateInstance("UIPadding", {
                    PaddingBottom = UDim.new(0, 29)
                })
            })
            return container
        end

        function Defaults.New(notificationData)
            local notification = {
                Title = notificationData.Title or "Notification",
                Content = notificationData.Content or nil,
                Icon = notificationData.Icon or nil,
                IconThemed = notificationData.IconThemed,
                Background = notificationData.Background,
                BackgroundImageTransparency = notificationData.BackgroundImageTransparency,
                Duration = notificationData.Duration or 5,
                Buttons = notificationData.Buttons or {},
                CanClose = true,
                UIElements = {},
                Closed = false,
            }
            
            if notification.CanClose == nil then
                notification.CanClose = true
            end
            
            Defaults.NotificationIndex = Defaults.NotificationIndex + 1
            Defaults.Notifications[Defaults.NotificationIndex] = notification

            local corner = CreateInstance("UICorner", {
                CornerRadius = UDim.new(0, Defaults.UICorner),
            })

            local stroke = CreateInstance("UIStroke", {
                ThemeTag = {
                    Color = "Text"
                },
                Transparency = 1,
                Thickness = 0.6,
            })

            local iconImage

            if notification.Icon then
                iconImage = Core.Image(
                    notification.Icon,
                    notification.Title .. ":" .. notification.Icon,
                    0,
                    window,
                    "Notification",
                    notification.IconThemed
                )
                iconImage.Size = UDim2.new(0, 26, 0, 26)
                iconImage.Position = UDim2.new(0, Defaults.UIPadding, 0, Defaults.UIPadding)
            end

            local closeButton
            if notification.CanClose then
                closeButton = CreateInstance("ImageButton", {
                    Image = Core.Icon("x")[1],
                    ImageRectSize = Core.Icon("x")[2].ImageRectSize,
                    ImageRectOffset = Core.Icon("x")[2].ImageRectPosition,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(1, -Defaults.UIPadding, 0, Defaults.UIPadding),
                    AnchorPoint = Vector2.new(1, 0),
                    ThemeTag = {
                        ImageColor3 = "Text"
                    }
                }, {
                    CreateInstance("TextButton", {
                        Size = UDim2.new(1, 8, 1, 8),
                        BackgroundTransparency = 1,
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.new(0.5, 0, 0.5, 0),
                        Text = "",
                    })
                })
            end

            local progressBar = CreateInstance("Frame", {
                Size = UDim2.new(1, 0, 0, 3),
                BackgroundTransparency = 0.9,
                ThemeTag = {
                    BackgroundColor3 = "Text",
                },
            })

            local contentContainer = CreateInstance("Frame", {
                Size = UDim2.new(1, notification.Icon and -28 - Defaults.UIPadding or 0, 1, 0),
                Position = UDim2.new(1, 0, 0, 0),
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 1,
                AutomaticSize = "Y",
            }, {
                CreateInstance("UIPadding", {
                    PaddingTop = UDim.new(0, Defaults.UIPadding),
                    PaddingLeft = UDim.new(0, Defaults.UIPadding),
                    PaddingRight = UDim.new(0, Defaults.UIPadding),
                    PaddingBottom = UDim.new(0, Defaults.UIPadding),
                }),
                CreateInstance("TextLabel", {
                    AutomaticSize = "Y",
                    Size = UDim2.new(1, -30 - Defaults.UIPadding, 0, 0),
                    TextWrapped = true,
                    TextXAlignment = "Left",
                    RichText = true,
                    BackgroundTransparency = 1,
                    TextSize = 16,
                    ThemeTag = {
                        TextColor3 = "Text"
                    },
                    Text = notification.Title,
                    FontFace = Font.new(Core.Font, Enum.FontWeight.SemiBold)
                }),
                CreateInstance("UIListLayout", {
                    Padding = UDim.new(0, Defaults.UIPadding / 3)
                })
            })

            if notification.Content then
                CreateInstance("TextLabel", {
                    AutomaticSize = "Y",
                    Size = UDim2.new(1, 0, 0, 0),
                    TextWrapped = true,
                    TextXAlignment = "Left",
                    RichText = true,
                    BackgroundTransparency = 1,
                    TextTransparency = 0.4,
                    TextSize = 15,
                    ThemeTag = {
                        TextColor3 = "Text"
                    },
                    Text = notification.Content,
                    FontFace = Font.new(Core.Font, Enum.FontWeight.Medium),
                    Parent = contentContainer
                })
            end

            local canvasGroup = CreateInstance("CanvasGroup", {
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(2, 0, 1, 0),
                AnchorPoint = Vector2.new(0, 1),
                AutomaticSize = "Y",
                BackgroundTransparency = 0.25,
                ThemeTag = {
                    BackgroundColor3 = "Accent"
                },
            }, {
                CreateInstance("ImageLabel", {
                    Name = "Background",
                    Image = notification.Background,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    ScaleType = "Crop",
                    ImageTransparency = notification.BackgroundImageTransparency
                }),
                stroke,
                corner,
                contentContainer,
                iconImage,
                closeButton,
                progressBar,
            })

            local container = CreateInstance("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0),
                Parent = holder
            }, {
                canvasGroup
            })

            function notification.Close()
                if not notification.Closed then
                    notification.Closed = true
                    TweenObject(container, 0.45, { Size = UDim2.new(1, 0, 0, -8) }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
                    TweenObject(canvasGroup, 0.55, { Position = UDim2.new(2, 0, 1, 0) }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
                    task.wait(0.45)
                    container:Destroy()
                end
            end

            task.spawn(function()
                task.wait()
                TweenObject(container, 0.45, {
                    Size = UDim2.new(
                        1,
                        0,
                        0,
                        canvasGroup.AbsoluteSize.Y
                    )
                }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
                
                TweenObject(canvasGroup, 0.45, { Position = UDim2.new(0, 0, 1, 0) }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
                
                if notification.Duration then
                    TweenObject(progressBar, notification.Duration, { Size = UDim2.new(0, 0, 0, 3) }, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut):Play()
                    task.wait(notification.Duration)
                    notification:Close()
                end
            end)

            if closeButton then
                Core.AddSignal(closeButton.TextButton.MouseButton1Click, function()
                    notification:Close()
                end)
            end

            return notification
        end

        return Defaults
    end

    function WindUI.dialogModule()
        local DialogModule = {}

        local Core = WindUI.load('core')
        local CreateInstance = Core.New
        local TweenObject = Core.Tween

        function DialogModule.new(dialogData)
            local dialog = {
                Title = dialogData.Title or "Dialog",
                Content = dialogData.Content,
                Icon = dialogData.Icon,
                IconThemed = dialogData.IconThemed,
                Thumbnail = dialogData.Thumbnail,
                Buttons = dialogData.Buttons
            }

            local PopupManager = WindUI.load('popupModule').Init(nil, dialogData.WindUI.ScreenGui.Popups)
            local popup = PopupManager.Create(true)

            local thumbSize = 200
            local popupWidth = 430
            if dialog.Thumbnail and dialog.Thumbnail.Image then
                popupWidth = 430 + (thumbSize / 2)
            end

            popup.UIElements.Main.AutomaticSize = "Y"
            popup.UIElements.Main.Size = UDim2.new(0, popupWidth, 0, 0)

            local iconImage

            if dialog.Icon then
                iconImage = Core.Image(
                    dialog.Icon,
                    dialog.Title .. ":" .. dialog.Icon,
                    0,
                    dialogData.WindUI.Window,
                    "Popup",
                    dialogData.IconThemed
                )
                iconImage.Size = UDim2.new(0, 22, 0, 22)
                iconImage.LayoutOrder = -1
            end

            local titleLabel = CreateInstance("TextLabel", {
                AutomaticSize = "XY",
                BackgroundTransparency = 1,
                Text = dialog.Title,
                TextXAlignment = "Left",
                FontFace = Font.new(Core.Font, Enum.FontWeight.SemiBold),
                ThemeTag = {
                    TextColor3 = "Text",
                },
                TextSize = 20
            })

            local titleContainer = CreateInstance("Frame", {
                BackgroundTransparency = 1,
                AutomaticSize = "XY",
            }, {
                CreateInstance("UIListLayout", {
                    Padding = UDim.new(0, 14),
                    FillDirection = "Horizontal",
                    VerticalAlignment = "Center"
                }),
                iconImage,
                titleLabel
            })

            local headerContainer = CreateInstance("Frame", {
                AutomaticSize = "Y",
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1,
            }, {
                titleContainer,
            })

            local contentLabel
            if dialog.Content and dialog.Content ~= "" then
                contentLabel = CreateInstance("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = "Y",
                    FontFace = Font.new(Core.Font, Enum.FontWeight.Medium),
                    TextXAlignment = "Left",
                    Text = dialog.Content,
                    TextSize = 18,
                    TextTransparency = 0.2,
                    ThemeTag = {
                        TextColor3 = "Text",
                    },
                    BackgroundTransparency = 1,
                    RichText = true
                })
            end

            local buttonContainer = CreateInstance("Frame", {
                Size = UDim2.new(1, 0, 0, 42),
                BackgroundTransparency = 1,
            }, {
                CreateInstance("UIListLayout", {
                    Padding = UDim.new(0, 9),
                    FillDirection = "Horizontal",
                    HorizontalAlignment = "Right"
                })
            })

            local thumbnail
            if dialog.Thumbnail and dialog.Thumbnail.Image then
                local thumbnailTitle
                if dialog.Thumbnail.Title then
                    thumbnailTitle = CreateInstance("TextLabel", {
                        Text = dialog.Thumbnail.Title,
                        ThemeTag = {
                            TextColor3 = "Text",
                        },
                        TextSize = 18,
                        FontFace = Font.new(Core.Font, Enum.FontWeight.Medium),
                        BackgroundTransparency = 1,
                        AutomaticSize = "XY",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.new(0.5, 0, 0.5, 0),
                    })
                end
                
                thumbnail = CreateInstance("ImageLabel", {
                    Image = dialog.Thumbnail.Image,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, thumbSize, 1, 0),
                    Parent = popup.UIElements.Main,
                    ScaleType = "Crop"
                }, {
                    thumbnailTitle,
                    CreateInstance("UICorner", {
                        CornerRadius = UDim.new(0, 0),
                    })
                })
            end

            CreateInstance("Frame", {
                Size = UDim2.new(1, thumbnail and -thumbSize or 0, 1, 0),
                Position = UDim2.new(0, thumbnail and thumbSize or 0, 0, 0),
                BackgroundTransparency = 1,
                Parent = popup.UIElements.Main
            }, {
                CreateInstance("Frame", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                }, {
                    CreateInstance("UIListLayout", {
                        Padding = UDim.new(0, 18),
                        FillDirection = "Vertical",
                    }),
                    headerContainer,
                    contentLabel,
                    buttonContainer,
                    CreateInstance("UIPadding", {
                        PaddingTop = UDim.new(0, 16),
                        PaddingLeft = UDim.new(0, 16),
                        PaddingRight = UDim.new(0, 16),
                        PaddingBottom = UDim.new(0, 16),
                    })
                }),
            })

            local ButtonCreator = WindUI.load('buttonModule').New

            for _, buttonInfo in next, dialog.Buttons do
                ButtonCreator(buttonInfo.Title, buttonInfo.Icon, buttonInfo.Callback, buttonInfo.Variant, buttonContainer, popup, true)
            end

            popup:Open()

            return dialog
        end

        return DialogModule
    end

    function WindUI.keybindButtonModule()
        local KeybindButtonModule = {}

        local Core = WindUI.load('core')
        local CreateInstance = Core.New
        local TweenObject = Core.Tween

        function KeybindButtonModule.New(text, icon, parent)
            local cornerSize = 10
            local iconLabel
            
            if icon and icon ~= "" then
                iconLabel = CreateInstance("ImageLabel", {
                    Image = Core.Icon(icon)[1],
                    ImageRectSize = Core.Icon(icon)[2].ImageRectSize,
                    ImageRectOffset = Core.Icon(icon)[2].ImageRectPosition,
                    Size = UDim2.new(0, 21, 0, 21),
                    BackgroundTransparency = 1,
                    ThemeTag = {
                        ImageColor3 = "Icon",
                    }
                })
            end

            local textLabel = CreateInstance("TextLabel", {
                BackgroundTransparency = 1,
                TextSize = 16,
                FontFace = Font.new(Core.Font, Enum.FontWeight.Regular),
                Size = UDim2.new(1, iconLabel and -29 or 0, 1, 0),
                TextXAlignment = "Left",
                ThemeTag = {
                    TextColor3 = "Text",
                },
                Text = text,
            })

            local button = CreateInstance("TextButton", {
                Size = UDim2.new(1, 0, 0, 42),
                Parent = parent,
                BackgroundTransparency = 1,
                Text = "",
            }, {
                CreateInstance("Frame", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                }, {
                    Core.NewRoundFrame(cornerSize, "Squircle", {
                        ThemeTag = {
                            ImageColor3 = "Accent",
                        },
                        Size = UDim2.new(1, 0, 1, 0),
                        ImageTransparency = 0.85,
                    }),
                    Core.NewRoundFrame(cornerSize, "SquircleOutline", {
                        ThemeTag = {
                            ImageColor3 = "Outline",
                        },
                        Size = UDim2.new(1, 0, 1, 0),
                        ImageTransparency = 0.9,
                    }),
                    Core.NewRoundFrame(cornerSize, "Squircle", {
                        Size = UDim2.new(1, 0, 1, 0),
                        Name = "Frame",
                        ImageColor3 = Color3.new(1, 1, 1),
                        ImageTransparency = 0.95
                    }, {
                        CreateInstance("UIPadding", {
                            PaddingLeft = UDim.new(0, 12),
                            PaddingRight = UDim.new(0, 12),
                        }),
                        CreateInstance("UIListLayout", {
                            FillDirection = "Horizontal",
                            Padding = UDim.new(0, 8),
                            VerticalAlignment = "Center",
                            HorizontalAlignment = "Left",
                        }),
                        iconLabel,
                        textLabel,
                    })
                })
            })

            return button
        end

        return KeybindButtonModule
    end

    function WindUI.scrollbarModule()
        local ScrollbarModule = {}

        local UserInputService = game:GetService("UserInputService")

        local Core = WindUI.load('core')
        local CreateInstance = Core.New
        local TweenObject = Core.Tween

        function ScrollbarModule.New(scrollingFrame, parentFrame, window, scrollbarWidth)
            local scrollbar = CreateInstance("Frame", {
                Size = UDim2.new(0, scrollbarWidth, 1, 0),
                BackgroundTransparency = 1,
                Position = UDim2.new(1, 0, 0, 0),
                AnchorPoint = Vector2.new(1, 0),
                Parent = parentFrame,
                ZIndex = 999,
                Active = true,
            })

            local thumb = Core.NewRoundFrame(scrollbarWidth / 2, "Squircle", {
                Size = UDim2.new(1, 0, 0, 0),
                ImageTransparency = 0.85,
                ThemeTag = { ImageColor3 = "Text" },
                Parent = scrollbar,
            })

            local dragArea = CreateInstance("Frame", {
                Size = UDim2.new(1, 12, 1, 12),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                Active = true,
                ZIndex = 999,
                Parent = thumb,
            })

            local isDragging = false
            local dragOffset = 0

            local function updateSliderSize()
                local canvasSize = scrollingFrame.AbsoluteCanvasSize.Y
                local windowSize = scrollingFrame.AbsoluteWindowSize.Y

                if canvasSize <= windowSize then
                    thumb.Visible = false
                    return
                end

                local thumbSize = math.clamp(windowSize / canvasSize, 0.1, 1)
                thumb.Size = UDim2.new(1, 0, thumbSize, 0)
                thumb.Visible = true
            end

            local function updateScrollingFramePosition()
                local thumbPos = thumb.Position.Y.Scale
                local canvasSize = scrollingFrame.AbsoluteCanvasSize.Y
                local windowSize = scrollingFrame.AbsoluteWindowSize.Y
                local maxScroll = math.max(canvasSize - windowSize, 0)

                if maxScroll <= 0 then return end

                local availableSpace = math.max(1 - thumb.Size.Y.Scale, 0)
                if availableSpace <= 0 then return end

                local scrollPercent = thumbPos / availableSpace

                scrollingFrame.CanvasPosition = Vector2.new(
                    scrollingFrame.CanvasPosition.X,
                    scrollPercent * maxScroll
                )
            end

            local function updateThumbPosition()
                if isDragging then return end

                local scrollPos = scrollingFrame.CanvasPosition.Y
                local canvasSize = scrollingFrame.AbsoluteCanvasSize.Y
                local windowSize = scrollingFrame.AbsoluteWindowSize.Y
                local maxScroll = math.max(canvasSize - windowSize, 0)

                if maxScroll <= 0 then
                    thumb.Position = UDim2.new(0, 0, 0, 0)
                    return
                end

                local scrollPercent = scrollPos / maxScroll
                local availableSpace = math.max(1 - thumb.Size.Y.Scale, 0)
                local thumbPos = math.clamp(scrollPercent * availableSpace, 0, availableSpace)

                thumb.Position = UDim2.new(0, 0, thumbPos, 0)
            end

            Core.AddSignal(scrollbar.InputBegan, function(input)
                if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                    local thumbTop = thumb.AbsolutePosition.Y
                    local thumbBottom = thumbTop + thumb.AbsoluteSize.Y

                    if not (input.Position.Y >= thumbTop and input.Position.Y <= thumbBottom) then
                        local scrollbarTop = scrollbar.AbsolutePosition.Y
                        local scrollbarHeight = scrollbar.AbsoluteSize.Y
                        local thumbHeight = thumb.AbsoluteSize.Y

                        local clickPos = input.Position.Y - scrollbarTop - thumbHeight / 2
                        local availableSpace = scrollbarHeight - thumbHeight

                        local newPos = math.clamp(clickPos / availableSpace, 0, 1 - thumb.Size.Y.Scale)

                        thumb.Position = UDim2.new(0, 0, newPos, 0)
                        updateScrollingFramePosition()
                    end
                end
            end)

            Core.AddSignal(dragArea.InputBegan, function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isDragging = true
                    dragOffset = input.Position.Y - thumb.AbsolutePosition.Y

                    local dragConnection
                    local endConnection

                    dragConnection = UserInputService.InputChanged:Connect(function(moveInput)
                        if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
                            local scrollbarTop = scrollbar.AbsolutePosition.Y
                            local scrollbarHeight = scrollbar.AbsoluteSize.Y
                            local thumbHeight = thumb.AbsoluteSize.Y

                            local dragPos = moveInput.Position.Y - scrollbarTop - dragOffset
                            local availableSpace = scrollbarHeight - thumbHeight

                            local newPos = math.clamp(dragPos / availableSpace, 0, 1 - thumb.Size.Y.Scale)

                            thumb.Position = UDim2.new(0, 0, newPos, 0)
                            updateScrollingFramePosition()
                        end
                    end)

                    endConnection = UserInputService.InputEnded:Connect(function(endInput)
                        if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                            isDragging = false
                            if dragConnection then dragConnection:Disconnect() end
                            if endConnection then endConnection:Disconnect() end
                        end
                    end)
                end
            end)

            Core.AddSignal(scrollingFrame:GetPropertyChangedSignal("AbsoluteWindowSize"), function()
                updateSliderSize()
                updateThumbPosition()
            end)

            Core.AddSignal(scrollingFrame:GetPropertyChangedSignal("AbsoluteCanvasSize"), function()
                updateSliderSize()
                updateThumbPosition()
            end)

            Core.AddSignal(scrollingFrame:GetPropertyChangedSignal("CanvasPosition"), function()
                if not isDragging then
                    updateThumbPosition()
                end
            end)

            updateSliderSize()
            updateThumbPosition()

            return scrollbar
        end

        return ScrollbarModule
    end

    function WindUI.tagModule()
        local TagModule = {}

        local Core = WindUI.load('core')
        local CreateInstance = Core.New

        local function Color3ToHSB(color)
            local r, g, b = color.R, color.G, color.B
            local max = math.max(r, g, b)
            local min = math.min(r, g, b)
            local delta = max - min

            local hue = 0
            if delta ~= 0 then
                if max == r then
                    hue = (g - b) / delta % 6
                elseif max == g then
                    hue = (b - r) / delta + 2
                else
                    hue = (r - g) / delta + 4
                end
                hue = hue * 60
            else
                hue = 0
            end

            local saturation = (max == 0) and 0 or (delta / max)
            local brightness = max

            return {
                h = math.floor(hue + 0.5),
                s = saturation,
                b = brightness
            }
        end

        local function GetPerceivedBrightness(color)
            local r = color.R
            local g = color.G
            local b = color.B
            return 0.299 * r + 0.587 * g + 0.114 * b
        end

        local function GetTextColorForHSB(color)
            local hsb = Color3ToHSB(color)
            local h, s, b = hsb.h, hsb.s, hsb.b
            
            if GetPerceivedBrightness(color) > 0.5 then
                return Color3.fromHSV(h / 360, 0, 0.05)
            else
                return Color3.fromHSV(h / 360, 0, 0.98)
            end
        end

        function TagModule.New(_, tagData, parent)
            local tag = {
                Title = tagData.Title or "Tag",
                Color = tagData.Color or Color3.fromHex("#315dff"),
                TagFrame = nil,
                Height = 30,
                Padding = 12,
                TextSize = 16,
            }

            local textLabel = CreateInstance("TextLabel", {
                BackgroundTransparency = 1,
                AutomaticSize = "XY",
                TextSize = tag.TextSize,
                FontFace = Font.new(Core.Font, Enum.FontWeight.SemiBold),
                Text = tag.Title,
                TextColor3 = GetTextColorForHSB(tag.Color)
            })

            Core.NewRoundFrame(999, "Squircle", {
                AutomaticSize = "X",
                Size = UDim2.new(0, 0, 0, tag.Height),
                Parent = parent,
                ImageColor3 = tag.Color,
            }, {
                CreateInstance("UIPadding", {
                    PaddingLeft = UDim.new(0, tag.Padding),
                    PaddingRight = UDim.new(0, tag.Padding),
                }),
                textLabel,
                CreateInstance("UIListLayout", {
                    FillDirection = "Horizontal",
                    VerticalAlignment = "Center",
                })
            })

            return tag
        end

        return TagModule
    end

    function WindUI.configManagerModule()
        local HttpService = game:GetService("HttpService")

        local ConfigManager = {
            Window = nil,
            Folder = nil,
            Path = nil,
            Configs = {},
            Parser = {
                Colorpicker = {
                    Save = function(element)
                        return {
                            __type = element.__type,
                            value = element.Default:ToHex(),
                            transparency = element.Transparency or nil,
                        }
                    end,
                    Load = function(element, data)
                        if element then
                            element:Update(Color3.fromHex(data.value), data.transparency or nil)
                        end
                    end
                },
                Dropdown = {
                    Save = function(element)
                        return {
                            __type = element.__type,
                            value = element.Value,
                        }
                    end,
                    Load = function(element, data)
                        if element then
                            element:Select(data.value)
                        end
                    end
                },
                Input = {
                    Save = function(element)
                        return {
                            __type = element.__type,
                            value = element.Value,
                        }
                    end,
                    Load = function(element, data)
                        if element then
                            element:Set(data.value)
                        end
                    end
                },
                Keybind = {
                    Save = function(element)
                        return {
                            __type = element.__type,
                            value = element.Value,
                        }
                    end,
                    Load = function(element, data)
                        if element then
                            element:Set(data.value)
                        end
                    end
                },
                Slider = {
                    Save = function(element)
                        return {
                            __type = element.__type,
                            value = element.Value.Default,
                        }
                    end,
                    Load = function(element, data)
                        if element then
                            element:Set(data.value)
                        end
                    end
                },
                Toggle = {
                    Save = function(element)
                        return {
                            __type = element.__type,
                            value = element.Value,
                        }
                    end,
                    Load = function(element, data)
                        if element then
                            element:Set(data.value)
                        end
                    end
                },
            }
        }

        function ConfigManager.Init(_, window)
            if not window.Folder then
                warn("[ WindUI.ConfigManager ] Window.Folder is not specified."
                return false
            end

            ConfigManager.Window = window
            ConfigManager.Folder = window.Folder
            ConfigManager.Path = "WindUI/" .. tostring(ConfigManager.Folder) .. "/config/"

            local allConfigs = ConfigManager:AllConfigs()

            for _, configName in next, allConfigs do
                if isfile(configName .. ".json") then
                    ConfigManager.Configs[configName] = readfile(configName .. ".json")
                end
            end

            return ConfigManager
        end

        function ConfigManager.CreateConfig(_, configName)
            local config = {
                Path = ConfigManager.Path .. configName .. ".json",
                Elements = {},
                CustomData = {},
                Version = 1.1
            }

            if not configName then
                return false, "No config file is selected"
            end

            function config.Register(elementId, element)
                config.Elements[elementId] = element
            end

            function config.Set(key, value)
                config.CustomData[key] = value
            end

            function config.Get(key)
                return config.CustomData[key]
            end

            function config.Save()
                local saveData = {
                    __version = config.Version,
                    __elements = {},
                    __custom = config.CustomData
                }

                for elementId, element in next, config.Elements do
                    if ConfigManager.Parser[element.__type] then
                        saveData.__elements[tostring(elementId)] = ConfigManager.Parser[element.__type].Save(element)
                    end
                end

                local jsonData = HttpService:JSONEncode(saveData)
                writefile(config.Path, jsonData)
            end

            function config.Load()
                if not isfile(config.Path) then
                    return false, "Config file does not exist"
                end

                local success, loadedData = pcall(function()
                    return HttpService:JSONDecode(readfile(config.Path))
                end)

                if not success then
                    return false, "Failed to parse config file"
                end

                if not loadedData.__version then
                    local updatedData = {
                        __version = config.Version,
                        __elements = loadedData,
                        __custom = {}
                    }
                    loadedData = updatedData
                end

                for elementId, elementData in next, (loadedData.__elements or {}) do
                    if config.Elements[elementId] and ConfigManager.Parser[elementData.__type] then
                        task.spawn(function()
                            ConfigManager.Parser[elementData.__type].Load(config.Elements[elementId], elementData)
                        end)
                    end
                end

                config.CustomData = loadedData.__custom or {}

                return config.CustomData
            end

            function config.GetData()
                return {
                    elements = config.Elements,
                    custom = config.CustomData
                }
            end

            ConfigManager.Configs[configName] = config
            return config
        end

        function ConfigManager.AllConfigs()
            if not listfiles then return {} end

            local configs = {}
            if not isfolder(ConfigManager.Path) then
                makefolder(ConfigManager.Path)
                return configs
            end

            for _, filePath in next, listfiles(ConfigManager.Path) do
                local configName = filePath:match("([^\\/]+)%.json$")
                if configName then
                    table.insert(configs, configName)
                end
            end

            return configs
        end

        function ConfigManager.GetConfig(_, configName)
            return ConfigManager.Configs[configName]
        end

        return ConfigManager
    end

    function WindUI.openButtonModule()
        local OpenButtonModule = {}

        local Core = WindUI.load('core')
        local CreateInstance = Core.New
        local TweenObject = Core.Tween

        local UserInputService = game:GetService("UserInputService")

        function OpenButtonModule.New(buttonData)
            local button = {
                Button = nil
            }

            local textLabel = CreateInstance("TextLabel", {
                Text = buttonData.Title,
                TextSize = 17,
                FontFace = Font.new(Core.Font, Enum.FontWeight.Medium),
                BackgroundTransparency = 1,
                AutomaticSize = "XY",
            })

            local dragIcon = CreateInstance("Frame", {
                Size = UDim2.new(0, 36, 0, 36),
                BackgroundTransparency = 1,
                Name = "Drag",
            }, {
                CreateInstance("ImageLabel", {
                    Image = Core.Icon("move")[1],
                    ImageRectOffset = Core.Icon("move")[2].ImageRectPosition,
                    ImageRectSize = Core.Icon("move")[2].ImageRectSize,
                    Size = UDim2.new(0, 18, 0, 18),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                })
            })
            
            local separator = CreateInstance("Frame", {
                Size = UDim2.new(0, 1, 1, 0),
                Position = UDim2.new(0, 36, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = Color3.new(1, 1, 1),
                BackgroundTransparency = 0.9,
            })

            local container = CreateInstance("Frame", {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0, 28),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Parent = buttonData.Parent,
                BackgroundTransparency = 1,
                Active = true,
                Visible = false,
            })
            
            local buttonFrame = CreateInstance("TextButton", {
                Size = UDim2.new(0, 0, 0, 44),
                AutomaticSize = "X",
                Parent = container,
                Active = false,
                BackgroundTransparency = 0.25,
                ZIndex = 99,
                BackgroundColor3 = Color3.new(0, 0, 0),
            }, {
                CreateInstance("UICorner", {
                    CornerRadius = UDim.new(1, 0)
                }),
                CreateInstance("UIStroke", {
                    Thickness = 1,
                    ApplyStrokeMode = "Border",
                    Color = Color3.new(1, 1, 1),
                    Transparency = 0,
                }, {
                    CreateInstance("UIGradient", {
                        Color = ColorSequence.new(Color3.fromHex("40c9ff"), Color3.fromHex("e81cff"))
                    })
                }),
                dragIcon,
                separator,
                CreateInstance("UIListLayout", {
                    Padding = UDim.new(0, 4),
                    FillDirection = "Horizontal",
                    VerticalAlignment = "Center",
                }),
                CreateInstance("TextButton", {
                    AutomaticSize = "XY",
                    Active = true,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 0, 0, 36),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                }, {
                    CreateInstance("UICorner", {
                        CornerRadius = UDim.new(1, -4)
                    }),
                    CreateInstance("UIListLayout", {
                        Padding = UDim.new(0, buttonData.UIPadding),
                        FillDirection = "Horizontal",
                        VerticalAlignment = "Center",
                    }),
                    textLabel,
                    CreateInstance("UIPadding", {
                        PaddingLeft = UDim.new(0, 12),
                        PaddingRight = UDim.new(0, 12),
                    }),
                }),
                CreateInstance("UIPadding", {
                    PaddingLeft = UDim.new(0, 4),
                    PaddingRight = UDim.new(0, 4),
                })
            })

            button.Button = buttonFrame

            function button.SetIcon(_, iconName)
                if currentIcon then
                    currentIcon:Destroy()
                end
                if iconName then
                    currentIcon = Core.Image(
                        iconName,
                        buttonData.Title,
                        0,
                        buttonData.Folder,
                        "OpenButton",
                        true,
                        buttonData.IconThemed
                    )
                    currentIcon.Size = UDim2.new(0, 22, 0, 22)
                    currentIcon.LayoutOrder = -1
                    currentIcon.Parent = button.Button.TextButton
                end
            end

            if buttonData.Icon then
                button:SetIcon(buttonData.Icon)
            end

            Core.AddSignal(buttonFrame:GetPropertyChangedSignal("AbsoluteSize"), function()
                container.Size = UDim2.new(
                    0, buttonFrame.AbsoluteSize.X,
                    0, buttonFrame.AbsoluteSize.Y
                )
            end)

            Core.AddSignal(buttonFrame.TextButton.MouseEnter, function()
                TweenObject(buttonFrame.TextButton, 0.1, { BackgroundTransparency = 0.93 }):Play()
            end)
            
            Core.AddSignal(buttonFrame.TextButton.MouseLeave, function()
                TweenObject(buttonFrame.TextButton, 0.1, { BackgroundTransparency = 1 }):Play()
            end)

            local dragController = Core.Drag(container)

            function button.Visible(_, state)
                container.Visible = state
            end

            function button.Edit(_, settings)
                local editSettings = {
                    Title = settings.Title,
                    Icon = settings.Icon,
                    Enabled = settings.Enabled,
                    Position = settings.Position,
                    Draggable = settings.Draggable,
                    OnlyMobile = settings.OnlyMobile,
                    CornerRadius = settings.CornerRadius or UDim.new(1, 0),
                    StrokeThickness = settings.StrokeThickness or 2,
                    Color = settings.Color or ColorSequence.new(Color3.fromHex("40c9ff"), Color3.fromHex("e81cff")),
                }

                if editSettings.Enabled == false then
                    buttonData.IsOpenButtonEnabled = false
                end
                
                if editSettings.Draggable == false and dragIcon and separator then
                    dragIcon.Visible = editSettings.Draggable
                    separator.Visible = editSettings.Draggable

                    if dragController then
                        dragController:Set(editSettings.Draggable)
                    end
                end
                
                if editSettings.Position and OpenButtonContainer then
                    OpenButtonContainer.Position = editSettings.Position
                end

                local hasKeyboard = UserInputService.KeyboardEnabled or not UserInputService.TouchEnabled
                button.Visible = not editSettings.OnlyMobile or not hasKeyboard

                if not button.Visible then return end

                if textLabel then
                    if editSettings.Title then
                        textLabel.Text = editSettings.Title
                        Core.ChangeTranslationKey(textLabel, editSettings.Title)
                    end
                end

                if editSettings.Icon then
                    button:SetIcon(editSettings.Icon)
                end

                buttonFrame.UIStroke.UIGradient.Color = editSettings.Color
                buttonFrame.UICorner.CornerRadius = editSettings.CornerRadius
                buttonFrame.TextButton.UICorner.CornerRadius = UDim.new(editSettings.CornerRadius.Scale, editSettings.CornerRadius.Offset - 4)
                buttonFrame.UIStroke.Thickness = editSettings.StrokeThickness
            end

            return button
        end

        return OpenButtonModule
    end

    function WindUI.tooltipModule()
        local TooltipModule = {}

        local Core = WindUI.load('core')
        local CreateInstance = Core.New
        local TweenObject = Core.Tween

        function TooltipModule.New(text, parent)
            local tooltip = {
                Container = nil,
                ToolTipSize = 16,
            }

            local textLabel = CreateInstance("TextLabel", {
                AutomaticSize = "XY",
                TextWrapped = true,
                BackgroundTransparency = 1,
                FontFace = Font.new(Core.Font, Enum.FontWeight.Medium),
                Text = text,
                TextSize = 17,
                ThemeTag = {
                    TextColor3 = "Text",
                }
            })

            local uiScale = CreateInstance("UIScale", {
                Scale = 0.9
            })

            local canvasGroup = CreateInstance("CanvasGroup", {
                AnchorPoint = Vector2.new(0.5, 0),
                AutomaticSize = "XY",
                BackgroundTransparency = 1,
                Parent = parent,
                GroupTransparency = 1,
                Visible = false
            }, {
                CreateInstance("UISizeConstraint", {
                    MaxSize = Vector2.new(400, math.huge)
                }),
                CreateInstance("Frame", {
                    AutomaticSize = "XY",
                    BackgroundTransparency = 1,
                    LayoutOrder = 99,
                    Visible = false
                }, {
                    CreateInstance("ImageLabel", {
                        Size = UDim2.new(0, tooltip.ToolTipSize, 0, tooltip.ToolTipSize / 2),
                        BackgroundTransparency = 1,
                        Rotation = 180,
                        Image = "rbxassetid://89524607682719",
                        ThemeTag = {
                            ImageColor3 = "Accent",
                        },
                    }, {
                        CreateInstance("ImageLabel", {
                            Size = UDim2.new(0, tooltip.ToolTipSize, 0, tooltip.ToolTipSize / 2),
                            BackgroundTransparency = 1,
                            LayoutOrder = 99,
                            ImageTransparency = 0.9,
                            Image = "rbxassetid://89524607682719",
                            ThemeTag = {
                                ImageColor3 = "Text",
                            },
                        }),
                    }),
                }),
                CreateInstance("Frame", {
                    AutomaticSize = "XY",
                    ThemeTag = {
                        BackgroundColor3 = "Accent",
                    },
                }, {
                    CreateInstance("UICorner", {
                        CornerRadius = UDim.new(0, 16),
                    }),
                    CreateInstance("Frame", {
                        ThemeTag = {
                            BackgroundColor3 = "Text",
                        },
                        AutomaticSize = "XY",
                        BackgroundTransparency = 0.9,
                    }, {
                        CreateInstance("UICorner", {
                            CornerRadius = UDim.new(0, 16),
                        }),
                        CreateInstance("UIListLayout", {
                            Padding = UDim.new(0, 12),
                            FillDirection = "Horizontal",
                            VerticalAlignment = "Center"
                        }),
                        textLabel,
                        CreateInstance("UIPadding", {
                            PaddingTop = UDim.new(0, 12),
                            PaddingLeft = UDim.new(0, 12),
                            PaddingRight = UDim.new(0, 12),
                            PaddingBottom = UDim.new(0, 12),
                        }),
                    })
                }),
                uiScale,
                CreateInstance("UIListLayout", {
                    Padding = UDim.new(0, 0),
                    FillDirection = "Vertical",
                    VerticalAlignment = "Center",
                    HorizontalAlignment = "Center",
                }),
            })
            
            tooltip.Container = canvasGroup

            function tooltip.Open()
                canvasGroup.Visible = true

                TweenObject(canvasGroup, 0.16, { GroupTransparency = 0 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
                TweenObject(uiScale, 0.18, { Scale = 1 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
            end

            function tooltip.Close()
                TweenObject(canvasGroup, 0.2, { GroupTransparency = 1 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
                TweenObject(uiScale, 0.2, { Scale = 0.9 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()

                task.wait(0.25)

                canvasGroup.Visible = false
                canvasGroup:Destroy()
            end

            return tooltip
        end

        return TooltipModule
    end

    function WindUI.sectionFrameCreator()
        local Core = WindUI.load('core')
        local CreateInstance = Core.New
        local CreateRoundFrame = Core.NewRoundFrame
        local TweenObject = Core.Tween

        local UserInputService = game:GetService("UserInputService")

        return function(sectionData)
            local section = {
                Title = sectionData.Title,
                Desc = sectionData.Desc or nil,
                Hover = sectionData.Hover,
                Thumbnail = sectionData.Thumbnail,
                ThumbnailSize = sectionData.ThumbnailSize or 80,
                Image = sectionData.Image,
                IconThemed = sectionData.IconThemed or false,
                ImageSize = sectionData.ImageSize or 30,
                Color = sectionData.Color,
                Scalable = sectionData.Scalable,
                Parent = sectionData.Parent,
                UIPadding = 14,
                UICorner = 14,
                UIElements = {}
            }

            local imageSize = section.ImageSize
            local thumbSize = section.ThumbnailSize
            local isInteractive = true

            local imageOffset = 0

            local thumbnailImage
            local iconImage
            
            if section.Thumbnail then
                thumbnailImage = Core.Image(
                    section.Thumbnail,
                    section.Title,
                    section.UICorner - 3,
                    sectionData.Window.Folder,
                    "Thumbnail",
                    false,
                    section.IconThemed
                )
                thumbnailImage.Size = UDim2.new(1, 0, 0, thumbSize)
            end
            
            if section.Image then
                iconImage = Core.Image(
                    section.Image,
                    section.Title,
                    section.UICorner - 3,
                    sectionData.Window.Folder,
                    "Image",
                    section.Color and true or false
                )
                
                if section.Color == "White" then
                    iconImage.ImageLabel.ImageColor3 = Color3.new(0, 0, 0)
                elseif section.Color then
                    iconImage.ImageLabel.ImageColor3 = Color3.new(1, 1, 1)
                end
                
                iconImage.Size = UDim2.new(0, imageSize, 0, imageSize)
                imageOffset = imageSize
            end

            local function CreateText(text, textType)
                return CreateInstance("TextLabel", {
                    BackgroundTransparency = 1,
                    Text = text or "",
                    TextSize = textType == "Desc" and 15 or 17,
                    TextXAlignment = "Left",
                    ThemeTag = {
                        TextColor3 = not section.Color and (textType == "Desc" and "Icon" or "Text") or nil,
                    },
                    TextColor3 = section.Color and (section.Color == "White" and Color3.new(0, 0, 0) or section.Color ~= "White" and Color3.new(1, 1, 1)) or nil,
                    TextTransparency = section.Color and (textType == "Desc" and 0.3 or 0),
                    TextWrapped = true,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = "Y",
                    FontFace = Font.new(Core.Font, Enum.FontWeight.Medium)
                })
            end

            local titleLabel = CreateText(section.Title, "Title")
            local descLabel = CreateText(section.Desc, "Desc")
            
            if not section.Desc or section.Desc == "" then
                descLabel.Visible = false
            end

            section.UIElements.Container = CreateInstance("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = "Y",
                BackgroundTransparency = 1,
            }, {
                CreateInstance("UIListLayout", {
                    Padding = UDim.new(0, section.UIPadding),
                    FillDirection = "Vertical",
                    VerticalAlignment = "Top",
                    HorizontalAlignment = "Left",
                }),
                thumbnailImage,
                CreateInstance("Frame", {
                    Size = UDim2.new(1, -sectionData.TextOffset, 0, 0),
                    AutomaticSize = "Y",
                    BackgroundTransparency = 1,
                }, {
                    CreateInstance("UIListLayout", {
                        Padding = UDim.new(0, section.UIPadding),
                        FillDirection = "Horizontal",
                        VerticalAlignment = "Top",
                        HorizontalAlignment = "Left",
                    }),
                    iconImage,
                    CreateInstance("Frame", {
                        BackgroundTransparency = 1,
                        AutomaticSize = "Y",
                        Size = UDim2.new(1, -imageOffset, 0, (50 - (section.UIPadding * 2)))
                    }, {
                        CreateInstance("UIListLayout", {
                            Padding = UDim.new(0, 4),
                            FillDirection = "Vertical",
                            VerticalAlignment = "Center",
                            HorizontalAlignment = "Left",
                        }),
                        titleLabel,
                        descLabel
                    }),
                })
            })

            section.UIElements.Locked = CreateRoundFrame(section.UICorner, "Squircle", {
                Size = UDim2.new(1, section.UIPadding * 2, 1, section.UIPadding * 2),
                ImageTransparency = 0.4,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                ImageColor3 = Color3.new(0, 0, 0),
                Visible = false,
                Active = false,
                ZIndex = 9999999,
            })

            section.UIElements.Main = CreateRoundFrame(section.UICorner, "Squircle", {
                Size = UDim2.new(1, 0, 0, 50),
                AutomaticSize = "Y",
                ImageTransparency = section.Color and 0.1 or 0.95,
                Parent = sectionData.Parent,
                ThemeTag = {
                    ImageColor3 = not section.Color and "Text" or nil
                },
                ImageColor3 = section.Color and Color3.fromHex(Core.Colors[section.Color]) or nil
            }, {
                section.UIElements.Container,
                section.UIElements.Locked,
                CreateInstance("UIPadding", {
                    PaddingTop = UDim.new(0, section.UIPadding),
                    PaddingLeft = UDim.new(0, section.UIPadding),
                    PaddingRight = UDim.new(0, section.UIPadding),
                    PaddingBottom = UDim.new(0, section.UIPadding),
                }),
            }, true)

            if section.Hover then
                Core.AddSignal(section.UIElements.Main.MouseEnter, function()
                    if isInteractive then
                        TweenObject(section.UIElements.Main, 0.05, { ImageTransparency = section.Color and 0.15 or 0.9 }):Play()
                    end
                end)
                
                Core.AddSignal(section.UIElements.Main.InputEnded, function()
                    if isInteractive then
                        TweenObject(section.UIElements.Main, 0.05, { ImageTransparency = section.Color and 0.1 or 0.95 }):Play()
                    end
                end)
            end

            function section.SetTitle(_, newTitle)
                titleLabel.Text = newTitle
            end

            function section.SetDesc(_, newDesc)
                descLabel.Text = newDesc or ""
                if not newDesc then
                    descLabel.Visible = false
                elseif not descLabel.Visible then
                    descLabel.Visible = true
                end
            end

            function section.Destroy()
                section.UIElements.Main:Destroy()
            end

            function section.Lock()
                isInteractive = false
                section.UIElements.Locked.Active = true
                section.UIElements.Locked.Visible = true
            end

            function section.Unlock()
                isInteractive = true
                section.UIElements.Locked.Active = false
                section.UIElements.Locked.Visible = false
            end

            return section
        end
    end

    function WindUI.buttonSectionModule()
        local ButtonSectionModule = {}

        local Core = WindUI.load('core')
        local CreateInstance = Core.New

        function ButtonSectionModule.New(_, buttonData)
            local button = {
                __type = "Button",
                Title = buttonData.Title or "Button",
                Desc = buttonData.Desc or nil,
                Locked = buttonData.Locked or false,
                Callback = buttonData.Callback or function() end,
                UIElements = {}
            }

            local isInteractive = true

            button.ButtonFrame = WindUI.load('sectionFrameCreator')({
                Title = button.Title,
                Desc = button.Desc,
                Parent = buttonData.Parent,
                Window = buttonData.Window,
                TextOffset = 20,
                Hover = true,
                Scalable = true,
            })

            button.UIElements.ButtonIcon = CreateInstance("ImageLabel", {
                Image = Core.Icon("mouse-pointer-click")[1],
                ImageRectOffset = Core.Icon("mouse-pointer-click")[2].ImageRectPosition,
                ImageRectSize = Core.Icon("mouse-pointer-click")[2].ImageRectSize,
                BackgroundTransparency = 1,
                Parent = button.ButtonFrame.UIElements.Main,
                Size = UDim2.new(0, 20, 0, 20),
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, 0, 0.5, 0),
                ThemeTag = {
                    ImageColor3 = "Text"
                }
            })

            function button.Lock()
                isInteractive = false
                return button.ButtonFrame:Lock()
            end
            
            function button.Unlock()
                isInteractive = true
                return button.ButtonFrame:Unlock()
            end

            if button.Locked then
                button:Lock()
            end

            Core.AddSignal(button.ButtonFrame.UIElements.Main.MouseButton1Click, function()
                if isInteractive then
                    task.spawn(function()
                        Core.SafeCallback(button.Callback)
                    end)
                end
            end)
            
            return button.__type, button
        end

        return ButtonSectionModule
    end

    function WindUI.toggleSwitchModule()
        local ToggleSwitchModule = {}

        local Core = WindUI.load('core')
        local CreateInstance = Core.New
        local TweenObject = Core.Tween

        function ToggleSwitchModule.New(initialState, icon, parent, callback)
            local toggleData = {}

            local cornerSize = 13
            local iconImage
            
            if icon and icon ~= "" then
                iconImage = CreateInstance("ImageLabel", {
                    Size = UDim2.new(1, -7, 1, -7),
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    Image = Core.Icon(icon)[1],
                    ImageRectOffset = Core.Icon(icon)[2].ImageRectPosition,
                    ImageRectSize = Core.Icon(icon)[2].ImageRectSize,
                    ImageTransparency = 1,
                    ImageColor3 = Color3.new(0, 0, 0),
                })
            end

            local toggleFrame = Core.NewRoundFrame(cornerSize, "Squircle", {
                ImageTransparency = 0.95,
                ThemeTag = {
                    ImageColor3 = "Text"
                },
                Parent = parent,
                Size = UDim2.new(0, 42, 0, 26),
            }, {
                Core.NewRoundFrame(cornerSize, "Squircle", {
                    Size = UDim2.new(1, 0, 1, 0),
                    Name = "Layer",
                    ThemeTag = {
                        ImageColor3 = "Button",
                    },
                    ImageTransparency = 1,
                }),
                Core.NewRoundFrame(cornerSize, "SquircleOutline", {
                    Size = UDim2.new(1, 0, 1, 0),
                    Name = "Stroke",
                    ImageColor3 = Color3.new(1, 1, 1),
                    ImageTransparency = 1,
                }, {
                    CreateInstance("UIGradient", {
                        Rotation = 90,
                        Transparency = NumberSequence.new{
                            NumberSequenceKeypoint.new(0, 0),
                            NumberSequenceKeypoint.new(1, 1),
                        }
                    })
                }),
                Core.NewRoundFrame(cornerSize, "Squircle", {
                    Size = UDim2.new(0, 18, 0, 18),
                    Position = UDim2.new(0, 3, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    ImageTransparency = 0,
                    ImageColor3 = Color3.new(1, 1, 1),
                    Name = "Frame",
                }, {
                    iconImage,
                })
            })

            function toggleData.Set(_, state)
                if state then
                    TweenObject(toggleFrame.Frame, 0.1, {
                        Position = UDim2.new(1, -22, 0.5, 0),
                    }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
                    
                    TweenObject(toggleFrame.Layer, 0.1, {
                        ImageTransparency = 0,
                    }):Play()
                    
                    TweenObject(toggleFrame.Stroke, 0.1, {
                        ImageTransparency = 0.95,
                    }):Play()

                    if iconImage then
                        TweenObject(iconImage, 0.1, {
                            ImageTransparency = 0,
                        }):Play()
                    end
                else
                    TweenObject(toggleFrame.Frame, 0.1, {
                        Position = UDim2.new(0, 4, 0.5, 0),
                        Size = UDim2.new(0, 18, 0, 18),
                    }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
                    
                    TweenObject(toggleFrame.Layer, 0.1, {
                        ImageTransparency = 1,
                    }):Play()
                    
                    TweenObject(toggleFrame.Stroke, 0.1, {
                        ImageTransparency = 1,
                    }):Play()

                    if iconImage then
                        TweenObject(iconImage, 0.1, {
                            ImageTransparency = 1,
                        }):Play()
                    end
                end

                task.spawn(function()
                    if callback then
                        Core.SafeCallback(callback, state)
                    end
                end)
            end

            return toggleFrame, toggleData
        end

        return ToggleSwitchModule
    end

    function WindUI.checkboxModule()
        local CheckboxModule = {}

        local Core = WindUI.load('core')
        local CreateInstance = Core.New
        local TweenObject = Core.Tween

        function CheckboxModule.New(initialState, icon, parent, callback)
            local checkboxData = {}

            icon = icon or "check"

            local cornerSize = 10
            local iconImage = CreateInstance("ImageLabel", {
                Size = UDim2.new(1, -10, 1, -10),
                BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Image = Core.Icon(icon)[1],
                ImageRectOffset = Core.Icon(icon)[2].ImageRectPosition,
                ImageRectSize = Core.Icon(icon)[2].ImageRectSize,
                ImageTransparency = 1,
                ImageColor3 = Color3.new(1, 1, 1),
            })

            local checkboxFrame = Core.NewRoundFrame(cornerSize, "Squircle", {
                ImageTransparency = 0.95,
                ThemeTag = {
                    ImageColor3 = "Text"
                },
                Parent = parent,
                Size = UDim2.new(0, 27, 0, 27),
            }, {
                Core.NewRoundFrame(cornerSize, "Squircle", {
                    Size = UDim2.new(1, 0, 1, 0),
                    Name = "Layer",
                    ThemeTag = {
                        ImageColor3 = "Button",
                    },
                    ImageTransparency = 1,
                }),
                Core.NewRoundFrame(cornerSize, "SquircleOutline", {
                    Size = UDim2.new(1, 0, 1, 0),
                    Name = "Stroke",
                    ImageColor3 = Color3.new(1, 1, 1),
                    ImageTransparency = 1,
                }, {
                    CreateInstance("UIGradient", {
                        Rotation = 90,
                        Transparency = NumberSequence.new{
                            NumberSequenceKeypoint.new(0, 0),
                            NumberSequenceKeypoint.new(1, 1),
                        }
                    })
                }),
                iconImage,
            })

            function checkboxData.Set(_, state)
                if state then
                    TweenObject(checkboxFrame.Layer, 0.06, {
                        ImageTransparency = 0,
                    }):Play()
                    
                    TweenObject(checkboxFrame.Stroke, 0.06, {
                        ImageTransparency = 0.95,
                    }):Play()
                    
                    TweenObject(iconImage, 0.06, {
                        ImageTransparency = 0,
                    }):Play()
                else
                    TweenObject(checkboxFrame.Layer, 0.05, {
                        ImageTransparency = 1,
                    }):Play()
                    
                    TweenObject(checkboxFrame.Stroke, 0.05, {
                        ImageTransparency = 1,
                    }):Play()
                    
                    TweenObject(iconImage, 0.06, {
                        ImageTransparency = 1,
                    }):Play()
                end

                task.spawn(function()
                    if callback then
                        Core.SafeCallback(callback, state)
                    end
                end)
            end

            return checkboxFrame, checkboxData
        end

        return CheckboxModule
    end

    function WindUI.toggleSectionModule()
        local ToggleSectionModule = WindUI.load('core')
        local CreateInstance = ToggleSectionModule.New
        local TweenObject = ToggleSectionModule.Tween

        local CreateToggleSwitch = WindUI.load('toggleSwitchModule').New
        local CreateCheckbox = WindUI.load('checkboxModule').New

        local ToggleModule = {}

        function ToggleModule.New(_, toggleData)
            local toggle = {
                __type = "Toggle",
                Title = toggleData.Title or "Toggle",
                Desc = toggleData.Desc or nil,
                Value = toggleData.Value,
                Icon = toggleData.Icon or nil,
                Type = toggleData.Type or "Toggle",
                Callback = toggleData.Callback or function() end,
                UIElements = {}
            }
            
            toggle.ToggleFrame = WindUI.load('sectionFrameCreator')({
                Title = toggle.Title,
                Desc = toggle.Desc,
                Window = toggleData.Window,
                Parent = toggleData.Parent,
                TextOffset = 44,
                Hover = false,
            })

            local isInteractive = true

            if toggle.Value == nil then
                toggle.Value = false
            end

            function toggle.Lock()
                isInteractive = false
                return toggle.ToggleFrame:Lock()
            end
            
            function toggle.Unlock()
                isInteractive = true
                return toggle.ToggleFrame:Unlock()
            end

            if toggle.Locked then
                toggle:Lock()
            end

            local currentValue = toggle.Value
            local toggleElement, toggleController

            if toggle.Type == "Toggle" then
                toggleElement, toggleController = CreateToggleSwitch(currentValue, toggle.Icon, toggle.ToggleFrame.UIElements.Main, toggle.Callback)
            elseif toggle.Type == "Checkbox" then
                toggleElement, toggleController = CreateCheckbox(currentValue, toggle.Icon, toggle.ToggleFrame.UIElements.Main, toggle.Callback)
            else
                error("Unknown Toggle Type: " .. tostring(toggle.Type))
            end

            toggleElement.AnchorPoint = Vector2.new(1, 0.5)
            toggleElement.Position = UDim2.new(1, 0, 0.5, 0)

            function toggle.Set(_, newState)
                if isInteractive then
                    toggleController:Set(newState)
                    currentValue = newState
                    toggle.Value = newState
                end
            end

            toggle:Set(currentValue)

            ToggleSectionModule.AddSignal(toggle.ToggleFrame.UIElements.Main.MouseButton1Click, function()
                toggle:Set(not currentValue)
            end)

            return toggle.__type, toggle
        end

        return ToggleModule
    end

    function WindUI.sliderModule()
        local SliderModule = {}

        local Core = WindUI.load('core')
        local CreateInstance = Core.New
        local TweenObject = Core.Tween

        local GlobalState = false

        function SliderModule.New(_, sliderData)
            local slider = {
                __type = "Slider",
                Title = sliderData.Title or "Slider",
                Desc = sliderData.Desc or nil,
                Locked = sliderData.Locked or nil,
                Value = sliderData.Value or {},
                Step = sliderData.Step or 1,
                Callback = sliderData.Callback or function() end,
                UIElements = {},
                IsFocusing = false,
            }
            
            local sliderBar
            local dragConnection
            local endConnection
            local currentValue = slider.Value.Default or slider.Value.Min or 0

            local lastValue = currentValue
            local valuePercent = (currentValue - (slider.Value.Min or 0)) / ((slider.Value.Max or 100) - (slider.Value.Min or 0))

            local isInteractive = true
            local hasDecimal = slider.Step % 1 ~= 0

            local function FormatValue(val)
                if hasDecimal then
                    return string.format("%.2f", val)
                else
                    return tostring(math.floor(val + 0.5))
                end
            end

            local function CalculateValue(val)
                if hasDecimal then
                    return math.floor(val / slider.Step + 0.5) * slider.Step
                else
                    return math.floor(val / slider.Step + 0.5) * slider.Step
                end
            end

            slider.SliderFrame = WindUI.load('sectionFrameCreator')({
                Title = slider.Title,
                Desc = slider.Desc,
                Parent = sliderData.Parent,
                TextOffset = 0,
                Hover = false,
            })

            slider.UIElements.SliderIcon = Core.NewRoundFrame(99, "Squircle", {
                ImageTransparency = 0.95,
                Size = UDim2.new(1, -68, 0, 4),
                Name = "Frame",
                ThemeTag = {
                    ImageColor3 = "Text",
                },
            }, {
                Core.NewRoundFrame(99, "Squircle", {
                    Name = "Frame",
                    Size = UDim2.new(valuePercent, 0, 1, 0),
                    ImageTransparency = 0.1,
                    ThemeTag = {
                        ImageColor3 = "Button",
                    },
                }, {
                    Core.NewRoundFrame(99, "Squircle", {
                        Size = UDim2.new(0, 13, 0, 13),
                        Position = UDim2.new(1, 0, 0.5, 0),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        ThemeTag = {
                            ImageColor3 = "Text",
                        },
                    })
                })
            })

            slider.UIElements.SliderContainer = CreateInstance("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = "Y",
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1,
                Parent = slider.SliderFrame.UIElements.Container,
            }, {
                CreateInstance("UIListLayout", {
                    Padding = UDim.new(0, 8),
                    FillDirection = "Horizontal",
                    VerticalAlignment = "Center",
                }),
                slider.UIElements.SliderIcon,
                CreateInstance("TextBox", {
                    Size = UDim2.new(0, 60, 0, 0),
                    TextXAlignment = "Left",
                    Text = FormatValue(currentValue),
                    ThemeTag = {
                        TextColor3 = "Text"
                    },
                    TextTransparency = 0.4,
                    AutomaticSize = "Y",
                    TextSize = 15,
                    FontFace = Font.new(Core.Font, Enum.FontWeight.Medium),
                    BackgroundTransparency = 1,
                    LayoutOrder = -1,
                })
            })

            function slider.Lock()
                isInteractive = false
                return slider.SliderFrame:Lock()
            end
            
            function slider.Unlock()
                isInteractive = true
                return slider.SliderFrame:Unlock()
            end

            if slider.Locked then
                slider:Lock()
            end

            function slider.Set(_, newValue, input)
                if isInteractive then
                    if not slider.IsFocusing and not GlobalState and (not input or (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch)) then
                        newValue = math.clamp(newValue, slider.Value.Min or 0, slider.Value.Max or 100)

                        local percent = math.clamp((newValue - (slider.Value.Min or 0)) / ((slider.Value.Max or 100) - (slider.Value.Min or 0)), 0, 1)
                        newValue = CalculateValue(slider.Value.Min + percent * (slider.Value.Max - slider.Value.Min))

                        if newValue ~= lastValue then
                            TweenObject(slider.UIElements.SliderIcon.Frame, 0.08, { Size = UDim2.new(percent, 0, 1, 0) }):Play()
                            slider.UIElements.SliderContainer.TextBox.Text = FormatValue(newValue)
                            slider.Value.Default = FormatValue(newValue)
                            lastValue = newValue
                            Core.SafeCallback(slider.Callback, FormatValue(newValue))
                        end

                        if input then
                            local isTouch = (input.UserInputType == Enum.UserInputType.Touch)
                            slider.SliderFrame.Parent.ScrollingEnabled = false
                            GlobalState = true
                            
                            dragConnection = game:GetService("RunService").RenderStepped:Connect(function()
                                local mousePos = isTouch and input.Position.X or game:GetService("UserInputService"):GetMouseLocation().X
                                local percent = math.clamp((mousePos - slider.UIElements.SliderIcon.AbsolutePosition.X) / slider.UIElements.SliderIcon.AbsoluteSize.X, 0, 1)
                                newValue = CalculateValue(slider.Value.Min + percent * (slider.Value.Max - slider.Value.Min))

                                if newValue ~= lastValue then
                                    TweenObject(slider.UIElements.SliderIcon.Frame, 0.08, { Size = UDim2.new(percent, 0, 1, 0) }):Play()
                                    slider.UIElements.SliderContainer.TextBox.Text = FormatValue(newValue)
                                    slider.Value.Default = FormatValue(newValue)
                                    lastValue = newValue
                                    Core.SafeCallback(slider.Callback, FormatValue(newValue))
                                end
                            end)
                            
                            endConnection = game:GetService("UserInputService").InputEnded:Connect(function(endInput)
                                if (endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch) and input == endInput then
                                    dragConnection:Disconnect()
                                    endConnection:Disconnect()
                                    GlobalState = false
                                    slider.SliderFrame.Parent.ScrollingEnabled = true
                                end
                            end)
                        end
                    end
                end
            end

            Core.AddSignal(slider.UIElements.SliderContainer.TextBox.FocusLost, function(enterPressed)
                if enterPressed then
                    local inputValue = tonumber(slider.UIElements.SliderContainer.TextBox.Text)
                    if inputValue then
                        slider:Set(inputValue)
                    else
                        slider.UIElements.SliderContainer.TextBox.Text = FormatValue(lastValue)
                    end
                end
            end)

            Core.AddSignal(slider.UIElements.SliderContainer.InputBegan, function(input)
                slider:Set(currentValue, input)
            end)

            return slider.__type, slider
        end

        return SliderModule
    end

    function WindUI.keybindModule()
        local UserInputService = game:GetService("UserInputService")

        local Core = WindUI.load('core')
        local CreateInstance = Core.New
        local TweenObject = Core.Tween

        local Defaults = {
            UICorner = 6,
            UIPadding = 8,
        }

        local KeybindButtonCreator = WindUI.load('keybindButtonModule').New

        function Defaults.New(_, keybindData)
            local keybind = {
                __type = "Keybind",
                Title = keybindData.Title or "Keybind",
                Desc = keybindData.Desc or nil,
                Locked = keybindData.Locked or false,
                Value = keybindData.Value or "F",
                Callback = keybindData.Callback or function() end,
                CanChange = keybindData.CanChange or true,
                Picking = false,
                UIElements = {},
            }

            local isInteractive = true

            keybind.KeybindFrame = WindUI.load('sectionFrameCreator')({
                Title = keybind.Title,
                Desc = keybind.Desc,
                Parent = keybindData.Parent,
                TextOffset = 85,
                Hover = keybind.CanChange,
            })

            keybind.UIElements.Keybind = KeybindButtonCreator(keybind.Value, nil, keybind.KeybindFrame.UIElements.Main)

            keybind.UIElements.Keybind.Size = UDim2.new(
                0, 24 + keybind.UIElements.Keybind.Frame.Frame.TextLabel.TextBounds.X,
                0, 42
            )
            keybind.UIElements.Keybind.AnchorPoint = Vector2.new(1, 0.5)
            keybind.UIElements.Keybind.Position = UDim2.new(1, 0, 0.5, 0)

            TweenObject("UIScale", {
                Parent = keybind.UIElements.Keybind,
                Scale = 0.85,
            })

            Core.AddSignal(keybind.UIElements.Keybind.Frame.Frame.TextLabel:GetPropertyChangedSignal("TextBounds"), function()
                keybind.UIElements.Keybind.Size = UDim2.new(
                    0, 24 + keybind.UIElements.Keybind.Frame.Frame.TextLabel.TextBounds.X,
                    0, 42
                )
            end)

            function keybind.Lock()
                isInteractive = false
                return keybind.KeybindFrame:Lock()
            end
            
            function keybind.Unlock()
                isInteractive = true
                return keybind.KeybindFrame:Unlock()
            end

            function keybind.Set(_, newValue)
                keybind.Value = newValue
                keybind.UIElements.Keybind.Frame.Frame.TextLabel.Text = newValue
            end

            if keybind.Locked then
                keybind:Lock()
            end

            Core.AddSignal(keybind.KeybindFrame.UIElements.Main.MouseButton1Click, function()
                if isInteractive then
                    if keybind.CanChange then
                        keybind.Picking = true
                        keybind.UIElements.Keybind.Frame.Frame.TextLabel.Text = "..."

                        task.wait(0.2)

                        local inputConnection
                        inputConnection = UserInputService.InputBegan:Connect(function(input)
                            local keyName

                            if input.UserInputType == Enum.UserInputType.Keyboard then
                                keyName = input.KeyCode.Name
                            elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                                keyName = "MouseLeft"
                            elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                                keyName = "MouseRight"
                            end

                            local releaseConnection
                            releaseConnection = UserInputService.InputEnded:Connect(function(endInput)
                                if endInput.KeyCode.Name == keyName or 
                                   (keyName == "MouseLeft" and endInput.UserInputType == Enum.UserInputType.MouseButton1) or 
                                   (keyName == "MouseRight" and endInput.UserInputType == Enum.UserInputType.MouseButton2) then
                                    keybind.Picking = false

                                    keybind.UIElements.Keybind.Frame.Frame.TextLabel.Text = keyName
                                    keybind.Value = keyName

                                    inputConnection:Disconnect()
                                    releaseConnection:Disconnect()
                                end
                            end)
                        end)
                    end
                end
            end)
            
            Core.AddSignal(UserInputService.InputBegan, function(input)
                if isInteractive then
                    if input.KeyCode.Name == keybind.Value then
                        Core.SafeCallback(keybind.Callback, input.KeyCode.Name)
                    end
                end
            end)
            
            return keybind.__type, keybind
        end

        return Defaults
    end

    function WindUI.inputSectionModule()
        local InputSectionModule = {}

        local Core = WindUI.load('core')
        local CreateInstance = Core.New
        local TweenObject = Core.Tween

        local Defaults = {
            UICorner = 8,
            UIPadding = 8,
        }
        
        local ButtonCreator = WindUI.load('buttonModule').New
        local InputCreator = WindUI.load('inputModule').New

        function Defaults.New(_, inputData)
            local input = {
                __type = "Input",
                Title = inputData.Title or "Input",
                Desc = inputData.Desc or nil,
                Type = inputData.Type or "Input",
                Locked = inputData.Locked or false,
                InputIcon = inputData.InputIcon or false,
                Placeholder = inputData.Placeholder or "Enter Text...",
                Value = inputData.Value or "",
                Callback = inputData.Callback or function() end,
                ClearTextOnFocus = inputData.ClearTextOnFocus or false,
                UIElements = {},
            }

            local isInteractive = true

            input.InputFrame = WindUI.load('sectionFrameCreator')({
                Title = input.Title,
                Desc = input.Desc,
                Parent = inputData.Parent,
                TextOffset = 0,
                Hover = false,
            })

            local inputElement = InputCreator(input.Placeholder, input.InputIcon, input.InputFrame.UIElements.Container, input.Type, function(value)
                input:Set(value)
            end)
            
            inputElement.Size = UDim2.new(1, 0, 0, input.Type == "Input" and 42 or 148)

            CreateInstance("UIScale", {
                Parent = inputElement,
                Scale = 1,
            })

            function input.Lock()
                isInteractive = false
                return input.InputFrame:Lock()
            end
            
            function input.Unlock()
                isInteractive = true
                return input.InputFrame:Unlock()
            end

            function input.Set(_, newValue)
                if isInteractive then
                    Core.SafeCallback(input.Callback, newValue)

                    inputElement.Frame.Frame.TextBox.Text = newValue
                    input.Value = newValue
                end
            end
            
            function input.SetPlaceholder(_, newPlaceholder)
                inputElement.Frame.Frame.TextBox.PlaceholderText = newPlaceholder
                input.Placeholder = newPlaceholder
            end

            input:Set(input.Value)

            if input.Locked then
                input:Lock()
            end

            return input.__type, input
        end

        return Defaults
    end

    function WindUI.dropdownModule()
        local UserInputService = game:GetService("UserInputService")
        local Mouse = game:GetService("Players").LocalPlayer:GetMouse()
        local Camera = game:GetService("Workspace").CurrentCamera

        local Core = WindUI.load('core')
        local CreateInstance = Core.New
        local TweenObject = Core.Tween

        local KeybindButtonCreator = WindUI.load('keybindButtonModule').New

        local Defaults = {
            UICorner = 10,
            UIPadding = 12,
            MenuCorner = 15,
            MenuPadding = 5,
            TabPadding = 10,
        }

        function Defaults.New(_, dropdownData)
            local dropdown = {
                __type = "Dropdown",
                Title = dropdownData.Title or "Dropdown",
                Desc = dropdownData.Desc or nil,
                Locked = dropdownData.Locked or false,
                Values = dropdownData.Values or {},
                MenuWidth = dropdownData.MenuWidth or 170,
                Value = dropdownData.Value,
                AllowNone = dropdownData.AllowNone,
                Multi = dropdownData.Multi,
                Callback = dropdownData.Callback or function() end,
                UIElements = {},
                Opened = false,
                Tabs = {}
            }

            if dropdown.Multi and not dropdown.Value then
                dropdown.Value = {}
            end

            local isInteractive = true

            dropdown.DropdownFrame = WindUI.load('sectionFrameCreator')({
                Title = dropdown.Title,
                Desc = dropdown.Desc,
                Parent = dropdownData.Parent,
                TextOffset = 0,
                Hover = false,
            })

            dropdown.UIElements.Dropdown = KeybindButtonCreator("", nil, dropdown.DropdownFrame.UIElements.Container)

            dropdown.UIElements.Dropdown.Frame.Frame.TextLabel.TextTruncate = "AtEnd"
            dropdown.UIElements.Dropdown.Frame.Frame.TextLabel.Size = UDim2.new(1, dropdown.UIElements.Dropdown.Frame.Frame.TextLabel.Size.X.Offset - 18 - 12 - 12, 0, 0)

            dropdown.UIElements.Dropdown.Size = UDim2.new(1, 0, 0, 40)

            CreateInstance("ImageLabel", {
                Image = Core.Icon("chevrons-up-down")[1],
                ImageRectOffset = Core.Icon("chevrons-up-down")[2].ImageRectPosition,
                ImageRectSize = Core.Icon("chevrons-up-down")[2].ImageRectSize,
                Size = UDim2.new(0, 18, 0, 18),
                Position = UDim2.new(1, -12, 0.5, 0),
                ThemeTag = {
                    ImageColor3 = "Icon"
                },
                AnchorPoint = Vector2.new(1, 0.5),
                Parent = dropdown.UIElements.Dropdown.Frame
            })

            dropdown.UIElements.UIListLayout = CreateInstance("UIListLayout", {
                Padding = UDim.new(0, Defaults.MenuPadding),
                FillDirection = "Vertical"
            })

            dropdown.UIElements.Menu = Core.NewRoundFrame(Defaults.MenuCorner, "Squircle", {
                ThemeTag = {
                    ImageColor3 = "Background",
                },
                ImageTransparency = 0.05,
                Size = UDim2.new(1, 0, 1, 0),
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, 0, 0, 0),
            }, {
                CreateInstance("UIPadding", {
                    PaddingTop = UDim.new(0, Defaults.MenuPadding),
                    PaddingLeft = UDim.new(0, Defaults.MenuPadding),
                    PaddingRight = UDim.new(0, Defaults.MenuPadding),
                    PaddingBottom = UDim.new(0, Defaults.MenuPadding),
                }),
                CreateInstance("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    ClipsDescendants = true
                }, {
                    CreateInstance("UICorner", {
                        CornerRadius = UDim.new(0, Defaults.MenuCorner - Defaults.MenuPadding),
                    }),
                    CreateInstance("ScrollingFrame", {
                        Size = UDim2.new(1, 0, 1, 0),
                        ScrollBarThickness = 0,
                        ScrollingDirection = "Y",
                        AutomaticCanvasSize = "Y",
                        CanvasSize = UDim2.new(0, 0, 0, 0),
                        BackgroundTransparency = 1,
                        ScrollBarImageTransparency = 1,
                    }, {
                        dropdown.UIElements.UIListLayout,
                    })
                })
            })

            dropdown.UIElements.MenuCanvas = CreateInstance("Frame", {
                Size = UDim2.new(0, dropdown.MenuWidth, 0, 300),
                BackgroundTransparency = 1,
                Position = UDim2.new(-10, 0, -10, 0),
                Visible = false,
                Active = false,
                Parent = dropdownData.WindUI.DropdownGui,
                AnchorPoint = Vector2.new(1, 0),
            }, {
                dropdown.UIElements.Menu,
                CreateInstance("UISizeConstraint", {
                    MinSize = Vector2.new(170, 0)
                })
            })

            function dropdown.Lock()
                isInteractive = false
                return dropdown.DropdownFrame:Lock()
            end
            
            function dropdown.Unlock()
                isInteractive = true
                return dropdown.DropdownFrame:Unlock()
            end

            if dropdown.Locked then
                dropdown:Lock()
            end

            local function RecalculateCanvasSize()
                dropdown.UIElements.Menu.Frame.ScrollingFrame.CanvasSize = UDim2.fromOffset(0, dropdown.UIElements.UIListLayout.AbsoluteContentSize.Y)
            end

            local function RecalculateListSize()
                if #dropdown.Values > 10 then
                    dropdown.UIElements.MenuCanvas.Size = UDim2.fromOffset(dropdown.UIElements.MenuCanvas.AbsoluteSize.X, 392)
                else
                    dropdown.UIElements.MenuCanvas.Size = UDim2.fromOffset(dropdown.UIElements.MenuCanvas.AbsoluteSize.X, dropdown.UIElements.UIListLayout.AbsoluteContentSize.Y + (Defaults.MenuPadding * 2))
                end
            end

            function UpdatePosition()
                local dropdownElement = dropdown.UIElements.Dropdown
                local menuCanvas = dropdown.UIElements.MenuCanvas

                local spaceBelow = Camera.ViewportSize.Y - (dropdownElement.AbsolutePosition.Y + dropdownElement.AbsoluteSize.Y) - Defaults.MenuPadding - 54
                local menuHeight = menuCanvas.AbsoluteSize.Y + Defaults.MenuPadding

                local offset = -54
                if spaceBelow < menuHeight then
                    offset = menuHeight - spaceBelow - 54
                end

                menuCanvas.Position = UDim2.new(
                    0,
                    dropdownElement.AbsolutePosition.X + dropdownElement.AbsoluteSize.X,
                    0,
                    dropdownElement.AbsolutePosition.Y + dropdownElement.AbsoluteSize.Y - offset + Defaults.MenuPadding
                )
            end

            function dropdown.Display()
                local values = dropdown.Values
                local displayText = ""

                if dropdown.Multi then
                    for _, value in next, values do
                        if table.find(dropdown.Value, value) then
                            displayText = displayText .. value .. ", "
                        end
                    end
                    displayText = displayText:sub(1, #displayText - 2)
                else
                    displayText = dropdown.Value or ""
                end

                dropdown.UIElements.Dropdown.Frame.Frame.TextLabel.Text = (displayText == "" and "--" or displayText)
            end

            function dropdown.Refresh(_, newValues)
                for _, child in next, dropdown.UIElements.Menu.Frame.ScrollingFrame:GetChildren() do
                    if not child:IsA("UIListLayout") then
                        child:Destroy()
                    end
                end

                dropdown.Tabs = {}

                for index, value in next, newValues do
                    local tab = {
                        Name = value,
                        Selected = false,
                        UIElements = {},
                    }
                    
                    tab.UIElements.TabItem = Core.NewRoundFrame(Defaults.MenuCorner - Defaults.MenuPadding, "Squircle", {
                        Size = UDim2.new(1, 0, 0, 34),
                        ImageTransparency = 1,
                        Parent = dropdown.UIElements.Menu.Frame.ScrollingFrame,
                        ImageColor3 = Color3.new(1, 1, 1),
                    }, {
                        Core.NewRoundFrame(Defaults.MenuCorner - Defaults.MenuPadding, "SquircleOutline", {
                            Size = UDim2.new(1, 0, 1, 0),
                            ImageColor3 = Color3.new(1, 1, 1),
                            ImageTransparency = 1,
                            Name = "Highlight",
                        }, {
                            CreateInstance("UIGradient", {
                                Rotation = 80,
                                Color = ColorSequence.new{
                                    ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 255, 255)),
                                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
                                    ColorSequenceKeypoint.new(1.0, Color3.fromRGB(255, 255, 255)),
                                },
                                Transparency = NumberSequence.new{
                                    NumberSequenceKeypoint.new(0.0, 0.1),
                                    NumberSequenceKeypoint.new(0.5, 1),
                                    NumberSequenceKeypoint.new(1.0, 0.1),
                                }
                            }),
                        }),
                        CreateInstance("Frame", {
                            Size = UDim2.new(1, 0, 1, 0),
                            BackgroundTransparency = 1,
                        }, {
                            CreateInstance("UIPadding", {
                                PaddingLeft = UDim.new(0, Defaults.TabPadding),
                                PaddingRight = UDim.new(0, Defaults.TabPadding),
                            }),
                            CreateInstance("UICorner", {
                                CornerRadius = UDim.new(0, Defaults.MenuCorner - Defaults.MenuPadding)
                            }),
                            CreateInstance("TextLabel", {
                                Text = value,
                                TextXAlignment = "Left",
                                FontFace = Font.new(Core.Font, Enum.FontWeight.Regular),
                                ThemeTag = {
                                    TextColor3 = "Text",
                                    BackgroundColor3 = "Text"
                                },
                                TextSize = 15,
                                BackgroundTransparency = 1,
                                TextTransparency = 0.4,
                                AutomaticSize = "Y",
                                Size = UDim2.new(1, 0, 0, 0),
                                AnchorPoint = Vector2.new(0, 0.5),
                                Position = UDim2.new(0, 0, 0.5, 0),
                            })
                        })
                    }, true)

                    if dropdown.Multi then
                        tab.Selected = table.find(dropdown.Value or {}, tab.Name)
                    else
                        tab.Selected = dropdown.Value == tab.Name
                    end

                    if tab.Selected then
                        tab.UIElements.TabItem.ImageTransparency = 0.95
                        tab.UIElements.TabItem.Highlight.ImageTransparency = 0.75
                        tab.UIElements.TabItem.Frame.TextLabel.TextTransparency = 0.05
                    end

                    dropdown.Tabs[index] = tab

                    dropdown:Display()

                    local function TabCallback()
                        dropdown:Display()
                        task.spawn(function()
                            Core.SafeCallback(dropdown.Callback, dropdown.Value)
                        end)
                    end

                    Core.AddSignal(tab.UIElements.TabItem.MouseButton1Click, function()
                        if dropdown.Multi then
                            if not tab.Selected then
                                tab.Selected = true
                                TweenObject(tab.UIElements.TabItem, 0.1, { ImageTransparency = 0.95 }):Play()
                                TweenObject(tab.UIElements.TabItem.Highlight, 0.1, { ImageTransparency = 0.75 }):Play()
                                TweenObject(tab.UIElements.TabItem.Frame.TextLabel, 0.1, { TextTransparency = 0 }):Play()
                                table.insert(dropdown.Value, tab.Name)
                            else
                                if not dropdown.AllowNone and #dropdown.Value == 1 then
                                    return
                                end
                                tab.Selected = false
                                TweenObject(tab.UIElements.TabItem, 0.1, { ImageTransparency = 1 }):Play()
                                TweenObject(tab.UIElements.TabItem.Highlight, 0.1, { ImageTransparency = 1 }):Play()
                                TweenObject(tab.UIElements.TabItem.Frame.TextLabel, 0.1, { TextTransparency = 0.4 }):Play()
                                
                                for idx, val in ipairs(dropdown.Value) do
                                    if val == tab.Name then
                                        table.remove(dropdown.Value, idx)
                                        break
                                    end
                                end
                            end
                        else
                            for _, otherTab in next, dropdown.Tabs do
                                TweenObject(otherTab.UIElements.TabItem, 0.1, { ImageTransparency = 1 }):Play()
                                TweenObject(otherTab.UIElements.TabItem.Highlight, 0.1, { ImageTransparency = 1 }):Play()
                                TweenObject(otherTab.UIElements.TabItem.Frame.TextLabel, 0.1, { TextTransparency = 0.5 }):Play()
                                otherTab.Selected = false
                            end
                            
                            tab.Selected = true
                            TweenObject(tab.UIElements.TabItem, 0.1, { ImageTransparency = 0.95 }):Play()
                            TweenObject(tab.UIElements.TabItem.Highlight, 0.1, { ImageTransparency = 0.75 }):Play()
                            TweenObject(tab.UIElements.TabItem.Frame.TextLabel, 0.1, { TextTransparency = 0.05 }):Play()
                            dropdown.Value = tab.Name
                        end
                        TabCallback()
                    end)

                    RecalculateCanvasSize()
                    RecalculateListSize()
                end

                local maxWidth = 0
                for _, tab in next, dropdown.Tabs do
                    if tab.UIElements.TabItem.Frame.TextLabel then
                        local textWidth = tab.UIElements.TabItem.Frame.TextLabel.TextBounds.X
                        maxWidth = math.max(maxWidth, textWidth)
                    end
                end

                dropdown.UIElements.MenuCanvas.Size = UDim2.new(0, maxWidth + 6 + 6 + 5 + 5 + 18 + 6 + 6, dropdown.UIElements.MenuCanvas.Size.Y.Scale, dropdown.UIElements.MenuCanvas.Size.Y.Offset)
            end

            dropdown:Refresh(dropdown.Values)

            function dropdown.Select(_, newValue)
                if newValue then
                    dropdown.Value = newValue
                else
                    if dropdown.Multi then
                        dropdown.Value = {}
                    else
                        dropdown.Value = nil
                    end
                end
                dropdown:Refresh(dropdown.Values)
            end

            RecalculateListSize()

            function dropdown.Open()
                if isInteractive then
                    dropdown.UIElements.Menu.Visible = true
                    dropdown.UIElements.MenuCanvas.Visible = true
                    dropdown.UIElements.MenuCanvas.Active = true
                    dropdown.UIElements.Menu.Size = UDim2.new(1, 0, 0, 0)
                    
                    TweenObject(dropdown.UIElements.Menu, 0.1, {
                        Size = UDim2.new(1, 0, 1, 0)
                    }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out):Play()

                    task.spawn(function()
                        task.wait(0.1)
                        dropdown.Opened = true
                    end)

                    UpdatePosition()
                end
            end
            
            function dropdown.Close()
                dropdown.Opened = false

                TweenObject(dropdown.UIElements.Menu, 0.25, {
                    Size = UDim2.new(1, 0, 0, 0)
                }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out):Play()

                task.spawn(function()
                    task.wait(0.2)
                    dropdown.UIElements.Menu.Visible = false
                end)

                task.spawn(function()
                    task.wait(0.25)
                    dropdown.UIElements.MenuCanvas.Visible = false
                    dropdown.UIElements.MenuCanvas.Active = false
                end)
            end

            Core.AddSignal(dropdown.UIElements.Dropdown.MouseButton1Click, function()
                dropdown:Open()
            end)

            Core.AddSignal(UserInputService.InputBegan, function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    local menuPos, menuSize = dropdown.UIElements.MenuCanvas.AbsolutePosition, dropdown.UIElements.MenuCanvas.AbsoluteSize
                    if dropdownData.Window.CanDropdown and dropdown.Opened and (Mouse.X < menuPos.X or Mouse.X > menuPos.X + menuSize.X or Mouse.Y < (menuPos.Y - 20 - 1) or Mouse.Y > menuPos.Y + menuSize.Y) then
                        dropdown:Close()
                    end
                end
            end)

            Core.AddSignal(dropdown.UIElements.Dropdown:GetPropertyChangedSignal("AbsolutePosition"), UpdatePosition)

            return dropdown.__type, dropdown
        end

        return Defaults
    end

    function WindUI.syntaxHighlighterModule()
        local SyntaxHighlighter = {}

        local Keywords = {
            lua = {
                "and", "break", "or", "else", "elseif", "if", "then", "until", "repeat", "while", "do", "for", "in", "end",
                "local", "return", "function", "export",
            },
            rbx = {
                "game", "workspace", "script", "math", "string", "table", "task", "wait", "select", "next", "Enum",
                "tick", "assert", "shared", "loadstring", "tonumber", "tostring", "type",
                "typeof", "unpack", "Instance", "CFrame", "Vector3", "Vector2", "Color3", "UDim", "UDim2", "Ray", "BrickColor",
                "OverlapParams", "RaycastParams", "Axes", "Random", "Region3", "Rect", "TweenInfo",
                "collectgarbage", "not", "utf8", "pcall", "xpcall", "_G", "setmetatable", "getmetatable", "os", "pairs", "ipairs"
            },
            operators = {
                "#", "+", "-", "*", "%", "/", "^", "=", "~", "=", "<", ">",
            }
        }

        local ColorMap = {
            numbers = Color3.fromHex("#FAB387"),
            boolean = Color3.fromHex("#FAB387"),
            operator = Color3.fromHex("#94E2D5"),
            lua = Color3.fromHex("#CBA6F7"),
            rbx = Color3.fromHex("#F38BA8"),
            str = Color3.fromHex("#A6E3A1"),
            comment = Color3.fromHex("#9399B2"),
            null = Color3.fromHex("#F38BA8"),
            call = Color3.fromHex("#89B4FA"),
            self_call = Color3.fromHex("#89B4FA"),
            local_property = Color3.fromHex("#CBA6F7"),
        }

        local function createKeywordSet(wordList)
            local set = {}
            for _, word in ipairs(wordList) do
                set[word] = true
            end
            return set
        end

        local luaKeywords = createKeywordSet(Keywords.lua)
        local rbxKeywords = createKeywordSet(Keywords.rbx)
        local operatorSet = createKeywordSet(Keywords.operators)

        local function getHighlight(tokens, index)
            local token = tokens[index]

            if ColorMap[token .. "_color"] then
                return ColorMap[token .. "_color"]
            end

            if tonumber(token) then
                return ColorMap.numbers
            elseif token == "nil" then
                return ColorMap.null
            elseif token:sub(1, 2) == "--" then
                return ColorMap.comment
            elseif operatorSet[token] then
                return ColorMap.operator
            elseif luaKeywords[token] then
                return ColorMap.lua
            elseif rbxKeywords[token] then
                return ColorMap.rbx
            elseif token:sub(1, 1) == "\"" or token:sub(1, 1) == "\'" then
                return ColorMap.str
            elseif token == "true" or token == "false" then
                return ColorMap.boolean
            end

            if tokens[index + 1] == "(" then
                if tokens[index - 1] == ":" then
                    return ColorMap.self_call
                end
                return ColorMap.call
            end

            if tokens[index - 1] == "." then
                if tokens[index - 2] == "Enum" then
                    return ColorMap.rbx
                end
                return ColorMap.local_property
            end
        end

        function SyntaxHighlighter.run(code)
            local tokens = {}
            local currentToken = ""

            local inComment = false
            local inString = false
            local inMultilineComment = false

            for i = 1, #code do
                local char = code:sub(i, i)

                if inComment then
                    if char == "\n" and not inMultilineComment then
                        table.insert(tokens, currentToken)
                        table.insert(tokens, char)
                        currentToken = ""

                        inComment = false
                    elseif code:sub(i - 1, i) == "]]" and inMultilineComment then
                        currentToken = currentToken .. "]"

                        table.insert(tokens, currentToken)
                        currentToken = ""

                        inComment = false
                        inMultilineComment = false
                    else
                        currentToken = currentToken .. char
                    end
                elseif inString then
                    if char == inString and code:sub(i - 1, i - 1) ~= "\\" or char == "\n" then
                        currentToken = currentToken .. char
                        inString = false
                    else
                        currentToken = currentToken .. char
                    end
                else
                    if code:sub(i, i + 1) == "--" then
                        table.insert(tokens, currentToken)
                        currentToken = "-"
                        inComment = true
                        inMultilineComment = code:sub(i + 2, i + 3) == "[["
                    elseif char == "\"" or char == "\'" then
                        table.insert(tokens, currentToken)
                        currentToken = char
                        inString = char
                    elseif operatorSet[char] then
                        table.insert(tokens, currentToken)
                        table.insert(tokens, char)
                        currentToken = ""
                    elseif char:match("[%w_]") then
                        currentToken = currentToken .. char
                    else
                        table.insert(tokens, currentToken)
                        table.insert(tokens, char)
                        currentToken = ""
                    end
                end
            end

            table.insert(tokens, currentToken)

            local highlightedTokens = {}

            for index, token in ipairs(tokens) do
                local color = getHighlight(tokens, index)

                if color then
                    local formatted = string.format("<font color = \"#%s\">%s</font>", color:ToHex(), token:gsub("<", "&lt;"):gsub(">", "&gt;"))
                    table.insert(highlightedTokens, formatted)
                else
                    table.insert(highlightedTokens, token)
                end
            end

            return table.concat(highlightedTokens)
        end

        return SyntaxHighlighter
    end

    function WindUI.codeBlockModule()
        local CodeBlockModule = {}

        local Core = WindUI.load('core')
        local CreateInstance = Core.New
        local TweenObject = Core.Tween

        local SyntaxHighlighter = WindUI.load('syntaxHighlighterModule')

        function CodeBlockModule.New(code, title, parent, copyCallback, scaleFactor)
            local styles = {
                Radius = 12,
                Padding = 10
            }

            local textLabel = CreateInstance("TextLabel", {
                Text = "",
                TextColor3 = Color3.fromHex("#CDD6F4"),
                TextTransparency = 0,
                TextSize = 14,
                TextWrapped = false,
                LineHeight = 1.15,
                RichText = true,
                TextXAlignment = "Left",
                Size = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1,
                AutomaticSize = "XY",
            }, {
                CreateInstance("UIPadding", {
                    PaddingTop = UDim.new(0, styles.Padding + 3),
                    PaddingLeft = UDim.new(0, styles.Padding + 3),
                    PaddingRight = UDim.new(0, styles.Padding + 3),
                    PaddingBottom = UDim.new(0, styles.Padding + 3),
                })
            })
            
            textLabel.Font = "Code"

            local scrollingFrame = CreateInstance("ScrollingFrame", {
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1,
                AutomaticCanvasSize = "X",
                ScrollingDirection = "X",
                ElasticBehavior = "Never",
                CanvasSize = UDim2.new(0, 0, 0, 0),
                ScrollBarThickness = 0,
            }, {
                textLabel
            })

            local copyButton = CreateInstance("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 30, 0, 30),
                Position = UDim2.new(1, -styles.Padding / 2, 0, styles.Padding / 2),
                AnchorPoint = Vector2.new(1, 0),
                Visible = copyCallback and true or false,
            }, {
                Core.NewRoundFrame(styles.Radius - 4, "Squircle", {
                    ImageColor3 = Color3.fromHex("#ffffff"),
                    ImageTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    Name = "Button",
                }, {
                    CreateInstance("UIScale", {
                        Scale = 1,
                    }),
                    CreateInstance("ImageLabel", {
                        Image = Core.Icon("copy")[1],
                        ImageRectSize = Core.Icon("copy")[2].ImageRectSize,
                        ImageRectOffset = Core.Icon("copy")[2].ImageRectPosition,
                        BackgroundTransparency = 1,
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.new(0.5, 0, 0.5, 0),
                        Size = UDim2.new(0, 12, 0, 12),
                        ImageColor3 = Color3.fromHex("#ffffff"),
                        ImageTransparency = 0.1,
                    })
                })
            })

            Core.AddSignal(copyButton.MouseEnter, function()
                TweenObject(copyButton.Button, 0.05, { ImageTransparency = 0.95 }):Play()
                TweenObject(copyButton.Button.UIScale, 0.05, { Scale = 0.9 }):Play()
            end)
            
            Core.AddSignal(copyButton.InputEnded, function()
                TweenObject(copyButton.Button, 0.08, { ImageTransparency = 1 }):Play()
                TweenObject(copyButton.Button.UIScale, 0.08, { Scale = 1 }):Play()
            end)

            Core.NewRoundFrame(styles.Radius, "Squircle", {
                ImageColor3 = Color3.fromHex("#212121"),
                ImageTransparency = 0.035,
                Size = UDim2.new(1, 0, 0, 20 + (styles.Padding * 2)),
                AutomaticSize = "Y",
                Parent = parent,
            }, {
                Core.NewRoundFrame(styles.Radius, "SquircleOutline", {
                    Size = UDim2.new(1, 0, 1, 0),
                    ImageColor3 = Color3.fromHex("#ffffff"),
                    ImageTransparency = 0.955,
                }),
                CreateInstance("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = "Y",
                }, {
                    Core.NewRoundFrame(styles.Radius, "Squircle-TL-TR", {
                        ImageColor3 = Color3.fromHex("#ffffff"),
                        ImageTransparency = 0.96,
                        Size = UDim2.new(1, 0, 0, 20 + (styles.Padding * 2)),
                        Visible = title and true or false
                    }, {
                        CreateInstance("ImageLabel", {
                            Size = UDim2.new(0, 18, 0, 18),
                            BackgroundTransparency = 1,
                            Image = "rbxassetid://132464694294269",
                            ImageColor3 = Color3.fromHex("#ffffff"),
                            ImageTransparency = 0.2,
                        }),
                        CreateInstance("TextLabel", {
                            Text = title,
                            TextColor3 = Color3.fromHex("#ffffff"),
                            TextTransparency = 0.2,
                            TextSize = 16,
                            AutomaticSize = "Y",
                            FontFace = Font.new(Core.Font, Enum.FontWeight.Medium),
                            TextXAlignment = "Left",
                            BackgroundTransparency = 1,
                            TextTruncate = "AtEnd",
                            Size = UDim2.new(1, copyCallback and -20 - (styles.Padding * 2) or 0, 0, 0)
                        }),
                        CreateInstance("UIPadding", {
                            PaddingLeft = UDim.new(0, styles.Padding + 3),
                            PaddingRight = UDim.new(0, styles.Padding + 3),
                        }),
                        CreateInstance("UIListLayout", {
                            Padding = UDim.new(0, styles.Padding),
                            FillDirection = "Horizontal",
                            VerticalAlignment = "Center",
                        })
                    }),
                    scrollingFrame,
                    CreateInstance("UIListLayout", {
                        Padding = UDim.new(0, 0),
                        FillDirection = "Vertical",
                    })
                }),
                copyButton,
            })

            Core.AddSignal(textLabel:GetPropertyChangedSignal("TextBounds"), function()
                scrollingFrame.Size = UDim2.new(1, 0, 0, (textLabel.TextBounds.Y / (scaleFactor or 1)) + ((styles.Padding + 3) * 2))
            end)

            function codeBlock.Set(newCode)
                textLabel.Text = SyntaxHighlighter.run(newCode)
            end

            codeBlock.Set(code)

            Core.AddSignal(copyButton.MouseButton1Click, function()
                if copyCallback then
                    copyCallback()
                    local checkIcon = Core.Icon("check")
                    copyButton.Button.ImageLabel.Image = checkIcon[1]
                    copyButton.Button.ImageLabel.ImageRectSize = checkIcon[2].ImageRectSize
                    copyButton.Button.ImageLabel.ImageRectOffset = checkIcon[2].ImageRectPosition
                end
            end)
            
            return codeBlock
        end

        return CodeBlockModule
    end

    function WindUI.codeSectionModule()
        local CodeSectionModule = {}

        local Core = WindUI.load('core')
        local CreateInstance = Core.New

        local CodeBlockCreator = WindUI.load('codeBlockModule')

        function CodeSectionModule.New(_, codeData)
            local codeSection = {
                __type = "Code",
                Title = codeData.Title,
                Code = codeData.Code,
                UIElements = {}
            }

            local isInteractive = not codeSection.Locked

            local codeBlock = CodeBlockCreator.New(codeSection.Code, codeSection.Title, codeData.Parent, function()
                if isInteractive then
                    local blockTitle = codeSection.Title or "code"
                    local success, errorMsg = pcall(function()
                        toclipboard(codeSection.Code)
                    end)
                    
                    if success then
                        codeData.WindUI:Notify({
                            Title = "Success",
                            Content = "The " .. blockTitle .. " copied to your clipboard.",
                            Icon = "check",
                            Duration = 5,
                        })
                    else
                        codeData.WindUI:Notify({
                            Title = "Error",
                            Content = "The " .. blockTitle .. " is not copied. Error: " .. errorMsg,
                            Icon = "x",
                            Duration = 5,
                        })
                    end
                end
            end, codeData.WindUI.UIScale)

            function codeSection.SetCode(_, newCode)
                codeBlock.Set(newCode)
            end

            return codeSection.__type, codeSection
        end

        return CodeSectionModule
    end

    function WindUI.colorpickerModule()
        local Core = WindUI.load('core')
        local CreateInstance = Core.New
        local TweenObject = Core.Tween

        local UserInputService = game:GetService("UserInputService")
        local RunService = game:GetService("RunService")
        local Players = game:GetService("Players")

        local RenderStepped = RunService.RenderStepped
        local LocalPlayer = Players.LocalPlayer
        local Mouse = LocalPlayer:GetMouse()

        local ButtonCreator = WindUI.load('buttonModule').New
        local InputCreator = WindUI.load('inputModule').New

        local ColorpickerModule = {
            UICorner = 8,
            UIPadding = 8
        }

        function ColorpickerModule.Colorpicker(_, colorData, callback)
            local picker = {
                __type = "Colorpicker",
                Title = colorData.Title,
                Desc = colorData.Desc,
                Default = colorData.Default,
                Callback = colorData.Callback,
                Transparency = colorData.Transparency,
                UIElements = colorData.UIElements,
            }

            function picker.SetHSVFromRGB(_, color)
                local h, s, v = Color3.toHSV(color)
                picker.Hue = h
                picker.Sat = s
                picker.Vib = v
            end

            picker:SetHSVFromRGB(picker.Default)

            local PopupManager = WindUI.load('popupModule').Init(colorData.Window)
            local popup = PopupManager.Create()

            picker.ColorpickerFrame = popup

            local hue, sat, vib = picker.Hue, picker.Sat, picker.Vib

            picker.UIElements.Title = CreateInstance("TextLabel", {
                Text = picker.Title,
                TextSize = 20,
                FontFace = Font.new(Core.Font, Enum.FontWeight.SemiBold),
                TextXAlignment = "Left",
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = "Y",
                ThemeTag = {
                    TextColor3 = "Text"
                },
                BackgroundTransparency = 1,
                Parent = popup.UIElements.Main
            }, {
                CreateInstance("UIPadding", {
                    PaddingTop = UDim.new(0, 8),
                    PaddingLeft = UDim.new(0, 8),
                    PaddingRight = UDim.new(0, 8),
                    PaddingBottom = UDim.new(0, 8),
                })
            })

            local indicator = CreateInstance("ImageLabel", {
                Size = UDim2.new(0, 18, 0, 18),
                ScaleType = Enum.ScaleType.Fit,
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                Image = "http://www.roblox.com/asset/?id=4805639000",
            })

            picker.UIElements.SatVibMap = CreateInstance("ImageLabel", {
                Size = UDim2.fromOffset(160, 158),
                Position = UDim2.fromOffset(0, 40),
                Image = "rbxassetid://4155801252",
                BackgroundColor3 = Color3.fromHSV(hue, 1, 1),
                BackgroundTransparency = 0,
                Parent = popup.UIElements.Main,
            }, {
                CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 8),
                }),
                CreateInstance("UIStroke", {
                    Thickness = 0.6,
                    ThemeTag = {
                        Color = "Text"
                    },
                    Transparency = 0.8,
                }),
                indicator,
            })

            picker.UIElements.Inputs = CreateInstance("Frame", {
                AutomaticSize = "XY",
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.fromOffset(picker.Transparency and 240 or 210, 40),
                BackgroundTransparency = 1,
                Parent = popup.UIElements.Main
            }, {
                CreateInstance("UIListLayout", {
                    Padding = UDim.new(0, 5),
                    FillDirection = "Vertical",
                })
            })

            local colorPreview1 = CreateInstance("Frame", {
                BackgroundColor3 = picker.Default,
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = picker.Transparency,
            }, {
                CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 8),
                }),
            })

            CreateInstance("ImageLabel", {
                Image = "http://www.roblox.com/asset/?id=14204231522",
                ImageTransparency = 0.45,
                ScaleType = Enum.ScaleType.Tile,
                TileSize = UDim2.fromOffset(40, 40),
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(85, 208),
                Size = UDim2.fromOffset(75, 24),
                Parent = popup.UIElements.Main,
            }, {
                CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 8),
                }),
                CreateInstance("UIStroke", {
                    Thickness = 1,
                    Transparency = 0.8,
                    ThemeTag = {
                        Color = "Text"
                    }
                }),
                colorPreview1,
            })

            local colorPreview2 = CreateInstance("Frame", {
                BackgroundColor3 = picker.Default,
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 0,
                ZIndex = 9,
            }, {
                CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 8),
                }),
            })

            CreateInstance("ImageLabel", {
                Image = "http://www.roblox.com/asset/?id=14204231522",
                ImageTransparency = 0.45,
                ScaleType = Enum.ScaleType.Tile,
                TileSize = UDim2.fromOffset(40, 40),
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(0, 208),
                Size = UDim2.fromOffset(75, 24),
                Parent = popup.UIElements.Main,
            }, {
                CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 8),
                }),
                CreateInstance("UIStroke", {
                    Thickness = 1,
                    Transparency = 0.8,
                    ThemeTag = {
                        Color = "Text"
                    }
                }),
                colorPreview2,
            })

            local keypoints = {}
            for point = 0, 1, 0.1 do
                table.insert(keypoints, ColorSequenceKeypoint.new(point, Color3.fromHSV(point, 1, 1)))
            end

            local gradient = CreateInstance("UIGradient", {
                Color = ColorSequence.new(keypoints),
                Rotation = 90,
            })

            local hueContainer = CreateInstance("Frame", {
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1,
            })

            local hueIndicator = CreateInstance("Frame", {
                Size = UDim2.new(0, 14, 0, 14),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 0, 0, 0),
                Parent = hueContainer,
                BackgroundColor3 = picker.Default
            }, {
                CreateInstance("UIStroke", {
                    Thickness = 2,
                    Transparency = 0.1,
                    ThemeTag = {
                        Color = "Text",
                    },
                }),
                CreateInstance("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                })
            })

            local hueBar = CreateInstance("Frame", {
                Size = UDim2.fromOffset(10, 192),
                Position = UDim2.fromOffset(180, 40),
                Parent = popup.UIElements.Main,
            }, {
                CreateInstance("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                }),
                gradient,
                hueContainer,
            })

            function CreateNewInput(label, defaultValue)
                local input = InputCreator(label, nil, picker.UIElements.Inputs)

                CreateInstance("TextLabel", {
                    BackgroundTransparency = 1,
                    TextTransparency = 0.4,
                    TextSize = 17,
                    FontFace = Font.new(Core.Font, Enum.FontWeight.Regular),
                    AutomaticSize = "XY",
                    ThemeTag = {
                        TextColor3 = "Placeholder",
                    },
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -12, 0.5, 0),
                    Parent = input.Frame,
                    Text = label,
                })

                CreateInstance("UIScale", {
                    Parent = input,
                    Scale = 0.85,
                })

                input.Frame.Frame.TextBox.Text = defaultValue
                input.Size = UDim2.new(0, 150, 0, 42)

                return input
            end

            local function ToRGB(color)
                return {
                    R = math.floor(color.R * 255),
                    G = math.floor(color.G * 255),
                    B = math.floor(color.B * 255)
                }
            end

            local hexInput = CreateNewInput("Hex", "#" .. picker.Default:ToHex())
            local redInput = CreateNewInput("Red", ToRGB(picker.Default).R)
            local greenInput = CreateNewInput("Green", ToRGB(picker.Default).G)
            local blueInput = CreateNewInput("Blue", ToRGB(picker.Default).B)
            local alphaInput
            
            if picker.Transparency then
                alphaInput = CreateNewInput("Alpha", ((1 - picker.Transparency) * 100) .. "%")
            end

            local buttonContainer = CreateInstance("Frame", {
                Size = UDim2.new(1, 0, 0, 40),
                AutomaticSize = "Y",
                Position = UDim2.new(0, 0, 0, 254),
                BackgroundTransparency = 1,
                Parent = popup.UIElements.Main,
                LayoutOrder = 4,
            }, {
                CreateInstance("UIListLayout", {
                    Padding = UDim.new(0, 6),
                    FillDirection = "Horizontal",
                    HorizontalAlignment = "Right",
                }),
            })

            local buttons = {
                {
                    Title = "Cancel",
                    Variant = "Secondary",
                    Callback = function() end
                },
                {
                    Title = "Apply",
                    Icon = "chevron-right",
                    Variant = "Primary",
                    Callback = function() callback(Color3.fromHSV(picker.Hue, picker.Sat, picker.Vib), picker.Transparency) end
                }
            }

            for _, btnInfo in next, buttons do
                local btn = ButtonCreator(btnInfo.Title, btnInfo.Icon, btnInfo.Callback, btnInfo.Variant, buttonContainer, popup, true)
                btn.Size = UDim2.new(0.5, -3, 0, 40)
                btn.AutomaticSize = "None"
            end

            local alphaBar, alphaIndicator, alphaBg
            if picker.Transparency then
                local alphaHandle = CreateInstance("Frame", {
                    Size = UDim2.new(1, 0, 1, 0),
                    Position = UDim2.fromOffset(0, 0),
                    BackgroundTransparency = 1,
                })

                alphaIndicator = CreateInstance("ImageLabel", {
                    Size = UDim2.new(0, 14, 0, 14),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(0.5, 0, 0, 0),
                    ThemeTag = {
                        BackgroundColor3 = "Text",
                    },
                    Parent = alphaHandle,
                }, {
                    CreateInstance("UIStroke", {
                        Thickness = 2,
                        Transparency = 0.1,
                        ThemeTag = {
                            Color = "Text",
                        },
                    }),
                    CreateInstance("UICorner", {
                        CornerRadius = UDim.new(1, 0),
                    })
                })

                alphaBg = CreateInstance("Frame", {
                    Size = UDim2.fromScale(1, 1),
                }, {
                    CreateInstance("UIGradient", {
                        Transparency = NumberSequence.new{
                            NumberSequenceKeypoint.new(0, 0),
                            NumberSequenceKeypoint.new(1, 1),
                        },
                        Rotation = 270,
                    }),
                    CreateInstance("UICorner", {
                        CornerRadius = UDim.new(0, 6),
                    }),
                })

                alphaBar = CreateInstance("Frame", {
                    Size = UDim2.fromOffset(10, 192),
                    Position = UDim2.fromOffset(210, 40),
                    Parent = popup.UIElements.Main,
                    BackgroundTransparency = 1,
                }, {
                    CreateInstance("UICorner", {
                        CornerRadius = UDim.new(1, 0),
                    }),
                    CreateInstance("ImageLabel", {
                        Image = "rbxassetid://14204231522",
                        ImageTransparency = 0.45,
                        ScaleType = Enum.ScaleType.Tile,
                        TileSize = UDim2.fromOffset(40, 40),
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(1, 1),
                    }, {
                        CreateInstance("UICorner", {
                            CornerRadius = UDim.new(1, 0),
                        }),
                    }),
                    alphaBg,
                    alphaHandle,
                })
            end

            function picker.Round(_, value, decimals)
                if decimals == 0 then
                    return math.floor(value)
                end
                value = tostring(value)
                return value:find("%.") and tonumber(value:sub(1, value:find("%.") + decimals)) or value
            end

            function picker.Update(_, newColor, newAlpha)
                if newColor then
                    hue, sat, vib = Color3.toHSV(newColor)
                else
                    hue, sat, vib = picker.Hue, picker.Sat, picker.Vib
                end

                picker.UIElements.SatVibMap.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                indicator.Position = UDim2.new(sat, 0, 1 - vib, 0)
                colorPreview2.BackgroundColor3 = Color3.fromHSV(hue, sat, vib)
                hueIndicator.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                hueIndicator.Position = UDim2.new(0.5, 0, hue, 0)

                hexInput.Frame.Frame.TextBox.Text = "#" .. Color3.fromHSV(hue, sat, vib):ToHex()
                redInput.Frame.Frame.TextBox.Text = ToRGB(Color3.fromHSV(hue, sat, vib)).R
                greenInput.Frame.Frame.TextBox.Text = ToRGB(Color3.fromHSV(hue, sat, vib)).G
                blueInput.Frame.Frame.TextBox.Text = ToRGB(Color3.fromHSV(hue, sat, vib)).B

                if newAlpha or picker.Transparency then
                    colorPreview2.BackgroundTransparency = picker.Transparency or newAlpha
                    alphaBg.BackgroundColor3 = Color3.fromHSV(hue, sat, vib)
                    alphaIndicator.BackgroundColor3 = Color3.fromHSV(hue, sat, vib)
                    alphaIndicator.BackgroundTransparency = picker.Transparency or newAlpha
                    alphaIndicator.Position = UDim2.new(0.5, 0, 1 - picker.Transparency or newAlpha, 0)
                    alphaInput.Frame.Frame.TextBox.Text = picker:Round((1 - picker.Transparency or newAlpha) * 100, 0) .. "%"
                end
            end

            picker:Update(picker.Default, picker.Transparency)

            local function GetRGB()
                local color = Color3.fromHSV(picker.Hue, picker.Sat, picker.Vib)
                return { R = math.floor(color.r * 255), G = math.floor(color.g * 255), B = math.floor(color.b * 255) }
            end

            local function clamp(value, min, max)
                return math.clamp(tonumber(value) or 0, min, max)
            end

            Core.AddSignal(hexInput.Frame.Frame.TextBox.FocusLost, function(enterPressed)
                if enterPressed then
                    local hexValue = hexInput.Frame.Frame.TextBox.Text:gsub("#", "")
                    local success, color = pcall(Color3.fromHex, hexValue)
                    if success and typeof(color) == "Color3" then
                        picker.Hue, picker.Sat, picker.Vib = Color3.toHSV(color)
                        picker:Update()
                        picker.Default = color
                    end
                end
            end)

            local function updateColorFromInput(inputElement, colorComponent)
                Core.AddSignal(inputElement.Frame.Frame.TextBox.FocusLost, function(enterPressed)
                    if enterPressed then
                        local inputText = inputElement.Frame.Frame.TextBox
                        local rgb = GetRGB()
                        local value = clamp(inputText.Text, 0, 255)
                        inputText.Text = tostring(value)

                        rgb[colorComponent] = value
                        local newColor = Color3.fromRGB(rgb.R, rgb.G, rgb.B)
                        picker.Hue, picker.Sat, picker.Vib = Color3.toHSV(newColor)
                        picker:Update()
                    end
                end)
            end

            updateColorFromInput(redInput, "R")
            updateColorFromInput(greenInput, "G")
            updateColorFromInput(blueInput, "B")

            if picker.Transparency then
                Core.AddSignal(alphaInput.Frame.Frame.TextBox.FocusLost, function(enterPressed)
                    if enterPressed then
                        local alphaText = alphaInput.Frame.Frame.TextBox
                        local value = clamp(alphaText.Text, 0, 100)
                        alphaText.Text = tostring(value)

                        picker.Transparency = 1 - value * 0.01
                        picker:Update(nil, picker.Transparency)
                    end
                end)
            end

            local satVibMap = picker.UIElements.SatVibMap
            Core.AddSignal(satVibMap.InputBegan, function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                        local left = satVibMap.AbsolutePosition.X
                        local right = left + satVibMap.AbsoluteSize.X
                        local mouseX = math.clamp(Mouse.X, left, right)

                        local top = satVibMap.AbsolutePosition.Y
                        local bottom = top + satVibMap.AbsoluteSize.Y
                        local mouseY = math.clamp(Mouse.Y, top, bottom)

                        picker.Sat = (mouseX - left) / (right - left)
                        picker.Vib = 1 - ((mouseY - top) / (bottom - top))
                        picker:Update()

                        RenderStepped:Wait()
                    end
                end
            end)

            Core.AddSignal(hueBar.InputBegan, function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                        local top = hueBar.AbsolutePosition.Y
                        local bottom = top + hueBar.AbsoluteSize.Y
                        local mouseY = math.clamp(Mouse.Y, top, bottom)

                        picker.Hue = (mouseY - top) / (bottom - top)
                        picker:Update()

                        RenderStepped:Wait()
                    end
                end
            end)

            if picker.Transparency then
                Core.AddSignal(alphaBar.InputBegan, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                            local top = alphaBar.AbsolutePosition.Y
                            local bottom = top + alphaBar.AbsoluteSize.Y
                            local mouseY = math.clamp(Mouse.Y, top, bottom)

                            picker.Transparency = 1 - ((mouseY - top) / (bottom - top))
                            picker:Update()

                            RenderStepped:Wait()
                        end
                    end
                end)
            end

            return picker
        end

        function ColorpickerModule.New(_, colorData)
            local colorpicker = {
                __type = "Colorpicker",
                Title = colorData.Title or "Colorpicker",
                Desc = colorData.Desc or nil,
                Locked = colorData.Locked or false,
                Default = colorData.Default or Color3.new(1, 1, 1),
                Callback = colorData.Callback or function() end,
                Window = colorData.Window,
                Transparency = colorData.Transparency,
                UIElements = {}
            }

            local isInteractive = true

            colorpicker.ColorpickerFrame = WindUI.load('sectionFrameCreator')({
                Title = colorpicker.Title,
                Desc = colorpicker.Desc,
                Parent = colorData.Parent,
                TextOffset = 40,
                Hover = false,
            })

            colorpicker.UIElements.Colorpicker = Core.NewRoundFrame(ColorpickerModule.UICorner, "Squircle", {
                ImageTransparency = 0,
                Active = true,
                ImageColor3 = colorpicker.Default,
                Parent = colorpicker.ColorpickerFrame.UIElements.Main,
                Size = UDim2.new(0, 30, 0, 30),
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, 0, 0.5, 0),
                ZIndex = 2
            }, nil, true)

            function colorpicker.Lock()
                isInteractive = false
                return colorpicker.ColorpickerFrame:Lock()
            end
            
            function colorpicker.Unlock()
                isInteractive = true
                return colorpicker.ColorpickerFrame:Unlock()
            end

            if colorpicker.Locked then
                colorpicker:Lock()
            end

            function colorpicker.Update(_, newColor, newTransparency)
                colorpicker.UIElements.Colorpicker.ImageTransparency = newTransparency or 0
                colorpicker.UIElements.Colorpicker.ImageColor3 = newColor
                colorpicker.Default = newColor
                if newTransparency then
                    colorpicker.Transparency = newTransparency
                end
            end

            function colorpicker.Set(_, newColor, newTransparency)
                return colorpicker:Update(newColor, newTransparency)
            end

            Core.AddSignal(colorpicker.UIElements.Colorpicker.MouseButton1Click, function()
                if isInteractive then
                    ColorpickerModule:Colorpicker(colorpicker, function(newColor, newTransparency)
                        colorpicker:Update(newColor, newTransparency)
                        colorpicker.Default = newColor
                        colorpicker.Transparency = newTransparency
                        Core.SafeCallback(colorpicker.Callback, newColor, newTransparency)
                    end).ColorpickerFrame:Open()
                end
            end)

            return colorpicker.__type, colorpicker
        end

        return ColorpickerModule
    end

    function WindUI.sectionModule()
        local SectionModule = {}

        local Core = WindUI.load('core')
        local CreateInstance = Core.New
        local TweenObject = Core.Tween

        function SectionModule.New(_, sectionData)
            local section = {
                __type = "Section",
                Title = sectionData.Title or "Section",
                Icon = sectionData.Icon,
                TextXAlignment = sectionData.TextXAlignment or "Left",
                TextSize = sectionData.TextSize or 19,
                UIElements = {},
            }

            local iconImage
            if section.Icon then
                iconImage = Core.Image(
                    section.Icon,
                    section.Icon .. ":" .. section.Title,
                    0,
                    sectionData.Window.Folder,
                    section.__type,
                    true
                )
                iconImage.Size = UDim2.new(0, 24, 0, 24)
            end

            section.UIElements.Main = CreateInstance("TextLabel", {
                BackgroundTransparency = 1,
                TextXAlignment = "Left",
                AutomaticSize = "XY",
                TextSize = section.TextSize,
                ThemeTag = {
                    TextColor3 = "Text",
                },
                FontFace = Font.new(Core.Font, Enum.FontWeight.SemiBold),
                Text = section.Title,
            })

            CreateInstance("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1,
                AutomaticSize = "Y",
                Parent = sectionData.Parent,
            }, {
                iconImage,
                section.UIElements.Main,
                CreateInstance("UIListLayout", {
                    Padding = UDim.new(0, 8),
                    FillDirection = "Horizontal",
                    VerticalAlignment = "Center",
                    HorizontalAlignment = section.TextXAlignment,
                }),
                CreateInstance("UIPadding", {
                    PaddingTop = UDim.new(0, 4),
                    PaddingBottom = UDim.new(0, 2),
                })
            })

            function section.SetTitle(_, newTitle)
                section.UIElements.Main.Text = newTitle
            end
            
            function section.Destroy()
                section.UIElements.Main.AutomaticSize = "None"
                section.UIElements.Main.Size = UDim2.new(1, 0, 0, section.UIElements.Main.TextBounds.Y)

                TweenObject(section.UIElements.Main, 0.1, { TextTransparency = 1 }):Play()
                task.wait(0.1)
                TweenObject(section.UIElements.Main, 0.15, { Size = UDim2.new(1, 0, 0, 0) }, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut):Play()
            end

            return section.__type, section
        end

        return SectionModule
    end

    function WindUI.tabManagerModule()
        local UserInputService = game:GetService("UserInputService")
        local Mouse = game.Players.LocalPlayer:GetMouse()

        local Core = WindUI.load('core')
        local CreateInstance = Core.New
        local TweenObject = Core.Tween

        local ButtonCreator = WindUI.load('buttonModule').New
        local TooltipCreator = WindUI.load('tooltipModule').New
        local ScrollbarCreator = WindUI.load('scrollbarModule').New

        local TabManager = {
            Window = nil,
            WindUI = nil,
            Tabs = {},
            Containers = {},
            SelectedTab = nil,
            TabCount = 0,
            ToolTipParent = nil,
            TabHighlight = nil,
            OnChangeFunc = function() end
        }

        function TabManager.Init(window, windUI, tooltipParent, tabHighlight)
            TabManager.Window = window
            TabManager.WindUI = windUI
            TabManager.ToolTipParent = tooltipParent
            TabManager.TabHighlight = tabHighlight
            return TabManager
        end

        function TabManager.New(tabData)
            local tab = {
                __type = "Tab",
                Title = tabData.Title or "Tab",
                Desc = tabData.Desc,
                Icon = tabData.Icon,
                IconThemed = tabData.IconThemed,
                Locked = tabData.Locked,
                ShowTabTitle = tabData.ShowTabTitle,
                Selected = false,
                Index = nil,
                Parent = tabData.Parent,
                UIElements = {},
                Elements = {},
                ContainerFrame = nil,
                UICorner = TabManager.Window.UICorner - (TabManager.Window.UIPadding / 2),
            }

            local window = TabManager.Window
            local windUI = TabManager.WindUI

            TabManager.TabCount = TabManager.TabCount + 1
            local tabIndex = TabManager.TabCount
            tab.Index = tabIndex

            tab.UIElements.Main = Core.NewRoundFrame(tab.UICorner, "Squircle", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -7, 0, 0),
                AutomaticSize = "Y",
                Parent = tabData.Parent,
                ThemeTag = {
                    ImageColor3 = "Text",
                },
                ImageTransparency = 1,
            }, {
                Core.NewRoundFrame(tab.UICorner, "SquircleOutline", {
                    Size = UDim2.new(1, 0, 1, 0),
                    ThemeTag = {
                        ImageColor3 = "Text",
                    },
                    ImageTransparency = 1,
                    Name = "Outline"
                }, {
                    CreateInstance("UIGradient", {
                        Rotation = 80,
                        Color = ColorSequence.new{
                            ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 255, 255)),
                            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
                            ColorSequenceKeypoint.new(1.0, Color3.fromRGB(255, 255, 255)),
                        },
                        Transparency = NumberSequence.new{
                            NumberSequenceKeypoint.new(0.0, 0.1),
                            NumberSequenceKeypoint.new(0.5, 1),
                            NumberSequenceKeypoint.new(1.0, 0.1),
                        }
                    }),
                }),
                Core.NewRoundFrame(tab.UICorner, "Squircle", {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = "Y",
                    ThemeTag = {
                        ImageColor3 = "Text",
                    },
                    ImageTransparency = 1,
                    Name = "Frame",
                }, {
                    CreateInstance("UIListLayout", {
                        SortOrder = "LayoutOrder",
                        Padding = UDim.new(0, 10),
                        FillDirection = "Horizontal",
                        VerticalAlignment = "Center",
                    }),
                    CreateInstance("TextLabel", {
                        Text = tab.Title,
                        ThemeTag = {
                            TextColor3 = "Text"
                        },
                        TextTransparency = not tab.Locked and 0.4 or 0.7,
                        TextSize = 15,
                        Size = UDim2.new(1, 0, 0, 0),
                        FontFace = Font.new(Core.Font, Enum.FontWeight.Medium),
                        TextWrapped = true,
                        RichText = true,
                        AutomaticSize = "Y",
                        LayoutOrder = 2,
                        TextXAlignment = "Left",
                        BackgroundTransparency = 1,
                    }),
                    CreateInstance("UIPadding", {
                        PaddingTop = UDim.new(0, 2 + (window.UIPadding / 2)),
                        PaddingLeft = UDim.new(0, 4 + (window.UIPadding / 2)),
                        PaddingRight = UDim.new(0, 4 + (window.UIPadding / 2)),
                        PaddingBottom = UDim.new(0, 2 + (window.UIPadding / 2)),
                    })
                }),
            }, true)

            local offset = 0
            local iconImage
            local titleIcon

            if tab.Icon then
                iconImage = Core.Image(
                    tab.Icon,
                    tab.Icon .. ":" .. tab.Title,
                    0,
                    TabManager.Window.Folder,
                    tab.__type,
                    true,
                    tab.IconThemed
                )
                iconImage.Size = UDim2.new(0, 16, 0, 16)
                iconImage.Parent = tab.UIElements.Main.Frame
                iconImage.ImageLabel.ImageTransparency = not tab.Locked and 0 or 0.7
                tab.UIElements.Main.Frame.TextLabel.Size = UDim2.new(1, -30, 0, 0)
                offset = -30

                tab.UIElements.Icon = iconImage

                titleIcon = Core.Image(
                    tab.Icon,
                    tab.Icon .. ":" .. tab.Title,
                    0,
                    TabManager.Window.Folder,
                    tab.__type,
                    true,
                    tab.IconThemed
                )
                titleIcon.Size = UDim2.new(0, 16, 0, 16)
                titleIcon.ImageLabel.ImageTransparency = not tab.Locked and 0 or 0.7
                offset = -30
            end

            tab.UIElements.ContainerFrame = CreateInstance("ScrollingFrame", {
                Size = UDim2.new(1, 0, 1, tab.ShowTabTitle and -((window.UIPadding * 2.4) + 12) or 0),
                BackgroundTransparency = 1,
                ScrollBarThickness = 0,
                ElasticBehavior = "Never",
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AnchorPoint = Vector2.new(0, 1),
                Position = UDim2.new(0, 0, 1, 0),
                AutomaticCanvasSize = "Y",
                ScrollingDirection = "Y",
            }, {
                CreateInstance("UIPadding", {
                    PaddingTop = UDim.new(0, 20),
                    PaddingLeft = UDim.new(0, 20),
                    PaddingRight = UDim.new(0, 20),
                    PaddingBottom = UDim.new(0, 20),
                }),
                CreateInstance("UIListLayout", {
                    SortOrder = "LayoutOrder",
                    Padding = UDim.new(0, 6),
                    HorizontalAlignment = "Center",
                })
            })

            tab.UIElements.ContainerFrameCanvas = CreateInstance("Frame", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Visible = false,
                Parent = window.UIElements.MainBar,
                ZIndex = 5,
            }, {
                tab.UIElements.ContainerFrame,
                CreateInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, ((window.UIPadding * 2.4) + 12)),
                    BackgroundTransparency = 1,
                    Visible = tab.ShowTabTitle or false,
                    Name = "TabTitle"
                }, {
                    titleIcon,
                    CreateInstance("TextLabel", {
                        Text = tab.Title,
                        ThemeTag = {
                            TextColor3 = "Text"
                        },
                        TextSize = 20,
                        TextTransparency = 0.1,
                        Size = UDim2.new(1, -offset, 1, 0),
                        FontFace = Font.new(Core.Font, Enum.FontWeight.SemiBold),
                        TextTruncate = "AtEnd",
                        RichText = true,
                        LayoutOrder = 2,
                        TextXAlignment = "Left",
                        BackgroundTransparency = 1,
                    }),
                    CreateInstance("UIPadding", {
                        PaddingTop = UDim.new(0, 20),
                        PaddingLeft = UDim.new(0, 20),
                        PaddingRight = UDim.new(0, 20),
                        PaddingBottom = UDim.new(0, 20),
                    }),
                    CreateInstance("UIListLayout", {
                        SortOrder = "LayoutOrder",
                        Padding = UDim.new(0, 10),
                        FillDirection = "Horizontal",
                        VerticalAlignment = "Center",
                    })
                }),
                CreateInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 1),
                    BackgroundTransparency = 0.9,
                    ThemeTag = {
                        BackgroundColor3 = "Text"
                    },
                    Position = UDim2.new(0, 0, 0, ((window.UIPadding * 2.4) + 12)),
                    Visible = tab.ShowTabTitle or false,
                })
            })

            TabManager.Containers[tabIndex] = tab.UIElements.ContainerFrameCanvas
            TabManager.Tabs[tabIndex] = tab

            tab.ContainerFrame = ContainerFrameCanvas

            Core.AddSignal(tab.UIElements.Main.MouseButton1Click, function()
                if not tab.Locked then
                    TabManager:SelectTab(tabIndex)
                end
            end)

            ScrollbarCreator(tab.UIElements.ContainerFrame, tab.UIElements.ContainerFrameCanvas, window, 3)

            local tooltipTimer
            local tooltipConnection
            local currentTooltip
            local isHovering = false

            if tab.Desc then
                Core.AddSignal(tab.UIElements.Main.InputBegan, function()
                    isHovering = true
                    tooltipTimer = task.spawn(function()
                        task.wait(0.35)
                        if isHovering and not currentTooltip then
                            currentTooltip = TooltipCreator(tab.Desc, TabManager.ToolTipParent)

                            local function updatePosition()
                                if currentTooltip then
                                    currentTooltip.Container.Position = UDim2.new(0, Mouse.X, 0, Mouse.Y - 20)
                                end
                            end

                            updatePosition()
                            tooltipConnection = Mouse.Move:Connect(updatePosition)
                            currentTooltip:Open()
                        end
                    end)
                end)

                Core.AddSignal(tab.UIElements.Main.MouseEnter, function()
                    if not tab.Locked then
                        TweenObject(tab.UIElements.Main.Frame, 0.08, { ImageTransparency = 0.97 }):Play()
                    end
                end)
                
                Core.AddSignal(tab.UIElements.Main.InputEnded, function()
                    if tab.Desc then
                        isHovering = false
                        if tooltipTimer then
                            task.cancel(tooltipTimer)
                            tooltipTimer = nil
                        end
                        if tooltipConnection then
                            tooltipConnection:Disconnect()
                            tooltipConnection = nil
                        end
                        if currentTooltip then
                            currentTooltip:Close()
                            currentTooltip = nil
                        end
                    end

                    if not tab.Locked then
                        TweenObject(tab.UIElements.Main.Frame, 0.08, { ImageTransparency = 1 }):Play()
                    end
                end)
            end

            local elementCreators = {
                Button = WindUI.load('buttonSectionModule'),
                Toggle = WindUI.load('toggleSectionModule'),
                Slider = WindUI.load('sliderModule'),
                Keybind = WindUI.load('keybindModule'),
                Input = WindUI.load('inputSectionModule'),
                Dropdown = WindUI.load('dropdownModule'),
                Code = WindUI.load('codeSectionModule'),
                Colorpicker = WindUI.load('colorpickerModule'),
                Section = WindUI.load('sectionModule'),
            }

            function tab.Divider()
                local line = CreateInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 1),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundTransparency = 0.9,
                    ThemeTag = {
                        BackgroundColor3 = "Text"
                    }
                })
                
                local container = CreateInstance("Frame", {
                    Parent = tab.UIElements.ContainerFrame,
                    Size = UDim2.new(1, -7, 0, 5),
                    BackgroundTransparency = 1,
                }, {
                    line
                })

                return container
            end

            function tab.Paragraph(_, paragraphData)
                paragraphData.Parent = tab.UIElements.ContainerFrame
                paragraphData.Window = window
                paragraphData.Hover = false
                paragraphData.TextOffset = 0
                paragraphData.IsButtons = paragraphData.Buttons and #paragraphData.Buttons > 0 and true or false

                local paragraph = {
                    __type = "Paragraph",
                    Title = paragraphData.Title or "Paragraph",
                    Desc = paragraphData.Desc or nil,
                    Locked = paragraphData.Locked or false,
                }
                
                local frameCreator = WindUI.load('sectionFrameCreator')
                local paragraphFrame = frameCreator(paragraphData)

                paragraph.ParagraphFrame = paragraphFrame
                
                if paragraphData.Buttons and #paragraphData.Buttons > 0 then
                    local buttonContainer = CreateInstance("Frame", {
                        Size = UDim2.new(1, 0, 0, 38),
                        BackgroundTransparency = 1,
                        AutomaticSize = "Y",
                        Parent = paragraphFrame.UIElements.Container
                    }, {
                        CreateInstance("UIListLayout", {
                            Padding = UDim.new(0, 10),
                            FillDirection = "Vertical",
                        })
                    })

                    for _, btnInfo in next, paragraphData.Buttons do
                        local btn = ButtonCreator(btnInfo.Title, btnInfo.Icon, btnInfo.Callback, "White", buttonContainer)
                        btn.Size = UDim2.new(1, 0, 0, 38)
                    end
                end

                function paragraph.SetTitle(_, newTitle)
                    paragraph.ParagraphFrame:SetTitle(newTitle)
                end
                
                function paragraph.SetDesc(_, newDesc)
                    paragraph.ParagraphFrame:SetDesc(newDesc)
                end
                
                function paragraph.Destroy()
                    paragraph.ParagraphFrame:Destroy()
                end

                table.insert(tab.Elements, paragraph)
                return paragraph
            end

            for elementType, creator in pairs(elementCreators) do
                tab[elementType] = function(_, elementData)
                    elementData.Parent = tab.UIElements.ContainerFrame
                    elementData.Window = window
                    elementData.WindUI = windUI
                    
                    local elementTypeName, element = creator.New(_, elementData)
                    table.insert(tab.Elements, element)

                    local elementFrame
                    for propName, propValue in pairs(element) do
                        if typeof(propValue) == "table" and propName:match("Frame$") then
                            elementFrame = propValue
                            break
                        end
                    end

                    if elementFrame then
                        function element.SetTitle(_, newTitle)
                            elementFrame:SetTitle(newTitle)
                        end
                        
                        function element.SetDesc(_, newDesc)
                            elementFrame:SetDesc(newDesc)
                        end
                        
                        function element.Destroy()
                            elementFrame:Destroy()
                        end
                    end
                    
                    return element
                end
            end

            task.spawn(function()
                local emptyMessage = CreateInstance("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, -window.UIElements.Main.Main.Topbar.AbsoluteSize.Y),
                    Parent = tab.UIElements.ContainerFrame
                }, {
                    CreateInstance("UIListLayout", {
                        Padding = UDim.new(0, 8),
                        SortOrder = "LayoutOrder",
                        VerticalAlignment = "Center",
                        HorizontalAlignment = "Center",
                        FillDirection = "Vertical",
                    }),
                    CreateInstance("ImageLabel", {
                        Size = UDim2.new(0, 48, 0, 48),
                        Image = Core.Icon("frown")[1],
                        ImageRectOffset = Core.Icon("frown")[2].ImageRectPosition,
                        ImageRectSize = Core.Icon("frown")[2].ImageRectSize,
                        ThemeTag = {
                            ImageColor3 = "Icon"
                        },
                        BackgroundTransparency = 1,
                        ImageTransparency = 0.6,
                    }),
                    CreateInstance("TextLabel", {
                        AutomaticSize = "XY",
                        Text = "This tab is empty",
                        ThemeTag = {
                            TextColor3 = "Text"
                        },
                        TextSize = 18,
                        TextTransparency = 0.5,
                        BackgroundTransparency = 1,
                        FontFace = Font.new(Core.Font, Enum.FontWeight.Medium),
                    })
                })

                Core.AddSignal(tab.UIElements.ContainerFrame.ChildAdded, function()
                    emptyMessage.Visible = false
                end)
            end)

            return tab
        end

        function TabManager.OnChange(_, callback)
            TabManager.OnChangeFunc = callback
        end

        function TabManager.SelectTab(_, tabIndex)
            if not TabManager.Tabs[tabIndex].Locked then
                TabManager.SelectedTab = tabIndex

                for index, tab in next, TabManager.Tabs do
                    if not tab.Locked then
                        TweenObject(tab.UIElements.Main, 0.15, { ImageTransparency = 1 }):Play()
                        TweenObject(tab.UIElements.Main.Outline, 0.15, { ImageTransparency = 1 }):Play()
                        TweenObject(tab.UIElements.Main.Frame.TextLabel, 0.15, { TextTransparency = 0.3 }):Play()
                        
                        if tab.UIElements.Icon then
                            TweenObject(tab.UIElements.Icon.ImageLabel, 0.15, { ImageTransparency = 0.4 }):Play()
                        end
                        
                        tab.Selected = false
                    end
                end
                
                TweenObject(TabManager.Tabs[tabIndex].UIElements.Main, 0.15, { ImageTransparency = 0.95 }):Play()
                TweenObject(TabManager.Tabs[tabIndex].UIElements.Main.Outline, 0.15, { ImageTransparency = 0.85 }):Play()
                TweenObject(TabManager.Tabs[tabIndex].UIElements.Main.Frame.TextLabel, 0.15, { TextTransparency = 0 }):Play()
                
                if TabManager.Tabs[tabIndex].UIElements.Icon then
                    TweenObject(TabManager.Tabs[tabIndex].UIElements.Icon.ImageLabel, 0.15, { ImageTransparency = 0.1 }):Play()
                end
                
                TabManager.Tabs[tabIndex].Selected = true

                task.spawn(function()
                    for containerIndex, container in next, TabManager.Containers do
                        container.AnchorPoint = Vector2.new(0, 0.05)
                        container.Visible = false
                    end
                    
                    TabManager.Containers[tabIndex].Visible = true
                    TweenObject(TabManager.Containers[tabIndex], 0.15, { AnchorPoint = Vector2.new(0, 0) }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out):Play()
                end)

                TabManager.OnChangeFunc(tabIndex)
            end
        end

        return TabManager
    end

    function WindUI.collapsibleSectionModule()
        local CollapsibleModule = {}

        local Core = WindUI.load('core')
        local CreateInstance = Core.New
        local TweenObject = Core.Tween

        local TabCreator = WindUI.load('tabManagerModule')

        function CollapsibleModule.New(sectionData, parent, folder, uiScale)
            local section = {
                Title = sectionData.Title or "Section",
                Icon = sectionData.Icon,
                IconThemed = sectionData.IconThemed,
                Opened = sectionData.Opened or false,
                HeaderSize = 42,
                IconSize = 18,
                Expandable = false,
            }

            local iconImage
            if section.Icon then
                iconImage = Core.Image(
                    section.Icon,
                    section.Icon,
                    0,
                    folder,
                    "Section",
                    true,
                    section.IconThemed
                )
                iconImage.Size = UDim2.new(0, section.IconSize, 0, section.IconSize)
                iconImage.ImageLabel.ImageTransparency = 0.25
            end

            local chevron = CreateInstance("Frame", {
                Size = UDim2.new(0, section.IconSize, 0, section.IconSize),
                BackgroundTransparency = 1,
                Visible = false
            }, {
                CreateInstance("ImageLabel", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Image = Core.Icon("chevron-down")[1],
                    ImageRectSize = Core.Icon("chevron-down")[2].ImageRectSize,
                    ImageRectOffset = Core.Icon("chevron-down")[2].ImageRectPosition,
                    ThemeTag = {
                        ImageColor3 = "Icon",
                    },
                    ImageTransparency = 0.7,
                })
            })

            local container = CreateInstance("Frame", {
                Size = UDim2.new(1, 0, 0, section.HeaderSize),
                BackgroundTransparency = 1,
                Parent = parent,
                ClipsDescendants = true,
            }, {
                CreateInstance("TextButton", {
                    Size = UDim2.new(1, 0, 0, section.HeaderSize),
                    BackgroundTransparency = 1,
                    Text = "",
                }, {
                    iconImage,
                    CreateInstance("TextLabel", {
                        Text = section.Title,
                        TextXAlignment = "Left",
                        Size = UDim2.new(
                            1,
                            iconImage and (-section.IconSize - 10) * 2 or (-section.IconSize - 10),
                            1,
                            0
                        ),
                        ThemeTag = {
                            TextColor3 = "Text",
                        },
                        FontFace = Font.new(Core.Font, Enum.FontWeight.SemiBold),
                        TextSize = 14,
                        BackgroundTransparency = 1,
                        TextTransparency = 0.7,
                        TextWrapped = true
                    }),
                    CreateInstance("UIListLayout", {
                        FillDirection = "Horizontal",
                        VerticalAlignment = "Center",
                        Padding = UDim.new(0, 10)
                    }),
                    chevron,
                    CreateInstance("UIPadding", {
                        PaddingLeft = UDim.new(0, 11),
                        PaddingRight = UDim.new(0, 11),
                    })
                }),
                CreateInstance("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = "Y",
                    Name = "Content",
                    Visible = true,
                    Position = UDim2.new(0, 0, 0, section.HeaderSize)
                }, {
                    CreateInstance("UIListLayout", {
                        FillDirection = "Vertical",
                        Padding = UDim.new(0, 0),
                        VerticalAlignment = "Bottom",
                    }),
                })
            })

            function section.Tab(_, tabData)
                if not section.Expandable then
                    section.Expandable = true
                    chevron.Visible = true
                end
                tabData.Parent = container.Content
                return TabCreator.New(tabData)
            end

            function section.Open()
                if section.Expandable then
                    section.Opened = true
                    TweenObject(container, 0.33, {
                        Size = UDim2.new(1, 0, 0, section.HeaderSize + (container.Content.AbsoluteSize.Y / uiScale))
                    }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()

                    TweenObject(chevron.ImageLabel, 0.1, { Rotation = 180 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
                end
            end
            
            function section.Close()
                if section.Expandable then
                    section.Opened = false
                    TweenObject(container, 0.26, {
                        Size = UDim2.new(1, 0, 0, section.HeaderSize)
                    }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
                    
                    TweenObject(chevron.ImageLabel, 0.1, { Rotation = 0 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
                end
            end

            Core.AddSignal(container.TextButton.MouseButton1Click, function()
                if section.Expandable then
                    if section.Opened then
                        section:Close()
                    else
                        section:Open()
                    end
                end
            end)

            if section.Opened then
                task.spawn(function()
                    task.wait()
                    section:Open()
                end)
            end

            return section
        end

        return CollapsibleModule
    end

    function WindUI.getIconMap()
        return {
            Tab = "table-of-contents",
            Paragraph = "type",
            Button = "square-mouse-pointer",
            Toggle = "toggle-right",
            Slider = "sliders-horizontal",
            Keybind = "command",
            Input = "text-cursor-input",
            Dropdown = "chevrons-up-down",
            Code = "terminal",
            Colorpicker = "palette",
        }
    end

    function WindUI.searchModule()
        local UserInputService = game:GetService("UserInputService")

        local Defaults = {
            Margin = 8,
            Padding = 9,
        }

        local Core = WindUI.load('core')
        local CreateInstance = Core.New
        local TweenObject = Core.Tween

        function Defaults.new(tabManager, parent, closeCallback)
            local styles = {
                IconSize = 14,
                Padding = 14,
                Radius = 18,
                Width = 400,
                MaxHeight = 380,
                Icons = WindUI.load('getIconMap')(),
            }

            local searchBox = CreateInstance("TextBox", {
                Text = "",
                PlaceholderText = "Search...",
                ThemeTag = {
                    PlaceholderColor3 = "Placeholder",
                    TextColor3 = "Text",
                },
                Size = UDim2.new(
                    1,
                    -((styles.IconSize * 2) + (styles.Padding * 2)),
                    0,
                    0
                ),
                AutomaticSize = "Y",
                ClipsDescendants = true,
                ClearTextOnFocus = false,
                BackgroundTransparency = 1,
                TextXAlignment = "Left",
                FontFace = Font.new(Core.Font, Enum.FontWeight.Regular),
                TextSize = 17,
            })

            local closeIcon = CreateInstance("ImageLabel", {
                Image = Core.Icon("x")[1],
                ImageRectSize = Core.Icon("x")[2].ImageRectSize,
                ImageRectOffset = Core.Icon("x")[2].ImageRectPosition,
                BackgroundTransparency = 1,
                ThemeTag = {
                    ImageColor3 = "Text",
                },
                ImageTransparency = 0.2,
                Size = UDim2.new(0, styles.IconSize, 0, styles.IconSize)
            }, {
                CreateInstance("TextButton", {
                    Size = UDim2.new(1, 8, 1, 8),
                    BackgroundTransparency = 1,
                    Active = true,
                    ZIndex = 999999999,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    Text = "",
                })
            })

            local resultsScroller = CreateInstance("ScrollingFrame", {
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticCanvasSize = "Y",
                ScrollingDirection = "Y",
                ElasticBehavior = "Never",
                ScrollBarThickness = 0,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1,
                Visible = false
            }, {
                CreateInstance("UIListLayout", {
                    Padding = UDim.new(0, 0),
                    FillDirection = "Vertical",
                }),
                CreateInstance("UIPadding", {
                    PaddingTop = UDim.new(0, styles.Padding),
                    PaddingLeft = UDim.new(0, styles.Padding),
                    PaddingRight = UDim.new(0, styles.Padding),
                    PaddingBottom = UDim.new(0, styles.Padding),
                })
            })

            local container = Core.NewRoundFrame(styles.Radius, "Squircle", {
                Size = UDim2.new(1, 0, 1, 0),
                ThemeTag = {
                    ImageColor3 = "Accent",
                },
                ImageTransparency = 0,
            }, {
                CreateInstance("Frame", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Visible = false,
                }, {
                    CreateInstance("Frame", {
                        Size = UDim2.new(1, 0, 0, 46),
                        BackgroundTransparency = 1,
                    }, {
                        CreateInstance("Frame", {
                            Size = UDim2.new(1, 0, 1, 0),
                            BackgroundTransparency = 1,
                        }, {
                            CreateInstance("ImageLabel", {
                                Image = Core.Icon("search")[1],
                                ImageRectSize = Core.Icon("search")[2].ImageRectSize,
                                ImageRectOffset = Core.Icon("search")[2].ImageRectPosition,
                                BackgroundTransparency = 1,
                                ThemeTag = {
                                    ImageColor3 = "Icon",
                                },
                                ImageTransparency = 0.05,
                                Size = UDim2.new(0, styles.IconSize, 0, styles.IconSize)
                            }),
                            searchBox,
                            closeIcon,
                            CreateInstance("UIListLayout", {
                                Padding = UDim.new(0, styles.Padding),
                                FillDirection = "Horizontal",
                                VerticalAlignment = "Center",
                            }),
                            CreateInstance("UIPadding", {
                                PaddingLeft = UDim.new(0, styles.Padding),
                                PaddingRight = UDim.new(0, styles.Padding),
                            })
                        })
                    }),
                    CreateInstance("Frame", {
                        BackgroundTransparency = 1,
                        AutomaticSize = "Y",
                        Size = UDim2.new(1, 0, 0, 0),
                        Name = "Results",
                    }, {
                        CreateInstance("Frame", {
                            Size = UDim2.new(1, 0, 0, 1),
                            ThemeTag = {
                                BackgroundColor3 = "Outline",
                            },
                            BackgroundTransparency = 0.9,
                            Visible = false,
                        }),
                        resultsScroller,
                        CreateInstance("UISizeConstraint", {
                            MaxSize = Vector2.new(styles.Width, styles.MaxHeight),
                        }),
                    }),
                    CreateInstance("UIListLayout", {
                        Padding = UDim.new(0, 0),
                        FillDirection = "Vertical",
                    }),
                })
            })

            local mainFrame = CreateInstance("Frame", {
                Size = UDim2.new(0, styles.Width, 0, 0),
                AutomaticSize = "Y",
                Parent = parent,
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Visible = false,
                ZIndex = 99999999,
            }, {
                CreateInstance("UIScale", {
                    Scale = 0.9,
                }),
                container,
                Core.NewRoundFrame(styles.Radius, "SquircleOutline2", {
                    Size = UDim2.new(1, 0, 1, 0),
                    ThemeTag = {
                        ImageColor3 = "Outline",
                    },
                    ImageTransparency = 0.7,
                }, {
                    CreateInstance("UIGradient", {
                        Rotation = 45,
                        Transparency = NumberSequence.new{
                            NumberSequenceKeypoint.new(0, 0.55),
                            NumberSequenceKeypoint.new(0.5, 0.8),
                            NumberSequenceKeypoint.new(1, 0.6)
                        }
                    })
                })
            })

            local function CreateSearchTab(title, desc, icon, parent, showParent, callback)
                local tab = CreateInstance("TextButton", {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = "Y",
                    BackgroundTransparency = 1,
                    Parent = parent or nil
                }, {
                    Core.NewRoundFrame(styles.Radius - 4, "Squircle", {
                        Size = UDim2.new(1, 0, 0, 0),
                        Position = UDim2.new(0.5, 0, 0.5, 0),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        ThemeTag = {
                            ImageColor3 = "Text",
                        },
                        ImageTransparency = 1,
                        Name = "Main"
                    }, {
                        CreateInstance("UIPadding", {
                            PaddingTop = UDim.new(0, styles.Padding - 2),
                            PaddingLeft = UDim.new(0, styles.Padding),
                            PaddingRight = UDim.new(0, styles.Padding),
                            PaddingBottom = UDim.new(0, styles.Padding - 2),
                        }),
                        CreateInstance("ImageLabel", {
                            Image = Core.Icon(icon)[1],
                            ImageRectSize = Core.Icon(icon)[2].ImageRectSize,
                            ImageRectOffset = Core.Icon(icon)[2].ImageRectPosition,
                            BackgroundTransparency = 1,
                            ThemeTag = {
                                ImageColor3 = "Text",
                            },
                            ImageTransparency = 0.2,
                            Size = UDim2.new(0, styles.IconSize, 0, styles.IconSize)
                        }),
                        CreateInstance("Frame", {
                            Size = UDim2.new(1, -styles.IconSize - styles.Padding, 0, 0),
                            BackgroundTransparency = 1,
                        }, {
                            CreateInstance("TextLabel", {
                                Text = title,
                                ThemeTag = {
                                    TextColor3 = "Text",
                                },
                                TextSize = 17,
                                BackgroundTransparency = 1,
                                TextXAlignment = "Left",
                                FontFace = Font.new(Core.Font, Enum.FontWeight.Medium),
                                Size = UDim2.new(1, 0, 0, 0),
                                TextTruncate = "AtEnd",
                                AutomaticSize = "Y",
                                Name = "Title"
                            }),
                            CreateInstance("TextLabel", {
                                Text = desc or "",
                                Visible = desc and true or false,
                                ThemeTag = {
                                    TextColor3 = "Text",
                                },
                                TextSize = 15,
                                TextTransparency = 0.2,
                                BackgroundTransparency = 1,
                                TextXAlignment = "Left",
                                FontFace = Font.new(Core.Font, Enum.FontWeight.Medium),
                                Size = UDim2.new(1, 0, 0, 0),
                                TextTruncate = "AtEnd",
                                AutomaticSize = "Y",
                                Name = "Desc"
                            }) or nil,
                            CreateInstance("UIListLayout", {
                                Padding = UDim.new(0, 6),
                                FillDirection = "Vertical",
                            })
                        }),
                        CreateInstance("UIListLayout", {
                            Padding = UDim.new(0, styles.Padding),
                            FillDirection = "Horizontal",
                        })
                    }, true),
                    CreateInstance("Frame", {
                        Name = "ParentContainer",
                        Size = UDim2.new(1, -styles.Padding, 0, 0),
                        AutomaticSize = "Y",
                        BackgroundTransparency = 1,
                        Visible = showParent,
                    }, {
                        Core.NewRoundFrame(99, "Squircle", {
                            Size = UDim2.new(0, 2, 1, 0),
                            BackgroundTransparency = 1,
                            ThemeTag = {
                                ImageColor3 = "Text"
                            },
                            ImageTransparency = 0.9,
                        }),
                        CreateInstance("Frame", {
                            Size = UDim2.new(1, -styles.Padding - 2, 0, 0),
                            Position = UDim2.new(0, styles.Padding + 2, 0, 0),
                            BackgroundTransparency = 1,
                        }, {
                            CreateInstance("UIListLayout", {
                                Padding = UDim.new(0, 0),
                                FillDirection = "Vertical",
                            }),
                        }),
                    }),
                    CreateInstance("UIListLayout", {
                        Padding = UDim.new(0, 0),
                        FillDirection = "Vertical",
                        HorizontalAlignment = "Right"
                    })
                })

                tab.Main.Size = UDim2.new(
                    1,
                    0,
                    0,
                    tab.Main.Frame.Desc.Visible and (((styles.Padding - 2) * 2) + tab.Main.Frame.Title.TextBounds.Y + 6 + tab.Main.Frame.Desc.TextBounds.Y)
                    or (((styles.Padding - 2) * 2) + tab.Main.Frame.Title.TextBounds.Y)
                )

                Core.AddSignal(tab.Main.MouseEnter, function()
                    TweenObject(tab.Main, 0.04, { ImageTransparency = 0.95 }):Play()
                end)
                
                Core.AddSignal(tab.Main.InputEnded, function()
                    TweenObject(tab.Main, 0.08, { ImageTransparency = 1 }):Play()
                end)
                
                Core.AddSignal(tab.Main.MouseButton1Click, function()
                    if callback then
                        callback()
                    end
                end)

                return tab
            end

            local function ContainsText(text, search)
                if not search or search == "" then
                    return false
                end

                if not text or text == "" then
                    return false
                end

                local lowerText = string.lower(text)
                local lowerSearch = string.lower(search)

                return string.find(lowerText, lowerSearch, 1, true) ~= nil
            end

            local function Search(searchText)
                if not searchText or searchText == "" then
                    return {}
                end

                local results = {}
                for tabIndex, tab in next, tabManager.Tabs do
                    local tabMatch = ContainsText(tab.Title or "", searchText)
                    local matchingElements = {}

                    for elementIndex, element in next, tab.Elements do
                        if element.__type ~= "Section" then
                            local titleMatch = ContainsText(element.Title or "", searchText)
                            local descMatch = ContainsText(element.Desc or "", searchText)

                            if titleMatch or descMatch then
                                matchingElements[elementIndex] = {
                                    Title = element.Title,
                                    Desc = element.Desc,
                                    Original = element,
                                    __type = element.__type
                                }
                            end
                        end
                    end

                    if tabMatch or next(matchingElements) ~= nil then
                        results[tabIndex] = {
                            Tab = tab,
                            Title = tab.Title,
                            Icon = tab.Icon,
                            Elements = matchingElements,
                        }
                    end
                end
                return results
            end

            function searchModule.Search(_, searchText)
                searchText = searchText or ""

                local results = Search(searchText)

                resultsScroller.Visible = true
                container.Frame.Results.Frame.Visible = true
                
                for _, child in next, resultsScroller:GetChildren() do
                    if child.ClassName ~= "UIListLayout" and child.ClassName ~= "UIPadding" then
                        child:Destroy()
                    end
                end

                if results and next(results) ~= nil then
                    for tabIndex, tabResult in next, results do
                        local tabIcon = styles.Icons.Tab
                        local tabElement = CreateSearchTab(tabResult.Title, nil, tabIcon, resultsScroller, true, function()
                            searchModule:Close()
                            tabManager:SelectTab(tabIndex)
                        end)
                        
                        if tabResult.Elements and next(tabResult.Elements) ~= nil then
                            for _, element in next, tabResult.Elements do
                                local elementIcon = styles.Icons[element.__type]
                                CreateSearchTab(
                                    element.Title,
                                    element.Desc,
                                    elementIcon,
                                    tabElement:FindFirstChild("ParentContainer") and tabElement.ParentContainer.Frame or nil,
                                    false,
                                    function()
                                        searchModule:Close()
                                        tabManager:SelectTab(tabIndex)
                                    end
                                )
                            end
                        end
                    end
                elseif searchText ~= "" then
                    CreateInstance("TextLabel", {
                        Size = UDim2.new(1, 0, 0, 70),
                        BackgroundTransparency = 1,
                        Text = "No results found",
                        TextSize = 16,
                        ThemeTag = {
                            TextColor3 = "Text",
                        },
                        TextTransparency = 0.2,
                        FontFace = Font.new(Core.Font, Enum.FontWeight.Medium),
                        Parent = resultsScroller,
                        Name = "NotFound",
                    })
                else
                    resultsScroller.Visible = false
                    container.Frame.Results.Frame.Visible = false
                end
            end

            Core.AddSignal(searchBox:GetPropertyChangedSignal("Text"), function()
                searchModule:Search(searchBox.Text)
            end)

            Core.AddSignal(resultsScroller.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
                TweenObject(resultsScroller, 0.06, {
                    Size = UDim2.new(
                        1,
                        0,
                        0,
                        math.clamp(resultsScroller.UIListLayout.AbsoluteContentSize.Y + (styles.Padding * 2), 0, styles.MaxHeight)
                    )
                }, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut):Play()
            end)

            local searchModule = {}

            function searchModule.Open()
                task.spawn(function()
                    container.Frame.Visible = true
                    mainFrame.Visible = true
                    TweenObject(mainFrame.UIScale, 0.12, { Scale = 1 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
                end)
            end

            function searchModule.Close()
                task.spawn(function()
                    closeCallback()
                    container.Frame.Visible = false
                    TweenObject(mainFrame.UIScale, 0.12, { Scale = 1 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()

                    task.wait(0.12)
                    mainFrame.Visible = false
                end)
            end

            Core.AddSignal(closeIcon.TextButton.MouseButton1Click, function()
                searchModule:Close()
            end)

            searchModule:Open()

            return searchModule
        end

        return Defaults
    end

    function WindUI.windowCreator()
        local UserInputService = game:GetService("UserInputService")
        local Camera = workspace.CurrentCamera

        local Core = WindUI.load('core')
        local CreateInstance = Core.New
        local TweenObject = Core.Tween

        local KeybindButtonCreator = WindUI.load('keybindButtonModule').New
        local ButtonCreator = WindUI.load('buttonModule').New
        local ScrollbarCreator = WindUI.load('scrollbarModule').New
        local TagCreator = WindUI.load('tagModule')
        local ConfigManager = WindUI.load('configManagerModule')

        return function(windowData)
            local window = {
                Title = windowData.Title or "UI Library",
                Author = windowData.Author,
                Icon = windowData.Icon,
                IconThemed = windowData.IconThemed,
                Folder = windowData.Folder,
                Resizable = windowData.Resizable,
                Background = windowData.Background,
                BackgroundImageTransparency = windowData.BackgroundImageTransparency or 0,
                User = windowData.User or {},
                Size = windowData.Size and UDim2.new(
                    0, math.clamp(windowData.Size.X.Offset, 480, 700),
                    0, math.clamp(windowData.Size.Y.Offset, 350, 520)
                ) or UDim2.new(0, 580, 0, 460),
                ToggleKey = windowData.ToggleKey or Enum.KeyCode.G,
                Transparent = windowData.Transparent or false,
                HideSearchBar = windowData.HideSearchBar,
                ScrollBarEnabled = windowData.ScrollBarEnabled or false,
                SideBarWidth = windowData.SideBarWidth or 200,
                Position = UDim2.new(0.5, 0, 0.5, 0),
                UICorner = 16,
                UIPadding = 14,
                UIElements = {},
                CanDropdown = true,
                Closed = false,
                Parent = windowData.Parent,
                Destroyed = false,
                IsFullscreen = false,
                CanResize = false,
                IsOpenButtonEnabled = true,
                ConfigManager = nil,
                CurrentTab = nil,
                TabModule = nil,
                OnCloseCallback = nil,
                OnDestroyCallback = nil,
                TopBarButtons = {},
            }

            if window.HideSearchBar ~= false then
                window.HideSearchBar = true
            end
            
            if window.Resizable ~= false then
                window.CanResize = true
                window.Resizable = true
            end

            if window.Folder then
                makefolder("WindUI/" .. window.Folder)
            end

            local corner = CreateInstance("UICorner", {
                CornerRadius = UDim.new(0, window.UICorner)
            })

            window.ConfigManager = ConfigManager:Init(window)

            local resizeHandle = CreateInstance("Frame", {
                Size = UDim2.new(0, 32, 0, 32),
                Position = UDim2.new(1, 0, 1, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                ZIndex = 99,
                Active = true
            }, {
                CreateInstance("ImageLabel", {
                    Size = UDim2.new(0, 96, 0, 96),
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://120997033468887",
                    Position = UDim2.new(0.5, -16, 0.5, -16),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    ImageTransparency = 1,
                })
            })
            
            local resizeOverlay = Core.NewRoundFrame(window.UICorner, "Squircle", {
                Size = UDim2.new(1, 0, 1, 0),
                ImageTransparency = 1,
                ImageColor3 = Color3.new(0, 0, 0),
                ZIndex = 98,
                Active = false,
            }, {
                CreateInstance("ImageLabel", {
                    Size = UDim2.new(0, 70, 0, 70),
                    Image = Core.Icon("expand")[1],
                    ImageRectOffset = Core.Icon("expand")[2].ImageRectPosition,
                    ImageRectSize = Core.Icon("expand")[2].ImageRectSize,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    ImageTransparency = 1,
                }),
            })

            local searchOverlay = Core.NewRoundFrame(window.UICorner, "Squircle", {
                Size = UDim2.new(1, 0, 1, 0),
                ImageTransparency = 1,
                ImageColor3 = Color3.new(0, 0, 0),
                ZIndex = 999,
                Active = false,
            })

            window.UIElements.SideBar = CreateInstance("ScrollingFrame", {
                Size = UDim2.new(
                    1,
                    window.ScrollBarEnabled and -3 - (window.UIPadding / 2) or 0,
                    1,
                    not window.HideSearchBar and -45 or 0
                ),
                Position = UDim2.new(0, 0, 1, 0),
                AnchorPoint = Vector2.new(0, 1),
                BackgroundTransparency = 1,
                ScrollBarThickness = 0,
                ElasticBehavior = "Never",
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = "Y",
                ScrollingDirection = "Y",
                ClipsDescendants = true,
                VerticalScrollBarPosition = "Left",
            }, {
                CreateInstance("Frame", {
                    BackgroundTransparency = 1,
                    AutomaticSize = "Y",
                    Size = UDim2.new(1, 0, 0, 0),
                    Name = "Frame",
                }, {
                    CreateInstance("UIPadding", {
                        PaddingTop = UDim.new(0, window.UIPadding / 2),
                        PaddingBottom = UDim.new(0, window.UIPadding / 2),
                    }),
                    CreateInstance("UIListLayout", {
                        SortOrder = "LayoutOrder",
                        Padding = UDim.new(0, 0)
                    })
                }),
                CreateInstance("UIPadding", {
                    PaddingLeft = UDim.new(0, window.UIPadding / 2),
                    PaddingRight = UDim.new(0, window.UIPadding / 2),
                }),
            })

            window.UIElements.SideBarContainer = CreateInstance("Frame", {
                Size = UDim2.new(0, window.SideBarWidth, 1, window.User.Enabled and -94 - (window.UIPadding * 2) or -52),
                Position = UDim2.new(0, 0, 0, 52),
                BackgroundTransparency = 1,
                Visible = true,
            }, {
                CreateInstance("Frame", {
                    Name = "Content",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(
                        1,
                        0,
                        1,
                        not window.HideSearchBar and -45 - window.UIPadding / 2 or 0
                    ),
                    Position = UDim2.new(0, 0, 1, 0),
                    AnchorPoint = Vector2.new(0, 1),
                }),
                window.UIElements.SideBar,
            })

            if window.ScrollBarEnabled then
                ScrollbarCreator(window.UIElements.SideBar, window.UIElements.SideBarContainer.Content, window, 3)
            end

            window.UIElements.MainBar = CreateInstance("Frame", {
                Size = UDim2.new(1, -window.UIElements.SideBarContainer.AbsoluteSize.X, 1, -52),
                Position = UDim2.new(1, 0, 1, 0),
                AnchorPoint = Vector2.new(1, 1),
                BackgroundTransparency = 1,
            }, {
                Core.NewRoundFrame(window.UICorner - (window.UIPadding / 2), "Squircle", {
                    Size = UDim2.new(1, 0, 1, 0),
                    ImageColor3 = Color3.new(1, 1, 1),
                    ZIndex = 3,
                    ImageTransparency = 0.95,
                    Name = "Background",
                }),
                CreateInstance("UIPadding", {
                    PaddingTop = UDim.new(0, window.UIPadding / 2),
                    PaddingLeft = UDim.new(0, window.UIPadding / 2),
                    PaddingRight = UDim.new(0, window.UIPadding / 2),
                    PaddingBottom = UDim.new(0, window.UIPadding / 2),
                })
            })

            local blurEffect = CreateInstance("ImageLabel", {
                Image = "rbxassetid://8992230677",
                ImageColor3 = Color3.new(0, 0, 0),
                ImageTransparency = 1,
                Size = UDim2.new(1, 120, 1, 116),
                Position = UDim2.new(0, -60, 0, -58),
                ScaleType = "Slice",
                SliceCenter = Rect.new(99, 99, 99, 99),
                BackgroundTransparency = 1,
                ZIndex = -999999999999999,
                Name = "Blur",
            })

            local isMobile
            if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
                isMobile = false
            elseif UserInputService.KeyboardEnabled then
                isMobile = true
            else
                isMobile = nil
            end

            local userButton
            if window.User.Enabled then
                local thumbnailType = window.User.Anonymous and 1 or game.Players.LocalPlayer.UserId
                local thumbnailUrl, thumbnailTypeResult = game.Players:GetUserThumbnailAsync(
                    thumbnailType,
                    Enum.ThumbnailType.HeadShot,
                    Enum.ThumbnailSize.Size420x420
                )

                userButton = CreateInstance("TextButton", {
                    Size = UDim2.new(0, (window.UIElements.SideBarContainer.AbsoluteSize.X) - (window.UIPadding / 2), 0, 42 + (window.UIPadding)),
                    Position = UDim2.new(0, window.UIPadding / 2, 1, -(window.UIPadding / 2)),
                    AnchorPoint = Vector2.new(0, 1),
                    BackgroundTransparency = 1,
                }, {
                    Core.NewRoundFrame(window.UICorner - (window.UIPadding / 2), "SquircleOutline", {
                        Size = UDim2.new(1, 0, 1, 0),
                        ThemeTag = {
                            ImageColor3 = "Text",
                        },
                        ImageTransparency = 1,
                        Name = "Outline"
                    }, {
                        CreateInstance("UIGradient", {
                            Rotation = 78,
                            Color = ColorSequence.new{
                                ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 255, 255)),
                                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
                                ColorSequenceKeypoint.new(1.0, Color3.fromRGB(255, 255, 255)),
                            },
                            Transparency = NumberSequence.new{
                                NumberSequenceKeypoint.new(0.0, 0.1),
                                NumberSequenceKeypoint.new(0.5, 1),
                                NumberSequenceKeypoint.new(1.0, 0.1),
                            }
                        }),
                    }),
                    Core.NewRoundFrame(window.UICorner - (window.UIPadding / 2), "Squircle", {
                        Size = UDim2.new(1, 0, 1, 0),
                        ThemeTag = {
                            ImageColor3 = "Text",
                        },
                        ImageTransparency = 1,
                        Name = "UserIcon",
                    }, {
                        CreateInstance("ImageLabel", {
                            Image = thumbnailUrl,
                            BackgroundTransparency = 1,
                            Size = UDim2.new(0, 42, 0, 42),
                            ThemeTag = {
                                BackgroundColor3 = "Text",
                            },
                            BackgroundTransparency = 0.93,
                        }, {
                            CreateInstance("UICorner", {
                                CornerRadius = UDim.new(1, 0)
                            })
                        }),
                        CreateInstance("Frame", {
                            AutomaticSize = "XY",
                            BackgroundTransparency = 1,
                        }, {
                            CreateInstance("TextLabel", {
                                Text = window.User.Anonymous and "Anonymous" or game.Players.LocalPlayer.DisplayName,
                                TextSize = 17,
                                ThemeTag = {
                                    TextColor3 = "Text",
                                },
                                FontFace = Font.new(Core.Font, Enum.FontWeight.SemiBold),
                                AutomaticSize = "Y",
                                BackgroundTransparency = 1,
                                Size = UDim2.new(1, -27, 0, 0),
                                TextTruncate = "AtEnd",
                                TextXAlignment = "Left",
                            }),
                            CreateInstance("TextLabel", {
                                Text = window.User.Anonymous and "@anonymous" or "@" .. game.Players.LocalPlayer.Name,
                                TextSize = 15,
                                TextTransparency = 0.6,
                                ThemeTag = {
                                    TextColor3 = "Text",
                                },
                                FontFace = Font.new(Core.Font, Enum.FontWeight.Medium),
                                AutomaticSize = "Y",
                                BackgroundTransparency = 1,
                                Size = UDim2.new(1, -27, 0, 0),
                                TextTruncate = "AtEnd",
                                TextXAlignment = "Left",
                            }),
                            CreateInstance("UIListLayout", {
                                Padding = UDim.new(0, 4),
                                HorizontalAlignment = "Left",
                            })
                        }),
                        CreateInstance("UIListLayout", {
                            Padding = UDim.new(0, window.UIPadding),
                            FillDirection = "Horizontal",
                            VerticalAlignment = "Center",
                        }),
                        CreateInstance("UIPadding", {
                            PaddingLeft = UDim.new(0, window.UIPadding / 2),
                            PaddingRight = UDim.new(0, window.UIPadding / 2),
                        })
                    })
                })

                if window.User.Callback then
                    Core.AddSignal(userButton.MouseButton1Click, function()
                        window.User.Callback()
                    end)
                    
                    Core.AddSignal(userButton.MouseEnter, function()
                        TweenObject(userButton.UserIcon, 0.04, { ImageTransparency = 0.95 }):Play()
                        TweenObject(userButton.Outline, 0.04, { ImageTransparency = 0.85 }):Play()
                    end)
                    
                    Core.AddSignal(userButton.InputEnded, function()
                        TweenObject(userButton.UserIcon, 0.04, { ImageTransparency = 1 }):Play()
                        TweenObject(userButton.Outline, 0.04, { ImageTransparency = 1 }):Play()
                    end)
                end
            end

            local backgroundElement
            local isVideoBackground = false

            local videoMatch = typeof(window.Background) == "string" and string.match(window.Background, "^video:(.+)") or nil

            if typeof(window.Background) == "string" and videoMatch then
                isVideoBackground = true

                if string.find(videoMatch, "http") then
                    local function SanitizeFilename(filename)
                        filename = filename:gsub("[%s/\\:*?\"<>|]+", "-")
                        filename = filename:gsub("[^%w%-_%.]", "")
                        return filename
                    end

                    local videoPath = window.Folder .. "/Assets/." .. SanitizeFilename(videoMatch) .. ".webm"
                    
                    if not isfile(videoPath) then
                        local success, errorMsg = pcall(function()
                            local videoData = game:HttpGet(videoMatch)
                            writefile(videoPath, videoData)
                        end)

                        if not success then
                            warn("[ WindUI.Background ]  Failed to download video: " .. tostring(errorMsg))
                            return
                        end
                    end
                    
                    videoMatch = getcustomasset(videoPath)
                end

                backgroundElement = CreateInstance("VideoFrame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Video = videoMatch,
                    Looped = true,
                    Volume = 0,
                }, {
                    CreateInstance("UICorner", {
                        CornerRadius = UDim.new(0, window.UICorner)
                    }),
                })
                
                backgroundElement:Play()
            elseif window.Background then
                backgroundElement = CreateInstance("ImageLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Image = typeof(window.Background) == "string" and window.Background or "",
                    ImageTransparency = 1,
                    ScaleType = "Crop",
                }, {
                    CreateInstance("UICorner", {
                        CornerRadius = UDim.new(0, window.UICorner)
                    }),
                })
            end

            local dragHandle = Core.NewRoundFrame(99, "Squircle", {
                ImageTransparency = 0.8,
                ImageColor3 = Color3.new(1, 1, 1),
                Size = UDim2.new(0, 0, 0, 4),
                Position = UDim2.new(0.5, 0, 1, 4),
                AnchorPoint = Vector2.new(0.5, 0),
            }, {
                CreateInstance("Frame", {
                    Size = UDim2.new(1, 12, 1, 12),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Active = true,
                    ZIndex = 99,
                })
            })

            local titleLabel = CreateInstance("TextLabel", {
                Text = window.Title,
                FontFace = Font.new(Core.Font, Enum.FontWeight.SemiBold),
                BackgroundTransparency = 1,
                AutomaticSize = "XY",
                Name = "Title",
                TextXAlignment = "Left",
                TextSize = 16,
                ThemeTag = {
                    TextColor3 = "Text"
                }
            })

            window.UIElements.Main = CreateInstance("Frame", {
                Size = window.Size,
                Position = window.Position,
                BackgroundTransparency = 1,
                Parent = windowData.Parent,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Active = true,
            }, {
                blurEffect,
                Core.NewRoundFrame(window.UICorner, "Squircle", {
                    ImageTransparency = 1,
                    Size = UDim2.new(1, 0, 1, -240),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    Name = "Background",
                    ThemeTag = {
                        ImageColor3 = "Background"
                    },
                }, {
                    backgroundElement,
                    dragHandle,
                    resizeHandle,
                }),
                corner,
                resizeOverlay,
                searchOverlay,
                CreateInstance("Frame", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Name = "Main",
                    Visible = false,
                    ZIndex = 97,
                }, {
                    CreateInstance("UICorner", {
                        CornerRadius = UDim.new(0, window.UICorner)
                    }),
                    window.UIElements.SideBarContainer,
                    window.UIElements.MainBar,
                    userButton,
                    CreateInstance("Frame", {
                        Size = UDim2.new(1, 0, 0, 52),
                        BackgroundTransparency = 1,
                        BackgroundColor3 = Color3.fromRGB(50, 50, 50),
                        Name = "Topbar"
                    }, {
                        CreateInstance("Frame", {
                            AutomaticSize = "X",
                            Size = UDim2.new(0, 0, 1, 0),
                            BackgroundTransparency = 1,
                            Name = "Left"
                        }, {
                            CreateInstance("UIListLayout", {
                                Padding = UDim.new(0, window.UIPadding + 4),
                                SortOrder = "LayoutOrder",
                                FillDirection = "Horizontal",
                                VerticalAlignment = "Center",
                            }),
                            CreateInstance("Frame", {
                                AutomaticSize = "XY",
                                BackgroundTransparency = 1,
                                Name = "Title",
                                Size = UDim2.new(0, 0, 1, 0),
                                LayoutOrder = 2,
                            }, {
                                CreateInstance("UIListLayout", {
                                    Padding = UDim.new(0, 0),
                                    SortOrder = "LayoutOrder",
                                    FillDirection = "Vertical",
                                    VerticalAlignment = "Top",
                                }),
                                titleLabel,
                            }),
                            CreateInstance("UIPadding", {
                                PaddingLeft = UDim.new(0, 4)
                            })
                        }),
                        CreateInstance("ScrollingFrame", {
                            Name = "Center",
                            BackgroundTransparency = 1,
                            AutomaticSize = "Y",
                            ScrollBarThickness = 0,
                            ScrollingDirection = "X",
                            AutomaticCanvasSize = "X",
                            CanvasSize = UDim2.new(0, 0, 0, 0),
                            Size = UDim2.new(0, 0, 1, 0),
                            AnchorPoint = Vector2.new(0, 0.5),
                            Position = UDim2.new(0, 0, 0.5, 0),
                            Visible = false,
                        }, {
                            CreateInstance("UIListLayout", {
                                FillDirection = "Horizontal",
                                VerticalAlignment = "Center",
                                HorizontalAlignment = "Left",
                                Padding = UDim.new(0, window.UIPadding / 2)
                            })
                        }),
                        CreateInstance("Frame", {
                            AutomaticSize = "XY",
                            BackgroundTransparency = 1,
                            Position = UDim2.new(1, 0, 0.5, 0),
                            AnchorPoint = Vector2.new(1, 0.5),
                            Name = "Right",
                        }, {
                            CreateInstance("UIListLayout", {
                                Padding = UDim.new(0, 9),
                                FillDirection = "Horizontal",
                                SortOrder = "LayoutOrder",
                            }),
                        }),
                        CreateInstance("UIPadding", {
                            PaddingTop = UDim.new(0, window.UIPadding),
                            PaddingLeft = UDim.new(0, window.UIPadding),
                            PaddingRight = UDim.new(0, 8),
                            PaddingBottom = UDim.new(0, window.UIPadding),
                        })
                    })
                })
            })

            Core.AddSignal(window.UIElements.Main.Main.Topbar.Left:GetPropertyChangedSignal("AbsoluteSize"), function()
                window.UIElements.Main.Main.Topbar.Center.Position = UDim2.new(0, window.UIElements.Main.Main.Topbar.Left.AbsoluteSize.X + window.UIPadding, 0.5, 0)
                window.UIElements.Main.Main.Topbar.Center.Size = UDim2.new(
                    1,
                    -window.UIElements.Main.Main.Topbar.Left.AbsoluteSize.X - window.UIElements.Main.Main.Topbar.Right.AbsoluteSize.X - window.UIPadding - window.UIPadding,
                    1,
                    0
                )
            end)

            function window.CreateTopbarButton(name, icon, callback, layoutOrder, iconThemed)
                local buttonIcon = Core.Image(
                    icon,
                    icon,
                    0,
                    window.Folder,
                    "TopbarIcon",
                    true,
                    iconThemed
                )
                buttonIcon.Size = UDim2.new(0, 16, 0, 16)
                buttonIcon.AnchorPoint = Vector2.new(0.5, 0.5)
                buttonIcon.Position = UDim2.new(0.5, 0, 0.5, 0)

                local button = Core.NewRoundFrame(9, "Squircle", {
                    Size = UDim2.new(0, 36, 0, 36),
                    LayoutOrder = layoutOrder or 999,
                    Parent = window.UIElements.Main.Main.Topbar.Right,
                    ZIndex = 9999,
                    ThemeTag = {
                        ImageColor3 = "Text"
                    },
                    ImageTransparency = 1
                }, {
                    Core.NewRoundFrame(9, "SquircleOutline", {
                        Size = UDim2.new(1, 0, 1, 0),
                        ThemeTag = {
                            ImageColor3 = "Text",
                        },
                        ImageTransparency = 1,
                        Name = "Outline"
                    }, {
                        CreateInstance("UIGradient", {
                            Rotation = 45,
                            Color = ColorSequence.new{
                                ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 255, 255)),
                                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
                                ColorSequenceKeypoint.new(1.0, Color3.fromRGB(255, 255, 255)),
                            },
                            Transparency = NumberSequence.new{
                                NumberSequenceKeypoint.new(0.0, 0.1),
                                NumberSequenceKeypoint.new(0.5, 1),
                                NumberSequenceKeypoint.new(1.0, 0.1),
                            }
                        }),
                    }),
                    buttonIcon,
                }, true)

                window.TopBarButtons[100 - layoutOrder] = {
                    Name = name,
                    Object = button
                }

                Core.AddSignal(button.MouseButton1Click, function()
                    callback()
                end)
                
                Core.AddSignal(button.MouseEnter, function()
                    TweenObject(button, 0.15, { ImageTransparency = 0.93 }):Play()
                    TweenObject(button.Outline, 0.15, { ImageTransparency = 0.75 }):Play()
                end)
                
                Core.AddSignal(button.MouseLeave, function()
                    TweenObject(button, 0.1, { ImageTransparency = 1 }):Play()
                    TweenObject(button.Outline, 0.1, { ImageTransparency = 1 }):Play()
                end)

                return button
            end

            local dragController = Core.Drag(
                window.UIElements.Main,
                { window.UIElements.Main.Main.Topbar, dragHandle.Frame },
                function(isDragging, dragFrame)
                    if not window.Closed then
                        if isDragging and dragFrame == dragHandle.Frame then
                            TweenObject(dragHandle, 0.1, { ImageTransparency = 0.35 }):Play()
                        else
                            TweenObject(dragHandle, 0.2, { ImageTransparency = 0.8 }):Play()
                        end
                    end
                end
            )

            if not isVideoBackground and window.Background and typeof(window.Background) == "table" then
                local gradient = CreateInstance("UIGradient")
                for propName, propValue in next, window.Background do
                    gradient[propName] = propValue
                end

                window.UIElements.BackgroundGradient = Core.NewRoundFrame(window.UICorner, "Squircle", {
                    Size = UDim2.new(1, 0, 1, 0),
                    Parent = window.UIElements.Main.Background,
                    ImageTransparency = window.Transparent and windowData.WindUI.TransparencyValue or 0
                }, {
                    gradient
                })
            end

            if window.Author then
                CreateInstance("TextLabel", {
                    Text = window.Author,
                    FontFace = Font.new(Core.Font, Enum.FontWeight.Medium),
                    BackgroundTransparency = 1,
                    TextTransparency = 0.4,
                    AutomaticSize = "XY",
                    Parent = window.UIElements.Main.Main.Topbar.Left.Title,
                    TextXAlignment = "Left",
                    TextSize = 13,
                    LayoutOrder = 2,
                    ThemeTag = {
                        TextColor3 = "Text"
                    }
                })
            end

            local openButton = WindUI.load('openButtonModule').New(window)

            task.spawn(function()
                if window.Icon then
                    local windowIcon = Core.Image(
                        window.Icon,
                        window.Title,
                        0,
                        window.Folder,
                        "Window",
                        true,
                        window.IconThemed
                    )
                    windowIcon.Parent = window.UIElements.Main.Main.Topbar.Left
                    windowIcon.Size = UDim2.new(0, 22, 0, 22)

                    openButton:SetIcon(window.Icon)
                else
                    openButton:SetIcon(window.Icon)
                end
            end)

            function window.SetToggleKey(_, newKey)
                window.ToggleKey = newKey
            end

            function window.SetBackgroundImage(_, imageUrl)
                window.UIElements.Main.Background.ImageLabel.Image = imageUrl
            end
            
            function window.SetBackgroundImageTransparency(_, transparency)
                window.UIElements.Main.Background.ImageLabel.ImageTransparency = transparency
                window.BackgroundImageTransparency = transparency
            end

            window:CreateTopbarButton("Fullscreen", "maximize", function()
                window:ToggleFullscreen()
            end, 998)

            function window.ToggleFullscreen()
                local isFullscreen = window.IsFullscreen

                dragController:Set(not isFullscreen)

                if not isFullscreen then
                    savedPosition = window.UIElements.Main.Position
                    savedSize = window.UIElements.Main.Size
                    window.CanResize = false
                else
                    if window.Resizable then
                        window.CanResize = true
                    end
                end

                TweenObject(window.UIElements.Main, 0.45, {
                    Size = isFullscreen and savedSize or UDim2.new(1, -20, 1, -72)
                }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()

                TweenObject(window.UIElements.Main, 0.45, {
                    Position = isFullscreen and savedPosition or UDim2.new(0.5, 0, 0.5, 26)
                }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()

                window.IsFullscreen = not isFullscreen
            end

            window:CreateTopbarButton("Minimize", "minus", function()
                window:Close()
                task.spawn(function()
                    task.wait(0.3)
                    if not isMobile and window.IsOpenButtonEnabled then
                        openButton:Visible(true)
                    end
                end)
            end, 997)

            function window.OnClose(_, callback)
                window.OnCloseCallback = callback
            end
            
            function window.OnDestroy(_, callback)
                window.OnDestroyCallback = callback
            end

            function window.Open()
                task.spawn(function()
                    task.wait(0.06)
                    window.Closed = false

                    TweenObject(window.UIElements.Main.Background, 0.2, {
                        ImageTransparency = window.Transparent and windowData.WindUI.TransparencyValue or 0,
                    }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()

                    if window.UIElements.BackgroundGradient then
                        TweenObject(window.UIElements.BackgroundGradient, 0.2, {
                            ImageTransparency = 0,
                        }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
                    end

                    TweenObject(window.UIElements.Main.Background, 0.4, {
                        Size = UDim2.new(1, 0, 1, 0),
                    }, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out):Play()

                    if backgroundElement then
                        if backgroundElement:IsA("VideoFrame") then
                            backgroundElement.Visible = true
                        end
                        TweenObject(backgroundElement, 0.2, {
                            ImageTransparency = backgroundElement:IsA("ImageLabel") and 0 or nil,
                        }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
                    end

                    TweenObject(blurEffect, 0.25, { ImageTransparency = 0.7 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
                    
                    if corner then
                        TweenObject(corner, 0.25, { Transparency = 0.8 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
                    end

                    task.spawn(function()
                        task.wait(0.5)
                        TweenObject(dragHandle, 0.45, {
                            Size = UDim2.new(0, 200, 0, 4),
                            ImageTransparency = 0.8
                        }, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out):Play()
                        
                        dragController:Set(true)
                        
                        task.wait(0.45)
                        if window.Resizable then
                            TweenObject(resizeHandle.ImageLabel, 0.45, { ImageTransparency = 0.8 }, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out):Play()
                            window.CanResize = true
                        end
                    end)

                    window.CanDropdown = true
                    window.UIElements.Main.Visible = true
                    
                    task.spawn(function()
                        task.wait(0.05)
                        window.UIElements.Main:WaitForChild("Main").Visible = true
                    end)
                end)
            end
            
            function window.Close()
                local closeReturn = {}

                if window.OnCloseCallback then
                    task.spawn(function()
                        Core.SafeCallback(window.OnCloseCallback)
                    end)
                end

                window.UIElements.Main:WaitForChild("Main").Visible = false

                window.CanDropdown = false
                window.Closed = true

                TweenObject(window.UIElements.Main.Background, 0.32, {
                    ImageTransparency = 1,
                }, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut):Play()
                
                if window.UIElements.BackgroundGradient then
                    TweenObject(window.UIElements.BackgroundGradient, 0.32, {
                        ImageTransparency = 1,
                    }, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut):Play()
                end

                TweenObject(window.UIElements.Main.Background, 0.4, {
                    Size = UDim2.new(1, 0, 1, -240),
                }, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut):Play()

                if backgroundElement then
                    if backgroundElement:IsA("VideoFrame") then
                        backgroundElement.Visible = false
                    end
                    TweenObject(backgroundElement, 0.2, {
                        ImageTransparency = backgroundElement:IsA("ImageLabel") and 1 or nil,
                    }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
                end
                
                TweenObject(blurEffect, 0.25, { ImageTransparency = 1 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
                
                if corner then
                    TweenObject(corner, 0.25, { Transparency = 1 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
                end

                TweenObject(dragHandle, 0.3, {
                    Size = UDim2.new(0, 0, 0, 4),
                    ImageTransparency = 1
                }, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut):Play()
                
                TweenObject(resizeHandle.ImageLabel, 0.3, { ImageTransparency = 1 }, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out):Play()
                dragController:Set(false)
                window.CanResize = false

                task.spawn(function()
                    task.wait(0.4)
                    window.UIElements.Main.Visible = false
                end)

                function closeReturn.Destroy()
                    if window.OnDestroyCallback then
                        task.spawn(function()
                            Core.SafeCallback(window.OnDestroyCallback)
                        end)
                    end
                    
                    window.Destroyed = true
                    task.wait(0.4)
                    windowData.Parent.Parent:Destroy()
                end

                return closeReturn
            end

            function window.ToggleTransparency(_, isTransparent)
                window.Transparent = isTransparent
                windowData.WindUI.Transparent = isTransparent

                window.UIElements.Main.Background.ImageTransparency = isTransparent and windowData.WindUI.TransparencyValue or 0
                window.UIElements.MainBar.Background.ImageTransparency = isTransparent and 0.97 or 0.95
            end

            function window.SetUIScale(_, scale)
                windowData.WindUI.UIScale = scale
                TweenObject(windowData.WindUI.ScreenGui.UIScale, 0.2, { Scale = scale }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
            end

            if (Camera.ViewportSize.X - 40 < window.UIElements.Main.AbsoluteSize.X) or (Camera.ViewportSize.Y - 40 < window.UIElements.Main.AbsoluteSize.Y) then
                if not window.IsFullscreen then
                    window:SetUIScale(0.9)
                end
            end

            if not isMobile and window.IsOpenButtonEnabled then
                Core.AddSignal(openButton.Button.TextButton.MouseButton1Click, function()
                    openButton:Visible(false)
                    window:Open()
                end)
            end

            Core.AddSignal(UserInputService.InputBegan, function(input, gameProcessed)
                if gameProcessed then return end

                if input.KeyCode == window.ToggleKey then
                    if window.Closed then
                        window:Open()
                    else
                        window:Close()
                    end
                end
            end)

            task.spawn(function()
                window:Open()
            end)

            function window.EditOpenButton(_, settings)
                return openButton:Edit(settings)
            end

            local TabManager = WindUI.load('tabManagerModule')
            local CollapsibleSection = WindUI.load('collapsibleSectionModule')
            
            local tabManager = TabManager.Init(window, windowData.WindUI, windowData.Parent.Parent.ToolTips)
            
            tabManager:OnChange(function(tabIndex)
                window.CurrentTab = tabIndex
            end)

            window.TabModule = tabManager

            function window.Tab(_, tabData)
                tabData.Parent = window.UIElements.SideBar.Frame
                return tabManager.New(tabData)
            end

            function window.SelectTab(_, tabIndex)
                tabManager:SelectTab(tabIndex)
            end

            function window.Section(_, sectionData)
                return CollapsibleSection.New(sectionData, window.UIElements.SideBar.Frame, window.Folder, windowData.WindUI.UIScale)
            end

            function window.IsResizable(_, isResizable)
                window.Resizable = isResizable
                window.CanResize = isResizable
            end

            function window.Divider()
                local line = CreateInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 1),
                    Position = UDim2.new(0.5, 0, 0, 0),
                    AnchorPoint = Vector2.new(0.5, 0),
                    BackgroundTransparency = 0.9,
                    ThemeTag = {
                        BackgroundColor3 = "Text"
                    }
                })
                
                local container = CreateInstance("Frame", {
                    Parent = window.UIElements.SideBar.Frame,
                    Size = UDim2.new(1, -7, 0, 5),
                    BackgroundTransparency = 1,
                }, {
                    line
                })

                return container
            end

            local PopupManager = WindUI.load('popupModule').Init(window, nil)
            
            function window.Dialog(_, dialogData)
                local dialog = {
                    Title = dialogData.Title or "Dialog",
                    Width = dialogData.Width or 320,
                    Content = dialogData.Content,
                    Buttons = dialogData.Buttons or {},
                    TextPadding = 10,
                }
                
                local popup = PopupManager.Create(false)

                popup.UIElements.Main.Size = UDim2.new(0, dialog.Width, 0, 0)

                local headerContainer = CreateInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = "Y",
                    BackgroundTransparency = 1,
                    Parent = popup.UIElements.Main
                }, {
                    CreateInstance("UIListLayout", {
                        FillDirection = "Horizontal",
                        Padding = UDim.new(0, popup.UIPadding),
                        VerticalAlignment = "Center"
                    }),
                    CreateInstance("UIPadding", {
                        PaddingTop = UDim.new(0, dialog.TextPadding),
                        PaddingLeft = UDim.new(0, dialog.TextPadding),
                        PaddingRight = UDim.new(0, dialog.TextPadding),
                    })
                })

                local dialogIcon
                if dialogData.Icon then
                    dialogIcon = Core.Image(
                        dialogData.Icon,
                        dialog.Title .. ":" .. dialogData.Icon,
                        0,
                        window,
                        "Dialog",
                        true,
                        dialogData.IconThemed
                    )
                    dialogIcon.Size = UDim2.new(0, 22, 0, 22)
                    dialogIcon.Parent = headerContainer
                end

                popup.UIElements.UIListLayout = CreateInstance("UIListLayout", {
                    Padding = UDim.new(0, 12),
                    FillDirection = "Vertical",
                    HorizontalAlignment = "Left",
                    Parent = popup.UIElements.Main
                })

                CreateInstance("UISizeConstraint", {
                    MinSize = Vector2.new(180, 20),
                    MaxSize = Vector2.new(400, math.huge),
                    Parent = popup.UIElements.Main,
                })

                popup.UIElements.Title = CreateInstance("TextLabel", {
                    Text = dialog.Title,
                    TextSize = 20,
                    FontFace = Font.new(Core.Font, Enum.FontWeight.SemiBold),
                    TextXAlignment = "Left",
                    TextWrapped = true,
                    RichText = true,
                    Size = UDim2.new(1, dialogIcon and -26 - popup.UIPadding or 0, 0, 0),
                    AutomaticSize = "Y",
                    ThemeTag = {
                        TextColor3 = "Text"
                    },
                    BackgroundTransparency = 1,
                    Parent = headerContainer
                })
                
                if dialog.Content then
                    CreateInstance("TextLabel", {
                        Text = dialog.Content,
                        TextSize = 18,
                        TextTransparency = 0.4,
                        TextWrapped = true,
                        RichText = true,
                        FontFace = Font.new(Core.Font, Enum.FontWeight.Medium),
                        TextXAlignment = "Left",
                        Size = UDim2.new(1, 0, 0, 0),
                        AutomaticSize = "Y",
                        LayoutOrder = 2,
                        ThemeTag = {
                            TextColor3 = "Text"
                        },
                        BackgroundTransparency = 1,
                        Parent = popup.UIElements.Main
                    }, {
                        CreateInstance("UIPadding", {
                            PaddingLeft = UDim.new(0, dialog.TextPadding),
                            PaddingRight = UDim.new(0, dialog.TextPadding),
                            PaddingBottom = UDim.new(0, dialog.TextPadding),
                        })
                    })
                end

                local buttonLayout = CreateInstance("UIListLayout", {
                    Padding = UDim.new(0, 6),
                    FillDirection = "Horizontal",
                    HorizontalAlignment = "Right",
                })

                local buttonContainer = CreateInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 40),
                    AutomaticSize = "None",
                    BackgroundTransparency = 1,
                    Parent = popup.UIElements.Main,
                    LayoutOrder = 4,
                }, {
                    buttonLayout,
                })

                local dialogButtons = {}

                for _, btnInfo in next, dialog.Buttons do
                    local btn = ButtonCreator(btnInfo.Title, btnInfo.Icon, btnInfo.Callback, btnInfo.Variant, buttonContainer, popup, true)
                    table.insert(dialogButtons, btn)
                end

                local function CheckButtonsOverflow()
                    buttonLayout.FillDirection = Enum.FillDirection.Horizontal
                    buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
                    buttonLayout.VerticalAlignment = Enum.VerticalAlignment.Center
                    buttonContainer.AutomaticSize = Enum.AutomaticSize.None

                    for _, btn in ipairs(dialogButtons) do
                        btn.Size = UDim2.new(0, 0, 1, 0)
                        btn.AutomaticSize = Enum.AutomaticSize.X
                    end

                    wait()

                    local contentWidth = buttonLayout.AbsoluteContentSize.X
                    local containerWidth = buttonContainer.AbsoluteSize.X

                    if contentWidth > containerWidth then
                        buttonLayout.FillDirection = Enum.FillDirection.Vertical
                        buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
                        buttonLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
                        buttonContainer.AutomaticSize = Enum.AutomaticSize.Y

                        for _, btn in ipairs(dialogButtons) do
                            btn.Size = UDim2.new(1, 0, 0, 40)
                            btn.AutomaticSize = Enum.AutomaticSize.None
                        end
                    else
                        local remainingSpace = containerWidth - contentWidth
                        if remainingSpace > 0 then
                            local smallestButton
                            local smallestWidth = math.huge

                            for _, btn in ipairs(dialogButtons) do
                                local btnWidth = btn.AbsoluteSize.X
                                if btnWidth < smallestWidth then
                                    smallestWidth = btnWidth
                                    smallestButton = btn
                                end
                            end

                            if smallestButton then
                                smallestButton.Size = UDim2.new(0, smallestWidth + remainingSpace, 1, 0)
                                smallestButton.AutomaticSize = Enum.AutomaticSize.None
                            end
                        end
                    end
                end

                Core.AddSignal(popup.UIElements.Main:GetPropertyChangedSignal("AbsoluteSize"), CheckButtonsOverflow)
                CheckButtonsOverflow()

                wait()
                popup:Open()

                return popup
            end

            window:CreateTopbarButton("Close", "x", function()
                TweenObject(window.UIElements.Main, 0.35, { Position = UDim2.new(0.5, 0, 0.5, 0) }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
                
                window:Dialog{
                    Title = "Close Window",
                    Content = "Do you want to close this window? You will not be able to open it again.",
                    Buttons = {
                        {
                            Title = "Cancel",
                            Callback = function() end,
                            Variant = "Secondary",
                        },
                        {
                            Title = "Close Window",
                            Callback = function() window:Close():Destroy() end,
                            Variant = "Primary",
                        }
                    }
                }
            end, 999)

            function window.Tag(_, tagData)
                if window.UIElements.Main.Main.Topbar.Center.Visible == false then
                    window.UIElements.Main.Main.Topbar.Center.Visible = true
                end
                return TagCreator:New(tagData, window.UIElements.Main.Main.Topbar.Center)
            end

            local isResizing = false
            local initialSize
            local initialInputPosition

            local function startResizing(input)
                if window.CanResize then
                    isResizing = true
                    resizeOverlay.Active = true
                    initialSize = window.UIElements.Main.Size
                    initialInputPosition = input.Position
                    
                    TweenObject(resizeOverlay, 0.12, { ImageTransparency = 0.65 }):Play()
                    TweenObject(resizeOverlay.ImageLabel, 0.12, { ImageTransparency = 0 }):Play()
                    TweenObject(resizeHandle.ImageLabel, 0.1, { ImageTransparency = 0.35 }):Play()

                    Core.AddSignal(input.Changed, function()
                        if input.UserInputState == Enum.UserInputState.End then
                            isResizing = false
                            resizeOverlay.Active = false
                            TweenObject(resizeOverlay, 0.2, { ImageTransparency = 1 }):Play()
                            TweenObject(resizeOverlay.ImageLabel, 0.17, { ImageTransparency = 1 }):Play()
                            TweenObject(resizeHandle.ImageLabel, 0.17, { ImageTransparency = 0.8 }):Play()
                        end
                    end)
                end
            end

            Core.AddSignal(resizeHandle.InputBegan, function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    if window.CanResize then
                        startResizing(input)
                    end
                end
            end)

            Core.AddSignal(UserInputService.InputChanged, function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    if isResizing and window.CanResize then
                        local delta = input.Position - initialInputPosition
                        local newSize = UDim2.new(0, initialSize.X.Offset + delta.X * 2, 0, initialSize.Y.Offset + delta.Y * 2)

                        TweenObject(window.UIElements.Main, 0, {
                            Size = UDim2.new(
                                0, math.clamp(newSize.X.Offset, 480, 700),
                                0, math.clamp(newSize.Y.Offset, 350, 520)
                            )
                        }):Play()
                    end
                end
            end)

            if not window.HideSearchBar then
                local SearchModule = WindUI.load('searchModule')
                local isSearchOpen = false

                local searchButton = KeybindButtonCreator("Search", "search", window.UIElements.SideBarContainer)
                searchButton.Size = UDim2.new(1, -window.UIPadding / 2, 0, 39)
                searchButton.Position = UDim2.new(0, window.UIPadding / 2, 0, window.UIPadding / 2)

                Core.AddSignal(searchButton.MouseButton1Click, function()
                    if isSearchOpen then return end

                    SearchModule.new(tabManager, window.UIElements.Main, function()
                        isSearchOpen = false
                        if window.Resizable then
                            window.CanResize = true
                        end
                        TweenObject(searchOverlay, 0.1, { ImageTransparency = 1 }):Play()
                        searchOverlay.Active = false
                    end)
                    
                    TweenObject(searchOverlay, 0.1, { ImageTransparency = 0.65 }):Play()
                    searchOverlay.Active = true

                    isSearchOpen = true
                    window.CanResize = false
                end)
            end

            function window.DisableTopbarButtons(_, buttonNames)
                for _, btnName in next, buttonNames do
                    for _, topBarBtn in next, window.TopBarButtons do
                        if topBarBtn.Name == btnName then
                            topBarBtn.Object.Visible = false
                        end
                    end
                end
            end

            return window
        end
    end
end

local WindUILibrary = {
    Window = nil,
    Theme = nil,
    Core = WindUI.load('core'),
    LocalizationModule = WindUI.load('localizationModule'),
    Themes = WindUI.load('themes'),
    Transparent = false,
    TransparencyValue = 0.15,
    UIScale = 1,
    ConfigManager = nil,
    Version = "1.6.4",
}

local KeySystem = WindUI.load('keySystemModule')

local Themes = WindUILibrary.Themes
local Core = WindUILibrary.Core

local CreateInstance = Core.New
local TweenObject = Core.Tween

Core.Themes = Themes

local LocalPlayer = game:GetService("Players") and game:GetService("Players").LocalPlayer or nil
WindUILibrary.Themes = Themes

local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end

local GetHui = gethui and gethui() or game.CoreGui

WindUILibrary.ScreenGui = CreateInstance("ScreenGui", {
    Name = "WindUI",
    Parent = GetHui,
    IgnoreGuiInset = true,
    ScreenInsets = "None",
}, {
    CreateInstance("UIScale", {
        Scale = WindUILibrary.Scale,
    }),
    CreateInstance("Folder", {
        Name = "Window"
    }),
    CreateInstance("Folder", {
        Name = "KeySystem"
    }),
    CreateInstance("Folder", {
        Name = "Popups"
    }),
    CreateInstance("Folder", {
        Name = "ToolTips"
    })
})

WindUILibrary.NotificationGui = CreateInstance("ScreenGui", {
    Name = "WindUI/Notifications",
    Parent = GetHui,
    IgnoreGuiInset = true,
})

WindUILibrary.DropdownGui = CreateInstance("ScreenGui", {
    Name = "WindUI/Dropdowns",
    Parent = GetHui,
    IgnoreGuiInset = true,
})

ProtectGui(WindUILibrary.ScreenGui)
ProtectGui(WindUILibrary.NotificationGui)
ProtectGui(WindUILibrary.DropdownGui)

Core.Init(WindUILibrary)

math.clamp(WindUILibrary.TransparencyValue, 0, 1)

local NotificationManager = WindUI.load('notificationModule')
local notificationHolder = NotificationManager.Init(WindUILibrary.NotificationGui)

function WindUILibrary.Notify(_, notificationData)
    notificationData.Holder = notificationHolder.Frame
    notificationData.Window = WindUILibrary.Window
    notificationData.WindUI = WindUILibrary
    return NotificationManager.New(notificationData)
end

function WindUILibrary.SetNotificationLower(_, isLower)
    notificationHolder.SetLower(isLower)
end

function WindUILibrary.SetFont(_, font)
    Core.UpdateFont(font)
end

function WindUILibrary.AddTheme(_, theme)
    Themes[theme.Name] = theme
    return theme
end

function WindUILibrary.SetTheme(_, themeName)
    if Themes[themeName] then
        WindUILibrary.Theme = Themes[themeName]
        Core.SetTheme(Themes[themeName])
        return Themes[themeName]
    end
    return nil
end

function WindUILibrary.GetThemes()
    return Themes
end

function WindUILibrary.GetCurrentTheme()
    return WindUILibrary.Theme.Name
end

function WindUILibrary.GetTransparency()
    return WindUILibrary.Transparent or false
end

function WindUILibrary.GetWindowSize()
    return Window.UIElements.Main.Size
end

function WindUILibrary.Localization(_, options)
    return WindUILibrary.LocalizationModule:New(options, Core)
end

function WindUILibrary.SetLanguage(_, language)
    if Core.Localization then
        return Core.SetLanguage(language)
    end
    return false
end

WindUILibrary:SetTheme("Dark")
WindUILibrary:SetLanguage(Core.Language)

function WindUILibrary.Gradient(_, colorData, transparencyData, additionalProps)
    local colorKeypoints = {}
    local transparencyKeypoints = {}

    for index, data in next, colorData do
        local position = tonumber(index)
        if position then
            position = math.clamp(position / 100, 0, 1)
            table.insert(colorKeypoints, ColorSequenceKeypoint.new(position, data.Color))
            table.insert(transparencyKeypoints, NumberSequenceKeypoint.new(position, data.Transparency or 0))
        end
    end

    table.sort(colorKeypoints, function(a, b) return a.Time < b.Time end)
    table.sort(transparencyKeypoints, function(a, b) return a.Time < b.Time end)

    if #colorKeypoints < 2 then
        error("ColorSequence requires at least 2 keypoints")
    end

    local gradient = {
        Color = ColorSequence.new(colorKeypoints),
        Transparency = NumberSequence.new(transparencyKeypoints),
    }

    if additionalProps then
        for propName, propValue in pairs(additionalProps) do
            gradient[propName] = propValue
        end
    end

    return gradient
end

function WindUILibrary.Popup(_, popupData)
    popupData.WindUI = WindUILibrary
    return WindUI.load('dialogModule').new(popupData)
end

function WindUILibrary.CreateWindow(_, windowData)
    local WindowCreator = WindUI.load('windowCreator')

    if not isfolder("WindUI") then
        makefolder("WindUI")
    end
    
    if windowData.Folder then
        makefolder(windowData.Folder)
    else
        makefolder(windowData.Title)
    end

    windowData.WindUI = WindUILibrary
    windowData.Parent = WindUILibrary.ScreenGui.Window

    if WindUILibrary.Window then
        warn("You cannot create more than one window")
        return
    end

    local isValidKey = true
    local selectedTheme = Themes[windowData.Theme or "Dark"]

    WindUILibrary.Theme = selectedTheme
    Core.SetTheme(selectedTheme)

    local playerName = LocalPlayer.Name or "Unknown"

    if windowData.KeySystem then
        isValidKey = false
        
        if windowData.KeySystem.SaveKey and windowData.Folder then
            if isfile(windowData.Folder .. "/" .. playerName .. ".key") then
                local isValid
                if type(windowData.KeySystem.Key) == "table" then
                    isValid = table.find(windowData.KeySystem.Key, readfile(windowData.Folder .. "/" .. playerName .. ".key"))
                else
                    isValid = tostring(windowData.KeySystem.Key) == tostring(readfile(windowData.Folder .. "/" .. playerName .. ".key"))
                end
                
                if isValid then
                    isValidKey = true
                end
            else
                KeySystem.new(windowData, playerName, function(result) isValidKey = result end)
            end
        else
            KeySystem.new(windowData, playerName, function(result) isValidKey = result end)
        end
        
        repeat task.wait() until isValidKey
    end

    local window = WindowCreator(windowData)

    WindUILibrary.Transparent = windowData.Transparent
    WindUILibrary.Window = window

    return window
end

return WindUILibrary
