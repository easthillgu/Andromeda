
local F, C = unpack(select(2, ...))
local ACTIONBAR = F:GetModule('ActionBar')

local LibCustomGlow = LibStub('LibCustomGlow-1.0', true)
if not LibCustomGlow then
    F:Print('|cffff0000错误:|r LibCustomGlow-1.0 未找到，Pixel Glow 功能不可用')
    return
end

-- Pixel Glow 默认配置（参考 WeakAuras）
local defaultPixelGlowConfig = {
    lines = 8,
    frequency = 0.25,
    length = 8,
    thickness = 1,
    xOffset = 0,
    yOffset = 0,
    border = false
}

-- 启动 Pixel Glow
function ACTIONBAR:PixelGlow_Start(frame, config, key)
    if not frame or not LibCustomGlow then return end

    local cfg = config or defaultPixelGlowConfig
    local k = key or 'AutoCast'

    local color = cfg.color or { C.r, C.g, C.b, 1 }

    LibCustomGlow.PixelGlow_Start(
        frame,
        color,
        cfg.lines,
        cfg.frequency,
        cfg.length,
        cfg.thickness,
        cfg.xOffset,
        cfg.yOffset,
        cfg.border,
        k
    )
end

-- 停止 Pixel Glow
function ACTIONBAR:PixelGlow_Stop(frame, key)
    if not frame or not LibCustomGlow then return end
    
    local k = key or 'AutoCast'
    LibCustomGlow.PixelGlow_Stop(frame, k)
end