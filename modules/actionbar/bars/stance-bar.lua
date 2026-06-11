local F, C, L = unpack(select(2, ...))
local ACTIONBAR = F:GetModule('ActionBar')

local num = _G.NUM_STANCE_SLOTS or 10

function ACTIONBAR:UpdateStanceBar()
    if InCombatLockdown() then
        return
    end

    local frame = _G[C.ADDON_TITLE .. 'ActionBarStance']
    if not frame then
        return
    end

    local size = C.DB['Actionbar']['BarStanceButtonSize']
    local fontSize = C.DB['Actionbar']['BarStanceFontSize']
    local perRow = C.DB['Actionbar']['BarStanceButtonPerRow']
    local margin = C.DB['Actionbar']['ButtonMargin']
    local padding = C.DB['Actionbar']['BarPadding']

    for i = 1, num do
        local button = frame.buttons[i]
        if button then
            button:SetSize(size, size)
            button:ClearAllPoints()
            if i == 1 then
                button:SetPoint('BOTTOMLEFT', frame, padding, padding)
            else
                button:SetPoint('LEFT', frame.buttons[i - 1], 'RIGHT', margin, 0)
            end
            ACTIONBAR:UpdateButtonFont(button, fontSize)
        end
    end

    frame:SetWidth(num * size + (num - 1) * margin + 2 * padding)
    frame:SetHeight(size + 2 * padding)
    frame.mover:SetSize(size, size)
end

function ACTIONBAR:UpdateStance()
    local inCombat = InCombatLockdown()
    local numForms = GetNumShapeshiftForms()
    local texture, isActive, isCastable

    for i = 1, numForms do
        local button = _G['StanceButton' .. i]
        if not button then
            break
        end

        if not inCombat then
            button:Show()
        end

        texture, isActive, isCastable = GetShapeshiftFormInfo(i)
        if texture then
            button.icon:SetTexture(texture)
            button.icon:SetTexCoord(0.1, 0.9, 0.13, 0.87)
            button.icon:Show()

            if isActive then
                button:SetChecked(true)
            else
                button:SetChecked(false)
            end

            if isCastable then
                button.icon:SetVertexColor(1.0, 1.0, 1.0)
            else
                button.icon:SetVertexColor(0.4, 0.4, 0.4)
            end
        else
            button.icon:Hide()
            button:Hide()
        end
    end

    if not inCombat then
        for i = numForms + 1, num do
            local button = _G['StanceButton' .. i]
            if button then
                button:Hide()
            end
        end
    end
end

function ACTIONBAR:StanceBarOnEvent(event)
    if event == 'UPDATE_SHAPESHIFT_COOLDOWN' then
        for i = 1, num do
            local button = _G['StanceButton' .. i]
            if button and button:IsShown() then
                local start, duration, enable = GetShapeshiftFormCooldown(i)
                CooldownFrame_Set(button.cooldown, start, duration, enable)
            end
        end
    else
        ACTIONBAR:UpdateStanceBar()
        ACTIONBAR.UpdateStance(_G.StanceBar)
    end
end

function ACTIONBAR:CreateStanceBar()
    if not C.DB['Actionbar']['BarStance'] then
        return
    end

    local margin = C.DB['Actionbar']['ButtonMargin']
    local padding = C.DB['Actionbar']['BarPadding']
    local buttonList = {}
    local success, frame = pcall(CreateFrame, 'Frame', C.ADDON_TITLE .. 'ActionBarStance', _G.UIParent,
        'SecureHandlerStateTemplate')
    if not success then
        frame = CreateFrame('Frame', C.ADDON_TITLE .. 'ActionBarStance', _G.UIParent)
    end

    if C.DB['UIAnchor']['StanceBar'] then
        C.DB['UIAnchor']['StanceBar'] = nil
    end

    frame.mover = F.Mover(frame, L['StanceBar'], 'StanceBar',
        { 'BOTTOMLEFT', _G[C.ADDON_TITLE .. 'ActionBar3'], 'TOPLEFT', 0, padding })

    ACTIONBAR.movers[11] = frame.mover

    -- StanceBar
    _G.StanceBar:SetParent(frame)
    _G.StanceBar:EnableMouse(true)
    _G.StanceBar:UnregisterAllEvents()

    for i = 1, num do
        local button = _G['StanceButton' .. i]
        button:SetParent(frame)
        tinsert(buttonList, button)
        tinsert(ACTIONBAR.buttons, button)
    end
    frame.buttons = buttonList

    -- Fix stance bar updating
    ACTIONBAR:StanceBarOnEvent()
    F:RegisterEvent('UPDATE_SHAPESHIFT_FORM', ACTIONBAR.StanceBarOnEvent)
    F:RegisterEvent('UPDATE_SHAPESHIFT_FORMS', ACTIONBAR.StanceBarOnEvent)
    F:RegisterEvent('UPDATE_SHAPESHIFT_USABLE', ACTIONBAR.StanceBarOnEvent)
    F:RegisterEvent('UPDATE_SHAPESHIFT_COOLDOWN', ACTIONBAR.StanceBarOnEvent)

    frame.frameVisibility = '[petbattle][overridebar][vehicleui][possessbar][shapeshift] hide; show'
    RegisterStateDriver(frame, 'visibility', frame.frameVisibility)
end

-- 确保登录时更新姿态条
F:RegisterEvent('PLAYER_LOGIN', function()
    F:Delay(1, function()
        ACTIONBAR:UpdateStanceBar()
    end)
end)
