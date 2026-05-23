local F, C, L = unpack(select(2, ...))
local ACTIONBAR = F:GetModule('ActionBar')
local LAB = F.Libs.LibActionButton

function ACTIONBAR:UpdateAllSize()
    if not C.DB['Actionbar']['Enable'] then
        return
    end

    ACTIONBAR:UpdateSize('Bar1')
    ACTIONBAR:UpdateSize('Bar2')
    ACTIONBAR:UpdateSize('Bar3')
    ACTIONBAR:UpdateSize('Bar4')
    ACTIONBAR:UpdateSize('Bar5')
    ACTIONBAR:UpdateSize('Bar6')
    ACTIONBAR:UpdateSize('Bar7')
    ACTIONBAR:UpdateSize('Bar8')
    ACTIONBAR:UpdateSize('BarPet')
    ACTIONBAR:UpdateStanceBar()
    ACTIONBAR:UpdateVehicleBar()
end

function ACTIONBAR:UpdateButtonFont(button, fontSize)
    local font = C.Assets.Fonts.Condensed

    if button.Name then
        button.Name:SetFont(font, fontSize, 'OUTLINE')
    end
    if button.Count then
        button.Count:SetFont(font, fontSize, 'OUTLINE')
    end
    if button.HotKey then
        button.HotKey:SetFont(font, fontSize, 'OUTLINE')
    end
end

function ACTIONBAR:UpdateSize(name)
    local frame = _G[C.ADDON_TITLE .. 'Action' .. name]

    if not frame then
        return
    end

    local size = C.DB['Actionbar'][name .. 'ButtonSize']
    local num = name == 'BarPet' and 10 or C.DB['Actionbar'][name .. 'ButtonNum']
    local perRow = C.DB['Actionbar'][name .. 'ButtonPerRow']
    local fontSize = C.DB['Actionbar'][name .. 'FontSize']
    local margin = C.DB['Actionbar']['ButtonMargin']
    local padding = C.DB['Actionbar']['BarPadding']
    local isSpecialBar = name == 'BarPet'

    if num == 0 then
        local column = 3
        local rows = 2
        frame:SetWidth(3 * size + (column - 1) * margin + 2 * padding)
        frame:SetHeight(size * rows + (rows - 1) * margin + 2 * padding)
        frame.mover:SetSize(frame:GetSize())
        if frame.child then
            frame.child:SetSize(frame:GetSize())
            frame.child.mover:SetSize(frame:GetSize())
            frame.child.mover.isDisable = false
        end

        for i = 1, 12 do
            local button = frame.buttons[i]
            button:SetSize(size, size)
            button:ClearAllPoints()
            if i == 1 then
                button:SetPoint('TOPLEFT', frame, padding, -padding)
            elseif i == 7 then
                button:SetPoint('TOPLEFT', frame.child or frame, padding, -padding)
            elseif mod(i - 1, 3) == 0 then
                button:SetPoint('TOP', frame.buttons[i - 3], 'BOTTOM', 0, -margin)
            else
                button:SetPoint('LEFT', frame.buttons[i - 1], 'RIGHT', margin, 0)
            end

            button:Show()
            ACTIONBAR:UpdateButtonFont(button, fontSize)
        end
    else
        for i = 1, num do
            local button = frame.buttons[i]
            button:SetSize(size, size)
            button:ClearAllPoints()

            if i == 1 then
                if isSpecialBar then
                    button:SetPoint('BOTTOMLEFT', frame, padding, padding)
                else
                    button:SetPoint('TOPLEFT', frame, padding, -padding)
                end
            elseif mod(i - 1, perRow) == 0 then
                if isSpecialBar then
                    button:SetPoint('BOTTOM', frame.buttons[i - perRow], 'TOP', 0, margin)
                else
                    button:SetPoint('TOP', frame.buttons[i - perRow], 'BOTTOM', 0, -margin)
                end
            else
                button:SetPoint('LEFT', frame.buttons[i - 1], 'RIGHT', margin, 0)
            end

            button:Show()
            ACTIONBAR:UpdateButtonFont(button, fontSize)
        end

        for i = num + 1, 12 do
            local button = frame.buttons[i]
            if not button then
                break
            end
            button:Hide()
        end

        local column = min(num, perRow)
        local rows = ceil(num / perRow)
        frame:SetWidth(column * size + (column - 1) * margin + 2 * padding)
        frame:SetHeight(size * rows + (rows - 1) * margin + 2 * padding)
        frame.mover:SetSize(frame:GetSize())
        if frame.child then
            frame.child.mover.isDisable = true
        end
    end
end

local directions = { 'UP', 'DOWN', 'LEFT', 'RIGHT' }
function ACTIONBAR:UpdateButtonConfig(i)
    if not self.buttonConfig then
        self.buttonConfig = {
            hideElements = {},
            text = {
                hotkey = { font = {}, position = {} },
                count = { font = {}, position = {} },
                macro = { font = {}, position = {} },
            },
        }
    end
    self.buttonConfig.clickOnDown = true
    self.buttonConfig.showGrid = true -- always show empty slots
    self.buttonConfig.flyoutDirection = directions[C.DB['Actionbar']['Bar' .. i .. 'Flyout']]

    local hotkey = self.buttonConfig.text.hotkey
    hotkey.font.font = C.Assets.Fonts.Condensed
    hotkey.font.size = C.DB['Actionbar']['Bar' .. i .. 'FontSize']
    hotkey.font.flags = 'OUTLINE,Monochrome'
    --hotkey.font.flags = 'Monochrome'
    hotkey.position.anchor = 'TOPLEFT'
    hotkey.position.relAnchor = false
    hotkey.position.offsetX = 2
    hotkey.position.offsetY = -2
    hotkey.justifyH = 'LEFT'

    local count = self.buttonConfig.text.count
    count.font.font = C.Assets.Fonts.Condensed
    count.font.size = C.DB['Actionbar']['Bar' .. i .. 'FontSize']
    count.font.flags = 'OUTLINE'
    count.position.anchor = 'BOTTOMRIGHT'
    count.position.relAnchor = false
    count.position.offsetX = -2
    count.position.offsetY = 2
    count.justifyH = 'RIGHT'

    local macro = self.buttonConfig.text.macro
    macro.font.font = C.Assets.Fonts.Condensed
    macro.font.size = C.DB['Actionbar']['Bar' .. i .. 'FontSize']
    macro.font.flags = 'OUTLINE'
    macro.position.anchor = 'BOTTOM'
    macro.position.relAnchor = false
    macro.position.offsetX = 0
    macro.position.offsetY = 2
    macro.justifyH = 'CENTER'

    local hideElements = self.buttonConfig.hideElements
    hideElements.hotkey = not C.DB['Actionbar']['ShowHotkey']
    hideElements.macro = not C.DB['Actionbar']['ShowMacroName']
    hideElements.equipped = not C.DB['Actionbar']['EquipColor']

    local lockBars = GetCVarBool('lockActionBars')
    for _, button in next, self.buttons do
        self.buttonConfig.keyBoundTarget = button.bindName
        button.keyBoundTarget = self.buttonConfig.keyBoundTarget

        button:SetAttribute('buttonlock', lockBars)

        button:SetAttribute('unlockedpreventdrag', not lockBars) -- make sure button can drag without being click
        button:SetAttribute('checkmouseovercast', true)
        button:SetAttribute('checkfocuscast', true)
        button:SetAttribute('checkselfcast', true)
        -- button:SetAttribute('*unit2', 'player')
        button:UpdateConfig(self.buttonConfig)

        if C.DB['Actionbar']['ClassColor'] then
            button.__bg:SetBackdropColor(C.r, C.g, C.b, 0.25)
        else
            button.__bg:SetBackdropColor(0.2, 0.2, 0.2, 0.25)
        end
    end
end

local fullPage =
'[bar:6]6;[bar:5]5;[bar:4]4;[bar:3]3;[bar:2]2;[possessbar]16;[overridebar]18;[shapeshift]17;[vehicleui]16;[bonusbar:5]11;[bonusbar:4]10;[bonusbar:3]9;[bonusbar:2]8;[bonusbar:1]7;1'

function ACTIONBAR:UpdateVisibility()
    for i = 1, 8 do
        local frame = _G[C.ADDON_TITLE .. 'ActionBar' .. i]
        if frame then
            if C.DB['Actionbar']['Bar' .. i] then
                frame:Show()
                frame.mover.isDisable = false
                RegisterStateDriver(frame, 'visibility', frame.visibility)
            else
                frame:Hide()
                frame.mover.isDisable = true
                UnregisterStateDriver(frame, 'visibility')
            end
        end
    end
end

function ACTIONBAR:UpdateBarConfig()
    for i = 1, 8 do
        local frame = _G[C.ADDON_TITLE .. 'ActionBar' .. i]
        if frame then
            ACTIONBAR.UpdateButtonConfig(frame, i)
        end
    end
end

function ACTIONBAR:ReassignBindings()
    if InCombatLockdown() then
        return
    end

    for index = 1, 8 do
        local frame = ACTIONBAR.headers[index]
        for _, button in next, frame.buttons do
            local keyName = button.keyBoundTarget
            if keyName then
                local ok, key = pcall(GetBindingKey, keyName)
                if ok and key and key ~= '' then
                    SetOverrideBindingClick(frame, false, key, button:GetName(), 'Keybind')
                end
            end
        end
    end
end

function ACTIONBAR:ClearBindings()
    if InCombatLockdown() then
        return
    end

    for index = 1, 8 do
        local frame = ACTIONBAR.headers[index]
        ClearOverrideBindings(frame)
    end
end

function ACTIONBAR:CreateBars()
    ACTIONBAR.headers = {}

    for index = 1, 8 do
        ACTIONBAR.headers[index] = CreateFrame('Frame', C.ADDON_TITLE .. 'ActionBar' .. index, _G.UIParent,
            'SecureHandlerStateTemplate')
    end

    local margin = C.DB['Actionbar']['ButtonMargin']
    local padding = C.DB['Actionbar']['BarPadding']

    local barData = {
        [1] = { page = 1, bindName = 'ACTIONBUTTON', anchor = { 'BOTTOM', _G.UIParent, 'BOTTOM', 0, 24 } },
        [2] = { page = 6, bindName = 'MULTIACTIONBAR1BUTTON', anchor = { 'BOTTOM', _G[C.ADDON_TITLE .. 'ActionBar1'], 'TOP', 0, 0 } },
        [3] = { page = 5, bindName = 'MULTIACTIONBAR2BUTTON', anchor = { 'BOTTOM', _G[C.ADDON_TITLE .. 'ActionBar2'], 'TOP', 0, 0 } },
        [4] = { page = 3, bindName = 'MULTIACTIONBAR3BUTTON', anchor = { 'BOTTOM', _G[C.ADDON_TITLE .. 'ActionBar3'], 'TOP', 0, 0 } },
        [5] = { page = 4, bindName = 'MULTIACTIONBAR4BUTTON', anchor = { 'BOTTOM', _G[C.ADDON_TITLE .. 'ActionBar4'], 'TOP', 0, 0 } },
        [6] = { page = 13, bindName = 'MULTIACTIONBAR5BUTTON', anchor = { 'BOTTOM', _G[C.ADDON_TITLE .. 'ActionBar5'], 'TOP', 0, 0 } },
        [7] = { page = 14, bindName = 'MULTIACTIONBAR6BUTTON', anchor = { 'BOTTOM', _G[C.ADDON_TITLE .. 'ActionBar6'], 'TOP', 0, 0 } },
        [8] = { page = 15, bindName = 'MULTIACTIONBAR7BUTTON', anchor = { 'BOTTOM', _G[C.ADDON_TITLE .. 'ActionBar7'], 'TOP', 0, 0 } },

    }

    local mIndex = 1
    for index = 1, 8 do
        local data = barData[index]
        local frame = ACTIONBAR.headers[index]

        frame.mover = F.Mover(frame, L['Actionbar'] .. index, 'Bar' .. index, data.anchor)
        ACTIONBAR.movers[mIndex] = frame.mover
        mIndex = mIndex + 1

        frame.buttons = {}

        for i = 1, 12 do
            local button = LAB:CreateButton(i, '$parentButton' .. i, frame)
            button:SetState(0, 'action', i)
            for k = 1, 18 do
                button:SetState(k, 'action', (k - 1) * 12 + i)
            end

            if i == 12 then
                button:SetState(GetVehicleBarIndex(), 'custom', {
                    func = function()
                        if UnitExists('vehicle') then
                            VehicleExit()
                        else
                            PetDismiss()
                        end
                    end,

                    texture = 136190, -- Spell_Shadow_SacrificialShield
                    tooltip = _G.LEAVE_VEHICLE,
                })
            end

            button.MasqueSkinned = true
            button.bindName = data.bindName .. i

            tinsert(frame.buttons, button)
            tinsert(ACTIONBAR.buttons, button)
        end

        frame.visibility = '[petbattle] hide; show'

        frame:SetAttribute(
            '_onstate-page',
            [[
            self:SetAttribute("state", newstate)
            control:ChildUpdate("state", newstate)
        ]]
        )
        RegisterStateDriver(frame, 'page', index == 1 and fullPage or data.page)
    end

    LAB.RegisterCallback(ACTIONBAR, 'OnButtonUpdate', ACTIONBAR.UpdateEquipedBorder)

    if LAB.flyoutHandler then
        LAB.flyoutHandler.Background:Hide()

        for _, button in next, LAB.FlyoutButtons do
            ACTIONBAR:HandleButton(button)
        end
    end

    local function delayUpdate()
        ACTIONBAR:UpdateBarConfig()
        F:UnregisterEvent('PLAYER_REGEN_ENABLED', delayUpdate)
    end

    F:RegisterEvent('CVAR_UPDATE', function(_, var)
        if var == 'lockActionBars' then
            if InCombatLockdown() then
                F:RegisterEvent('PLAYER_REGEN_ENABLED', delayUpdate)
                return
            end

            ACTIONBAR:UpdateBarConfig()
        end
    end)
end
