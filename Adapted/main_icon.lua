local Icons = {
    ["lucide"] = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/cxnker/WindUI/refs/heads/main/Adapted/lucide.lua"))()
}

local IconModule = {
    IconsType = "lucide",
    -- Añadimos un icono por defecto para cuando no se encuentre el solicitado
    DefaultIcon = "rbxassetid://110786993356448" -- El icono "x" como fallback
}

function IconModule.SetIconsType(iconType)
    IconModule.IconsType = iconType
end

function IconModule.Icon(Icon, Type)
    local iconSet = Icons[Type or IconModule.IconsType]
    
    if not iconSet then
        warn(`[IconModule] Conjunto de iconos "{Type or IconModule.IconsType}" no encontrado. Usando icono por defecto.`)
        return { IconModule.DefaultIcon, {} }
    end

    local assetId = iconSet[Icon]
    
    if assetId then
        return { assetId, {} }
    else
        -- Icono no encontrado - devolvemos el icono por defecto en lugar de nil
        warn(`[IconModule] Icono "{Icon}" no encontrado. Usando icono por defecto.`)
        return { IconModule.DefaultIcon, {} }
    end
end

return IconModule
