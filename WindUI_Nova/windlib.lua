--[[
     _      ___         ____  ______
    | | /| / (_)__  ___/ / / / /  _/
    | |/ |/ / / _ \/ _  / /_/ // /  
    |__/|__/_/_//_/\_,_/\____/___/
    
    by .ftgs#0 (Discord)
    
    WindUI Library - Version 1.6.1
    Desminificado y documentado para facilitar modificaciones
    
    Estructura principal:
    - a: Módulo principal que contiene todas las funcionalidades
    - a.a(): Sistema principal UI
    - a.b(): Temas predeterminados
    - a.c(): Resaltado de sintaxis para código
    - a.d(): Elementos UI básicos (botones, inputs, etc.)
    - a.e(): Sistema de popups/dialogs
    - a.f(): Sistema de keys
    - a.g(): Sistema de notificaciones
    - a.h(): Sistema de diálogos
    - a.i(): Elemento Paragraph
    - a.j(): Elemento Button
    - a.k(): Elemento Toggle
    - a.l(): Elemento Slider
    - a.m(): Elemento Keybind
    - a.n(): Elemento Input
    - a.o(): Elemento Dropdown
    - a.p(): Elemento Code
    - a.q(): Elemento Colorpicker
    - a.r(): Elemento Section
    - a.s(): Sistema de Tabs
    - a.t(): Sistema de búsqueda
    - a.u(): Sistema de ventana principal
]]

local a = {}

-- Cache para módulos cargados
a.cache = {}

-- Sistema de carga de módulos
function a.load(moduleName)
    if not a.cache[moduleName] then
        a.cache[moduleName] = {
            c = a[moduleName]()  -- Ejecuta el módulo y guarda resultado
        }
    end
    return a.cache[moduleName].c
end

--------------------------------------------------------------------
-- MÓDULO PRINCIPAL (a.a)
-- Sistema core de la UI
--------------------------------------------------------------------
do
    function a.a()
        -- Servicios de Roblox
        local RunService = game:GetService('RunService')
        local UserInputService = game:GetService('UserInputService')
        local TweenService = game:GetService('TweenService')
        
        -- Cargar sistema de íconos
        local IconLoader = loadstring(game:HttpGetAsync(
            'https://raw.githubusercontent.com/cxnker/WindUI/main/WindUI_1.6.1/Main_Icon.lua'
        ))()
        IconLoader.SetIconsType('lucide')  -- Usar íconos tipo Lucide
        
        -- Configuración principal
        local UI = {
            Font = 'rbxassetid://12187365364',  -- Fuente personalizada
            CanDraggable = true,
            Theme = nil,
            Themes = nil,
            Objects = {},      -- Objetos con temas aplicados
            FontObjects = {},  -- Objetos que usan la fuente personalizada
            Request = http_request or (syn and syn.request) or request,
            
            -- Propiedades por defecto para elementos UI
            DefaultProperties = {
                ScreenGui = {
                    ResetOnSpawn = false,
                    ZIndexBehavior = 'Sibling'
                },
                CanvasGroup = {
                    BorderSizePixel = 0,
                    BackgroundColor3 = Color3.new(1, 1, 1)
                },
                Frame = {
                    BorderSizePixel = 0,
                    BackgroundColor3 = Color3.new(1, 1, 1)
                },
                TextLabel = {
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    Text = '',
                    RichText = true,
                    TextColor3 = Color3.new(1, 1, 1),
                    TextSize = 14
                },
                TextButton = {
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    Text = '',
                    AutoButtonColor = false,
                    TextColor3 = Color3.new(1, 1, 1),
                    TextSize = 14
                },
                TextBox = {
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderColor3 = Color3.new(0, 0, 0),
                    ClearTextOnFocus = false,
                    Text = '',
                    TextColor3 = Color3.new(0, 0, 0),
                    TextSize = 14
                },
                ImageLabel = {
                    BackgroundTransparency = 1,
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0
                },
                ImageButton = {
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    AutoButtonColor = false
                },
                UIListLayout = {
                    SortOrder = 'LayoutOrder'
                }
            },
            
            -- Colores predefinidos
            Colors = {
                Red = '#e53935',
                Orange = '#f57c00',
                Green = '#43a047',
                Blue = '#039be5',
                White = '#ffffff',
                Grey = '#484848'
            }
        }
        
        -- Cambiar tema
        function UI.SetTheme(themeName)
            UI.Theme = themeName
            UI.UpdateTheme(nil, true)  -- Actualizar con animación
        end
        
        -- Añadir objeto que usa fuente personalizada
        function UI.AddFontObject(obj)
            table.insert(UI.FontObjects, obj)
            UI.UpdateFont(UI.Font)
        end
        
        -- Actualizar fuente de todos los objetos
        function UI.UpdateFont(newFont)
            UI.Font = newFont
            for _, obj in next, UI.FontObjects do
                obj.FontFace = Font.new(newFont, obj.FontFace.Weight, obj.FontFace.Style)
            end
        end
        
        -- Obtener propiedad del tema
        function UI.GetThemeProperty(property, theme)
            return theme[property] or UI.Themes.Dark[property]
        end
        
        -- Añadir objeto que usa temas
        function UI.AddThemeObject(obj, properties)
            UI.Objects[obj] = {
                Object = obj,
                Properties = properties
            }
            UI.UpdateTheme(obj)
            return obj
        end
        
        -- Actualizar tema de objetos
        function UI.UpdateTheme(specificObject, animate)
            local function updateObject(objData)
                for property, themeProperty in pairs(objData.Properties or {}) do
                    local colorHex = UI.GetThemeProperty(themeProperty, UI.Theme)
                    if colorHex then
                        if not animate then
                            objData.Object[property] = Color3.fromHex(colorHex)
                        else
                            UI.Tween(objData.Object, 0.08, {
                                [property] = Color3.fromHex(colorHex)
                            }):Play()
                        end
                    end
                end
            end
            
            if specificObject then
                -- Actualizar objeto específico
                local objData = UI.Objects[specificObject]
                if objData then
                    updateObject(objData)
                end
            else
                -- Actualizar todos los objetos
                for _, objData in pairs(UI.Objects) do
                    updateObject(objData)
                end
            end
        end
        
        -- Obtener ícono
        function UI.Icon(iconName)
            return IconLoader.Icon(iconName)
        end
        
        -- Crear nuevo elemento UI
        function UI.New(className, properties, children)
            local instance = Instance.new(className)
            
            -- Aplicar propiedades por defecto
            for prop, value in next, UI.DefaultProperties[className] or {} do
                instance[prop] = value
            end
            
            -- Aplicar propiedades personalizadas
            for prop, value in next, properties or {} do
                if prop ~= 'ThemeTag' then
                    instance[prop] = value
                end
            end
            
            -- Añadir hijos
            for _, child in next, children or {} do
                child.Parent = instance
            end
            
            -- Configurar tema si existe
            if properties and properties.ThemeTag then
                UI.AddThemeObject(instance, properties.ThemeTag)
            end
            
            -- Configurar fuente si existe
            if properties and properties.FontFace then
                UI.AddFontObject(instance)
            end
            
            return instance
        end
        
        -- Crear tween
        function UI.Tween(obj, duration, properties, ...)
            return TweenService:Create(obj, TweenInfo.new(duration, ...), properties)
        end
        
        -- Crear frame con bordes redondeados (usando imágenes)
        function UI.NewRoundFrame(cornerRadius, imageType, properties, children, isButton)
            local frame = UI.New(isButton and 'ImageButton' or 'ImageLabel', {
                Image = imageType == 'Squircle' and 'rbxassetid://80999662900595' or
                        imageType == 'SquircleOutline' and 'rbxassetid://117788349049947' or
                        imageType == 'Shadow-sm' and 'rbxassetid://84825982946844' or
                        imageType == 'Squircle-TL-TR' and 'rbxassetid://73569156276236',
                ScaleType = 'Slice',
                SliceCenter = imageType ~= 'Shadow-sm' and Rect.new(256, 256, 256, 256) or Rect.new(512, 512, 512, 512),
                SliceScale = 1,
                BackgroundTransparency = 1,
                ThemeTag = properties.ThemeTag and properties.ThemeTag
            }, children)
            
            -- Aplicar propiedades adicionales
            for prop, value in pairs(properties or {}) do
                if prop ~= 'ThemeTag' then
                    frame[prop] = value
                end
            end
            
            -- Ajustar escala según radio
            local function updateScale(radius)
                local scale = imageType ~= 'Shadow-sm' and (radius / 256) or (radius / 512)
                frame.SliceScale = scale
            end
            updateScale(cornerRadius)
            
            return frame
        end
        
        -- Sistema de arrastre para ventanas
        function UI.Drag(mainObject, dragObjects, callback)
            local state = {
                CanDraggable = true
            }
            
            -- Si no se especifican objetos, usar el principal
            if not dragObjects or type(dragObjects) ~= 'table' then
                dragObjects = {mainObject}
            end
            
            local currentDragObject = nil
            local isDragging = false
            local startPosition = nil
            local startPos = nil
            local mouseMoveConnection = nil
            
            local function updatePosition(input)
                local delta = input.Position - startPosition
                UI.Tween(mainObject, 0.02, {
                    Position = UDim2.new(
                        startPos.X.Scale,
                        startPos.X.Offset + delta.X,
                        startPos.Y.Scale,
                        startPos.Y.Offset + delta.Y
                    )
                }):Play()
            end
            
            -- Conectar eventos de arrastre
            for _, obj in pairs(dragObjects) do
                obj.InputBegan:Connect(function(input)
                    if (input.UserInputType == Enum.UserInputType.MouseButton1 or 
                        input.UserInputType == Enum.UserInputType.Touch) and state.CanDraggable then
                        
                        if currentDragObject == nil then
                            currentDragObject = obj
                            isDragging = true
                            startPosition = input.Position
                            startPos = mainObject.Position
                            
                            if callback and type(callback) == 'function' then
                                callback(true, currentDragObject)
                            end
                            
                            input.Changed:Connect(function()
                                if input.UserInputState == Enum.UserInputState.End then
                                    isDragging = false
                                    currentDragObject = nil
                                    if callback and type(callback) == 'function' then
                                        callback(false, currentDragObject)
                                    end
                                end
                            end)
                        end
                    end
                end)
                
                obj.InputChanged:Connect(function(input)
                    if currentDragObject == obj and isDragging then
                        if input.UserInputType == Enum.UserInputType.MouseMovement or 
                           input.UserInputType == Enum.UserInputType.Touch then
                            mouseMoveConnection = input
                        end
                    end
                end)
            end
            
            -- Conectar movimiento del mouse
            RunService.InputChanged:Connect(function(input)
                if input == mouseMoveConnection and isDragging and currentDragObject ~= nil then
                    if state.CanDraggable then
                        updatePosition(input)
                    end
                end
            end)
            
            -- Función para habilitar/deshabilitar arrastre
            function state.Set(canDrag)
                state.CanDraggable = canDrag
            end
            
            return state
        end
        
        -- Crear imagen desde URL o asset
        function UI.Image(url, title, cornerRadius, folder, assetType, useTextColor)
            local container = UI.New('Frame', {
                Size = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1
            }, {
                UI.New('ImageLabel', {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    ScaleType = 'Crop',
                    ThemeTag = UI.Icon(url) and {ImageColor3 = useTextColor and 'Text'} or nil
                }, {
                    UI.New('UICorner', {CornerRadius = UDim.new(0, cornerRadius)})
                })
            })
            
            -- Si es un ícono predefinido
            if UI.Icon(url) then
                container.ImageLabel.Image = UI.Icon(url)[1]
                container.ImageLabel.ImageRectOffset = UI.Icon(url)[2].ImageRectPosition
                container.ImageLabel.ImageRectSize = UI.Icon(url)[2].ImageRectSize
            end
            
            -- Si es una URL
            if string.find(url, 'http') then
                local filePath = 'WindUI/' .. folder .. '/Assets/.' .. assetType .. '-' .. title .. '.png'
                local success, err = pcall(function()
                    if not isfile(filePath) then
                        local response = UI.Request{
                            Url = url,
                            Method = 'GET'
                        }.Body
                        writefile(filePath, response)
                    end
                    container.ImageLabel.Image = getcustomasset(filePath)
                end)
                
                if not success then
                    container:Destroy()
                    warn("[ WindUI.Creator ]  '" .. identifyexecutor() .. 
                         "' doesnt support the URL Images. Error: " .. err)
                end
                
            -- Si es un asset de Roblox
            elseif string.find(url, 'rbxassetid') then
                container.ImageLabel.Image = url
            end
            
            return container
        end
        
        return UI
    end
end

--------------------------------------------------------------------
-- MÓDULO DE TEMAS (a.b)
-- Temas predefinidos de la UI
--------------------------------------------------------------------
function a.b()
    return {
        Dark = {
            Name = 'Dark',
            Accent = '#18181b',
            Outline = '#FFFFFF',
            Text = '#FFFFFF',
            Placeholder = '#999999',
            Background = '#0e0e10',
            Button = '#52525b',
            Icon = '#a1a1aa'
        },
        Light = {
            Name = 'Light',
            Accent = '#FFFFFF',
            Outline = '#09090b',
            Text = '#000000',
            Placeholder = '#777777',
            Background = '#e4e4e7',
            Button = '#18181b',
            Icon = '#a1a1aa'
        },
        Rose = {
            Name = 'Rose',
            Accent = '#881337',
            Outline = '#FFFFFF',
            Text = '#FFFFFF',
            Placeholder = '#6B7280',
            Background = '#4c0519',
            Button = '#52525b',
            Icon = '#a1a1aa'
        },
        Plant = {
            Name = 'Plant',
            Accent = '#365314',
            Outline = '#FFFFFF',
            Text = '#e6ffe5',
            Placeholder = '#7d977d',
            Background = '#1a2e05',
            Button = '#52525b',
            Icon = '#a1a1aa'
        },
        Red = {
            Name = 'Red',
            Accent = '#7f1d1d',
            Outline = '#FFFFFF',
            Text = '#ffeded',
            Placeholder = '#977d7d',
            Background = '#450a0a',
            Button = '#52525b',
            Icon = '#a1a1aa'
        },
        Indigo = {
            Name = 'Indigo',
            Accent = '#312e81',
            Outline = '#FFFFFF',
            Text = '#ffeded',
            Placeholder = '#977d7d',
            Background = '#1e1b4b',
            Button = '#52525b',
            Icon = '#a1a1aa'
        }
    }
end

--------------------------------------------------------------------
-- MÓDULO DE RESALTADO DE SINTAXIS (a.c)
-- Para el elemento Code
--------------------------------------------------------------------
function a.c()
    local keywords = {
        lua = {'and', 'break', 'or', 'else', 'elseif', 'if', 'then', 'until', 
               'repeat', 'while', 'do', 'for', 'in', 'end', 'local', 'return', 
               'function', 'export'},
        rbx = {'game', 'workspace', 'script', 'math', 'string', 'table', 'task', 
               'wait', 'select', 'next', 'Enum', 'tick', 'assert', 'shared', 
               'loadstring', 'tonumber', 'tostring', 'type', 'typeof', 'unpack', 
               'Instance', 'CFrame', 'Vector3', 'Vector2', 'Color3', 'UDim', 
               'UDim2', 'Ray', 'BrickColor', 'OverlapParams', 'RaycastParams', 
               'Axes', 'Random', 'Region3', 'Rect', 'TweenInfo', 'collectgarbage', 
               'not', 'utf8', 'pcall', 'xpcall', '_G', 'setmetatable', 
               'getmetatable', 'os', 'pairs', 'ipairs'},
        operators = {'#', '+', '-', '*', '%', '/', '^', '=', '~', '=', '<', '>'}
    }
    
    -- Colores para diferentes tipos de tokens
    local colors = {
        numbers = Color3.fromHex('#FAB387'),
        boolean = Color3.fromHex('#FAB387'),
        operator = Color3.fromHex('#94E2D5'),
        lua = Color3.fromHex('#CBA6F7'),
        rbx = Color3.fromHex('#F38BA8'),
        str = Color3.fromHex('#A6E3A1'),
        comment = Color3.fromHex('#9399B2'),
        null = Color3.fromHex('#F38BA8'),
        call = Color3.fromHex('#89B4FA'),
        self_call = Color3.fromHex('#89B4FA'),
        local_property = Color3.fromHex('#CBA6F7')
    }
    
    -- Convertir listas a sets para búsqueda rápida
    local function listToSet(list)
        local set = {}
        for _, item in ipairs(list) do
            set[item] = true
        end
        return set
    end
    
    local luaSet = listToSet(keywords.lua)
    local rbxSet = listToSet(keywords.rbx)
    local operatorSet = listToSet(keywords.operators)
    
    -- Determinar color de un token
    local function getTokenColor(tokens, index)
        local token = tokens[index]
        
        -- Color por tipo
        if colors[token .. '_color'] then
            return colors[token .. '_color']
        end
        
        -- Números
        if tonumber(token) then
            return colors.numbers
        end
        
        -- nil
        if token == 'nil' then
            return colors.null
        end
        
        -- Comentarios
        if token:sub(1, 2) == '--' then
            return colors.comment
        end
        
        -- Operadores
        if operatorSet[token] then
            return colors.operator
        end
        
        -- Palabras clave de Lua
        if luaSet[token] then
            return colors.lua
        end
        
        -- Palabras clave de Roblox
        if rbxSet[token] then
            return colors.rbx
        end
        
        -- Strings
        if token:sub(1, 1) == '"' or token:sub(1, 1) == "'" then
            return colors.str
        end
        
        -- Booleanos
        if token == 'true' or token == 'false' then
            return colors.boolean
        end
        
        -- Llamadas a función
        if tokens[index + 1] == '(' then
            if tokens[index - 1] == ':' then
                return colors.self_call
            end
            return colors.call
        end
        
        -- Propiedades locales
        if tokens[index - 1] == '.' then
            if tokens[index - 2] == 'Enum' then
                return colors.rbx
            end
            return colors.local_property
        end
    end
    
    -- Función principal de resaltado
    local highlighter = {}
    
    function highlighter.run(code)
        local tokens = {}
        local currentToken = ''
        local inString = false
        local inComment = false
        local isMultiLineComment = false
        
        -- Tokenización
        for i = 1, #code do
            local char = code:sub(i, i)
            
            if inComment then
                if char == '\n' and not isMultiLineComment then
                    table.insert(tokens, currentToken)
                    table.insert(tokens, char)
                    currentToken = ''
                    inComment = false
                elseif code:sub(i-1, i) == ']]' and isMultiLineComment then
                    currentToken = currentToken .. ']'
                    table.insert(tokens, currentToken)
                    currentToken = ''
                    inComment = false
                    isMultiLineComment = false
                else
                    currentToken = currentToken .. char
                end
                
            elseif inString then
                if char == inString and code:sub(i-1, i-1) ~= '\\' or char == '\n' then
                    currentToken = currentToken .. char
                    inString = false
                else
                    currentToken = currentToken .. char
                end
                
            else
                if code:sub(i, i+1) == '--' then
                    table.insert(tokens, currentToken)
                    currentToken = '-'
                    inComment = true
                    isMultiLineComment = code:sub(i+2, i+3) == '[['
                    
                elseif char == '"' or char == "'" then
                    table.insert(tokens, currentToken)
                    currentToken = char
                    inString = char
                    
                elseif operatorSet[char] then
                    table.insert(tokens, currentToken)
                    table.insert(tokens, char)
                    currentToken = ''
                    
                elseif char:match('[%w_]') then
                    currentToken = currentToken .. char
                    
                else
                    table.insert(tokens, currentToken)
                    table.insert(tokens, char)
                    currentToken = ''
                end
            end
        end
        
        table.insert(tokens, currentToken)
        
        -- Aplicar colores
        local result = {}
        for i, token in ipairs(tokens) do
            local color = getTokenColor(tokens, i)
            if color then
                local escapedToken = token:gsub('<', '&lt;'):gsub('>', '&gt;')
                table.insert(result, string.format(
                    '<font color = "#%s">%s</font>',
                    color:ToHex(),
                    escapedToken
                ))
            else
                table.insert(result, token)
            end
        end
        
        return table.concat(result)
    end
    
    return highlighter
end

--------------------------------------------------------------------
-- MÓDULO DE ELEMENTOS BÁSICOS (a.d)
-- Botones, inputs, labels, toggles, checkboxes, scroll sliders, tooltips
--------------------------------------------------------------------
function a.d()
    local UserInputService = game:GetService('UserInputService')
    local TweenService = game:GetService('TweenService')
    local SyntaxHighlighter = a.load('c')
    local Core = a.load('a')
    local New = Core.New
    local Tween = Core.Tween
    
    local Elements = {}
    
    -- Crear botón
    function Elements.Button(title, icon, callback, variant, parent, popup)
        variant = variant or 'Primary'
        local cornerRadius = 10
        
        -- Ícono opcional
        local iconLabel
        if icon and icon ~= '' then
            iconLabel = New('ImageLabel', {
                Image = Core.Icon(icon)[1],
                ImageRectSize = Core.Icon(icon)[2].ImageRectSize,
                ImageRectOffset = Core.Icon(icon)[2].ImageRectPosition,
                Size = UDim2.new(0, 21, 0, 21),
                BackgroundTransparency = 1,
                ThemeTag = {ImageColor3 = 'Icon'}
            })
        end
        
        -- Botón principal
        local button = New('TextButton', {
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = 'X',
            Parent = parent,
            BackgroundTransparency = 1
        }, {
            Core.NewRoundFrame(cornerRadius, 'Squircle', {
                ThemeTag = {ImageColor3 = variant ~= 'White' and 'Button' or nil},
                ImageColor3 = variant == 'White' and Color3.new(1, 1, 1) or nil,
                Size = UDim2.new(1, 0, 1, 0),
                Name = 'Squircle',
                ImageTransparency = variant == 'Primary' and 0 or 
                                    variant == 'White' and 0 or 1
            }),
            Core.NewRoundFrame(cornerRadius, 'Squircle', {
                ImageColor3 = Color3.new(1, 1, 1),
                Size = UDim2.new(1, 0, 1, 0),
                Name = 'Special',
                ImageTransparency = variant == 'Secondary' and 0.95 or 1
            }),
            Core.NewRoundFrame(cornerRadius, 'Shadow-sm', {
                ImageColor3 = Color3.new(0, 0, 0),
                Size = UDim2.new(1, 3, 1, 3),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Name = 'Shadow',
                ImageTransparency = variant == 'Secondary' and 0 or 1
            }),
            Core.NewRoundFrame(cornerRadius, 'SquircleOutline', {
                ThemeTag = {ImageColor3 = variant ~= 'White' and 'Outline' or nil},
                Size = UDim2.new(1, 0, 1, 0),
                ImageColor3 = variant == 'White' and Color3.new(0, 0, 0) or nil,
                ImageTransparency = variant == 'Primary' and 0.95 or 0.85
            }),
            Core.NewRoundFrame(cornerRadius, 'Squircle', {
                Size = UDim2.new(1, 0, 1, 0),
                Name = 'Frame',
                ThemeTag = {ImageColor3 = variant ~= 'White' and 'Text' or nil},
                ImageColor3 = variant == 'White' and Color3.new(0, 0, 0) or nil,
                ImageTransparency = 1
            }, {
                New('UIPadding', {
                    PaddingLeft = UDim.new(0, 12),
                    PaddingRight = UDim.new(0, 12)
                }),
                New('UIListLayout', {
                    FillDirection = 'Horizontal',
                    Padding = UDim.new(0, 8),
                    VerticalAlignment = 'Center',
                    HorizontalAlignment = 'Center'
                }),
                iconLabel,
                New('TextLabel', {
                    BackgroundTransparency = 1,
                    FontFace = Font.new(Core.Font, Enum.FontWeight.SemiBold),
                    Text = title or 'Button',
                    ThemeTag = {TextColor3 = (variant ~= 'Primary' and variant ~= 'White') and 'Text'},
                    TextColor3 = variant == 'Primary' and Color3.new(1, 1, 1) or
                                 variant == 'White' and Color3.new(0, 0, 0) or nil,
                    AutomaticSize = 'XY',
                    TextSize = 18
                })
            })
        })
        
        -- Efectos hover
        button.MouseEnter:Connect(function()
            Tween(button.Frame, 0.047, {ImageTransparency = 0.95}):Play()
        end)
        
        button.MouseLeave:Connect(function()
            Tween(button.Frame, 0.047, {ImageTransparency = 1}):Play()
        end)
        
        -- Click
        button.MouseButton1Up:Connect(function()
            if popup then
                popup:Close()()
            end
            if callback then
                callback()
            end
        end)
        
        return button
    end
    
    -- Crear input
    function Elements.Input(placeholder, icon, parent, callback)
        local cornerRadius = 10
        
        -- Ícono opcional
        local iconLabel
        if icon and icon ~= '' then
            iconLabel = New('ImageLabel', {
                Image = Core.Icon(icon)[1],
                ImageRectSize = Core.Icon(icon)[2].ImageRectSize,
                ImageRectOffset = Core.Icon(icon)[2].ImageRectPosition,
                Size = UDim2.new(0, 21, 0, 21),
                BackgroundTransparency = 1,
                ThemeTag = {ImageColor3 = 'Icon'}
            })
        end
        
        -- Cuadro de texto
        local textBox = New('TextBox', {
            BackgroundTransparency = 1,
            TextSize = 18,
            FontFace = Font.new(Core.Font, Enum.FontWeight.Regular),
            Size = UDim2.new(1, icon and -29 or 0, 1, 0),
            PlaceholderText = placeholder,
            ClearTextOnFocus = false,
            ClipsDescendants = true,
            MultiLine = false,
            TextXAlignment = 'Left',
            ThemeTag = {
                PlaceholderColor3 = 'PlaceholderText',
                TextColor3 = 'Text'
            }
        })
        
        -- Contenedor
        local container = New('Frame', {
            Size = UDim2.new(1, 0, 0, 42),
            Parent = parent,
            BackgroundTransparency = 1
        }, {
            New('Frame', {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1
            }, {
                Core.NewRoundFrame(cornerRadius, 'Squircle', {
                    ThemeTag = {ImageColor3 = 'Accent'},
                    Size = UDim2.new(1, 0, 1, 0),
                    ImageTransparency = 0.45
                }),
                Core.NewRoundFrame(cornerRadius, 'SquircleOutline', {
                    ThemeTag = {ImageColor3 = 'Outline'},
                    Size = UDim2.new(1, 0, 1, 0),
                    ImageTransparency = 0.9
                }),
                Core.NewRoundFrame(cornerRadius, 'Squircle', {
                    Size = UDim2.new(1, 0, 1, 0),
                    Name = 'Frame',
                    ImageColor3 = Color3.new(1, 1, 1),
                    ImageTransparency = 0.95
                }, {
                    New('UIPadding', {
                        PaddingLeft = UDim.new(0, 12),
                        PaddingRight = UDim.new(0, 12)
                    }),
                    New('UIListLayout', {
                        FillDirection = 'Horizontal',
                        Padding = UDim.new(0, 8),
                        VerticalAlignment = 'Center',
                        HorizontalAlignment = 'Left'
                    }),
                    iconLabel,
                    textBox
                })
            })
        })
        
        -- Callback al perder foco
        textBox.FocusLost:Connect(function()
            if callback then
                callback(textBox.Text)
            end
        end)
        
        return container
    end
    
    -- Crear label (elemento de texto clickeable)
    function Elements.Label(text, icon, parent)
        local cornerRadius = 10
        
        -- Ícono opcional
        local iconLabel
        if icon and icon ~= '' then
            iconLabel = New('ImageLabel', {
                Image = Core.Icon(icon)[1],
                ImageRectSize = Core.Icon(icon)[2].ImageRectSize,
                ImageRectOffset = Core.Icon(icon)[2].ImageRectPosition,
                Size = UDim2.new(0, 21, 0, 21),
                BackgroundTransparency = 1,
                ThemeTag = {ImageColor3 = 'Icon'}
            })
        end
        
        -- Texto
        local textLabel = New('TextLabel', {
            BackgroundTransparency = 1,
            TextSize = 18,
            FontFace = Font.new(Core.Font, Enum.FontWeight.Regular),
            Size = UDim2.new(1, icon and -29 or 0, 1, 0),
            TextXAlignment = 'Left',
            ThemeTag = {TextColor3 = 'Text'},
            Text = text
        })
        
        -- Botón clickeable
        local button = New('TextButton', {
            Size = UDim2.new(1, 0, 0, 42),
            Parent = parent,
            BackgroundTransparency = 1,
            Text = ''
        }, {
            New('Frame', {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1
            }, {
                Core.NewRoundFrame(cornerRadius, 'Squircle', {
                    ThemeTag = {ImageColor3 = 'Accent'},
                    Size = UDim2.new(1, 0, 1, 0),
                    ImageTransparency = 0.45
                }),
                Core.NewRoundFrame(cornerRadius, 'SquircleOutline', {
                    ThemeTag = {ImageColor3 = 'Outline'},
                    Size = UDim2.new(1, 0, 1, 0),
                    ImageTransparency = 0.9
                }),
                Core.NewRoundFrame(cornerRadius, 'Squircle', {
                    Size = UDim2.new(1, 0, 1, 0),
                    Name = 'Frame',
                    ImageColor3 = Color3.new(1, 1, 1),
                    ImageTransparency = 0.95
                }, {
                    New('UIPadding', {
                        PaddingLeft = UDim.new(0, 12),
                        PaddingRight = UDim.new(0, 12)
                    }),
                    New('UIListLayout', {
                        FillDirection = 'Horizontal',
                        Padding = UDim.new(0, 8),
                        VerticalAlignment = 'Center',
                        HorizontalAlignment = 'Left'
                    }),
                    iconLabel,
                    textLabel
                })
            })
        })
        
        return button
    end
    
    -- Crear toggle
    function Elements.Toggle(title, icon, parent, callback)
        local state = {}
        local cornerRadius = 13
        
        -- Ícono opcional
        local iconLabel
        if icon and icon ~= '' then
            iconLabel = New('ImageLabel', {
                Size = UDim2.new(1, -7, 1, -7),
                BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Image = Core.Icon(icon)[1],
                ImageRectOffset = Core.Icon(icon)[2].ImageRectPosition,
                ImageRectSize = Core.Icon(icon)[2].ImageRectSize,
                ImageTransparency = 1,
                ImageColor3 = Color3.new(0, 0, 0)
            })
        end
        
        -- Marco del toggle
        local frame = Core.NewRoundFrame(cornerRadius, 'Squircle', {
            ImageTransparency = 0.95,
            ThemeTag = {ImageColor3 = 'Text'},
            Parent = parent,
            Size = UDim2.new(0, 42, 0, 26)
        }, {
            Core.NewRoundFrame(cornerRadius, 'Squircle', {
                Size = UDim2.new(1, 0, 1, 0),
                Name = 'Layer',
                ThemeTag = {ImageColor3 = 'Button'},
                ImageTransparency = 1
            }),
            Core.NewRoundFrame(cornerRadius, 'SquircleOutline', {
                Size = UDim2.new(1, 0, 1, 0),
                Name = 'Stroke',
                ImageColor3 = Color3.new(1, 1, 1),
                ImageTransparency = 1
            }, {
                New('UIGradient', {
                    Rotation = 90,
                    Transparency = NumberSequence.new{
                        NumberSequenceKeypoint.new(0, 0),
                        NumberSequenceKeypoint.new(1, 1)
                    }
                })
            }),
            Core.NewRoundFrame(cornerRadius, 'Squircle', {
                Size = UDim2.new(0, 18, 0, 18),
                Position = UDim2.new(0, 3, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                ImageTransparency = 0,
                ImageColor3 = Color3.new(1, 1, 1),
                Name = 'Frame'
            }, {
                iconLabel
            })
        })
        
        -- Función para establecer estado
        function state.Set(newState)
            if newState then
                -- Activar
                Tween(frame.Frame, 0.1, {
                    Position = UDim2.new(1, -22, 0.5, 0)
                }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
                
                Tween(frame.Layer, 0.1, {ImageTransparency = 0}):Play()
                Tween(frame.Stroke, 0.1, {ImageTransparency = 0.95}):Play()
                
                if iconLabel then
                    Tween(iconLabel, 0.1, {ImageTransparency = 0}):Play()
                end
                
            else
                -- Desactivar
                Tween(frame.Frame, 0.1, {
                    Position = UDim2.new(0, 4, 0.5, 0),
                    Size = UDim2.new(0, 18, 0, 18)
                }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
                
                Tween(frame.Layer, 0.1, {ImageTransparency = 1}):Play()
                Tween(frame.Stroke, 0.1, {ImageTransparency = 1}):Play()
                
                if iconLabel then
                    Tween(iconLabel, 0.1, {ImageTransparency = 1}):Play()
                end
            end
            
            task.spawn(function()
                if callback then
                    callback(newState)
                end
            end)
        end
        
        return frame, state
    end
    
    -- Crear checkbox
    function Elements.Checkbox(title, icon, parent, callback)
        local state = {}
        icon = icon or 'check'
        local cornerRadius = 10
        
        -- Ícono
        local iconLabel = New('ImageLabel', {
            Size = UDim2.new(1, -10, 1, -10),
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Image = Core.Icon(icon)[1],
            ImageRectOffset = Core.Icon(icon)[2].ImageRectPosition,
            ImageRectSize = Core.Icon(icon)[2].ImageRectSize,
            ImageTransparency = 1,
            ImageColor3 = Color3.new(1, 1, 1)
        })
        
        -- Marco
        local frame = Core.NewRoundFrame(cornerRadius, 'Squircle', {
            ImageTransparency = 0.95,
            ThemeTag = {ImageColor3 = 'Text'},
            Parent = parent,
            Size = UDim2.new(0, 27, 0, 27)
        }, {
            Core.NewRoundFrame(cornerRadius, 'Squircle', {
                Size = UDim2.new(1, 0, 1, 0),
                Name = 'Layer',
                ThemeTag = {ImageColor3 = 'Button'},
                ImageTransparency = 1
            }),
            Core.NewRoundFrame(cornerRadius, 'SquircleOutline', {
                Size = UDim2.new(1, 0, 1, 0),
                Name = 'Stroke',
                ImageColor3 = Color3.new(1, 1, 1),
                ImageTransparency = 1
            }, {
                New('UIGradient', {
                    Rotation = 90,
                    Transparency = NumberSequence.new{
                        NumberSequenceKeypoint.new(0, 0),
                        NumberSequenceKeypoint.new(1, 1)
                    }
                })
            }),
            iconLabel
        })
        
        -- Función para establecer estado
        function state.Set(newState)
            if newState then
                Tween(frame.Layer, 0.06, {ImageTransparency = 0}):Play()
                Tween(frame.Stroke, 0.06, {ImageTransparency = 0.95}):Play()
                Tween(iconLabel, 0.06, {ImageTransparency = 0}):Play()
            else
                Tween(frame.Layer, 0.05, {ImageTransparency = 1}):Play()
                Tween(frame.Stroke, 0.05, {ImageTransparency = 1}):Play()
                Tween(iconLabel, 0.06, {ImageTransparency = 1}):Play()
            end
            
            task.spawn(function()
                if callback then
                    callback(newState)
                end
            end)
        end
        
        return frame, state
    end
    
    -- Crear scroll slider (barra de desplazamiento)
    function Elements.ScrollSlider(scrollingFrame, parent, padding, width)
        -- Marco de la barra
        local sliderFrame = New('Frame', {
            Size = UDim2.new(0, width, 1, -padding.UIPadding * 2),
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -padding.UIPadding / 3, 0, padding.UIPadding),
            AnchorPoint = Vector2.new(1, 0),
            Parent = parent,
            ZIndex = 999,
            Active = true
        })
        
        -- Barra deslizante
        local slider = Core.NewRoundFrame(width / 2, 'Squircle', {
            Size = UDim2.new(1, 0, 0, 0),
            ImageTransparency = 0.85,
            ThemeTag = {ImageColor3 = 'Text'},
            Parent = sliderFrame
        })
        
        -- Área de arrastre
        local dragArea = New('Frame', {
            Size = UDim2.new(1, 12, 1, 12),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Active = true,
            ZIndex = 999,
            Parent = slider
        })
        
        -- Funciones de actualización
        local function updateSliderSize()
            local canvasSize = scrollingFrame.AbsoluteCanvasSize.Y
            local windowSize = scrollingFrame.AbsoluteWindowSize.Y
            local ratio = math.clamp(windowSize / math.max(canvasSize, 1), 0, 1)
            
            slider.Size = UDim2.new(1, 0, ratio, 0)
            slider.Visible = ratio < 1 and canvasSize > windowSize
        end
        
        local function updatePositionFromSlider()
            local sliderPos = slider.Position.Y.Scale
            local maxScroll = math.max(scrollingFrame.AbsoluteCanvasSize.Y - scrollingFrame.AbsoluteWindowSize.Y, 1)
            local availableSpace = 1 - slider.Size.Y.Scale
            local targetScroll = sliderPos / availableSpace
            
            scrollingFrame.CanvasPosition = Vector2.new(
                scrollingFrame.CanvasPosition.X,
                targetScroll * maxScroll
            )
        end
        
        local function updateSliderFromPosition()
            local currentScroll = scrollingFrame.CanvasPosition.Y
            local maxScroll = math.max(scrollingFrame.AbsoluteCanvasSize.Y - scrollingFrame.AbsoluteWindowSize.Y, 1)
            local ratio, availableSpace = currentScroll / maxScroll, 1 - slider.Size.Y.Scale
            
            ratio = math.clamp(ratio, 0, availableSpace)
            slider.Position = UDim2.new(0, 0, ratio, 0)
        end
        
        -- Eventos
        sliderFrame.InputBegan:Connect(function(input)
            if (input.UserInputType == Enum.UserInputType.MouseButton1 or 
                input.UserInputType == Enum.UserInputType.Touch) and 
                not (input.Position.Y >= slider.AbsolutePosition.Y and 
                     input.Position.Y <= slider.AbsolutePosition.Y + slider.AbsoluteSize.Y) then
                
                local totalHeight = sliderFrame.AbsoluteSize.Y - slider.AbsoluteSize.Y
                local framePos = sliderFrame.AbsolutePosition.Y
                local sliderHalf = slider.AbsoluteSize.Y / 2
                
                local newPos = (input.Position.Y - framePos - sliderHalf) / totalHeight
                local maxPos = 1 - slider.Size.Y.Scale
                newPos = math.clamp(newPos, 0, maxPos)
                
                slider.Position = UDim2.new(0, 0, newPos, 0)
                updatePositionFromSlider()
            end
        end)
        
        dragArea.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or 
               input.UserInputType == Enum.UserInputType.Touch then
                
                local dragStart = (input.Position.Y - slider.AbsolutePosition.Y)
                
                local dragConnection
                local endConnection
                
                dragConnection = UserInputService.InputChanged:Connect(function(moveInput)
                    if moveInput.UserInputType == Enum.UserInputType.MouseMovement or 
                       moveInput.UserInputType == Enum.UserInputType.Touch then
                        
                        local totalHeight = sliderFrame.AbsoluteSize.Y - slider.AbsoluteSize.Y
                        local framePos = sliderFrame.AbsolutePosition.Y
                        local newPos = (moveInput.Position.Y - framePos - dragStart) / totalHeight
                        local maxPos = 1 - slider.Size.Y.Scale
                        
                        newPos = math.clamp(newPos, 0, maxPos)
                        slider.Position = UDim2.new(0, 0, newPos, 0)
                        updatePositionFromSlider()
                    end
                end)
                
                endConnection = UserInputService.InputEnded:Connect(function(endInput)
                    if endInput.UserInputType == Enum.UserInputType.MouseButton1 or 
                       endInput.UserInputType == Enum.UserInputType.Touch then
                        
                        if dragConnection then
                            dragConnection:Disconnect()
                        end
                        if endConnection then
                            endConnection:Disconnect()
                        end
                    end
                end)
            end
        end)
        
        -- Conectar señales de cambio
        scrollingFrame:GetPropertyChangedSignal('AbsoluteWindowSize'):Connect(updateSliderSize)
        updateSliderSize()
        updateSliderFromPosition()
        
        scrollingFrame:GetPropertyChangedSignal('CanvasPosition'):Connect(function()
            updateSliderFromPosition()
        end)
        
        return sliderFrame
    end
    
    -- Crear tooltip
    function Elements.ToolTip(text, parent)
        local tooltip = {
            Container = nil,
            ToolTipSize = 16
        }
        
        -- Etiqueta de texto
        local textLabel = New('TextLabel', {
            AutomaticSize = 'XY',
            TextWrapped = true,
            BackgroundTransparency = 1,
            FontFace = Font.new(Core.Font, Enum.FontWeight.Medium),
            Text = text,
            TextSize = 17,
            ThemeTag = {TextColor3 = 'Text'}
        })
        
        -- Escala
        local scale = New('UIScale', {Scale = 0.9})
        
        -- Contenedor principal
        local container = New('CanvasGroup', {
            AnchorPoint = Vector2.new(0.5, 0),
            AutomaticSize = 'XY',
            BackgroundTransparency = 1,
            Parent = parent,
            GroupTransparency = 1,
            Visible = false
        }, {
            New('UISizeConstraint', {MaxSize = Vector2.new(400, math.huge)}),
            New('Frame', {
                AutomaticSize = 'XY',
                BackgroundTransparency = 1,
                LayoutOrder = 99,
                Visible = false
            }, {
                New('ImageLabel', {
                    Size = UDim2.new(0, tooltip.ToolTipSize, 0, tooltip.ToolTipSize / 2),
                    BackgroundTransparency = 1,
                    Rotation = 180,
                    Image = 'rbxassetid://89524607682719',
                    ThemeTag = {ImageColor3 = 'Accent'}
                }, {
                    New('ImageLabel', {
                        Size = UDim2.new(0, tooltip.ToolTipSize, 0, tooltip.ToolTipSize / 2),
                        BackgroundTransparency = 1,
                        LayoutOrder = 99,
                        ImageTransparency = 0.9,
                        Image = 'rbxassetid://89524607682719',
                        ThemeTag = {ImageColor3 = 'Text'}
                    })
                })
            }),
            New('Frame', {
                AutomaticSize = 'XY',
                ThemeTag = {BackgroundColor3 = 'Accent'}
            }, {
                New('UICorner', {CornerRadius = UDim.new(0, 16)}),
                New('Frame', {
                    ThemeTag = {BackgroundColor3 = 'Text'},
                    AutomaticSize = 'XY',
                    BackgroundTransparency = 0.9
                }, {
                    New('UICorner', {CornerRadius = UDim.new(0, 16)}),
                    New('UIListLayout', {
                        Padding = UDim.new(0, 12),
                        FillDirection = 'Horizontal',
                        VerticalAlignment = 'Center'
                    }),
                    textLabel,
                    New('UIPadding', {
                        PaddingTop = UDim.new(0, 12),
                        PaddingLeft = UDim.new(0, 12),
                        PaddingRight = UDim.new(0, 12),
                        PaddingBottom = UDim.new(0, 12)
                    })
                })
            }),
            scale,
            New('UIListLayout', {
                Padding = UDim.new(0, 0),
                FillDirection = 'Vertical',
                VerticalAlignment = 'Center',
                HorizontalAlignment = 'Center'
            })
        })
        
        tooltip.Container = container
        
        -- Abrir tooltip
        function tooltip.Open()
            container.Visible = true
            Tween(container, 0.16, {GroupTransparency = 0}, 
                  Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
            Tween(scale, 0.18, {Scale = 1}, 
                  Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
        end
        
        -- Cerrar tooltip
        function tooltip.Close()
            Tween(container, 0.2, {GroupTransparency = 1}, 
                  Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
            Tween(scale, 0.2, {Scale = 0.9}, 
                  Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
            task.wait(0.25)
            container.Visible = false
            container:Destroy()
        end
        
        return tooltip
    end
    
    -- Crear editor de código
    function Elements.Code(code, title, parent, onCopy)
        local config = {
            Radius = 12,
            Padding = 10
        }
        
        -- Etiqueta de código
        local codeLabel = New('TextLabel', {
            Text = '',
            TextColor3 = Color3.fromHex('#CDD6F4'),
            TextTransparency = 0,
            TextSize = 14,
            TextWrapped = false,
            LineHeight = 1.15,
            RichText = true,
            TextXAlignment = 'Left',
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            AutomaticSize = 'XY'
        }, {
            New('UIPadding', {
                PaddingTop = UDim.new(0, config.Padding + 3),
                PaddingLeft = UDim.new(0, config.Padding + 3),
                PaddingRight = UDim.new(0, config.Padding + 3),
                PaddingBottom = UDim.new(0, config.Padding + 3)
            })
        })
        codeLabel.Font = 'Code'
        
        -- Scrolling frame
        local scrollingFrame = New('ScrollingFrame', {
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1,
            AutomaticCanvasSize = 'X',
            ScrollingDirection = 'X',
            ElasticBehavior = 'Never',
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 0
        }, {
            codeLabel
        })
        
        -- Botón de copiar
        local copyButton = New('TextButton', {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 30, 0, 30),
            Position = UDim2.new(1, -config.Padding / 2, 0, config.Padding / 2),
            AnchorPoint = Vector2.new(1, 0),
            Visible = onCopy and true or false
        }, {
            Core.NewRoundFrame(config.Radius - 4, 'Squircle', {
                ImageColor3 = Color3.fromHex('#ffffff'),
                ImageTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Name = 'Button'
            }, {
                New('UIScale', {Scale = 1}),
                New('ImageLabel', {
                    Image = Core.Icon('copy')[1],
                    ImageRectSize = Core.Icon('copy')[2].ImageRectSize,
                    ImageRectOffset = Core.Icon('copy')[2].ImageRectPosition,
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    Size = UDim2.new(0, 12, 0, 12),
                    ImageColor3 = Color3.fromHex('#ffffff'),
                    ImageTransparency = 0.1
                })
            })
        })
        
        -- Efectos hover
        copyButton.MouseEnter:Connect(function()
            Tween(copyButton.Button, 0.05, {ImageTransparency = 0.95}):Play()
            Tween(copyButton.Button.UIScale, 0.05, {Scale = 0.9}):Play()
        end)
        
        copyButton.InputEnded:Connect(function()
            Tween(copyButton.Button, 0.08, {ImageTransparency = 1}):Play()
            Tween(copyButton.Button.UIScale, 0.08, {Scale = 1}):Play()
        end)
        
        -- Marco principal
        Core.NewRoundFrame(config.Radius, 'Squircle', {
            ImageColor3 = Color3.fromHex('#212121'),
            ImageTransparency = 0.035,
            Size = UDim2.new(1, 0, 0, 20 + (config.Padding * 2)),
            AutomaticSize = 'Y',
            Parent = parent
        }, {
            Core.NewRoundFrame(config.Radius, 'SquircleOutline', {
                Size = UDim2.new(1, 0, 1, 0),
                ImageColor3 = Color3.fromHex('#ffffff'),
                ImageTransparency = 0.955
            }),
            New('Frame', {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = 'Y'
            }, {
                Core.NewRoundFrame(config.Radius, 'Squircle-TL-TR', {
                    ImageColor3 = Color3.fromHex('#ffffff'),
                    ImageTransparency = 0.96,
                    Size = UDim2.new(1, 0, 0, 20 + (config.Padding * 2)),
                    Visible = title and true or false
                }, {
                    New('ImageLabel', {
                        Size = UDim2.new(0, 18, 0, 18),
                        BackgroundTransparency = 1,
                        Image = 'rbxassetid://132464694294269',
                        ImageColor3 = Color3.fromHex('#ffffff'),
                        ImageTransparency = 0.2
                    }),
                    New('TextLabel', {
                        Text = title,
                        TextColor3 = Color3.fromHex('#ffffff'),
                        TextTransparency = 0.2,
                        TextSize = 16,
                        AutomaticSize = 'Y',
                        FontFace = Font.new(Core.Font, Enum.FontWeight.Medium),
                        TextXAlignment = 'Left',
                        BackgroundTransparency = 1,
                        TextTruncate = 'AtEnd',
                        Size = UDim2.new(1, copyButton and -20 - (config.Padding * 2), 0, 0)
                    }),
                    New('UIPadding', {
                        PaddingLeft = UDim.new(0, config.Padding + 3),
                        PaddingRight = UDim.new(0, config.Padding + 3)
                    }),
                    New('UIListLayout', {
                        Padding = UDim.new(0, config.Padding),
                        FillDirection = 'Horizontal',
                        VerticalAlignment = 'Center'
                    })
                }),
                scrollingFrame,
                New('UIListLayout', {
                    Padding = UDim.new(0, 0),
                    FillDirection = 'Vertical'
                })
            }),
            copyButton
        })
        
        -- Actualizar tamaño
        codeLabel:GetPropertyChangedSignal('TextBounds'):Connect(function()
            scrollingFrame.Size = UDim2.new(
                1, 0,
                0, codeLabel.TextBounds.Y + ((config.Padding + 3) * 2)
            )
        end)
        
        -- Establecer código
        local codeElement = {}
        function codeElement.Set(newCode)
            codeLabel.Text = SyntaxHighlighter.run(newCode)
        end
        codeElement.Set(code)
        
        -- Copiar al portapapeles
        copyButton.MouseButton1Click:Connect(function()
            if onCopy then
                onCopy()
                local checkIcon = Core.Icon('check')
                copyButton.Button.ImageLabel.Image = checkIcon[1]
                copyButton.Button.ImageLabel.ImageRectSize = checkIcon[2].ImageRectSize
                copyButton.Button.ImageLabel.ImageRectOffset = checkIcon[2].ImageRectPosition
            end
        end)
        
        return codeElement
    end
    
    return Elements
end
--------------------------------------------------------------------
-- MÓDULO DE POPUPS (a.e)
-- Sistema para crear ventanas emergentes modales
--------------------------------------------------------------------
function a.e()
    local Core = a.load('a')
    local New = Core.New
    local Tween = Core.Tween
    
    local PopupSystem = {
        UICorner = 14,
        UIPadding = 12,
        Holder = nil,
        Window = nil
    }
    
    -- Inicializar sistema
    function PopupSystem.Init(window)
        PopupSystem.Window = window
        return PopupSystem
    end
    
    -- Crear nuevo popup
    function PopupSystem.Create(isFullScreen)
        local popup = {
            UICorner = 19,
            UIPadding = 16,
            UIElements = {}
        }
        
        -- Ajustes según tipo
        if isFullScreen then
            popup.UIPadding = 0
            popup.UICorner = 22
            
            -- Fondo oscuro para popup fullscreen
            popup.UIElements.FullScreen = New('Frame', {
                ZIndex = 999,
                BackgroundTransparency = 1,
                BackgroundColor3 = Color3.fromHex('#2a2a2a'),
                Size = UDim2.new(1, 0, 1, 0),
                Active = false,
                Visible = false,
                Parent = isFullScreen and PopupSystem.Window or 
                         PopupSystem.Window.UIElements.Main.Main
            }, {
                New('UICorner', {
                    CornerRadius = UDim.new(0, PopupSystem.Window.UICorner)
                })
            })
        end
        
        -- Contenedor principal
        popup.UIElements.Main = New('Frame', {
            ThemeTag = {BackgroundColor3 = 'Accent'},
            AutomaticSize = 'XY',
            BackgroundTransparency = 1,
            Visible = false,
            ZIndex = 99999
        }, {
            New('UIPadding', {
                PaddingTop = UDim.new(0, popup.UIPadding),
                PaddingLeft = UDim.new(0, popup.UIPadding),
                PaddingRight = UDim.new(0, popup.UIPadding),
                PaddingBottom = UDim.new(0, popup.UIPadding)
            })
        })
        
        -- Contenedor con bordes redondeados
        popup.UIElements.MainContainer = Core.NewRoundFrame(
            popup.UICorner, 'Squircle', {
                Visible = false,
                ImageTransparency = isFullScreen and 0.15 or 0,
                Parent = isFullScreen and PopupSystem.Window or popup.UIElements.FullScreen,
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                AutomaticSize = 'XY',
                ThemeTag = {ImageColor3 = 'Accent'},
                ZIndex = 9999
            }, {
                popup.UIElements.Main,
                New('UIScale', {Scale = 0.9}),
                Core.NewRoundFrame(popup.UICorner, 'SquircleOutline', {
                    Size = UDim2.new(1, 0, 1, 0),
                    ImageTransparency = 0.9,
                    ThemeTag = {ImageColor3 = 'Outline'}
                }, {
                    New('UIGradient', {
                        Rotation = 90,
                        Transparency = NumberSequence.new{
                            NumberSequenceKeypoint.new(0, 0),
                            NumberSequenceKeypoint.new(1, 1)
                        }
                    })
                })
            }
        )
        
        -- Función para abrir popup
        function popup.Open()
            if not isFullScreen then
                popup.UIElements.FullScreen.Visible = true
                popup.UIElements.FullScreen.Active = true
            end
            
            task.spawn(function()
                popup.UIElements.MainContainer.Visible = true
                
                if not isFullScreen then
                    Tween(popup.UIElements.FullScreen, 0.1, {
                        BackgroundTransparency = 0.5
                    }):Play()
                end
                
                Tween(popup.UIElements.MainContainer, 0.1, {
                    ImageTransparency = 0
                }):Play()
                
                Tween(popup.UIElements.MainContainer.UIScale, 0.1, {
                    Scale = 1
                }):Play()
                
                task.spawn(function()
                    task.wait(0.05)
                    popup.UIElements.Main.Visible = true
                end)
            end)
        end
        
        -- Función para cerrar popup
        function popup.Close()
            if not isFullScreen then
                Tween(popup.UIElements.FullScreen, 0.1, {
                    BackgroundTransparency = 1
                }):Play()
                popup.UIElements.FullScreen.Active = false
                
                task.spawn(function()
                    task.wait(0.1)
                    popup.UIElements.FullScreen.Visible = false
                end)
            end
            
            popup.UIElements.Main.Visible = false
            
            Tween(popup.UIElements.MainContainer, 0.1, {
                ImageTransparency = 1
            }):Play()
            
            Tween(popup.UIElements.MainContainer.UIScale, 0.1, {
                Scale = 0.9
            }):Play()
            
            task.spawn(function()
                task.wait(0.1)
                if not isFullScreen then
                    popup.UIElements.FullScreen:Destroy()
                else
                    popup.UIElements.MainContainer:Destroy()
                end
            end)
            
            return function() end
        end
        
        return popup
    end
    
    return PopupSystem
end

--------------------------------------------------------------------
-- MÓDULO DE NOTIFICACIONES (a.g)
-- Sistema para mostrar notificaciones emergentes
--------------------------------------------------------------------
function a.g()
    local Core = a.load('a')
    local New = Core.New
    local Tween = Core.Tween
    
    local NotificationSystem = {
        Size = UDim2.new(0, 300, 1, -156),
        SizeLower = UDim2.new(0, 300, 1, -56),
        UICorner = 16,
        UIPadding = 14,
        ButtonPadding = 9,
        Holder = nil,
        NotificationIndex = 0,
        Notifications = {}
    }
    
    -- Inicializar sistema
    function NotificationSystem.Init(parent)
        local holder = {
            Lower = false
        }
        
        function holder.SetLower(newState)
            holder.Lower = newState
            holder.Frame.Size = newState and NotificationSystem.SizeLower or NotificationSystem.Size
        end
        
        holder.Frame = New('Frame', {
            Position = UDim2.new(1, -29, 0, 56),
            AnchorPoint = Vector2.new(1, 0),
            Size = NotificationSystem.Size,
            Parent = parent,
            BackgroundTransparency = 1
        }, {
            New('UIListLayout', {
                HorizontalAlignment = 'Center',
                SortOrder = 'LayoutOrder',
                VerticalAlignment = 'Bottom',
                Padding = UDim.new(0, 8)
            }),
            New('UIPadding', {
                PaddingBottom = UDim.new(0, 29)
            })
        })
        
        return holder
    end
    
    -- Crear nueva notificación
    function NotificationSystem.New(config)
        local notification = {
            Title = config.Title or 'Notification',
            Content = config.Content or nil,
            Icon = config.Icon or nil,
            Background = config.Background,
            Duration = config.Duration or 5,
            Buttons = config.Buttons or {},
            CanClose = true,
            UIElements = {},
            Closed = false
        }
        
        if notification.CanClose == nil then
            notification.CanClose = true
        end
        
        NotificationSystem.NotificationIndex = NotificationSystem.NotificationIndex + 1
        NotificationSystem.Notifications[NotificationSystem.NotificationIndex] = notification
        
        -- Elementos UI
        local uiCorner = New('UICorner', {CornerRadius = UDim.new(0, NotificationSystem.UICorner)})
        local uiStroke = New('UIStroke', {
            ThemeTag = {Color = 'Text'},
            Transparency = 1,
            Thickness = 0.6
        })
        
        -- Ícono
        local iconLabel
        if notification.Icon then
            if Core.Icon(notification.Icon) and Core.Icon(notification.Icon)[2] then
                iconLabel = New('ImageLabel', {
                    Size = UDim2.new(0, 26, 0, 26),
                    Position = UDim2.new(0, NotificationSystem.UIPadding, 0, NotificationSystem.UIPadding),
                    BackgroundTransparency = 1,
                    Image = Core.Icon(notification.Icon)[1],
                    ImageRectSize = Core.Icon(notification.Icon)[2].ImageRectSize,
                    ImageRectOffset = Core.Icon(notification.Icon)[2].ImageRectPosition,
                    ThemeTag = {ImageColor3 = 'Text'}
                })
            elseif string.find(notification.Icon, 'rbxassetid') then
                iconLabel = New('ImageLabel', {
                    Size = UDim2.new(0, 26, 0, 26),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, NotificationSystem.UIPadding, 0, NotificationSystem.UIPadding),
                    Image = notification.Icon
                })
            end
        end
        
        -- Botón de cerrar
        local closeButton
        if notification.CanClose then
            closeButton = New('ImageButton', {
                Image = Core.Icon('x')[1],
                ImageRectSize = Core.Icon('x')[2].ImageRectSize,
                ImageRectOffset = Core.Icon('x')[2].ImageRectPosition,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(1, -NotificationSystem.UIPadding, 0, NotificationSystem.UIPadding),
                AnchorPoint = Vector2.new(1, 0),
                ThemeTag = {ImageColor3 = 'Text'}
            }, {
                New('TextButton', {
                    Size = UDim2.new(1, 8, 1, 8),
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    Text = ''
                })
            })
        end
        
        -- Barra de progreso
        local progressBar = New('Frame', {
            Size = UDim2.new(1, 0, 0, 3),
            BackgroundTransparency = 0.9,
            ThemeTag = {BackgroundColor3 = 'Text'}
        })
        
        -- Contenedor de texto
        local textContainer = New('Frame', {
            Size = UDim2.new(1, notification.Icon and -28 - NotificationSystem.UIPadding or 0, 1, 0),
            Position = UDim2.new(1, 0, 0, 0),
            AnchorPoint = Vector2.new(1, 0),
            BackgroundTransparency = 1,
            AutomaticSize = 'Y'
        }, {
            New('UIPadding', {
                PaddingTop = UDim.new(0, NotificationSystem.UIPadding),
                PaddingLeft = UDim.new(0, NotificationSystem.UIPadding),
                PaddingRight = UDim.new(0, NotificationSystem.UIPadding),
                PaddingBottom = UDim.new(0, NotificationSystem.UIPadding)
            }),
            New('TextLabel', {
                AutomaticSize = 'Y',
                Size = UDim2.new(1, -30 - NotificationSystem.UIPadding, 0, 0),
                TextWrapped = true,
                TextXAlignment = 'Left',
                RichText = true,
                BackgroundTransparency = 1,
                TextSize = 16,
                ThemeTag = {TextColor3 = 'Text'},
                Text = notification.Title,
                FontFace = Font.new(Core.Font, Enum.FontWeight.SemiBold)
            }),
            New('UIListLayout', {
                Padding = UDim.new(0, NotificationSystem.UIPadding / 3)
            })
        })
        
        -- Añadir contenido si existe
        if notification.Content then
            New('TextLabel', {
                AutomaticSize = 'Y',
                Size = UDim2.new(1, 0, 0, 0),
                TextWrapped = true,
                TextXAlignment = 'Left',
                RichText = true,
                BackgroundTransparency = 1,
                TextTransparency = 0.4,
                TextSize = 15,
                ThemeTag = {TextColor3 = 'Text'},
                Text = notification.Content,
                FontFace = Font.new(Core.Font, Enum.FontWeight.Medium),
                Parent = textContainer
            })
        end
        
        -- Contenedor principal
        local canvasGroup = New('CanvasGroup', {
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(2, 0, 1, 0),
            AnchorPoint = Vector2.new(0, 1),
            AutomaticSize = 'Y',
            BackgroundTransparency = 0.25,
            ThemeTag = {BackgroundColor3 = 'Accent'}
        }, {
            New('ImageLabel', {
                Name = 'Background',
                Image = notification.Background,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                ScaleType = 'Crop'
            }),
            uiStroke,
            uiCorner,
            textContainer,
            iconLabel,
            closeButton,
            progressBar
        })
        
        -- Marco exterior
        local outerFrame = New('Frame', {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            Parent = NotificationSystem.Holder.Frame
        }, {
            canvasGroup
        })
        
        -- Función para cerrar
        function notification.Close()
            if not notification.Closed then
                notification.Closed = true
                
                Tween(outerFrame, 0.45, {
                    Size = UDim2.new(1, 0, 0, -8)
                }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
                
                Tween(canvasGroup, 0.55, {
                    Position = UDim2.new(2, 0, 1, 0)
                }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
                
                task.wait(0.45)
                outerFrame:Destroy()
            end
        end
        
        -- Animación de entrada
        task.spawn(function()
            task.wait()
            
            Tween(outerFrame, 0.45, {
                Size = UDim2.new(1, 0, 0, canvasGroup.AbsoluteSize.Y)
            }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
            
            Tween(canvasGroup, 0.45, {
                Position = UDim2.new(0, 0, 1, 0)
            }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
            
            -- Duración y cierre automático
            if notification.Duration then
                Tween(progressBar, notification.Duration, {
                    Size = UDim2.new(0, 0, 0, 3)
                }, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut):Play()
                
                task.wait(notification.Duration)
                notification:Close()
            end
        end)
        
        -- Botón de cerrar
        if closeButton then
            closeButton.TextButton.MouseButton1Click:Connect(function()
                notification:Close()
            end)
        end
        
        return notification
    end
    
    return NotificationSystem
end

--------------------------------------------------------------------
-- MÓDULO DE DIÁLOGOS (a.h)
-- Sistema para crear cuadros de diálogo interactivos
--------------------------------------------------------------------
function a.h()
    local Core = a.load('a')
    local New = Core.New
    local Tween = Core.Tween
    
    return function(config)
        local dialog = {
            Title = config.Title or 'Dialog',
            Content = config.Content,
            Icon = config.Icon,
            Thumbnail = config.Thumbnail,
            Buttons = config.Buttons
        }
        
        -- Inicializar sistema de popups
        local PopupSystem = a.load('e').Init(config.WindUI.ScreenGui.Popups)
        local popup, thumbnailWidth, popupWidth = PopupSystem.Create(true), 200, 430
        
        -- Ajustar ancho si hay thumbnail
        if dialog.Thumbnail and dialog.Thumbnail.Image then
            popupWidth = 430 + (thumbnailWidth / 2)
        end
        
        popup.UIElements.Main.AutomaticSize = 'Y'
        popup.UIElements.Main.Size = UDim2.new(0, popupWidth, 0, 0)
        
        -- Ícono
        local iconElement
        if dialog.Icon then
            iconElement = Core.Image(
                dialog.Icon, 
                dialog.Title, 
                popup.UICorner - 4, 
                config.WindUI.Window, 
                'Popup'
            )
            iconElement.Size = UDim2.new(0, 24, 0, 24)
            iconElement.LayoutOrder = -1
        end
        
        -- Título
        local titleLabel = New('TextLabel', {
            AutomaticSize = 'XY',
            BackgroundTransparency = 1,
            Text = dialog.Title,
            FontFace = Font.new(Core.Font, Enum.FontWeight.SemiBold),
            ThemeTag = {TextColor3 = 'Text'},
            TextSize = 20
        })
        
        -- Contenedor de título
        local titleContainer = New('Frame', {
            BackgroundTransparency = 1,
            AutomaticSize = 'XY'
        }, {
            New('UIListLayout', {
                Padding = UDim.new(0, 14),
                FillDirection = 'Horizontal',
                VerticalAlignment = 'Center'
            }),
            iconElement,
            titleLabel
        })
        
        -- Contenedor principal de contenido
        local contentContainer = New('Frame', {
            AutomaticSize = 'Y',
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1
        }, {
            titleContainer
        })
        
        -- Texto de contenido
        if dialog.Content and dialog.Content ~= '' then
            contentContainer = New('TextLabel', {
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = 'Y',
                FontFace = Font.new(Core.Font, Enum.FontWeight.Medium),
                TextXAlignment = 'Left',
                Text = dialog.Content,
                TextSize = 18,
                TextTransparency = 0.2,
                ThemeTag = {TextColor3 = 'Text'},
                BackgroundTransparency = 1,
                RichText = true
            })
        end
        
        -- Contenedor de botones
        local buttonContainer = New('Frame', {
            Size = UDim2.new(1, 0, 0, 42),
            BackgroundTransparency = 1
        }, {
            New('UIListLayout', {
                Padding = UDim.new(0, 9),
                FillDirection = 'Horizontal',
                HorizontalAlignment = 'Right'
            })
        })
        
        -- Thumbnail
        local thumbnailElement
        if dialog.Thumbnail and dialog.Thumbnail.Image then
            local thumbnailTitle
            if dialog.Thumbnail.Title then
                thumbnailTitle = New('TextLabel', {
                    Text = dialog.Thumbnail.Title,
                    ThemeTag = {TextColor3 = 'Text'},
                    TextSize = 18,
                    FontFace = Font.new(Core.Font, Enum.FontWeight.Medium),
                    BackgroundTransparency = 1,
                    AutomaticSize = 'XY',
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(0.5, 0, 0.5, 0)
                })
            end
            
            thumbnailElement = New('ImageLabel', {
                Image = dialog.Thumbnail.Image,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, thumbnailWidth, 1, 0),
                Parent = popup.UIElements.Main,
                ScaleType = 'Crop'
            }, {
                thumbnailTitle,
                New('UICorner', {CornerRadius = UDim.new(0, 0)})
            })
        end
        
        -- Contenedor principal
        local mainContainer = New('Frame', {
            Size = UDim2.new(1, thumbnailElement and -thumbnailWidth or 0, 1, 0),
            Position = UDim2.new(0, thumbnailElement and thumbnailWidth or 0, 0, 0),
            BackgroundTransparency = 1,
            Parent = popup.UIElements.Main
        }, {
            New('Frame', {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1
            }, {
                New('UIListLayout', {
                    Padding = UDim.new(0, 18),
                    FillDirection = 'Vertical'
                }),
                contentContainer,
                buttonContainer,
                New('UIPadding', {
                    PaddingTop = UDim.new(0, 16),
                    PaddingLeft = UDim.new(0, 16),
                    PaddingRight = UDim.new(0, 16),
                    PaddingBottom = UDim.new(0, 16)
                })
            })
        })
        
        -- Crear botones
        local ButtonCreator = a.load('d').Button
        for _, buttonData in next, dialog.Buttons do
            ButtonCreator(
                buttonData.Title,
                buttonData.Icon,
                buttonData.Callback,
                buttonData.Variant,
                buttonContainer,
                popup
            )
        end
        
        popup:Open()
    end
end

--------------------------------------------------------------------
-- MÓDULO DE PARAGRAPH (a.i)
-- Elemento para mostrar texto con formato, imágenes y thumbnails
--------------------------------------------------------------------
function a.i()
    local Core = a.load('a')
    local New = Core.New
    local NewRoundFrame = Core.NewRoundFrame
    local Tween = Core.Tween
    local UserInputService = game:GetService('UserInputService')
    
    return function(config)
        local paragraph = {
            Title = config.Title or 'Paragraph',
            Desc = config.Desc or nil,
            Hover = config.Hover,
            Thumbnail = config.Thumbnail,
            ThumbnailSize = config.ThumbnailSize or 80,
            Image = config.Image,
            ImageSize = config.ImageSize or 22,
            Color = config.Color,
            Scalable = config.Scalable,
            UIPadding = 12,
            UICorner = 12,
            UIElements = {}
        }
        
        local imageSize = paragraph.ImageSize
        local thumbnailSize = paragraph.ThumbnailSize
        local interactive = true
        local isPressing = false
        
        -- Crear thumbnail si existe
        local thumbnailElement
        if paragraph.Thumbnail then
            thumbnailElement = Core.Image(
                paragraph.Thumbnail,
                paragraph.Title,
                paragraph.UICorner - 5,
                config.Window.Folder,
                'Thumbnail',
                false
            )
            thumbnailElement.Size = UDim2.new(1, 0, 0, thumbnailSize)
        end
        
        -- Crear imagen si existe
        local imageElement
        if paragraph.Image then
            imageElement = Core.Image(
                paragraph.Image,
                paragraph.Title,
                paragraph.UICorner - 5,
                config.Window.Folder,
                'Image',
                paragraph.Color ~= 'White'
            )
            
            if paragraph.Color == 'White' then
                imageElement.ImageLabel.ImageColor3 = Color3.new(0, 0, 0)
            end
            
            imageElement.Size = UDim2.new(0, imageSize, 0, imageSize)
            imageElement.Position = UDim2.new(
                0, paragraph.UIPadding / 2,
                0, thumbnailElement and thumbnailSize + (paragraph.UIPadding * 1.5) or paragraph.UIPadding / 2
            )
        end
        
        -- Elemento principal
        paragraph.UIElements.Main = New('TextButton', {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = 'Y',
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Visible = false,
            BackgroundTransparency = 1
        }, {
            New('UIScale', {Scale = 0.98}),
            imageElement,
            thumbnailElement,
            New('Frame', {
                Size = UDim2.new(1, paragraph.Image and -(imageSize + paragraph.UIPadding) or 0, 0, 0),
                AutomaticSize = 'Y',
                AnchorPoint = Vector2.new(0, 0),
                Position = UDim2.new(
                    0, imageElement and imageSize + paragraph.UIPadding or 0,
                    0, thumbnailElement and thumbnailSize + paragraph.UIPadding or 0
                ),
                BackgroundTransparency = 1,
                Name = 'Title'
            }, {
                New('UIListLayout', {Padding = UDim.new(0, 7)}),
                New('TextLabel', {
                    Text = paragraph.Title,
                    ThemeTag = {TextColor3 = not paragraph.Color and 'Text' or nil},
                    TextColor3 = paragraph.Color and (
                        paragraph.Color == 'White' and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
                    ),
                    TextSize = 16,
                    TextWrapped = true,
                    RichText = true,
                    LayoutOrder = 0,
                    Name = 'Title',
                    TextXAlignment = 'Left',
                    Size = UDim2.new(1, -config.TextOffset, 0, 0),
                    FontFace = Font.new(Core.Font, Enum.FontWeight.Medium),
                    BackgroundTransparency = 1,
                    AutomaticSize = 'Y'
                }),
                New('UIPadding', {
                    PaddingTop = UDim.new(0, (paragraph.UIPadding / 2) + 2),
                    PaddingLeft = UDim.new(0, paragraph.UIPadding / 2),
                    PaddingRight = UDim.new(0, paragraph.UIPadding / 2),
                    PaddingBottom = UDim.new(0, (paragraph.UIPadding / 2) + 2)
                })
            }),
            NewRoundFrame(paragraph.UICorner, 'Squircle', {
                Size = UDim2.new(1, paragraph.UIPadding, 1, paragraph.UIPadding),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Name = 'MainBG',
                ThemeTag = {ImageColor3 = not paragraph.Color and 'Text' or nil},
                ImageTransparency = not paragraph.Color and 0.95 or 0.1,
                ImageColor3 = paragraph.Color and Color3.fromHex(Core.Colors[paragraph.Color]),
                ZIndex = -1
            }),
            NewRoundFrame(paragraph.UICorner, 'Squircle', {
                Size = UDim2.new(1, paragraph.UIPadding, 1, paragraph.UIPadding),
                ThemeTag = {ImageColor3 = 'Text'},
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                ImageTransparency = 1,
                Name = 'Highlight',
                ZIndex = -1
            }),
            NewRoundFrame(paragraph.UICorner, 'SquircleOutline', {
                Size = UDim2.new(1, paragraph.UIPadding, 1, paragraph.UIPadding),
                ThemeTag = {ImageColor3 = 'Text'},
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                ImageTransparency = paragraph.Color == 'White' and 0 or 0.95,
                Name = 'Outline',
                ZIndex = -1
            }, {
                New('UIGradient', {
                    Rotation = 90,
                    Transparency = NumberSequence.new{
                        NumberSequenceKeypoint.new(0, 0),
                        NumberSequenceKeypoint.new(1, 1)
                    }
                })
            }),
            New('Frame', {
                Size = UDim2.new(1, paragraph.UIPadding, 1, paragraph.UIPadding),
                BackgroundColor3 = Color3.new(0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                ZIndex = 999999,
                Name = 'Lock'
            }, {
                New('UICorner', {CornerRadius = UDim.new(0, 11)}),
                New('ImageLabel', {
                    Image = Core.Icon('lock')[1],
                    ImageRectOffset = Core.Icon('lock')[2].ImageRectPosition,
                    ImageRectSize = Core.Icon('lock')[2].ImageRectSize,
                    Size = UDim2.new(0, 22, 0, 22),
                    ImageTransparency = 1,
                    BackgroundTransparency = 1,
                    Active = false
                }),
                New('TextLabel', {
                    BackgroundTransparency = 1,
                    Text = 'Locked',
                    TextTransparency = 1,
                    AutomaticSize = 'XY',
                    FontFace = Font.new(Core.Font, Enum.FontWeight.SemiBold),
                    TextSize = 16,
                    Active = false,
                    TextColor3 = Color3.new(1, 1, 1)
                }),
                New('UIListLayout', {
                    Padding = UDim.new(0, paragraph.UIPadding),
                    FillDirection = 'Horizontal',
                    VerticalAlignment = 'Center',
                    HorizontalAlignment = 'Center'
                })
            }),
            New('UIPadding', {
                PaddingTop = UDim.new(0, paragraph.UIPadding / 2),
                PaddingLeft = UDim.new(0, paragraph.UIPadding / 2),
                PaddingRight = UDim.new(0, paragraph.UIPadding / 2),
                PaddingBottom = UDim.new(0, paragraph.UIPadding / 2)
            })
        })
        
        -- Contenedor exterior
        paragraph.UIElements.MainContainer = New('Frame', {
            Size = UDim2.new(1, 0, 0, paragraph.UIElements.Main.AbsoluteSize.Y),
            BackgroundTransparency = 1,
            Parent = config.Parent
        }, {
            paragraph.UIElements.Main
        })
        
        -- Descripción
        local descLabel = New('TextLabel', {
            Text = paragraph.Desc,
            ThemeTag = {TextColor3 = not paragraph.Color and 'Text' or nil},
            TextColor3 = paragraph.Color and (
                paragraph.Color == 'White' and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
            ),
            TextTransparency = 0.2,
            TextSize = 15,
            TextWrapped = true,
            LayoutOrder = 9999,
            Name = 'Desc',
            TextXAlignment = 'Left',
            Size = UDim2.new(1, -config.TextOffset, 0, 0),
            FontFace = Font.new(Core.Font, Enum.FontWeight.Medium),
            BackgroundTransparency = 1,
            AutomaticSize = 'Y'
        })
        
        if paragraph.Desc then
            descLabel.Parent = paragraph.UIElements.Main.Title
        end
        
        -- Eventos hover
        if paragraph.Hover then
            paragraph.UIElements.Main.MouseEnter:Connect(function()
                if interactive then
                    Tween(paragraph.UIElements.Main.Highlight, 0.047, {
                        ImageTransparency = 0.975
                    }):Play()
                end
            end)
            
            paragraph.UIElements.Main.MouseButton1Down:Connect(function()
                if interactive then
                    isPressing = true
                    if paragraph.Scalable then
                        Tween(paragraph.UIElements.Main.UIScale, 0.07, {
                            Scale = 0.985
                        }, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out):Play()
                    end
                end
            end)
            
            paragraph.UIElements.Main.InputEnded:Connect(function()
                if interactive then
                    Tween(paragraph.UIElements.Main.Highlight, 0.066, {
                        ImageTransparency = 1
                    }):Play()
                    
                    if paragraph.Scalable then
                        Tween(paragraph.UIElements.Main.UIScale, 0.175, {
                            Scale = 1
                        }, Enum.EasingStyle.Back, Enum.EasingDirection.Out):Play()
                    end
                    
                    task.wait(0.16)
                    isPressing = false
                end
            end)
        end
        
        -- Actualizar tamaño del contenedor
        local sizeConnection = paragraph.UIElements.Main:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
            if not isPressing then
                paragraph.UIElements.MainContainer.Size = UDim2.new(
                    1, 0,
                    0, paragraph.UIElements.Main.AbsoluteSize.Y
                )
            end
        end)
        
        -- Métodos públicos
        function paragraph.SetTitle(newTitle)
            paragraph.UIElements.Main.Title.Title.Text = newTitle
        end
        
        function paragraph.SetDesc(newDesc)
            descLabel.Text = newDesc
            paragraph.Desc = newDesc
            if not descLabel.Parent then
                descLabel.Parent = paragraph.UIElements.Main.Title
            end
        end
        
        function paragraph.Show()
            paragraph.UIElements.Main.Visible = true
            Tween(paragraph.UIElements.Main.UIScale, 0.1, {Scale = 1}):Play()
        end
        
        function paragraph.Destroy()
            Tween(paragraph.UIElements.Main.UIScale, 0.15, {Scale = 0.98}):Play()
            sizeConnection:Disconnect()
            paragraph.UIElements.MainContainer.AutomaticSize = 'None'
            
            task.wait(0.1)
            paragraph.UIElements.Main.Visible = false
            
            Tween(paragraph.UIElements.MainContainer, 0.18, {
                Size = UDim2.new(1, 0, 0, -6)
            }, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut):Play()
            
            task.wait(0.23)
            paragraph.UIElements.MainContainer:Destroy()
        end
        
        function paragraph.Lock()
            Tween(paragraph.UIElements.Main.Lock, 0.08, {
                BackgroundTransparency = 0.6
            }):Play()
            
            Tween(paragraph.UIElements.Main.Lock.ImageLabel, 0.08, {
                ImageTransparency = 0
            }):Play()
            
            Tween(paragraph.UIElements.Main.Lock.TextLabel, 0.08, {
                TextTransparency = 0
            }):Play()
            
            paragraph.UIElements.Main.Lock.Active = true
            interactive = false
        end
        
        function paragraph.Unlock()
            Tween(paragraph.UIElements.Main.Lock, 0.08, {
                BackgroundTransparency = 1
            }):Play()
            
            Tween(paragraph.UIElements.Main.Lock.ImageLabel, 0.08, {
                ImageTransparency = 1
            }):Play()
            
            Tween(paragraph.UIElements.Main.Lock.TextLabel, 0.08, {
                TextTransparency = 1
            }):Play()
            
            paragraph.UIElements.Main.Lock.Active = false
            interactive = true
        end
        
        paragraph:Show()
        return paragraph
    end
end

--------------------------------------------------------------------
-- MÓDULO DE BUTTON (a.j)
-- Elemento de botón interactivo
--------------------------------------------------------------------
function a.j()
    local Core = a.load('a')
    local New = Core.New
    
    local ButtonModule = {}
    
    function ButtonModule.New(config)
        local button = {
            __type = 'Button',
            Title = config.Title or 'Button',
            Desc = config.Desc or nil,
            Locked = config.Locked or false,
            Callback = config.Callback or function() end,
            UIElements = {}
        }
        
        local interactive = true
        
        -- Crear elemento base usando Paragraph
        button.ButtonFrame = a.load('i')({
            Title = button.Title,
            Desc = button.Desc,
            Parent = config.Parent,
            Window = config.Window,
            TextOffset = 20,
            Hover = true,
            Scalable = true
        })
        
        -- Añadir ícono de click
        button.UIElements.ButtonIcon = New('ImageLabel', {
            Image = Core.Icon('mouse-pointer-click')[1],
            ImageRectOffset = Core.Icon('mouse-pointer-click')[2].ImageRectPosition,
            ImageRectSize = Core.Icon('mouse-pointer-click')[2].ImageRectSize,
            BackgroundTransparency = 1,
            Parent = button.ButtonFrame.UIElements.Main,
            Size = UDim2.new(0, 20, 0, 20),
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -button.ButtonFrame.UIPadding / 2, 0.5, 0),
            ThemeTag = {ImageColor3 = 'Text'}
        })
        
        -- Métodos de bloqueo
        function button.Lock()
            interactive = false
            return button.ButtonFrame:Lock()
        end
        
        function button.Unlock()
            interactive = true
            return button.ButtonFrame:Unlock()
        end
        
        if button.Locked then
            button:Lock()
        end
        
        -- Evento click
        button.ButtonFrame.UIElements.Main.MouseButton1Click:Connect(function()
            if interactive then
                task.spawn(function()
                    button.Callback()
                end)
            end
        end)
        
        return button.__type, button
    end
    
    return ButtonModule
end

--------------------------------------------------------------------
-- MÓDULO DE TOGGLE (a.k)
-- Elemento de interruptor (toggle o checkbox)
--------------------------------------------------------------------
function a.k()
    local Core = a.load('a')
    local New = Core.New
    local Tween = Core.Tween
    local Elements = a.load('d')
    local ToggleFunc = Elements.Toggle
    local CheckboxFunc = Elements.Checkbox
    
    local ToggleModule = {}
    
    function ToggleModule.New(config)
        local toggle = {
            __type = 'Toggle',
            Title = config.Title or 'Toggle',
            Desc = config.Desc or nil,
            Value = config.Value,
            Icon = config.Icon or nil,
            Type = config.Type or 'Toggle',
            Callback = config.Callback or function() end,
            UIElements = {}
        }
        
        -- Crear elemento base
        toggle.ToggleFrame = a.load('i')({
            Title = toggle.Title,
            Desc = toggle.Desc,
            Window = config.Window,
            Parent = config.Parent,
            TextOffset = 44,
            Hover = false
        })
        
        local interactive = true
        
        if toggle.Value == nil then
            toggle.Value = false
        end
        
        -- Métodos de bloqueo
        function toggle.Lock()
            interactive = false
            return toggle.ToggleFrame:Lock()
        end
        
        function toggle.Unlock()
            interactive = true
            return toggle.ToggleFrame:Unlock()
        end
        
        if toggle.Locked then
            toggle:Lock()
        end
        
        -- Crear elemento toggle/checkbox
        local toggleElement, setter
        if toggle.Type == 'Toggle' then
            toggleElement, setter = ToggleFunc(
                toggle.Value,
                toggle.Icon,
                toggle.ToggleFrame.UIElements.Main,
                toggle.Callback
            )
        elseif toggle.Type == 'Checkbox' then
            toggleElement, setter = CheckboxFunc(
                toggle.Value,
                toggle.Icon,
                toggle.ToggleFrame.UIElements.Main,
                toggle.Callback
            )
        else
            error('Unknown Toggle Type: ' .. tostring(toggle.Type))
        end
        
        toggleElement.AnchorPoint = Vector2.new(1, 0.5)
        toggleElement.Position = UDim2.new(1, -toggle.ToggleFrame.UIPadding / 2, 0.5, 0)
        
        -- Método Set
        function toggle.Set(newState)
            if interactive then
                setter:Set(newState)
                toggle.Value = newState
            end
        end
        
        toggle:Set(toggle.Value)
        
        -- Evento click
        toggle.ToggleFrame.UIElements.Main.MouseButton1Click:Connect(function()
            toggle:Set(not toggle.Value)
        end)
        
        return toggle.__type, toggle
    end
    
    return ToggleModule
end

--------------------------------------------------------------------
-- MÓDULO DE SLIDER (a.l)
-- Elemento deslizante para seleccionar valores numéricos
--------------------------------------------------------------------
function a.l()
    local Core = a.load('a')
    local New = Core.New
    local Tween = Core.Tween
    local UserInputService = game:GetService('UserInputService')
    local RunService = game:GetService('RunService')
    
    local SliderModule = {}
    local isDragging = false
    
    function SliderModule.New(config)
        local slider = {
            __type = 'Slider',
            Title = config.Title or 'Slider',
            Desc = config.Desc or nil,
            Locked = config.Locked or nil,
            Value = config.Value or {},
            Step = config.Step or 1,
            Callback = config.Callback or function() end,
            UIElements = {},
            IsFocusing = false
        }
        
        local currentValue = slider.Value.Default or slider.Value.Min or 0
        local currentRatio = (currentValue - (slider.Value.Min or 0)) / 
                            ((slider.Value.Max or 100) - (slider.Value.Min or 0))
        local interactive = true
        
        -- Crear elemento base
        slider.SliderFrame = a.load('i')({
            Title = slider.Title,
            Desc = slider.Desc,
            Parent = config.Parent,
            TextOffset = 160,
            Hover = false
        })
        
        -- Barra del slider
        slider.UIElements.SliderIcon = Core.NewRoundFrame(99, 'Squircle', {
            ImageTransparency = 0.95,
            Size = UDim2.new(0, 126, 0, 4),
            Name = 'Frame',
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            ThemeTag = {ImageColor3 = 'Text'}
        }, {
            Core.NewRoundFrame(99, 'Squircle', {
                Name = 'Frame',
                Size = UDim2.new(currentRatio, 0, 1, 0),
                ImageTransparency = 0.1,
                ThemeTag = {ImageColor3 = 'Button'}
            }, {
                Core.NewRoundFrame(99, 'Squircle', {
                    Size = UDim2.new(0, 13, 0, 13),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    ThemeTag = {ImageColor3 = 'Text'}
                })
            })
        })
        
        -- Contenedor del slider
        slider.UIElements.SliderContainer = New('Frame', {
            Size = UDim2.new(0, 0, 0, 0),
            AutomaticSize = 'XY',
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -slider.SliderFrame.UIPadding / 2, 0.5, 0),
            BackgroundTransparency = 1,
            Parent = slider.SliderFrame.UIElements.Main
        }, {
            New('UIListLayout', {
                Padding = UDim.new(0, 8),
                FillDirection = 'Horizontal',
                VerticalAlignment = 'Center'
            }),
            slider.UIElements.SliderIcon,
            New('TextBox', {
                Size = UDim2.new(0, 60, 0, 0),
                TextXAlignment = 'Right',
                Text = tostring(currentValue),
                ThemeTag = {TextColor3 = 'Text'},
                TextTransparency = 0.4,
                AutomaticSize = 'Y',
                TextSize = 15,
                FontFace = Font.new(Core.Font, Enum.FontWeight.Medium),
                BackgroundTransparency = 1,
                LayoutOrder = -1
            })
        })
        
        -- Métodos de bloqueo
        function slider.Lock()
            interactive = false
            return slider.SliderFrame:Lock()
        end
        
        function slider.Unlock()
            interactive = true
            return slider.SliderFrame:Unlock()
        end
        
        if slider.Locked then
            slider:Lock()
        end
        
        -- Método Set
        function slider.Set(newValue, input)
            if not interactive then return end
            if slider.IsFocusing and not (input and (input.UserInputType == Enum.UserInputType.MouseButton1 or 
                                                     input.UserInputType == Enum.UserInputType.Touch)) then
                return
            end
            
            newValue = math.clamp(newValue, slider.Value.Min or 0, slider.Value.Max or 100)
            local ratio = math.clamp(
                (newValue - (slider.Value.Min or 0)) / 
                ((slider.Value.Max or 100) - (slider.Value.Min or 0)),
                0, 1
            )
            
            -- Redondear según step
            newValue = math.floor(
                (slider.Value.Min + ratio * (slider.Value.Max - slider.Value.Min)) / 
                slider.Step + 0.5
            ) * slider.Step
            
            if newValue ~= currentValue then
                Tween(slider.UIElements.SliderIcon.Frame, 0.08, {
                    Size = UDim2.new(ratio, 0, 1, 0)
                }):Play()
                
                slider.UIElements.SliderContainer.TextBox.Text = tostring(newValue)
                currentValue = newValue
                slider.Callback(newValue)
            end
            
            if input then
                isDragging = (input.UserInputType == Enum.UserInputType.Touch)
                slider.SliderFrame.UIElements.Main.Parent.Parent.ScrollingEnabled = false
                slider.IsFocusing = true
                
                local dragConnection
                local endConnection
                
                dragConnection = RunService.RenderStepped:Connect(function()
                    local mousePos = isDragging and input.Position.X or 
                                    UserInputService:GetMouseLocation().X
                    local newRatio = math.clamp(
                        (mousePos - slider.UIElements.SliderIcon.AbsolutePosition.X) / 
                        slider.UIElements.SliderIcon.Size.X.Offset,
                        0, 1
                    )
                    
                    newValue = math.floor(
                        (slider.Value.Min + newRatio * (slider.Value.Max - slider.Value.Min)) / 
                        slider.Step + 0.5
                    ) * slider.Step
                    
                    if newValue ~= currentValue then
                        Tween(slider.UIElements.SliderIcon.Frame, 0.08, {
                            Size = UDim2.new(newRatio, 0, 1, 0)
                        }):Play()
                        
                        slider.UIElements.SliderContainer.TextBox.Text = tostring(newValue)
                        currentValue = newValue
                        slider.Callback(newValue)
                    end
                end)
                
                endConnection = UserInputService.InputEnded:Connect(function(endInput)
                    if (endInput.UserInputType == Enum.UserInputType.MouseButton1 or 
                        endInput.UserInputType == Enum.UserInputType.Touch) and input == endInput then
                        
                        dragConnection:Disconnect()
                        endConnection:Disconnect()
                        slider.IsFocusing = false
                        slider.SliderFrame.UIElements.Main.Parent.Parent.ScrollingEnabled = true
                    end
                end)
            end
        end
        
        -- Evento del textbox
        slider.UIElements.SliderContainer.TextBox.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                local newValue = tonumber(slider.UIElements.SliderContainer.TextBox.Text)
                if newValue then
                    slider:Set(newValue)
                else
                    slider.UIElements.SliderContainer.TextBox.Text = tostring(currentValue)
                end
            end
        end)
        
        -- Evento de arrastre
        slider.UIElements.SliderContainer.InputBegan:Connect(function(input)
            slider:Set(currentValue, input)
        end)
        
        return slider.__type, slider
    end
    
    return SliderModule
end

--------------------------------------------------------------------
-- MÓDULO DE INPUT (a.n)
-- Elemento de entrada de texto
--------------------------------------------------------------------
function a.n()
    local Core = a.load('a')
    local New = Core.New
    local Tween = Core.Tween
    local Elements = a.load('d')
    local InputFunc = Elements.Input
    
    local InputModule = {
        UICorner = 8,
        UIPadding = 8
    }
    
    function InputModule.New(config)
        local input = {
            __type = 'Input',
            Title = config.Title or 'Input',
            Desc = config.Desc or nil,
            Locked = config.Locked or false,
            InputIcon = config.InputIcon or false,
            PlaceholderText = config.Placeholder or 'Enter Text...',
            Value = config.Value or '',
            Callback = config.Callback or function() end,
            ClearTextOnFocus = config.ClearTextOnFocus or false,
            UIElements = {}
        }
        
        local interactive = true
        
        -- Crear elemento base
        input.InputFrame = a.load('i')({
            Title = input.Title,
            Desc = input.Desc,
            Parent = config.Parent,
            TextOffset = 190,
            Hover = false
        })
        
        -- Crear input
        local inputElement = InputFunc(
            input.PlaceholderText,
            input.InputIcon,
            input.InputFrame.UIElements.Main,
            function(newValue)
                input:Set(newValue)
            end
        )
        
        inputElement.Size = UDim2.new(0, 180, 0, 42)
        inputElement.AnchorPoint = Vector2.new(1, 0.5)
        inputElement.Position = UDim2.new(1, -input.InputFrame.UIPadding / 2, 0.5, 0)
        New('UIScale', {Parent = inputElement, Scale = 0.85})
        
        -- Métodos de bloqueo
        function input.Lock()
            interactive = false
            return input.InputFrame:Lock()
        end
        
        function input.Unlock()
            interactive = true
            return input.InputFrame:Unlock()
        end
        
        -- Método Set
        function input.Set(newValue)
            if interactive then
                input.Callback(newValue)
                inputElement.Frame.Frame.TextBox.Text = newValue
                input.Value = newValue
            end
        end
        
        input:Set(input.Value)
        
        if input.Locked then
            input:Lock()
        end
        
        return input.__type, input
    end
    
    return InputModule
end

--------------------------------------------------------------------
-- MÓDULO DE DROPDOWN (a.o)
-- Elemento de menú desplegable para seleccionar opciones
--------------------------------------------------------------------
function a.o()
    local UserInputService = game:GetService('UserInputService')
    local LocalPlayer = game:GetService('Players').LocalPlayer
    local Mouse = LocalPlayer:GetMouse()
    local Camera = game:GetService('Workspace').CurrentCamera
    local Core = a.load('a')
    local New = Core.New
    local Tween = Core.Tween
    local Elements = a.load('d')
    local LabelFunc = Elements.Label
    
    local DropdownModule = {
        UICorner = 10,
        UIPadding = 12,
        MenuCorner = 14,
        MenuPadding = 5,
        TabPadding = 6
    }
    
    function DropdownModule.New(window, config)
        local dropdown = {
            __type = 'Dropdown',
            Title = config.Title or 'Dropdown',
            Desc = config.Desc or nil,
            Locked = config.Locked or false,
            Values = config.Values or {},
            Value = config.Value,
            AllowNone = config.AllowNone,
            Multi = config.Multi,
            Callback = config.Callback or function() end,
            UIElements = {},
            Opened = false,
            Tabs = {}
        }
        
        local interactive = true
        
        -- Crear elemento base
        dropdown.DropdownFrame = a.load('i')({
            Title = dropdown.Title,
            Desc = dropdown.Desc,
            Parent = config.Parent,
            TextOffset = 190,
            Hover = false
        })
        
        -- Elemento dropdown (label clickeable)
        dropdown.UIElements.Dropdown = LabelFunc('', nil, dropdown.DropdownFrame.UIElements.Main)
        dropdown.UIElements.Dropdown.Frame.Frame.TextLabel.TextTruncate = 'AtEnd'
        dropdown.UIElements.Dropdown.Frame.Frame.TextLabel.Size = UDim2.new(
            1, dropdown.UIElements.Dropdown.Frame.Frame.TextLabel.Size.X.Offset - 18 - 12 - 12,
            0, 0
        )
        dropdown.UIElements.Dropdown.Size = UDim2.new(0, 180, 0, 42)
        dropdown.UIElements.Dropdown.AnchorPoint = Vector2.new(1, 0.5)
        dropdown.UIElements.Dropdown.Position = UDim2.new(1, -dropdown.DropdownFrame.UIPadding / 2, 0.5, 0)
        New('UIScale', {Parent = dropdown.UIElements.Dropdown, Scale = 0.85})
        
        -- Ícono de chevron
        local chevron = New('ImageLabel', {
            Image = Core.Icon('chevron-down')[1],
            ImageRectOffset = Core.Icon('chevron-down')[2].ImageRectPosition,
            ImageRectSize = Core.Icon('chevron-down')[2].ImageRectSize,
            Size = UDim2.new(0, 18, 0, 18),
            Position = UDim2.new(1, -12, 0.5, 0),
            ThemeTag = {ImageColor3 = 'Text'},
            AnchorPoint = Vector2.new(1, 0.5),
            Parent = dropdown.UIElements.Dropdown.Frame
        })
        
        -- Layout para opciones
        dropdown.UIElements.UIListLayout = New('UIListLayout', {
            Padding = UDim.new(0, DropdownModule.MenuPadding / 1.5),
            FillDirection = 'Vertical'
        })
        
        -- Menú desplegable
        dropdown.UIElements.Menu = New('Frame', {
            ThemeTag = {BackgroundColor3 = 'Accent'},
            BackgroundTransparency = 0.15,
            Size = UDim2.new(1, 0, 1, 0)
        }, {
            New('UICorner', {CornerRadius = UDim.new(0, DropdownModule.MenuCorner)}),
            New('UIStroke', {
                Thickness = 1,
                Transparency = 1,
                ThemeTag = {Color = 'Text'}
            }),
            New('Frame', {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Name = 'CanvasGroup',
                ClipsDescendants = true
            }, {
                New('UIPadding', {
                    PaddingTop = UDim.new(0, DropdownModule.MenuPadding),
                    PaddingLeft = UDim.new(0, DropdownModule.MenuPadding),
                    PaddingRight = UDim.new(0, DropdownModule.MenuPadding),
                    PaddingBottom = UDim.new(0, DropdownModule.MenuPadding)
                }),
                New('ScrollingFrame', {
                    Size = UDim2.new(1, 0, 1, 0),
                    ScrollBarThickness = 0,
                    ScrollingDirection = 'Y',
                    AutomaticCanvasSize = 'Y',
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = 1
                }, {
                    dropdown.UIElements.UIListLayout
                })
            })
        })
        
        -- Canvas del menú
        dropdown.UIElements.MenuCanvas = New('CanvasGroup', {
            Size = UDim2.new(0, 190, 0, 300),
            BackgroundTransparency = 1,
            Position = UDim2.new(-10, 0, -10, 0),
            Visible = false,
            Active = false,
            GroupTransparency = 1,
            Parent = window.SuperParent.Parent.Dropdowns,
            AnchorPoint = Vector2.new(1, 0)
        }, {
            dropdown.UIElements.Menu,
            New('UIPadding', {
                PaddingTop = UDim.new(0, 1),
                PaddingLeft = UDim.new(0, 1),
                PaddingRight = UDim.new(0, 1),
                PaddingBottom = UDim.new(0, 1)
            }),
            New('UISizeConstraint', {MinSize = Vector2.new(190, 0)})
        })
        
        -- Métodos de bloqueo
        function dropdown.Lock()
            interactive = false
            return dropdown.DropdownFrame:Lock()
        end
        
        function dropdown.Unlock()
            interactive = true
            return dropdown.DropdownFrame:Unlock()
        end
        
        if dropdown.Locked then
            dropdown:Lock()
        end
        
        -- Funciones auxiliares
        local function updateCanvasSize()
            dropdown.UIElements.Menu.CanvasGroup.ScrollingFrame.CanvasSize = 
                UDim2.fromOffset(0, dropdown.UIElements.UIListLayout.AbsoluteContentSize.Y)
        end
        
        local function updateMenuSize()
            if #dropdown.Values > 10 then
                dropdown.UIElements.MenuCanvas.Size = UDim2.fromOffset(
                    dropdown.UIElements.UIListLayout.AbsoluteContentSize.X,
                    392
                )
            else
                dropdown.UIElements.MenuCanvas.Size = UDim2.fromOffset(
                    dropdown.UIElements.UIListLayout.AbsoluteContentSize.X,
                    dropdown.UIElements.UIListLayout.AbsoluteContentSize.Y + 
                    DropdownModule.MenuPadding * 2 + 2
                )
            end
        end
        
        -- Actualizar posición del menú
        local function updatePosition()
            local offset = -dropdown.UIElements.Dropdown.AbsoluteSize.Y
            
            if Camera.ViewportSize.Y - dropdown.UIElements.Dropdown.AbsolutePosition.Y - 
               dropdown.UIElements.Dropdown.AbsoluteSize.Y + offset < 
               dropdown.UIElements.MenuCanvas.AbsoluteSize.Y + 10 then
                offset = dropdown.UIElements.MenuCanvas.AbsoluteSize.Y - 
                        (Camera.ViewportSize.Y - dropdown.UIElements.Dropdown.AbsolutePosition.Y) + 10
            end
            
            dropdown.UIElements.MenuCanvas.Position = UDim2.new(
                0, dropdown.UIElements.Dropdown.AbsolutePosition.X + 
                   dropdown.UIElements.Dropdown.AbsoluteSize.X + 1,
                0, dropdown.UIElements.Dropdown.AbsolutePosition.Y + 
                   dropdown.UIElements.Dropdown.AbsoluteSize.Y - offset
            )
        end
        
        -- Mostrar valor seleccionado
        function dropdown.Display()
            local selectedText = ''
            
            if dropdown.Multi then
                for _, value in next, dropdown.Values do
                    if table.find(dropdown.Value, value) then
                        selectedText = selectedText .. value .. ', '
                    end
                end
                selectedText = selectedText:sub(1, #selectedText - 2)
            else
                selectedText = dropdown.Value or ''
            end
            
            dropdown.UIElements.Dropdown.Frame.Frame.TextLabel.Text = 
                (selectedText == '' and '--' or selectedText)
        end
        
        -- Refrescar opciones
        function dropdown.Refresh(newValues)
            -- Limpiar opciones existentes
            for _, child in next, dropdown.UIElements.Menu.CanvasGroup.ScrollingFrame:GetChildren() do
                if not child:IsA('UIListLayout') then
                    child:Destroy()
                end
            end
            
            dropdown.Tabs = {}
            
            -- Crear nuevas opciones
            for index, value in next, newValues do
                local tab = {
                    Name = value,
                    Selected = false,
                    UIElements = {}
                }
                
                tab.UIElements.TabItem = New('TextButton', {
                    Size = UDim2.new(1, 0, 0, 34),
                    BackgroundTransparency = 1,
                    Parent = dropdown.UIElements.Menu.CanvasGroup.ScrollingFrame,
                    Text = ''
                }, {
                    New('UIPadding', {
                        PaddingTop = UDim.new(0, DropdownModule.TabPadding),
                        PaddingLeft = UDim.new(0, DropdownModule.TabPadding),
                        PaddingRight = UDim.new(0, DropdownModule.TabPadding),
                        PaddingBottom = UDim.new(0, DropdownModule.TabPadding)
                    }),
                    New('UICorner', {
                        CornerRadius = UDim.new(0, DropdownModule.MenuCorner - DropdownModule.MenuPadding)
                    }),
                    New('ImageLabel', {
                        Image = Core.Icon('check')[1],
                        ImageRectSize = Core.Icon('check')[2].ImageRectSize,
                        ImageRectOffset = Core.Icon('check')[2].ImageRectPosition,
                        ThemeTag = {ImageColor3 = 'Text'},
                        ImageTransparency = 1,
                        Size = UDim2.new(0, 18, 0, 18),
                        AnchorPoint = Vector2.new(0, 0.5),
                        Position = UDim2.new(0, 0, 0.5, 0),
                        BackgroundTransparency = 1
                    }),
                    New('TextLabel', {
                        Text = value,
                        TextXAlignment = 'Left',
                        FontFace = Font.new(Core.Font, Enum.FontWeight.Medium),
                        ThemeTag = {TextColor3 = 'Text', BackgroundColor3 = 'Text'},
                        TextSize = 15,
                        BackgroundTransparency = 1,
                        TextTransparency = 0.4,
                        AutomaticSize = 'Y',
                        TextTruncate = 'AtEnd',
                        Size = UDim2.new(1, -18 - DropdownModule.TabPadding * 3, 0, 0),
                        AnchorPoint = Vector2.new(0, 0.5),
                        Position = UDim2.new(0, 0, 0.5, 0)
                    })
                })
                
                -- Determinar si está seleccionado
                if dropdown.Multi then
                    tab.Selected = table.find(dropdown.Value or {}, tab.Name)
                else
                    tab.Selected = dropdown.Value == tab.Name
                end
                
                if tab.Selected then
                    tab.UIElements.TabItem.BackgroundTransparency = 0.93
                    tab.UIElements.TabItem.ImageLabel.ImageTransparency = 0.1
                    tab.UIElements.TabItem.TextLabel.Position = UDim2.new(0, 18 + DropdownModule.TabPadding, 0.5, 0)
                    tab.UIElements.TabItem.TextLabel.TextTransparency = 0
                end
                
                dropdown.Tabs[index] = tab
                dropdown:Display()
                
                -- Evento click
                tab.UIElements.TabItem.MouseButton1Click:Connect(function()
                    if dropdown.Multi then
                        if not tab.Selected then
                            -- Seleccionar
                            tab.Selected = true
                            Tween(tab.UIElements.TabItem, 0.1, {BackgroundTransparency = 0.93}):Play()
                            Tween(tab.UIElements.TabItem.ImageLabel, 0.1, {ImageTransparency = 0.1}):Play()
                            Tween(tab.UIElements.TabItem.TextLabel, 0.1, {
                                Position = UDim2.new(0, 18 + DropdownModule.TabPadding, 0.5, 0),
                                TextTransparency = 0
                            }):Play()
                            
                            table.insert(dropdown.Value, tab.Name)
                        else
                            -- Deseleccionar
                            if not dropdown.AllowNone and #dropdown.Value == 1 then
                                return
                            end
                            
                            tab.Selected = false
                            Tween(tab.UIElements.TabItem, 0.1, {BackgroundTransparency = 1}):Play()
                            Tween(tab.UIElements.TabItem.ImageLabel, 0.1, {ImageTransparency = 1}):Play()
                            Tween(tab.UIElements.TabItem.TextLabel, 0.1, {
                                Position = UDim2.new(0, 0, 0.5, 0),
                                TextTransparency = 0.4
                            }):Play()
                            
                            for i, v in ipairs(dropdown.Value) do
                                if v == tab.Name then
                                    table.remove(dropdown.Value, i)
                                    break
                                end
                            end
                        end
                    else
                        -- Modo single selection
                        for _, otherTab in next, dropdown.Tabs do
                            Tween(otherTab.UIElements.TabItem, 0.1, {BackgroundTransparency = 1}):Play()
                            Tween(otherTab.UIElements.TabItem.ImageLabel, 0.1, {ImageTransparency = 1}):Play()
                            Tween(otherTab.UIElements.TabItem.TextLabel, 0.1, {
                                Position = UDim2.new(0, 0, 0.5, 0),
                                TextTransparency = 0.4
                            }):Play()
                            otherTab.Selected = false
                        end
                        
                        tab.Selected = true
                        Tween(tab.UIElements.TabItem, 0.1, {BackgroundTransparency = 0.93}):Play()
                        Tween(tab.UIElements.TabItem.ImageLabel, 0.1, {ImageTransparency = 0.1}):Play()
                        Tween(tab.UIElements.TabItem.TextLabel, 0.1, {
                            Position = UDim2.new(0, 18 + DropdownModule.TabPadding, 0.5, 0),
                            TextTransparency = 0
                        }):Play()
                        
                        dropdown.Value = tab.Name
                    end
                    
                    dropdown:Display()
                    task.spawn(function()
                        dropdown.Callback(dropdown.Value)
                    end)
                end)
            end
            
            updateCanvasSize()
            updateMenuSize()
        end
        
        dropdown:Refresh(dropdown.Values)
        
        -- Método Select
        function dropdown.Select(newValue)
            if newValue then
                dropdown.Value = newValue
            end
            dropdown:Refresh(dropdown.Values)
        end
        
        -- Abrir menú
        function dropdown.Open()
            dropdown.Opened = true
            dropdown.UIElements.MenuCanvas.Visible = true
            dropdown.UIElements.MenuCanvas.Active = true
            dropdown.UIElements.Menu.Size = UDim2.new(1, 0, 0, 0)
            
            Tween(dropdown.UIElements.Menu, 0.1, {
                Size = UDim2.new(1, 0, 1, 0)
            }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out):Play()
            
            Tween(chevron, 0.15, {Rotation = 180}):Play()
            Tween(dropdown.UIElements.MenuCanvas, 0.15, {GroupTransparency = 0}):Play()
            
            updatePosition()
        end
        
        -- Cerrar menú
        function dropdown.Close()
            dropdown.Opened = false
            
            Tween(dropdown.UIElements.Menu, 0.1, {
                Size = UDim2.new(1, 0, 0.8, 0)
            }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out):Play()
            
            Tween(chevron, 0.15, {Rotation = 0}):Play()
            Tween(dropdown.UIElements.MenuCanvas, 0.15, {GroupTransparency = 1}):Play()
            
            task.wait(0.1)
            dropdown.UIElements.MenuCanvas.Visible = false
            dropdown.UIElements.MenuCanvas.Active = false
        end
        
        -- Evento click en dropdown
        dropdown.UIElements.Dropdown.MouseButton1Click:Connect(function()
            if interactive then
                dropdown:Open()
            end
        end)
        
        -- Cerrar al hacer clic fuera
        UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or 
               input.UserInputType == Enum.UserInputType.Touch then
                
                local menuPos = dropdown.UIElements.MenuCanvas.AbsolutePosition
                local menuSize = dropdown.UIElements.MenuCanvas.AbsoluteSize
                
                if window.CanDropdown and
                   (Mouse.X < menuPos.X or Mouse.X > menuPos.X + menuSize.X or
                    Mouse.Y < (menuPos.Y - 20 - 1) or Mouse.Y > menuPos.Y + menuSize.Y) then
                    dropdown:Close()
                end
            end
        end)
        
        -- Actualizar posición al moverse
        dropdown.UIElements.Dropdown:GetPropertyChangedSignal('AbsolutePosition'):Connect(updatePosition)
        
        return dropdown.__type, dropdown
    end
    
    return DropdownModule
end

--------------------------------------------------------------------
-- MÓDULO DE SECTION (a.r)
-- Elemento para agrupar otros elementos con un título
--------------------------------------------------------------------
function a.r()
    local Core = a.load('a')
    local New = Core.New
    local Tween = Core.Tween
    
    local SectionModule = {}
    
    function SectionModule.New(config)
        local section = {
            __type = 'Section',
            Title = config.Title or 'Section',
            TextXAlignment = config.TextXAlignment or 'Left',
            TextSize = config.TextSize or 19,
            UIElements = {}
        }
        
        -- Elemento principal
        section.UIElements.Main = New('TextLabel', {
            BackgroundTransparency = 1,
            TextXAlignment = section.TextXAlignment,
            AutomaticSize = 'Y',
            TextSize = section.TextSize,
            ThemeTag = {TextColor3 = 'Text'},
            FontFace = Font.new(Core.Font, Enum.FontWeight.SemiBold),
            Parent = config.Parent,
            Size = UDim2.new(1, 0, 0, 0),
            Text = section.Title
        }, {
            New('UIPadding', {
                PaddingTop = UDim.new(0, 4),
                PaddingBottom = UDim.new(0, 2)
            })
        })
        
        -- Métodos públicos
        function section.SetTitle(newTitle)
            section.UIElements.Main.Text = newTitle
        end
        
        function section.Destroy()
            section.UIElements.Main.AutomaticSize = 'None'
            section.UIElements.Main.Size = UDim2.new(
                1, 0,
                0, section.UIElements.Main.TextBounds.Y
            )
            
            Tween(section.UIElements.Main, 0.1, {TextTransparency = 1}):Play()
            
            task.wait(0.1)
            
            Tween(section.UIElements.Main, 0.15, {
                Size = UDim2.new(1, 0, 0, 0)
            }, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut):Play()
        end
        
        return section.__type, section
    end
    
    return SectionModule
end

--------------------------------------------------------------------
-- MÓDULO DE TABS (a.s)
-- Sistema de pestañas para organizar elementos
--------------------------------------------------------------------
function a.s()
    local UserInputService = game:GetService('UserInputService')
    local Mouse = game.Players.LocalPlayer:GetMouse()
    local Core = a.load('a')
    local New = Core.New
    local Tween = Core.Tween
    local Elements = a.load('d')
    local ButtonFunc = Elements.Button
    local ScrollSliderFunc = Elements.ScrollSlider
    
    local TabSystem = {
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
    
    -- Inicializar sistema
    function TabSystem.Init(window, windUI, tooltipParent, tabHighlight)
        TabSystem.Window = window
        TabSystem.WindUI = windUI
        TabSystem.ToolTipParent = tooltipParent
        TabSystem.TabHighlight = tabHighlight
        return TabSystem
    end
    
    -- Crear nueva pestaña
    function TabSystem.New(config)
        local tab = {
            Title = config.Title or 'Tab',
            Desc = config.Desc,
            Icon = config.Icon,
            Locked = config.Locked,
            ShowTabTitle = config.ShowTabTitle,
            Selected = false,
            Index = nil,
            Parent = config.Parent,
            UIElements = {},
            Elements = {},
            ContainerFrame = nil
        }
        
        local window = TabSystem.Window
        local windUI = TabSystem.WindUI
        
        TabSystem.TabCount = TabSystem.TabCount + 1
        local tabIndex = TabSystem.TabCount
        tab.Index = tabIndex
        
        -- Elemento principal de la pestaña en la barra lateral
        tab.UIElements.Main = New('TextButton', {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -7, 0, 0),
            AutomaticSize = 'Y',
            Parent = config.Parent
        }, {
            New('UIListLayout', {
                SortOrder = 'LayoutOrder',
                Padding = UDim.new(0, 10),
                FillDirection = 'Horizontal',
                VerticalAlignment = 'Center'
            }),
            New('TextLabel', {
                Text = tab.Title,
                ThemeTag = {TextColor3 = 'Text'},
                TextTransparency = not tab.Locked and 0.4 or 0.7,
                TextSize = 15,
                Size = UDim2.new(1, 0, 0, 0),
                FontFace = Font.new(Core.Font, Enum.FontWeight.Medium),
                TextWrapped = true,
                RichText = true,
                AutomaticSize = 'Y',
                LayoutOrder = 2,
                TextXAlignment = 'Left',
                BackgroundTransparency = 1
            }),
            New('UIPadding', {
                PaddingTop = UDim.new(0, 6),
                PaddingBottom = UDim.new(0, 6)
            })
        })
        
        -- Ícono de la pestaña
        local iconOffset = 0
        if tab.Icon and Core.Icon(tab.Icon) then
            iconOffset = -30
            local icon = New('ImageLabel', {
                ImageTransparency = not tab.Locked and 0.5 or 0.7,
                Image = Core.Icon(tab.Icon)[1],
                ImageRectOffset = Core.Icon(tab.Icon)[2].ImageRectPosition,
                ImageRectSize = Core.Icon(tab.Icon)[2].ImageRectSize,
                Size = UDim2.new(0, 18, 0, 18),
                LayoutOrder = 1,
                ThemeTag = {ImageColor3 = 'Text'},
                BackgroundTransparency = 1,
                Parent = tab.UIElements.Main
            })
            tab.UIElements.Main.TextLabel.Size = UDim2.new(1, iconOffset, 0, 0)
            
        elseif tab.Icon and string.find(tab.Icon, 'rbxassetid://') then
            iconOffset = -30
            local icon = New('ImageLabel', {
                ImageTransparency = not tab.Locked and 0.5 or 0.7,
                Image = tab.Icon,
                Size = UDim2.new(0, 18, 0, 18),
                LayoutOrder = 1,
                ThemeTag = {ImageColor3 = 'Text'},
                BackgroundTransparency = 1,
                Parent = tab.UIElements.Main
            })
            tab.UIElements.Main.TextLabel.Size = UDim2.new(1, iconOffset, 0, 0)
        end
        
        -- Frame contenedor para los elementos de la pestaña
        tab.UIElements.ContainerFrame = New('ScrollingFrame', {
            Size = UDim2.new(
                1, 0,
                1, tab.ShowTabTitle and -((window.UIPadding * 2.4) + 12) or 0
            ),
            BackgroundTransparency = 1,
            ScrollBarThickness = 0,
            ElasticBehavior = 'Never',
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.new(0, 0, 1, 0),
            AutomaticCanvasSize = 'Y',
            ScrollingDirection = 'Y'
        }, {
            New('UIPadding', {
                PaddingTop = UDim.new(0, window.UIPadding * 1.2),
                PaddingLeft = UDim.new(0, window.UIPadding * 1.2),
                PaddingRight = UDim.new(0, window.UIPadding * 1.2),
                PaddingBottom = UDim.new(0, window.UIPadding * 1.2)
            }),
            New('UIListLayout', {
                SortOrder = 'LayoutOrder',
                Padding = UDim.new(0, 6)
            })
        })
        
        -- Canvas contenedor
        tab.UIElements.ContainerFrameCanvas = New('Frame', {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = window.UIElements.MainBar,
            ZIndex = 5
        }, {
            tab.UIElements.ContainerFrame,
            
            -- Título de la pestaña (si está activado)
            New('Frame', {
                Size = UDim2.new(1, 0, 0, ((window.UIPadding * 2.4) + 12)),
                BackgroundTransparency = 1,
                Visible = tab.ShowTabTitle or false,
                Name = 'TabTitle'
            }, {
                tab.Icon and Core.Icon(tab.Icon) and New('ImageLabel', {
                    Image = Core.Icon(tab.Icon)[1],
                    ImageRectOffset = Core.Icon(tab.Icon)[2].ImageRectPosition,
                    ImageRectSize = Core.Icon(tab.Icon)[2].ImageRectSize,
                    Size = UDim2.new(0, 18, 0, 18),
                    ThemeTag = {ImageColor3 = 'Text'},
                    BackgroundTransparency = 1
                }) or nil,
                New('TextLabel', {
                    Text = tab.Title,
                    ThemeTag = {TextColor3 = 'Text'},
                    TextSize = 20,
                    TextTransparency = 0.1,
                    Size = UDim2.new(1, 0, 1, 0),
                    FontFace = Font.new(Core.Font, Enum.FontWeight.SemiBold),
                    TextTruncate = 'AtEnd',
                    RichText = true,
                    LayoutOrder = 2,
                    TextXAlignment = 'Left',
                    BackgroundTransparency = 1
                }),
                New('UIPadding', {
                    PaddingTop = UDim.new(0, window.UIPadding * 1.2),
                    PaddingLeft = UDim.new(0, window.UIPadding * 1.2),
                    PaddingRight = UDim.new(0, window.UIPadding * 1.2),
                    PaddingBottom = UDim.new(0, window.UIPadding * 1.2)
                }),
                New('UIListLayout', {
                    SortOrder = 'LayoutOrder',
                    Padding = UDim.new(0, 10),
                    FillDirection = 'Horizontal',
                    VerticalAlignment = 'Center'
                })
            }),
            
            -- Línea separadora
            New('Frame', {
                Size = UDim2.new(1, 0, 0, 1),
                BackgroundTransparency = 0.9,
                ThemeTag = {BackgroundColor3 = 'Text'},
                Position = UDim2.new(0, 0, 0, ((window.UIPadding * 2.4) + 12)),
                Visible = tab.ShowTabTitle or false
            })
        })
        
        TabSystem.Containers[tabIndex] = tab.UIElements.ContainerFrameCanvas
        TabSystem.Tabs[tabIndex] = tab
        tab.ContainerFrame = tab.UIElements.ContainerFrameCanvas
        
        -- Evento click para seleccionar pestaña
        tab.UIElements.Main.MouseButton1Click:Connect(function()
            if not tab.Locked then
                TabSystem:SelectTab(tabIndex)
            end
        end)
        
        -- Tooltip para descripción
        if tab.Desc then
            local isHovering = false
            local tooltip = nil
            local hoverConnection = nil
            local timer = nil
            
            local function closeTooltip()
                isHovering = false
                if timer then
                    task.cancel(timer)
                    timer = nil
                end
                if hoverConnection then
                    hoverConnection:Disconnect()
                    hoverConnection = nil
                end
                if tooltip then
                    tooltip:Close()
                    tooltip = nil
                end
            end
            
            tab.UIElements.Main.InputBegan:Connect(function()
                isHovering = true
                timer = task.spawn(function()
                    task.wait(0.35)
                    if isHovering and not tooltip then
                        tooltip = Elements.ToolTip(tab.Desc, TabSystem.ToolTipParent)
                        
                        local function updatePosition()
                            if tooltip then
                                tooltip.Container.Position = UDim2.new(
                                    0, Mouse.X,
                                    0, Mouse.Y - 20
                                )
                            end
                        end
                        
                        updatePosition()
                        hoverConnection = Mouse.Move:Connect(updatePosition)
                        tooltip:Open()
                    end
                end)
            end)
            
            tab.UIElements.Main.InputEnded:Connect(closeTooltip)
        end
        
        -- Cargar módulos de elementos
        local ElementModules = {
            Button = a.load('j'),
            Toggle = a.load('k'),
            Slider = a.load('l'),
            Keybind = a.load('m'),
            Input = a.load('n'),
            Dropdown = a.load('o'),
            Code = a.load('p'),
            Colorpicker = a.load('q'),
            Section = a.load('r')
        }
        
        -- Método para crear párrafo
        function tab.Paragraph(_, paragraphConfig)
            paragraphConfig.Parent = tab.UIElements.ContainerFrame
            paragraphConfig.Window = window
            paragraphConfig.Hover = false
            paragraphConfig.TextOffset = 0
            paragraphConfig.IsButtons = paragraphConfig.Buttons and #paragraphConfig.Buttons > 0
            
            local paragraph = {
                __type = 'Paragraph',
                Title = paragraphConfig.Title or 'Paragraph',
                Desc = paragraphConfig.Desc or nil,
                Locked = paragraphConfig.Locked or false
            }
            
            paragraph.ParagraphFrame = a.load('i')(paragraphConfig)
            
            -- Crear botones si existen
            if paragraphConfig.Buttons and #paragraphConfig.Buttons > 0 then
                local buttonContainer = New('Frame', {
                    Size = UDim2.new(1, 0, 0, 38),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(
                        0, 0,
                        0, paragraphConfig.Image and 
                           paragraph.ParagraphFrame.ImageSize > paragraph.ParagraphFrame.UIElements.Main.Title.AbsoluteSize.Y and
                           paragraph.ParagraphFrame.ImageSize + paragraph.ParagraphFrame.UIPadding or
                           paragraph.ParagraphFrame.UIElements.Main.Title.AbsoluteSize.Y + paragraph.ParagraphFrame.UIPadding +
                           (paragraphConfig.ThumbnailSize or 0)
                    ),
                    Parent = paragraph.ParagraphFrame.UIElements.Main
                }, {
                    New('UIListLayout', {
                        Padding = UDim.new(0, 10),
                        FillDirection = 'Vertical'
                    })
                })
                
                for _, btnData in next, paragraphConfig.Buttons do
                    local btn = ButtonFunc(
                        btnData.Title,
                        btnData.Icon,
                        btnData.Callback,
                        'White',
                        buttonContainer
                    )
                    btn.Size = UDim2.new(1, 0, 0, 38)
                    btn.AutomaticSize = 'None'
                end
            end
            
            -- Métodos públicos
            function paragraph.SetTitle(newTitle)
                paragraph.ParagraphFrame:SetTitle(newTitle)
            end
            
            function paragraph.SetDesc(newDesc)
                paragraph.ParagraphFrame:SetDesc(newDesc)
            end
            
            function paragraph.Destroy()
                paragraph.ParagraphFrame:Destroy()
            end
            
            table.insert(tab.Elements, paragraph)
            return paragraph
        end
        
        -- Métodos para otros elementos
        for name, module in pairs(ElementModules) do
            tab[name] = function(_, elementConfig)
                elementConfig.Parent = tab.UIElements.ContainerFrame
                elementConfig.Window = window
                elementConfig.WindUI = windUI
                
                local elementType, element = module:New(elementConfig)
                
                -- Buscar frame asociado para métodos comunes
                local elementFrame
                for prop, value in pairs(element) do
                    if typeof(value) == 'table' and prop:match('Frame$') then
                        elementFrame = value
                        break
                    end
                end
                
                if elementFrame then
                    function element.SetTitle(newTitle)
                        elementFrame:SetTitle(newTitle)
                    end
                    
                    function element.SetDesc(newDesc)
                        elementFrame:SetDesc(newDesc)
                    end
                    
                    function element.Destroy()
                        elementFrame:Destroy()
                    end
                end
                
                table.insert(tab.Elements, element)
                return element
            end
        end
        
        -- Mensaje de pestaña vacía
        task.spawn(function()
            local emptyMessage = New('Frame', {
                BackgroundTransparency = 1,
                Size = UDim2.new(
                    1, 0,
                    1, -window.UIElements.Main.Main.Topbar.AbsoluteSize.Y
                ),
                Parent = tab.UIElements.ContainerFrame
            }, {
                New('UIListLayout', {
                    Padding = UDim.new(0, 8),
                    SortOrder = 'LayoutOrder',
                    VerticalAlignment = 'Center',
                    HorizontalAlignment = 'Center',
                    FillDirection = 'Vertical'
                }),
                New('ImageLabel', {
                    Size = UDim2.new(0, 48, 0, 48),
                    Image = Core.Icon('frown')[1],
                    ImageRectOffset = Core.Icon('frown')[2].ImageRectPosition,
                    ImageRectSize = Core.Icon('frown')[2].ImageRectSize,
                    ThemeTag = {ImageColor3 = 'Text'},
                    BackgroundTransparency = 1,
                    ImageTransparency = 0.4
                }),
                New('TextLabel', {
                    AutomaticSize = 'XY',
                    Text = 'This tab is empty',
                    ThemeTag = {TextColor3 = 'Text'},
                    TextSize = 18,
                    TextTransparency = 0.4,
                    BackgroundTransparency = 1,
                    FontFace = Font.new(Core.Font, Enum.FontWeight.Medium)
                })
            })
            
            tab.UIElements.ContainerFrame.ChildAdded:Connect(function()
                emptyMessage.Visible = false
            end)
        end)
        
        return tab
    end
    
    -- Establecer callback de cambio
    function TabSystem.OnChange(callback)
        TabSystem.OnChangeFunc = callback
    end
    
    -- Seleccionar pestaña
    function TabSystem.SelectTab(index)
        if not TabSystem.Tabs[index].Locked then
            TabSystem.SelectedTab = index
            
            -- Deseleccionar todas las pestañas
            for i, tab in next, TabSystem.Tabs do
                if not tab.Locked then
                    Tween(tab.UIElements.Main.TextLabel, 0.15, {
                        TextTransparency = 0.45
                    }):Play()
                    
                    if tab.Icon and Core.Icon(tab.Icon) then
                        Tween(tab.UIElements.Main.ImageLabel, 0.15, {
                            ImageTransparency = 0.5
                        }):Play()
                    end
                    
                    tab.Selected = false
                end
            end
            
            -- Seleccionar la nueva pestaña
            Tween(TabSystem.Tabs[index].UIElements.Main.TextLabel, 0.15, {
                TextTransparency = 0
            }):Play()
            
            if TabSystem.Tabs[index].Icon and Core.Icon(TabSystem.Tabs[index].Icon) then
                Tween(TabSystem.Tabs[index].UIElements.Main.ImageLabel, 0.15, {
                    ImageTransparency = 0.15
                }):Play()
            end
            
            TabSystem.Tabs[index].Selected = true
            
            -- Mover el highlight
            Tween(TabSystem.TabHighlight, 0.25, {
                Position = UDim2.new(
                    0, 0,
                    0, TabSystem.Tabs[index].UIElements.Main.AbsolutePosition.Y -
                       TabSystem.Tabs[index].Parent.AbsolutePosition.Y
                ),
                Size = UDim2.new(
                    1, -7,
                    0, TabSystem.Tabs[index].UIElements.Main.AbsoluteSize.Y
                )
            }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
            
            -- Mostrar el contenedor de la pestaña
            task.spawn(function()
                for _, container in next, TabSystem.Containers do
                    container.AnchorPoint = Vector2.new(0, 0.05)
                    container.Visible = false
                end
                
                TabSystem.Containers[index].Visible = true
                Tween(TabSystem.Containers[index], 0.15, {
                    AnchorPoint = Vector2.new(0, 0)
                }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out):Play()
            end)
            
            TabSystem.OnChangeFunc(index)
        end
    end
    
    return TabSystem
end

--------------------------------------------------------------------
-- MÓDULO DE VENTANA PRINCIPAL (a.u)
-- Sistema principal de la ventana UI
--------------------------------------------------------------------
function a.u()
    local UserInputService = game:GetService('UserInputService')
    local RunService = game:GetService('RunService')
    local Core = a.load('a')
    local New = Core.New
    local Tween = Core.Tween
    local isResizing = false
    
    return function(config)
        local window = {
            Title = config.Title or 'UI Library',
            Author = config.Author,
            Icon = config.Icon,
            Folder = config.Folder,
            Background = config.Background,
            User = config.User or {},
            Size = config.Size and UDim2.new(
                0, math.clamp(config.Size.X.Offset, 480, 700),
                0, math.clamp(config.Size.Y.Offset, 350, 520)
            ) or UDim2.new(0, 580, 0, 460),
            ToggleKey = config.ToggleKey or Enum.KeyCode.G,
            Transparent = config.Transparent or false,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            UICorner = 16,
            UIPadding = 14,
            UIElements = {},
            CanDropdown = true,
            Closed = false,
            HasOutline = config.HasOutline or false,
            SuperParent = config.Parent,
            Destroyed = false,
            IsFullscreen = false,
            CanResize = true,
            IsOpenButtonEnabled = true,
            CurrentTab = nil,
            TabModule = nil,
            TopBarButtons = {}
        }
        
        -- Crear carpeta si no existe
        if window.Folder then
            makefolder('WindUI/' .. window.Folder)
        end
        
        -- Elementos UI principales
        local uiCorner = New('UICorner', {CornerRadius = UDim.new(0, window.UICorner)})
        
        -- Botón de resize
        local resizeHandle = New('Frame', {
            Size = UDim2.new(0, 32, 0, 32),
            Position = UDim2.new(1, 0, 1, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            ZIndex = 99,
            Active = true
        }, {
            New('ImageLabel', {
                Size = UDim2.new(0, 96, 0, 96),
                BackgroundTransparency = 1,
                Image = 'rbxassetid://120997033468887',
                Position = UDim2.new(0.5, -16, 0.5, -16),
                AnchorPoint = Vector2.new(0.5, 0.5),
                ImageTransparency = 0.8
            })
        })
        
        -- Overlay de resize
        local resizeOverlay = Core.NewRoundFrame(window.UICorner, 'Squircle', {
            Size = UDim2.new(1, 0, 1, 0),
            ImageTransparency = 1,
            ImageColor3 = Color3.new(0, 0, 0),
            ZIndex = 98,
            Active = false
        }, {
            New('ImageLabel', {
                Size = UDim2.new(0, 70, 0, 70),
                Image = Core.Icon('expand')[1],
                ImageRectOffset = Core.Icon('expand')[2].ImageRectPosition,
                ImageRectSize = Core.Icon('expand')[2].ImageRectSize,
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                ImageTransparency = 1
            })
        })
        
        -- Overlay de fullscreen
        local fullscreenOverlay = Core.NewRoundFrame(window.UICorner, 'Squircle', {
            Size = UDim2.new(1, 0, 1, 0),
            ImageTransparency = 1,
            ImageColor3 = Color3.new(0, 0, 0),
            ZIndex = 999,
            Active = false
        })
        
        -- Highlight de pestañas
        local tabHighlight = Core.NewRoundFrame(
            window.UICorner - (window.UIPadding / 2), 'Squircle', {
                Size = UDim2.new(1, 0, 0, 0),
                ImageTransparency = 0.95,
                ThemeTag = {ImageColor3 = 'Text'}
            }
        )
        
        -- Barra lateral
        window.UIElements.SideBar = New('ScrollingFrame', {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 0,
            ElasticBehavior = 'Never',
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = 'Y',
            ScrollingDirection = 'Y',
            ClipsDescendants = true,
            VerticalScrollBarPosition = 'Left'
        }, {
            New('Frame', {
                BackgroundTransparency = 1,
                AutomaticSize = 'Y',
                Size = UDim2.new(1, 0, 0, 0),
                Name = 'Frame'
            }, {
                New('UIPadding', {
                    PaddingTop = UDim.new(0, window.UIPadding / 2),
                    PaddingLeft = UDim.new(0, 4 + (window.UIPadding / 2)),
                    PaddingRight = UDim.new(0, 4 + (window.UIPadding / 2)),
                    PaddingBottom = UDim.new(0, window.UIPadding / 2)
                }),
                New('UIListLayout', {
                    SortOrder = 'LayoutOrder',
                    Padding = UDim.new(0, 6)
                })
            }),
            New('UIPadding', {
                PaddingLeft = UDim.new(0, window.UIPadding / 2),
                PaddingRight = UDim.new(0, window.UIPadding / 2)
            }),
            tabHighlight
        })
        
        -- Contenedor de la barra lateral
        window.UIElements.SideBarContainer = New('Frame', {
            Size = UDim2.new(0, window.SideBarWidth, 1, window.User.Enabled and -94 - (window.UIPadding * 2) or -52),
            Position = UDim2.new(0, 0, 0, 52),
            BackgroundTransparency = 1,
            Visible = true
        }, {
            window.UIElements.SideBar
        })
        
        -- Barra principal de contenido
        window.UIElements.MainBar = New('Frame', {
            Size = UDim2.new(1, -window.UIElements.SideBarContainer.AbsoluteSize.X, 1, -52),
            Position = UDim2.new(1, 0, 1, 0),
            AnchorPoint = Vector2.new(1, 1),
            BackgroundTransparency = 1
        }, {
            Core.NewRoundFrame(window.UICorner - (window.UIPadding / 2), 'Squircle', {
                Size = UDim2.new(1, 0, 1, 0),
                ImageColor3 = Color3.new(1, 1, 1),
                ZIndex = 3,
                ImageTransparency = 0.93,
                Name = 'Background'
            }),
            New('UIPadding', {
                PaddingTop = UDim.new(0, window.UIPadding / 2),
                PaddingLeft = UDim.new(0, window.UIPadding / 2),
                PaddingRight = UDim.new(0, window.UIPadding / 2),
                PaddingBottom = UDim.new(0, window.UIPadding / 2)
            })
        })
        
        -- Elementos de fondo
        local backgroundImage1 = New('ImageLabel', {
            Image = 'rbxassetid://8992230677',
            ImageColor3 = Color3.new(0, 0, 0),
            ImageTransparency = 1,
            Size = UDim2.new(1, 120, 1, 116),
            Position = UDim2.new(0, -60, 0, -58),
            ScaleType = 'Slice',
            SliceCenter = Rect.new(99, 99, 99, 99),
            BackgroundTransparency = 1,
            ZIndex = -9999
        })
        
        -- Determinar si es mobile
        local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
        
        -- Botón flotante para mobile
        local openButton, openButtonFrame
        if not isMobile then
            local openButtonIcon = New('ImageLabel', {
                Image = '',
                Size = UDim2.new(0, 22, 0, 22),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                LayoutOrder = -1,
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                Name = 'Icon'
            })
            
            local openButtonTitle = New('TextLabel', {
                Text = window.Title,
                TextSize = 17,
                FontFace = Font.new(Core.Font, Enum.FontWeight.Medium),
                BackgroundTransparency = 1,
                AutomaticSize = 'XY'
            })
            
            local openButtonDrag = New('Frame', {
                Size = UDim2.new(0, 36, 0, 36),
                BackgroundTransparency = 1,
                Name = 'Drag'
            }, {
                New('ImageLabel', {
                    Image = Core.Icon('move')[1],
                    ImageRectOffset = Core.Icon('move')[2].ImageRectPosition,
                    ImageRectSize = Core.Icon('move')[2].ImageRectSize,
                    Size = UDim2.new(0, 18, 0, 18),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0.5, 0.5)
                })
            })
            
            local openButtonDivider = New('Frame', {
                Size = UDim2.new(0, 1, 1, 0),
                Position = UDim2.new(0, 36, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = Color3.new(1, 1, 1),
                BackgroundTransparency = 0.9
            })
            
            openButton = New('Frame', {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0, 28),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Parent = config.Parent,
                BackgroundTransparency = 1,
                Active = true,
                Visible = false
            })
            
            openButtonFrame = New('TextButton', {
                Size = UDim2.new(0, 0, 0, 44),
                AutomaticSize = 'X',
                Parent = openButton,
                Active = false,
                BackgroundTransparency = 0.25,
                ZIndex = 99,
                BackgroundColor3 = Color3.new(0, 0, 0)
            }, {
                New('UICorner', {CornerRadius = UDim.new(1, 0)}),
                New('UIStroke', {
                    Thickness = 1,
                    ApplyStrokeMode = 'Border',
                    Color = Color3.new(1, 1, 1),
                    Transparency = 0
                }, {
                    New('UIGradient', {
                        Color = ColorSequence.new(
                            Color3.fromHex('40c9ff'),
                            Color3.fromHex('e81cff')
                        )
                    })
                }),
                openButtonDrag,
                openButtonDivider,
                New('UIListLayout', {
                    Padding = UDim.new(0, 4),
                    FillDirection = 'Horizontal',
                    VerticalAlignment = 'Center'
                }),
                New('TextButton', {
                    AutomaticSize = 'XY',
                    Active = true,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 0, 0, 36),
                    BackgroundColor3 = Color3.new(1, 1, 1)
                }, {
                    New('UICorner', {CornerRadius = UDim.new(1, -4)}),
                    openButtonIcon,
                    New('UIListLayout', {
                        Padding = UDim.new(0, window.UIPadding),
                        FillDirection = 'Horizontal',
                        VerticalAlignment = 'Center'
                    }),
                    openButtonTitle,
                    New('UIPadding', {
                        PaddingLeft = UDim.new(0, 12),
                        PaddingRight = UDim.new(0, 12)
                    })
                }),
                New('UIPadding', {
                    PaddingLeft = UDim.new(0, 4),
                    PaddingRight = UDim.new(0, 4)
                })
            })
            
            -- Animación del gradiente
            local gradient = openButtonFrame and openButtonFrame.UIStroke.UIGradient
            RunService.RenderStepped:Connect(function()
                if window.UIElements.Main and openButton and openButton.Parent then
                    if gradient then
                        gradient.Rotation = (gradient.Rotation + 1) % 360
                    end
                end
            end)
            
            openButtonFrame:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
                openButton.Size = UDim2.new(0, openButtonFrame.AbsoluteSize.X, 0, openButtonFrame.AbsoluteSize.Y)
            end)
            
            openButtonFrame.TextButton.MouseEnter:Connect(function()
                Tween(openButtonFrame.TextButton, 0.1, {BackgroundTransparency = 0.93}):Play()
            end)
            
            openButtonFrame.TextButton.MouseLeave:Connect(function()
                Tween(openButtonFrame.TextButton, 0.1, {BackgroundTransparency = 1}):Play()
            end)
        end
        
        -- Perfil de usuario
        local userProfile
        if window.User.Enabled then
            local thumbnailType = window.User.Anonymous and 1 or game.Players.LocalPlayer.UserId
            local thumbnail, thumbnailReady = game.Players:GetUserThumbnailAsync(
                thumbnailType,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size420x420
            )
            
            userProfile = New('TextButton', {
                Size = UDim2.new(
                    0, (window.UIElements.SideBarContainer.AbsoluteSize.X) - (window.UIPadding / 2),
                    0, 42 + (window.UIPadding)
                ),
                Position = UDim2.new(0, window.UIPadding / 2, 1, -(window.UIPadding / 2)),
                AnchorPoint = Vector2.new(0, 1),
                BackgroundTransparency = 1
            }, {
                Core.NewRoundFrame(window.UICorner - (window.UIPadding / 2), 'Squircle', {
                    Size = UDim2.new(1, 0, 1, 0),
                    ThemeTag = {ImageColor3 = 'Text'},
                    ImageTransparency = 1,
                    Name = 'UserIcon'
                }, {
                    New('ImageLabel', {
                        Image = thumbnail,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0, 42, 0, 42),
                        ThemeTag = {BackgroundColor3 = 'Text'},
                        BackgroundTransparency = 0.93
                    }, {
                        New('UICorner', {CornerRadius = UDim.new(1, 0)})
                    }),
                    New('Frame', {
                        AutomaticSize = 'XY',
                        BackgroundTransparency = 1
                    }, {
                        New('TextLabel', {
                            Text = window.User.Anonymous and 'Anonymous' or game.Players.LocalPlayer.DisplayName,
                            TextSize = 17,
                            ThemeTag = {TextColor3 = 'Text'},
                            FontFace = Font.new(Core.Font, Enum.FontWeight.SemiBold),
                            AutomaticSize = 'Y',
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, -27, 0, 0),
                            TextTruncate = 'AtEnd',
                            TextXAlignment = 'Left'
                        }),
                        New('TextLabel', {
                            Text = window.User.Anonymous and '@anonymous' or '@' .. game.Players.LocalPlayer.Name,
                            TextSize = 15,
                            TextTransparency = 0.6,
                            ThemeTag = {TextColor3 = 'Text'},
                            FontFace = Font.new(Core.Font, Enum.FontWeight.Medium),
                            AutomaticSize = 'Y',
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, -27, 0, 0),
                            TextTruncate = 'AtEnd',
                            TextXAlignment = 'Left'
                        }),
                        New('UIListLayout', {
                            Padding = UDim.new(0, 4),
                            HorizontalAlignment = 'Left'
                        })
                    }),
                    New('UIListLayout', {
                        Padding = UDim.new(0, window.UIPadding),
                        FillDirection = 'Horizontal',
                        VerticalAlignment = 'Center'
                    }),
                    New('UIPadding', {
                        PaddingLeft = UDim.new(0, window.UIPadding / 2),
                        PaddingRight = UDim.new(0, window.UIPadding / 2)
                    })
                })
            })
            
            if window.User.Callback then
                userProfile.MouseButton1Click:Connect(function()
                    window.User.Callback()
                end)
                
                userProfile.MouseEnter:Connect(function()
                    Tween(userProfile.UserIcon, 0.04, {ImageTransparency = 0.94}):Play()
                end)
                
                userProfile.InputEnded:Connect(function()
                    Tween(userProfile.UserIcon, 0.04, {ImageTransparency = 1}):Play()
                end)
            end
        end
        
        -- Barra de resize
        local resizeBar = Core.NewRoundFrame(99, 'Squircle', {
            ImageTransparency = 0.8,
            ImageColor3 = Color3.new(1, 1, 1),
            Size = UDim2.new(0, 200, 0, 4),
            Position = UDim2.new(0.5, 0, 1, 4),
            AnchorPoint = Vector2.new(0.5, 0)
        }, {
            New('Frame', {
                Size = UDim2.new(1, 12, 1, 12),
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Active = true,
                ZIndex = 99
            })
        })
        
        -- Título de la ventana
        local titleLabel = New('TextLabel', {
            Text = window.Title,
            FontFace = Font.new(Core.Font, Enum.FontWeight.SemiBold),
            BackgroundTransparency = 1,
            AutomaticSize = 'XY',
            Name = 'Title',
            TextXAlignment = 'Left',
            TextSize = 16,
            ThemeTag = {TextColor3 = 'Text'}
        })
        
        -- Ventana principal
        window.UIElements.Main = New('Frame', {
            Size = window.Size,
            Position = window.Position,
            BackgroundTransparency = 1,
            Parent = config.Parent,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Active = true
        }, {
            backgroundImage1,
            Core.NewRoundFrame(window.UICorner, 'Squircle', {
                ImageTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Name = 'Background',
                ThemeTag = {ImageColor3 = 'Background'},
                ZIndex = -99
            }, {
                New('ImageLabel', {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Image = window.Background,
                    ImageTransparency = 1,
                    ScaleType = 'Crop'
                }, {
                    New('UICorner', {CornerRadius = UDim.new(0, window.UICorner)})
                }),
                New('UIScale', {Scale = 0.95})
            }),
            uiCorner,
            resizeHandle,
            resizeOverlay,
            fullscreenOverlay,
            resizeBar,
            New('Frame', {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Name = 'Main',
                Visible = false,
                ZIndex = 97
            }, {
                New('UICorner', {CornerRadius = UDim.new(0, window.UICorner)}),
                window.UIElements.SideBarContainer,
                window.UIElements.MainBar,
                userProfile,
                titleLabel,
                
                -- Barra superior
                New('Frame', {
                    Size = UDim2.new(1, 0, 0, 52),
                    BackgroundTransparency = 1,
                    BackgroundColor3 = Color3.fromRGB(50, 50, 50),
                    Name = 'Topbar'
                }, {
                    titleLabel,
                    
                    -- Lado izquierdo de la barra
                    New('Frame', {
                        AutomaticSize = 'X',
                        Size = UDim2.new(0, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Name = 'Left'
                    }, {
                        New('UIListLayout', {
                            Padding = UDim.new(0, 10),
                            SortOrder = 'LayoutOrder',
                            FillDirection = 'Horizontal',
                            VerticalAlignment = 'Center'
                        }),
                        New('Frame', {
                            AutomaticSize = 'XY',
                            BackgroundTransparency = 1,
                            Name = 'Title',
                            Size = UDim2.new(0, 0, 1, 0),
                            LayoutOrder = 2
                        }, {
                            New('UIListLayout', {
                                Padding = UDim.new(0, 0),
                                SortOrder = 'LayoutOrder',
                                FillDirection = 'Vertical',
                                VerticalAlignment = 'Top'
                            }),
                            titleLabel
                        }),
                        New('UIPadding', {PaddingLeft = UDim.new(0, 4)})
                    }),
                    
                    -- Lado derecho de la barra
                    New('Frame', {
                        AutomaticSize = 'XY',
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, 0, 0.5, 0),
                        AnchorPoint = Vector2.new(1, 0.5),
                        Name = 'Right'
                    }, {
                        New('UIListLayout', {
                            Padding = UDim.new(0, 9),
                            FillDirection = 'Horizontal',
                            SortOrder = 'LayoutOrder'
                        })
                    }),
                    
                    New('UIPadding', {
                        PaddingTop = UDim.new(0, window.UIPadding),
                        PaddingLeft = UDim.new(0, window.UIPadding),
                        PaddingRight = UDim.new(0, 8),
                        PaddingBottom = UDim.new(0, window.UIPadding)
                    })
                })
            })
        })
        
        -- Crear botón en barra superior
        function window.CreateTopbarButton(iconName, callback, order)
            local button = New('TextButton', {
                Size = UDim2.new(0, 36, 0, 36),
                BackgroundTransparency = 1,
                LayoutOrder = order or 999,
                Parent = window.UIElements.Main.Main.Topbar.Right,
                ZIndex = 9999,
                ThemeTag = {BackgroundColor3 = 'Text'},
                BackgroundTransparency = 1
            }, {
                New('UICorner', {CornerRadius = UDim.new(0, 9)}),
                New('ImageLabel', {
                    Image = Core.Icon(iconName)[1],
                    ImageRectOffset = Core.Icon(iconName)[2].ImageRectPosition,
                    ImageRectSize = Core.Icon(iconName)[2].ImageRectSize,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 16, 0, 16),
                    ThemeTag = {ImageColor3 = 'Text'},
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    Active = false,
                    ImageTransparency = 0.2
                })
            })
            
            window.TopBarButtons[100 - order] = button
            
            button.MouseButton1Click:Connect(callback)
            
            button.MouseEnter:Connect(function()
                Tween(button, 0.15, {BackgroundTransparency = 0.93}):Play()
                Tween(button.ImageLabel, 0.15, {ImageTransparency = 0}):Play()
            end)
            
            button.MouseLeave:Connect(function()
                Tween(button, 0.1, {BackgroundTransparency = 1}):Play()
                Tween(button.ImageLabel, 0.1, {ImageTransparency = 0.2}):Play()
            end)
            
            return button
        end
        
        -- Hacer la ventana arrastrable
        local dragController = Core.Drag(
            window.UIElements.Main,
            {window.UIElements.Main.Main.Topbar, resizeBar.Frame},
            function(isDragging, obj)
                if isDragging and obj == resizeBar.Frame then
                    Tween(resizeBar, 0.1, {ImageTransparency = 0.35}):Play()
                else
                    Tween(resizeBar, 0.2, {ImageTransparency = 0.8}):Play()
                end
            end
        )
        
        -- Hacer el botón flotante arrastrable
        if not isMobile then
            local openButtonDragController = Core.Drag(openButton)
        end
        
        -- Añadir autor si existe
        if window.Author then
            New('TextLabel', {
                Text = window.Author,
                FontFace = Font.new(Core.Font, Enum.FontWeight.Medium),
                BackgroundTransparency = 1,
                TextTransparency = 0.4,
                AutomaticSize = 'XY',
                Parent = window.UIElements.Main.Main.Topbar.Left.Title,
                TextXAlignment = 'Left',
                TextSize = 14,
                LayoutOrder = 2,
                ThemeTag = {TextColor3 = 'Text'}
            })
        end
        
        -- Añadir ícono
        task.spawn(function()
            if window.Icon then
                local icon = Core.Image(
                    window.Icon,
                    window.Title,
                    window.UICorner - 4,
                    window.Folder,
                    'Window'
                )
                icon.Parent = window.UIElements.Main.Main.Topbar.Left
                icon.Size = UDim2.new(0, 22, 0, 22)
                
                if Core.Icon(tostring(window.Icon))[1] then
                    openButtonIcon.Image = Core.Icon(window.Icon)[1]
                    openButtonIcon.ImageRectOffset = Core.Icon(window.Icon)[2].ImageRectPosition
                    openButtonIcon.ImageRectSize = Core.Icon(window.Icon)[2].ImageRectSize
                end
            else
                openButtonIcon.Visible = false
            end
        end)
        
        -- Establecer tecla de toggle
        function window.SetToggleKey(newKey)
            window.ToggleKey = newKey
        end
        
        -- Establecer imagen de fondo
        function window.SetBackgroundImage(imageId)
            window.UIElements.Main.Background.ImageLabel.Image = imageId
        end
        
        -- Botones de fullscreen y minimizar
        local minimizeIcon = Core.Icon('minimize')
        local maximizeIcon = Core.Icon('maximize')
        
        local fullscreenButton = window:CreateTopbarButton(
            'maximize',
            function()
                local wasFullscreen = window.IsFullscreen
                dragController:Set(wasFullscreen)
                
                if not wasFullscreen then
                    window.lastPosition = window.UIElements.Main.Position
                    window.lastSize = window.UIElements.Main.Size
                    fullscreenButton.ImageLabel.Image = minimizeIcon[1]
                    fullscreenButton.ImageLabel.ImageRectOffset = minimizeIcon[2].ImageRectPosition
                    fullscreenButton.ImageLabel.ImageRectSize = minimizeIcon[2].ImageRectSize
                    window.CanResize = false
                else
                    fullscreenButton.ImageLabel.Image = maximizeIcon[1]
                    fullscreenButton.ImageLabel.ImageRectOffset = maximizeIcon[2].ImageRectPosition
                    fullscreenButton.ImageLabel.ImageRectSize = maximizeIcon[2].ImageRectSize
                    window.CanResize = true
                end
                
                Tween(window.UIElements.Main, 0.45, {
                    Size = wasFullscreen and window.lastSize or UDim2.new(1, -20, 1, -72)
                }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
                
                Tween(window.UIElements.Main, 0.45, {
                    Position = wasFullscreen and window.lastPosition or UDim2.new(0.5, 0, 0.5, 26)
                }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
                
                window.IsFullscreen = not wasFullscreen
            end,
            998
        )
        
        local wasMinimized = false
        window:CreateTopbarButton(
            'minus',
            function()
                window:Close()
                
                task.spawn(function()
                    task.wait(0.3)
                    if not isMobile and window.IsOpenButtonEnabled then
                        openButton.Visible = true
                    end
                end)
                
                local message = isMobile and 
                    'Press ' .. window.ToggleKey.Name .. ' to open the Window' or
                    'Click the Button to open the Window'
                
                if not window.IsOpenButtonEnabled then
                    wasMinimized = true
                end
                
                if not wasMinimized then
                    wasMinimized = true
                    config.WindUI:Notify{
                        Title = 'Minimize',
                        Content = "You've closed the Window. " .. message,
                        Icon = 'eye-off',
                        Duration = 5
                    }
                end
            end,
            997
        )
        
        -- Abrir ventana
        function window.Open()
            task.spawn(function()
                window.Closed = false
                
                Tween(window.UIElements.Main.Background, 0.25, {
                    ImageTransparency = config.Transparent and config.WindUI.TransparencyValue or 0
                }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
                
                Tween(window.UIElements.Main.Background.ImageLabel, 0.2, {
                    ImageTransparency = 0
                }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
                
                Tween(window.UIElements.Main.Background.UIScale, 0.2, {
                    Scale = 1
                }, Enum.EasingStyle.Back, Enum.EasingDirection.Out):Play()
                
                Tween(backgroundImage1, 0.25, {
                    ImageTransparency = 0.7
                }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
                
                if resizeOverlay then
                    Tween(resizeOverlay, 0.25, {Transparency = 0.8}, 
                          Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
                end
                
                window.CanDropdown = true
                window.UIElements.Main.Visible = true
                
                task.wait(0.1)
                window.UIElements.Main.Main.Visible = true
            end)
        end
        
        -- Cerrar ventana
        function window.Close()
            local closeActions = {}
            
            window.UIElements.Main.Main.Visible = false
            window.CanDropdown = false
            window.Closed = true
            
            Tween(window.UIElements.Main.Background, 0.25, {
                ImageTransparency = 1
            }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
            
            Tween(window.UIElements.Main.Background.UIScale, 0.19, {
                Scale = 0.95
            }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
            
            Tween(window.UIElements.Main.Background.ImageLabel, 0.2, {
                ImageTransparency = 1
            }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
            
            Tween(backgroundImage1, 0.25, {
                ImageTransparency = 1
            }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
            
            if resizeOverlay then
                Tween(resizeOverlay, 0.25, {Transparency = 1}, 
                      Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
            end
            
            task.spawn(function()
                task.wait(0.25)
                window.UIElements.Main.Visible = false
            end)
            
            function closeActions.Destroy()
                window.Destroyed = true
                task.wait(0.25)
                config.Parent.Parent:Destroy()
            end
            
            return closeActions
        end
        
        -- Toggle transparencia
        function window.ToggleTransparency(transparent)
            config.Transparent = transparent
            config.WindUI.Transparent = transparent
            config.WindUI.Window.Transparent = transparent
            
            window.UIElements.Main.Background.ImageTransparency = transparent and config.WindUI.TransparencyValue or 0
            window.UIElements.Main.Background.ImageLabel.ImageTransparency = transparent and config.WindUI.TransparencyValue or 0
            window.UIElements.MainBar.Background.ImageTransparency = transparent and 0.97 or 0.93
        end
        
        -- Evento de click en botón flotante
        if not isMobile and window.IsOpenButtonEnabled then
            openButtonFrame.TextButton.MouseButton1Click:Connect(function()
                openButton.Visible = false
                window:Open()
            end)
        end
        
        -- Evento de tecla para abrir/cerrar
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            
            if input.KeyCode == window.ToggleKey then
                if window.Closed then
                    window:Open()
                else
                    window:Close()
                end
            end
        end)
        
        -- Abrir ventana inicialmente
        task.spawn(function()
            window:Open()
        end)
        
        -- Editar botón flotante
        function window.EditOpenButton(_, buttonConfig)
            if openButton and openButton.Parent then
                local config = {
                    Title = buttonConfig.Title,
                    Icon = buttonConfig.Icon or window.Icon,
                    Enabled = buttonConfig.Enabled,
                    Position = buttonConfig.Position,
                    Draggable = buttonConfig.Draggable,
                    OnlyMobile = buttonConfig.OnlyMobile,
                    CornerRadius = buttonConfig.CornerRadius or UDim.new(1, 0),
                    StrokeThickness = buttonConfig.StrokeThickness or 2,
                    Color = buttonConfig.Color or ColorSequence.new(
                        Color3.fromHex('40c9ff'),
                        Color3.fromHex('e81cff')
                    )
                }
                
                if config.Enabled == false then
                    window.IsOpenButtonEnabled = false
                end
                
                if config.Draggable == false and openButtonDrag and openButtonDivider then
                    openButtonDrag.Visible = config.Draggable
                    openButtonDivider.Visible = config.Draggable
                    if openButtonDragController then
                        openButtonDragController:Set(config.Draggable)
                    end
                end
                
                if config.Position and openButton then
                    openButton.Position = config.Position
                end
                
                local hasKeyboard = UserInputService.KeyboardEnabled or not UserInputService.TouchEnabled
                openButton.Visible = not config.OnlyMobile or not hasKeyboard
                
                if not openButton.Visible then
                    return
                end
                
                if openButtonTitle then
                    if config.Title then
                        openButtonTitle.Text = config.Title
                    end
                end
                
                if Core.Icon(config.Icon) and openButtonIcon then
                    openButtonIcon.Visible = true
                    openButtonIcon.Image = Core.Icon(config.Icon)[1]
                    openButtonIcon.ImageRectOffset = Core.Icon(config.Icon)[2].ImageRectPosition
                    openButtonIcon.ImageRectSize = Core.Icon(config.Icon)[2].ImageRectSize
                end
                
                if openButtonFrame then
                    openButtonFrame.UIStroke.UIGradient.Color = config.Color
                    openButtonFrame.UICorner.CornerRadius = config.CornerRadius
                    openButtonFrame.TextButton.UICorner.CornerRadius = UDim.new(
                        config.CornerRadius.Scale,
                        config.CornerRadius.Offset - 4
                    )
                    openButtonFrame.UIStroke.Thickness = config.StrokeThickness
                end
            end
        end
        
        -- Inicializar sistema de pestañas
        local TabSystem = a.load('s')
        local tabSystem = TabSystem.Init(
            window,
            config.WindUI,
            config.Parent.Parent.ToolTips,
            tabHighlight
        )
        
        tabSystem:OnChange(function(index)
            window.CurrentTab = index
        end)
        
        window.TabModule = tabSystem
        
        -- Crear pestaña
        function window.Tab(_, tabConfig)
            tabConfig.Parent = window.UIElements.SideBar.Frame
            return tabSystem.New(tabConfig)
        end
        
        -- Seleccionar pestaña
        function window.SelectTab(_, index)
            tabSystem:SelectTab(index)
        end
        
        -- Crear divisor
        function window.Divider(_)
            local divider = New('Frame', {
                Size = UDim2.new(1, 0, 0, 1),
                Position = UDim2.new(0.5, 0, 0, 0),
                AnchorPoint = Vector2.new(0.5, 0),
                BackgroundTransparency = 0.9,
                ThemeTag = {BackgroundColor3 = 'Text'}
            })
            
            New('Frame', {
                Parent = window.UIElements.SideBar.Frame,
                Size = UDim2.new(1, -7, 0, 1),
                BackgroundTransparency = 1
            }, {
                divider
            })
        end
        
        -- Inicializar sistema de popups
        local PopupSystem = a.load('e').Init(window)
        
        -- Crear diálogo
        function window.Dialog(_, dialogConfig)
            local dialog = {
                Title = dialogConfig.Title or 'Dialog',
                Content = dialogConfig.Content,
                Buttons = dialogConfig.Buttons or {}
            }
            
            local popup = PopupSystem.Create()
            
            -- Contenedor de título
            local titleContainer = New('Frame', {
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = 'Y',
                BackgroundTransparency = 1,
                Parent = popup.UIElements.Main
            }, {
                New('UIListLayout', {
                    FillDirection = 'Horizontal',
                    Padding = UDim.new(0, popup.UIPadding),
                    VerticalAlignment = 'Center'
                })
            })
            
            -- Ícono
            local iconElement
            if dialogConfig.Icon and Core.Icon(dialogConfig.Icon)[2] then
                iconElement = New('ImageLabel', {
                    Image = Core.Icon(dialogConfig.Icon)[1],
                    ImageRectSize = Core.Icon(dialogConfig.Icon)[2].ImageRectSize,
                    ImageRectOffset = Core.Icon(dialogConfig.Icon)[2].ImageRectPosition,
                    ThemeTag = {ImageColor3 = 'Text'},
                    Size = UDim2.new(0, 26, 0, 26),
                    BackgroundTransparency = 1,
                    Parent = titleContainer
                })
            end
            
            -- Layout principal
            popup.UIElements.UIListLayout = New('UIListLayout', {
                Padding = UDim.new(0, 18.4),
                FillDirection = 'Vertical',
                HorizontalAlignment = 'Left',
                Parent = popup.UIElements.Main
            })
            
            New('UISizeConstraint', {
                MinSize = Vector2.new(180, 20),
                MaxSize = Vector2.new(400, math.huge),
                Parent = popup.UIElements.Main
            })
            
            -- Título
            popup.UIElements.Title = New('TextLabel', {
                Text = dialog.Title,
                TextSize = 19,
                FontFace = Font.new(Core.Font, Enum.FontWeight.SemiBold),
                TextXAlignment = 'Left',
                TextWrapped = true,
                RichText = true,
                Size = UDim2.new(1, iconElement and -26 - popup.UIPadding or 0, 0, 0),
                AutomaticSize = 'Y',
                ThemeTag = {TextColor3 = 'Text'},
                BackgroundTransparency = 1,
                Parent = titleContainer
            })
            
            -- Contenido
            if dialog.Content then
                New('TextLabel', {
                    Text = dialog.Content,
                    TextSize = 18,
                    TextTransparency = 0.4,
                    TextWrapped = true,
                    RichText = true,
                    FontFace = Font.new(Core.Font, Enum.FontWeight.Medium),
                    TextXAlignment = 'Left',
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = 'Y',
                    LayoutOrder = 2,
                    ThemeTag = {TextColor3 = 'Text'},
                    BackgroundTransparency = 1,
                    Parent = popup.UIElements.Main
                })
            end
            
            -- Contenedor de botones
            local buttonLayout = New('UIListLayout', {
                Padding = UDim.new(0, 10),
                FillDirection = 'Horizontal',
                HorizontalAlignment = 'Right'
            })
            
            local buttonContainer = New('Frame', {
                Size = UDim2.new(1, 0, 0, 40),
                AutomaticSize = 'None',
                BackgroundTransparency = 1,
                Parent = popup.UIElements.Main,
                LayoutOrder = 4
            }, {
                buttonLayout
            })
            
            local ButtonCreator = a.load('d').Button
            local buttons = {}
            
            for _, btnData in next, dialog.Buttons do
                local btn = ButtonCreator(
                    btnData.Title,
                    btnData.Icon,
                    btnData.Callback,
                    btnData.Variant,
                    buttonContainer,
                    popup
                )
                table.insert(buttons, btn)
            end
            
            -- Ajustar layout de botones según espacio
            local function updateButtonLayout()
                local totalWidth = buttonLayout.AbsoluteContentSize.X
                local containerWidth = buttonContainer.AbsoluteSize.X - 1
                
                if totalWidth > containerWidth then
                    buttonLayout.FillDirection = 'Vertical'
                    buttonLayout.HorizontalAlignment = 'Right'
                    buttonLayout.VerticalAlignment = 'Bottom'
                    buttonContainer.AutomaticSize = 'Y'
                    
                    for _, btn in ipairs(buttons) do
                        btn.Size = UDim2.new(1, 0, 0, 40)
                        btn.AutomaticSize = 'None'
                    end
                else
                    buttonLayout.FillDirection = 'Horizontal'
                    buttonLayout.HorizontalAlignment = 'Right'
                    buttonLayout.VerticalAlignment = 'Center'
                    buttonContainer.AutomaticSize = 'None'
                    
                    for _, btn in ipairs(buttons) do
                        btn.Size = UDim2.new(0, 0, 1, 0)
                        btn.AutomaticSize = 'X'
                    end
                end
            end
            
            popup.UIElements.Main:GetPropertyChangedSignal('AbsoluteSize'):Connect(updateButtonLayout)
            updateButtonLayout()
            
            popup:Open()
            return popup
        end
        
        -- Botón de cerrar ventana
        window:CreateTopbarButton(
            'x',
            function()
                Tween(window.UIElements.Main, 0.35, {
                    Position = UDim2.new(0.5, 0, 0.5, 0)
                }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
                
                window:Dialog{
                    Icon = 'trash-2',
                    Title = 'Close Window',
                    Content = [[Do you want to close this window? You will not be able to open it again.]],
                    Buttons = {
                        {
                            Title = 'Cancel',
                            Callback = function() end,
                            Variant = 'Secondary'
                        },
                        {
                            Title = 'Close Window',
                            Callback = function()
                                window:Close():Destroy()
                            end,
                            Variant = 'Primary'
                        }
                    }
                }
            end,
            999
        )
        
        -- Sistema de resize
        local function startResize(input)
            if window.CanResize then
                isResizing = true
                resizeOverlay.Active = true
                
                local initialSize = window.UIElements.Main.Size
                local initialInputPos = input.Position
                
                Tween(resizeOverlay, 0.2, {ImageTransparency = 0.65}):Play()
                Tween(resizeOverlay.ImageLabel, 0.2, {ImageTransparency = 0}):Play()
                Tween(resizeHandle.ImageLabel, 0.1, {ImageTransparency = 0.35}):Play()
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        isResizing = false
                        resizeOverlay.Active = false
                        Tween(resizeOverlay, 0.2, {ImageTransparency = 1}):Play()
                        Tween(resizeOverlay.ImageLabel, 0.2, {ImageTransparency = 1}):Play()
                        Tween(resizeHandle.ImageLabel, 0.2, {ImageTransparency = 0.8}):Play()
                    end
                end)
            end
        end
        
        resizeHandle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or
               input.UserInputType == Enum.UserInputType.Touch then
                if window.CanResize then
                    startResize(input)
                end
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or
               input.UserInputType == Enum.UserInputType.Touch then
                if isResizing and window.CanResize then
                    local delta = input.Position - initialInputPos
                    local newSize = UDim2.new(
                        0, initialSize.X.Offset + delta.X * 2,
                        0, initialSize.Y.Offset + delta.Y * 2
                    )
                    
                    Tween(window.UIElements.Main, 0.06, {
                        Size = UDim2.new(
                            0, math.clamp(newSize.X.Offset, 480, 700),
                            0, math.clamp(newSize.Y.Offset, 350, 520)
                        )
                    }):Play()
                end
            end
        end)
        
        -- Sistema de búsqueda
        local SearchSystem = a.load('t')
        local isSearchOpen = false
        
        local searchButton = window:CreateTopbarButton(
            'search',
            function()
                if isSearchOpen then return end
                
                SearchSystem.new(
                    window.TabModule,
                    window.UIElements.Main,
                    function()
                        isSearchOpen = false
                        window.CanResize = true
                        Tween(searchButton, 0.1, {ImageTransparency = 1}):Play()
                        searchButton.Active = false
                    end
                )
                
                Tween(searchButton, 0.1, {ImageTransparency = 0.65}):Play()
                searchButton.Active = true
                isSearchOpen = true
                window.CanResize = false
            end,
            996
        )
        
        return window
    end
end

-- Devolver el módulo principal
return a