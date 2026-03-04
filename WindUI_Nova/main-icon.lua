local Icons = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/cxnker/WindUI/refs/heads/main/WindUI_Nova/lucide-icons.lua"))()

local IconModule = {
    IconsType = "lucide"
}

function IconModule.SetIconsType(iconType)
    IconModule.IconsType = iconType
end

function IconModule.Icon(IconName)
    local iconAssetId = Icons[IconName]
    
    if iconAssetId then
        return {
            iconAssetId,
            {
                ImageRectPosition = Vector2.new(0, 0),
                ImageRectSize = Vector2.new(24, 24)
            }
        }
    end
    
    return nil
end

function IconModule.GetAssetId(IconName)
    return Icons[IconName]
end

return IconModule
