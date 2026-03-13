local Icons = {
    ["lucide"] = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/cxnker/WindUI/refs/heads/main/WindUI_1.6.1/lucide.lua"))()
}


local IconModule = {
    IconsType = "lucide"
}

function IconModule.SetIconsType(iconType)
    IconModule.IconsType = iconType
end

function IconModule.Icon(Icon, Type)
    local iconType = Icons[Type or IconModule.IconsType]
    
    if iconType[Icon] then
        return { assetId, {} }
    end
    return nil
end

return IconModule