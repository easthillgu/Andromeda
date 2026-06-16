local F, C, L = unpack(select(2, ...))
local AURA = F:GetModule('Aura')
local oUF = F.Libs.oUF

local function onEvent(_, isLogin, isReload)
    if isLogin or isReload then
        F.HideObject(_G.BuffFrame)
        F.HideObject(_G.DebuffFrame)
        _G.BuffFrame.numHideableBuffs = 0 -- IS_NEW_PATCH_10_1
    end
end

function AURA:HideBlizzFrame()
    if not C.DB.Aura.Enable and not C.DB.Aura.HideBlizzFrame then
        return
    end

    F:RegisterEvent('PLAYER_ENTERING_WORLD', onEvent)
end

function AURA:BuildBuffFrame()
    if not C.DB.Aura.Enable then
        return
    end

    -- Config
    AURA.settings = {
        Buffs = {
            offset = 12,
            size = C.DB.Aura.BuffSize,
            wrapAfter = C.DB.Aura.BuffPerRow,
            maxWraps = 3,
            reverseGrow = C.DB.Aura.BuffReverse,
        },
        Debuffs = {
            offset = 12,
            size = C.DB.Aura.DebuffSize,
            wrapAfter = C.DB.Aura.DebuffPerRow,
            maxWraps = 1,
            reverseGrow = C.DB.Aura.DebuffReverse,
        },
    }

    -- Movers
    AURA.BuffFrame = AURA:CreateAuraHeader('HELPFUL')
    AURA.BuffFrame.mover = F.Mover(AURA.BuffFrame, L['BuffFrame'], 'BuffAnchor', { 'TOPLEFT', _G.UIParent, 'TOPLEFT', C.UI_GAP, -C.UI_GAP })
    AURA.BuffFrame:ClearAllPoints()
    AURA.BuffFrame:SetPoint('TOPRIGHT', AURA.BuffFrame.mover)

    AURA.DebuffFrame = AURA:CreateAuraHeader('HARMFUL')
    AURA.DebuffFrame.mover = F.Mover(AURA.DebuffFrame, L['DebuffFrame'], 'DebuffAnchor', { 'TOPLEFT', AURA.BuffFrame, 'BOTTOMLEFT', 0, -5 })
    AURA.DebuffFrame:ClearAllPoints()
    AURA.DebuffFrame:SetPoint('TOPRIGHT', AURA.DebuffFrame.mover)

    AURA:CreatePrivateAuras()
end

local day, hour, minute = 86400, 3600, 60
function AURA:FormatAuraTime(s)
    if s >= day then
        return format('|cffbebfb3%d|r' .. C.INFO_COLOR .. 'd', s / day + 0.5), s % day
    elseif s >= hour then
        return format('|cff4fcd35%d|r' .. C.INFO_COLOR .. 'h', s / hour + 0.5), s % hour
    elseif s >= 2 * hour then
        return format('|cff4fcd35%d|r' .. C.INFO_COLOR .. 'h', s / hour + 0.5), s % hour
    elseif s >= 10 * minute then
        return format('|cff21c8de%d|r' .. C.INFO_COLOR .. 'm', s / minute + 0.5), s % minute
    elseif s >= minute then
        return format('|cff21c8de%d:%.2d|r', s / minute, s % minute), s - floor(s)
    elseif s > 10 then
        return format('|cffffe700%d|r' .. C.INFO_COLOR .. 's', s + 0.5), s - floor(s)
    elseif s > 5 then
        return format('|cffffff00%.1f|r', s), s - format('%.1f', s)
    else
        return format('|cffff0000%.1f|r', s), s - format('%.1f', s)
    end
end

function AURA:UpdateTimer(elapsed)
    local onTooltip = _G.GameTooltip:IsOwned(self)

    if not (self.timeLeft or self.expiration or onTooltip) then
        self:SetScript('OnUpdate', nil)
        return
    end

    if self.expiration then
        self.timeLeft = self.expiration / 1e3
    elseif self.timeLeft then
        self.timeLeft = self.timeLeft - elapsed
    end

    if self.nextUpdate > 0 then
        self.nextUpdate = self.nextUpdate - elapsed
        return
    end

    if self.timeLeft and self.timeLeft >= 0 then
        local timer, nextUpdate = AURA:FormatAuraTime(self.timeLeft)
        self.nextUpdate = nextUpdate
        self.timer:SetText(timer)
    end

    if onTooltip then
        AURA:Button_SetTooltip(self)
    end
end

function AURA:UpdateAuras(button, index)
    local unit, filter = button.header:GetAttribute('unit'), button.filter
    local name, texture, count, debuffType, duration, expirationTime, _, _, _, spellID = UnitAura(unit, index, filter)
    if not name then
        return
    end

    if duration > 0 and expirationTime then
        local timeLeft = expirationTime - GetTime()
        if not button.timeLeft then
            button.nextUpdate = -1
            button.timeLeft = timeLeft
            button:SetScript('OnUpdate', AURA.UpdateTimer)
        else
            button.timeLeft = timeLeft
        end
        button.nextUpdate = -1
        AURA.UpdateTimer(button, 0)
    else
        button.timeLeft = nil
        button.timer:SetText('')
    end

    if count and count > 1 then
        button.count:SetText(count)
    else
        button.count:SetText('')
    end

    if filter == 'HARMFUL' then
        local color = oUF.colors.debuff[debuffType or 'none']
        button:SetBackdropBorderColor(color[1], color[2], color[3])
        if button.__shadow then
            button.__shadow:SetBackdropBorderColor(color[1], color[2], color[3], 0.25)
        end
    else
        button:SetBackdropBorderColor(0, 0, 0)
        if button.__shadow then
            button.__shadow:SetBackdropBorderColor(0, 0, 0, 0.25)
        end
    end

    button.spellID = spellID
    button.icon:SetTexture(texture)
    button.expiration = nil
end

function AURA:UpdateTempEnchant(button, index)
    local expirationTime = select(button.enchantOffset, GetWeaponEnchantInfo())
    if expirationTime then
        local quality = GetInventoryItemQuality('player', index)
        local color = C.QualityColors[quality or 1]
        button:SetBackdropBorderColor(color.r, color.g, color.b)
        button.icon:SetTexture(GetInventoryItemTexture('player', index))

        button.expiration = expirationTime
        button:SetScript('OnUpdate', AURA.UpdateTimer)
        button.nextUpdate = -1
        AURA.UpdateTimer(button, 0)
    else
        button.expiration = nil
        button.timeLeft = nil
        button.timer:SetText('')
    end
end

function AURA:OnAttributeChanged(attribute, value)
    if attribute == 'index' then
        AURA:UpdateAuras(self, value)
    elseif attribute == 'target-slot' then
        AURA:UpdateTempEnchant(self, value)
    end
end

function AURA:UpdateOptions()
    AURA.settings.Buffs.size = C.DB.Aura.BuffSize
    AURA.settings.Buffs.wrapAfter = C.DB.Aura.BuffPerRow
    AURA.settings.Buffs.reverseGrow = C.DB.Aura.BuffReverse
    AURA.settings.Debuffs.size = C.DB.Aura.DebuffSize
    AURA.settings.Debuffs.wrapAfter = C.DB.Aura.DebuffPerRow
    AURA.settings.Debuffs.reverseGrow = C.DB.Aura.DebuffReverse
end

function AURA:UpdateHeader(header)
    local cfg = AURA.settings.Debuffs
    if header.filter == 'HELPFUL' then
        cfg = AURA.settings.Buffs
        header:SetAttribute('consolidateTo', 0)
        header:SetAttribute('weaponTemplate', format(C.ADDON_TITLE .. 'AuraTemplate%d', cfg.size))
        header:SetAttribute('separateOwn', 0) -- buff不使用separateOwn，显示所有buff
    else
        header:SetAttribute('separateOwn', C.DB.Aura.OnlyShowPlayer and 1 or 0) -- debuff使用配置
    end

    header:SetAttribute('sortMethod', 'INDEX')
    header:SetAttribute('sortDirection', '+')
    header:SetAttribute('wrapAfter', cfg.wrapAfter)
    header:SetAttribute('maxWraps', cfg.maxWraps)
    header:SetAttribute('point', cfg.reverseGrow and 'TOPLEFT' or 'TOPRIGHT')
    header:SetAttribute('minWidth', (cfg.size + C.DB.Aura.Margin) * cfg.wrapAfter)
    header:SetAttribute('minHeight', (cfg.size + cfg.offset) * cfg.maxWraps)
    header:SetAttribute('xOffset', (cfg.reverseGrow and 1 or -1) * (cfg.size + C.DB.Aura.Margin))
    header:SetAttribute('yOffset', 0)
    header:SetAttribute('wrapXOffset', 0)
    header:SetAttribute('wrapYOffset', -(cfg.size + cfg.offset))
    header:SetAttribute('template', format(C.ADDON_TITLE .. 'AuraTemplate%d', cfg.size))

    local fontSize = floor(cfg.size / 30 * 10 + 0.5)
    local index = 1
    local child = select(index, header:GetChildren())
    while child do
        if (floor(child:GetWidth() * 100 + 0.5) / 100) ~= cfg.size then
            child:SetSize(cfg.size, cfg.size)
        end

        child.count:SetFont(C.Assets.Fonts.HalfHeight, fontSize, 'OUTLINE')
        child.timer:SetFont(C.Assets.Fonts.HalfHeight, fontSize, 'OUTLINE')

        -- Blizzard bug fix, icons arent being hidden when you reduce the amount of maximum buttons
        if index > (cfg.maxWraps * cfg.wrapAfter) and child:IsShown() then
            child:Hide()
        end

        index = index + 1
        child = select(index, header:GetChildren())
    end
end

function AURA:CreateAuraHeader(filter)
    local name = C.ADDON_TITLE .. 'PlayerDebuffs'
    if filter == 'HELPFUL' then
        name = C.ADDON_TITLE .. 'PlayerBuffs'
    end

    local header = CreateFrame('Frame', name, _G.UIParent, 'SecureAuraHeaderTemplate')
    header:SetClampedToScreen(true)
    header:UnregisterEvent('UNIT_AURA') -- we only need to watch player and vehicle
    header:RegisterUnitEvent('UNIT_AURA', 'player', 'vehicle')
    header:SetAttribute('unit', 'player')
    header:SetAttribute('filter', filter)
    header.filter = filter
    RegisterAttributeDriver(header, 'unit', '[vehicleui] vehicle; player')

    header.visibility = CreateFrame('Frame', nil, _G.UIParent, 'SecureHandlerStateTemplate')
    SecureHandlerSetFrameRef(header.visibility, 'AuraHeader', header)
    RegisterStateDriver(header.visibility, 'customVisibility', '[petbattle] 0;1')
    header.visibility:SetAttribute(
        '_onstate-customVisibility',
        [[
        local header = self:GetFrameRef('AuraHeader')
        local hide, shown = newstate == 0, header:IsShown()
        if hide and shown then header:Hide() elseif not hide and not shown then header:Show() end
    ]]
    ) -- use custom script that will only call hide when it needs to, this prevents spam to `SecureAuraHeader_Update`

    if filter == 'HELPFUL' then
        header:SetAttribute('consolidateDuration', -1)
        header:SetAttribute('includeWeapons', 1)
    end

    AURA:UpdateHeader(header)
    header:Show()

    return header
end

function AURA:Button_SetTooltip(button)
    if button:GetAttribute('index') then
        _G.GameTooltip:SetUnitAura(button.header:GetAttribute('unit'), button:GetID(), button.filter)
    elseif button:GetAttribute('target-slot') then
        _G.GameTooltip:SetInventoryItem('player', button:GetID())
    end
end

function AURA:Button_OnEnter()
    _G.GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMLEFT', -5, -5)
    -- Update tooltip
    self.nextUpdate = -1
    self:SetScript('OnUpdate', AURA.UpdateTimer)
end

local indexToOffset = { 2, 6, 10 }
function AURA:CreateAuraIcon(button)
    -- 在战斗中跳过，避免受保护框架的问题
    if InCombatLockdown() then
        return
    end
    
    -- 使用 pcall 保护整个函数，防止任何错误
    pcall(function()
        -- 只处理 Andromeda 自己创建的 aura 图标
        local buttonName = button and button.GetName and button:GetName()
        if not buttonName then
            return  -- 跳过没有名称的按钮
        end
        
        -- 检查按钮名称是否符合我们的模板模式
        local isAndromedaAura = strfind(buttonName, '^Andromeda') or strfind(buttonName, C.ADDON_TITLE)
        if not isAndromedaAura then
            return  -- 跳过非 Andromeda 创建的图标
        end
        
        button.header = button:GetParent()
        if not button.header then
            return
        end
        
        button.filter = button.header.filter
        button.name = buttonName
        local enchantIndex = tonumber(strmatch(buttonName, 'TempEnchant(%d)$'))
        button.enchantOffset = indexToOffset[enchantIndex]

        local cfg = AURA.settings.Debuffs
        if button.filter == 'HELPFUL' then
            cfg = AURA.settings.Buffs
        end
        local fontSize = floor(cfg.size / 30 * 10 + 0.5)

        button.icon = button:CreateTexture(nil, 'BORDER')
        if button.icon and button.icon.SetInside then
            button.icon:SetInside()
            button.icon:SetTexCoord(unpack(C.TEX_COORD))
        end

        button.count = button:CreateFontString(nil, 'ARTWORK')
        if button.count then
            button.count:SetPoint('CENTER', button, 'TOP')
            button.count:SetFont(C.Assets.Fonts.HalfHeight, fontSize, 'OUTLINE')
        end

        button.timer = button:CreateFontString(nil, 'ARTWORK')
        if button.timer then
            button.timer:SetPoint('CENTER', button, 'BOTTOM')
            button.timer:SetFont(C.Assets.Fonts.HalfHeight, fontSize, 'OUTLINE')
        end

        button.highlight = button:CreateTexture(nil, 'HIGHLIGHT')
        if button.highlight then
            button.highlight:SetColorTexture(1, 1, 1, 0.25)
            if button.highlight.SetInside then
                button.highlight:SetInside()
            end
        end

        if F.CreateBD then
            F.CreateBD(button, 0.25)
        end
        if F.CreateSD then
            F.CreateSD(button)
        end

        -- 安全注册点击（仅在非战斗状态）
        if button.RegisterForClicks and not InCombatLockdown() then
            pcall(function()
                button:RegisterForClicks('RightButtonUp')
            end)
        end
        
        -- 安全设置脚本
        if button.SetScript then
            if AURA.OnAttributeChanged then
                pcall(function() button:SetScript('OnAttributeChanged', AURA.OnAttributeChanged) end)
            end
            if AURA.Button_OnEnter then
                pcall(function() button:SetScript('OnEnter', AURA.Button_OnEnter) end)
            end
            if F.HideTooltip then
                pcall(function() button:SetScript('OnLeave', F.HideTooltip) end)
            end
        end
    end)

end

local auraAnchor = {
    unitToken = 'player',
    auraIndex = 1,
    parent = _G.UIParent,
    showCountdownFrame = true,
    showCountdownNumbers = true,

    iconInfo = {
        iconWidth = 30,
        iconHeight = 30,
        iconAnchor = {
            point = 'CENTER',
            relativeTo = _G.UIParent,
            relativePoint = 'CENTER',
            offsetX = 0,
            offsetY = 0,
        },
    },

    durationAnchor = {
        point = 'TOP',
        relativeTo = _G.UIParent,
        relativePoint = 'BOTTOM',
        offsetX = 0,
        offsetY = 0,
    },
}

function AURA:CreatePrivateAuras()
    if not C.IS_NEW_PATCH_10_1 then
        return
    end

    local maxButtons = 4 -- only 4 in blzz code, needs review
    local buttonSize = C.DB.Aura.PrivateSize
    local reverse = C.DB.Aura.PrivateReverse

    AURA.PrivateFrame = CreateFrame('Frame', 'NDuiPrivateAuras', _G.UIParent)
    AURA.PrivateFrame:SetSize((buttonSize + C.DB.Aura.Margin) * maxButtons - C.DB.Aura.Margin, buttonSize + 2 * C.DB.Aura.Margin)
    AURA.PrivateFrame.mover = F.Mover(AURA.PrivateFrame, 'PrivateAuras', 'PrivateAuras', { 'TOPRIGHT', AURA.DebuffFrame.mover, 'BOTTOMRIGHT', 0, -12 })
    AURA.PrivateFrame:ClearAllPoints()
    AURA.PrivateFrame:SetPoint('TOPRIGHT', AURA.PrivateFrame.mover)

    AURA.PrivateAuras = {}
    local prevButton

    local rel1 = reverse and 'TOPLEFT' or 'TOPRIGHT'
    local rel2 = reverse and 'LEFT' or 'RIGHT'
    local rel3 = reverse and 'RIGHT' or 'LEFT'
    local margin = reverse and C.DB.Aura.Margin or -C.DB.Aura.Margin

    for i = 1, maxButtons do
        local button = CreateFrame('Frame', '$parentAnchor' .. i, AURA.PrivateFrame)
        button:SetSize(buttonSize, buttonSize)
        if not prevButton then
            button:SetPoint(rel1, AURA.PrivateFrame)
        else
            button:SetPoint(rel2, prevButton, rel3, margin, 0)
        end
        prevButton = button

        auraAnchor.auraIndex = i
        auraAnchor.parent = button
        auraAnchor.durationAnchor.relativeTo = button
        auraAnchor.iconInfo.iconWidth = buttonSize
        auraAnchor.iconInfo.iconHeight = buttonSize
        auraAnchor.iconInfo.iconAnchor.relativeTo = button

        C_UnitAuras.RemovePrivateAuraAnchor(i)
        C_UnitAuras.AddPrivateAuraAnchor(auraAnchor)
        AURA.PrivateAuras[i] = button
    end
end

function AURA:OnLogin()
    if not C.DB.Aura.Enable then
        return
    end

    AURA:HideBlizzFrame()
    AURA:BuildBuffFrame()
end
