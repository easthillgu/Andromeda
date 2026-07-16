local F, C = unpack(select(2, ...))

local function GetBestScale()
    local scale = max(0.4, min(1.15, 768 / C.SCREEN_HEIGHT))
    return F:Round(scale, 2)
end

function F:SetupUIScale(init)
    local scale = GetBestScale() * _G.ANDROMEDA_ADB.UIScale

    if init then
        local pixel = 1
        local ratio = 768 / C.SCREEN_HEIGHT
        C.MULT = (pixel / scale) - ((pixel - ratio) / scale)
    else
        -- #TODO: hide UIScale options

        if not InCombatLockdown() then
            _G.UIParent:SetScale(scale)
        end
    end
end

local isScaling = false
function F:UpdatePixelScale(event)
    if isScaling then
        return
    end

    isScaling = true

    if event == 'UI_SCALE_CHANGED' then
        C.SCREEN_WIDTH, C.SCREEN_HEIGHT = GetPhysicalScreenSize()
    end

    F:SetupUIScale(true)
    F:SetupUIScale()
    
    -- Update smart pixel scale
    F:GetPixelScale()

    isScaling = false
end

function F:InitializePixelScale()
    F:GetPixelScale()
    F:RegisterEvent('UI_SCALE_CHANGED', function()
        F:GetPixelScale()
    end)
end