local F, C = unpack(select(2, ...))
local r, g, b = C.r or 1, C.g or 1, C.b or 1

local function nop() end

-- 替换纯蓝色状态条颜色为更柔和的蓝色
local function replaceBlueColor(bar, r, g, b)
    if r == 0 and g == 0 and b > .99 then
        bar:SetStatusBarColor(0, .6, 1, .5)
    end
end

function F:ReskinIconSelector()
    if not self then return end
    F.StripTextures(self)
    F.SetBD(self):SetInside()
    if self.BorderBox then
        F.StripTextures(self.BorderBox)
        if self.BorderBox.IconSelectorEditBox then
            F.StripTextures(self.BorderBox.IconSelectorEditBox, 2)
            F.ReskinEditbox(self.BorderBox.IconSelectorEditBox)
        end
        if self.BorderBox.SelectedIconArea and self.BorderBox.SelectedIconArea.SelectedIconButton then
            F.StripTextures(self.BorderBox.SelectedIconArea.SelectedIconButton)
            if self.BorderBox.SelectedIconArea.SelectedIconButton.Icon then
                F.ReskinIcon(self.BorderBox.SelectedIconArea.SelectedIconButton.Icon)
            end
        end
        if self.BorderBox.OkayButton then F.ReskinButton(self.BorderBox.OkayButton) end
        if self.BorderBox.CancelButton then F.ReskinButton(self.BorderBox.CancelButton) end
    end
    if self.IconSelector and self.IconSelector.ScrollBar then
        F.ReskinTrimScroll(self.IconSelector.ScrollBar)
    end

    if self.IconSelector and self.IconSelector.ScrollBox then
        hooksecurefunc(self.IconSelector.ScrollBox, 'Update', function(scrollBox)
            for i = 1, scrollBox.ScrollTarget:GetNumChildren() do
                local child = select(i, scrollBox.ScrollTarget:GetChildren())
                if child and child.Icon and not child.styled then
                    child:DisableDrawLayer('BACKGROUND')
                    if child.SelectedTexture then
                        child.SelectedTexture:SetColorTexture(1, 0.8, 0, 0.5)
                        child.SelectedTexture:SetAllPoints(child.Icon)
                    end
                    local hl = child:GetHighlightTexture()
                    if hl then
                        hl:SetColorTexture(1, 1, 1, 0.25)
                        hl:SetAllPoints(child.Icon)
                    end
                    F.ReskinIcon(child.Icon)
                    child.styled = true
                end
            end
        end)
    end
end

tinsert(C.BlizzThemes, function()
    if not _G.ANDROMEDA_ADB.ReskinBlizz then
        return
    end

    local r, g, b = C.r, C.g, C.b
    local x1, x2, y1, y2 = unpack(C.TEX_COORD)

    F.ReskinPortraitFrame(_G.CharacterFrame)
    F.StripTextures(_G.PaperDollFrame)

    local CHARACTERFRAME_SUBFRAMES = type(_G.CHARACTERFRAME_SUBFRAMES) == 'number' and _G.CHARACTERFRAME_SUBFRAMES or 5

    for i = 1, CHARACTERFRAME_SUBFRAMES do
        local tab = _G['CharacterFrameTab' .. i]
        if tab then
            tab.bg = F.ReskinTab(tab)
            local hl = _G['CharacterFrameTab' .. i .. 'HighlightTexture']
            if hl and tab.bg then
                hl:SetPoint('TOPLEFT', tab.bg, C.MULT, -C.MULT)
                hl:SetPoint('BOTTOMRIGHT', tab.bg, -C.MULT, C.MULT)
            end
        end
    end

    if _G.CharacterModelFrame then
        local bg = F.CreateBDFrame(_G.CharacterModelFrame, 0.25)
        bg:SetPoint('TOPLEFT', -2, 4)
        bg:SetPoint('BOTTOMRIGHT', _G.CharacterAttributesFrame, 2, -10)

        if F.ReskinRotationButtons then
            F.ReskinRotationButtons(_G.CharacterModelFrame)
        end
        _G.CharacterModelFrameRotateLeftButton:SetPoint('TOPLEFT', 3, -3)
        _G.CharacterModelFrameRotateRightButton:SetPoint('TOPLEFT', _G.CharacterModelFrameRotateLeftButton, 'TOPRIGHT', 3, 0)
    end

    if _G.CharacterModelScene then
        _G.CharacterModelScene:DisableDrawLayer('BACKGROUND')
        _G.CharacterModelScene:DisableDrawLayer('BORDER')
        _G.CharacterModelScene:DisableDrawLayer('OVERLAY')
    end

    if _G.PlayerStatFrameLeftDropdown then F.ReskinDropdown(_G.PlayerStatFrameLeftDropdown, 110) end
    if _G.PlayerStatFrameRightDropdown then F.ReskinDropdown(_G.PlayerStatFrameRightDropdown, 110) end
    if _G.PlayerTitleDropdown then F.ReskinDropdown(_G.PlayerTitleDropdown) end

    for _, direc in pairs({'Left', 'Right'}) do
        for i = 1, 6 do
            local frameName = 'PlayerStatFrame' .. direc .. i
            local label = _G[frameName .. 'Label']
            local text = _G[frameName .. 'StatText']
            if label then
                label:SetFontObject(Game13Font)
            end
            if text then
                text:SetFontObject(Game13Font)
            end
        end
    end

    if _G.CharacterAttributesFrame then
        F.StripTextures(_G.CharacterAttributesFrame)
        local bg = F.CreateBDFrame(_G.CharacterAttributesFrame, 0.25)
        bg:SetPoint('BOTTOMRIGHT', 0, -8)
    end

    local function colourPopout(self)
        if self.arrow then
            self.arrow:SetVertexColor(r, g, b)
        end
    end

    local function clearPopout(self)
        if self.arrow then
            self.arrow:SetVertexColor(1, 1, 1)
        end
    end

    local function updateCheckState(button, state)
        if button.bg then
            if state then
                button.bg:SetBackdropBorderColor(r, g, b)
            else
                button.bg:SetBackdropBorderColor(0, 0, 0)
            end
        end
    end

    local itemSlotData = {
        ['CharacterHeadSlot']          = 1,
        ['CharacterNeckSlot']          = 2,
        ['CharacterShoulderSlot']      = 3,
        ['CharacterShirtSlot']         = 4,
        ['CharacterChestSlot']          = 5,
        ['CharacterWaistSlot']          = 6,
        ['CharacterLegsSlot']           = 7,
        ['CharacterFeetSlot']          = 8,
        ['CharacterWristSlot']          = 9,
        ['CharacterHandsSlot']          = 10,
        ['CharacterFinger0Slot']       = 11,
        ['CharacterFinger1Slot']       = 12,
        ['CharacterTrinket0Slot']      = 13,
        ['CharacterTrinket1Slot']      = 14,
        ['CharacterBackSlot']           = 15,
        ['CharacterMainHandSlot']      = 16,
        ['CharacterSecondaryHandSlot']  = 17,
        ['CharacterRangedSlot']         = 18,
        ['CharacterTabardSlot']        = 19,
    }

    local function GetQualityColor(rarity)
        local r, g, b = GetItemQualityColor(rarity)
        if type(r) == 'table' then
            return r.r, r.g, r.b
        end
        return r, g, b
    end

    local function UpdateSlotQualityAndLevel(slotFrame)
        local slotName = slotFrame:GetName()
        local slotId = itemSlotData[slotName]
        if not slotId then return end

        -- 获取装备槽尺寸用于计算字体大小
        local slotWidth, slotHeight = slotFrame:GetSize()
        local fontSize = math.floor(math.min(slotWidth, slotHeight) * 0.32)
        fontSize = math.max(fontSize, 10)
        fontSize = math.min(fontSize, 14)
        local outline = _G.ANDROMEDA_ADB.FontOutline
        local fontFlag = outline and 'NONE' or 'THICK'
        local offset = math.floor(fontSize * 0.3)
        local innerOffset = math.floor(fontSize * 0.15)

        local rarity = GetInventoryItemQuality('player', slotId)
        if slotFrame.bg then
            if rarity and rarity > 1 then
                local cr, cg, cb = GetQualityColor(rarity)
                slotFrame.bg:SetBackdropBorderColor(cr, cg, cb)
            else
                slotFrame.bg:SetBackdropBorderColor(0, 0, 0)
            end
        end

        -- 清除所有文本
        if slotFrame.iLvl then
            slotFrame.iLvl:SetText('')
        end
        if slotFrame.durability then
            slotFrame.durability:SetText('')
        end

        local link = GetInventoryItemLink('player', slotId)
        if link then
            local _, _, _, itemLevel = GetItemInfo(link)

            -- 左下：装备等级
            if itemLevel and itemLevel > 0 and not (slotId == 4 or slotId == 19) then
                if not slotFrame.iLvl then
                    slotFrame.iLvl = F.CreateFS(slotFrame, C.Assets.Fonts.Bold, fontSize, outline or nil, '', nil, fontFlag, 'BOTTOMLEFT', innerOffset, innerOffset)
                end
                if slotFrame.iLvl then
                    slotFrame.iLvl:SetFont(C.Assets.Fonts.Bold, fontSize, outline and 'OUTLINE' or '')
                    slotFrame.iLvl:SetText(itemLevel)
                    if rarity and rarity > 1 then
                        local ir, ig, ib = GetQualityColor(rarity)
                        slotFrame.iLvl:SetTextColor(ir, ig, ib)
                    else
                        slotFrame.iLvl:SetTextColor(1, 1, 1)
                    end
                end
            end

            -- 左上：耐久度
            if slotId ~= 2 and slotId ~= 11 and slotId ~= 12 and slotId ~= 13 and slotId ~= 14 then
                local current, max = GetInventoryItemDurability(slotId)
                if current and max and max > 0 then
                    if not slotFrame.durability then
                        slotFrame.durability = F.CreateFS(slotFrame, C.Assets.Fonts.Bold, fontSize, outline or nil, '', nil, fontFlag, 'TOPLEFT', innerOffset, -innerOffset)
                    end
                    if slotFrame.durability then
                        slotFrame.durability:SetFont(C.Assets.Fonts.Bold, fontSize, outline and 'OUTLINE' or '')
                        local percent = math.floor(current / max * 100)
                        slotFrame.durability:SetText(percent .. '%')
                        if percent < 50 then
                            slotFrame.durability:SetTextColor(1, 0.82, 0)
                        elseif percent < 25 then
                            slotFrame.durability:SetTextColor(1, 0, 0)
                        else
                            slotFrame.durability:SetTextColor(0, 1, 0)
                        end
                    end
                end
            end
        end
    end

    local slots = {
        'Head', 'Neck', 'Shoulder', 'Shirt', 'Chest', 'Waist', 'Legs', 'Feet',
        'Wrist', 'Hands', 'Finger0', 'Finger1', 'Trinket0', 'Trinket1',
        'Back', 'MainHand', 'SecondaryHand', 'Tabard', 'Ranged',
    }

    local slotSize = 39

    for i = 1, #slots do
        local slot = _G['Character' .. slots[i] .. 'Slot']
        if slot then
            slot:SetSize(slotSize, slotSize)
            slot:SetNormalTexture(0)
            slot:SetPushedTexture(0)
            slot:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
            slot.SetHighlightTexture = nop
            if slot.icon then
                slot.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
                slot.icon:SetInside()
            end
            slot.bg = F.CreateBDFrame(slot, 0.25)

            -- 设置数量位置：右下
            if slot.Count then
                local outline = _G.ANDROMEDA_ADB.FontOutline
                local fontSize = math.floor(slotSize * 0.28)
                fontSize = math.max(fontSize, 10)
                F.SetFS(slot.Count, C.Assets.Fonts.Bold, fontSize, outline or nil, '', nil, outline and 'NONE' or 'THICK', 'BOTTOMRIGHT', -2, 2)
            end

            -- 设置冷却时间覆盖整个图标
            if slot.Cooldown then
                slot.Cooldown:ClearAllPoints()
                slot.Cooldown:SetPoint('TOPLEFT', slot.icon, 'TOPLEFT')
                slot.Cooldown:SetPoint('BOTTOMRIGHT', slot.icon, 'BOTTOMRIGHT')
            end

            local popout = slot.popoutButton
            if popout then
                popout:SetNormalTexture(0)
                popout:SetHighlightTexture(0)

                local arrow = popout:CreateTexture(nil, 'OVERLAY')
                arrow:SetSize(14, 14)
                if slot.verticalFlyout then
                    F.SetupArrow(arrow, 'down')
                    arrow:SetPoint('TOP', slot, 'BOTTOM', 0, 1)
                else
                    F.SetupArrow(arrow, 'right')
                    arrow:SetPoint('LEFT', slot, 'RIGHT', -1, 0)
                end
                popout.arrow = arrow

                colourPopout(popout)
                popout:HookScript('OnEnter', clearPopout)
                popout:HookScript('OnLeave', colourPopout)
            end
        end
    end

    hooksecurefunc('PaperDollItemSlotButton_Update', function(button)
        if button.icon then
            button.icon:SetShown(button.hasItem)
        end
        UpdateSlotQualityAndLevel(button)
    end)

    hooksecurefunc('PaperDollFrame_UpdateStats', function()
        for i = 1, #slots do
            local slot = _G['Character' .. slots[i] .. 'Slot']
            if slot then
                UpdateSlotQualityAndLevel(slot)
            end
        end
    end)

    local durabilityFrame = CreateFrame('Frame')
    durabilityFrame:RegisterEvent('UPDATE_INVENTORY_DURABILITY')
    durabilityFrame:SetScript('OnEvent', function()
        if PaperDollFrame:IsVisible() then
            for i = 1, #slots do
                local slot = _G['Character' .. slots[i] .. 'Slot']
                if slot then
                    UpdateSlotQualityAndLevel(slot)
                end
            end
        end
    end)

    if _G.CharacterAmmoSlot then
        F.StripTextures(_G.CharacterAmmoSlot)
        if _G.CharacterAmmoSlotIconTexture then
            _G.CharacterAmmoSlotIconTexture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        end
        _G.CharacterAmmoSlot:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
        F.CreateBDFrame(_G.CharacterAmmoSlot, 0.25)
    end

    local newResIcons = {136116, 135826, 136074, 135843, 135945}

    local ResistanceCoords = {
        {0.21875, 0.8125, 0.25, 0.32421875},
        {0.21875, 0.8125, 0.0234375, 0.09765625},
        {0.21875, 0.8125, 0.13671875, 0.2109375},
        {0.21875, 0.8125, 0.36328125, 0.4375},
        {0.21875, 0.8125, 0.4765625, 0.55078125},
    }

    for i = 1, 5 do
        local bu = _G['MagicResFrame' .. i]
        if bu then
            bu:SetSize(24, 24)

            if i ~= 1 then
                bu:ClearAllPoints()
                bu:SetPoint('TOP', _G['MagicResFrame' .. (i - 1)], 'BOTTOM', 0, -1)
            end

            local icon = bu:GetRegions()
            if icon then
                icon:SetInside()
                icon:SetTexCoord(unpack(ResistanceCoords[i]))
                icon:SetDrawLayer('ARTWORK')
            end
        end
    end

    for _, direc in pairs({'Left', 'Right'}) do
        for i = 1, 6 do
            local frameName = 'PlayerStatFrame' .. direc .. i
            local label = _G[frameName .. 'Label']
            local text = _G[frameName .. 'StatText']
            if label then label:SetFontObject(Game13Font) end
            if text then text:SetFontObject(Game13Font) end
        end
    end

    local pane = _G.CharacterStatsPane
    if pane then
        if pane.ClassBackground then
            pane.ClassBackground:Hide()
        end

        local categories = {pane.ItemLevelCategory, pane.AttributesCategory, pane.EnhancementsCategory}
        for _, category in pairs(categories) do
            if category then
                if category.Background then
                    category.Background:SetTexture('Interface\\LFGFrame\\UI-LFG-SEPARATOR')
                    category.Background:SetTexCoord(0, 0.66, 0, 0.31)
                    category.Background:SetVertexColor(r, g, b, 0.8)
                    category.Background:SetPoint('BOTTOMLEFT', -30, -4)
                end
                if category.Title then
                    category.Title:SetTextColor(r, g, b)
                end
            end
        end
    end

    if _G.PaperDollSidebarTabs then
        if _G.PaperDollSidebarTabs.DecorRight then
            _G.PaperDollSidebarTabs.DecorRight:Hide()
        end

        if _G.PAPERDOLL_SIDEBARS then
            for i = 1, #_G.PAPERDOLL_SIDEBARS do
                local tab = _G['PaperDollSidebarTab' .. i]
                if tab then
                    if i == 1 then
                        for j = 1, 4 do
                            local region = select(j, tab:GetRegions())
                            if region then
                                region:SetTexCoord(0.16, 0.86, 0.16, 0.86)
                                region.SetTexCoord = nop
                            end
                        end
                    end

                    tab.bg = F.CreateBDFrame(tab)
                    if tab.bg then
                        tab.bg:SetPoint('TOPLEFT', 2, -3)
                        tab.bg:SetPoint('BOTTOMRIGHT', 0, -2)
                    end

                    if tab.Icon then tab.Icon:SetInside(tab.bg) end
                    if tab.Hider then tab.Hider:SetInside(tab.bg); tab.Hider:SetColorTexture(0.3, 0.3, 0.3, 0.4) end
                    if tab.Highlight then tab.Highlight:SetInside(tab.bg); tab.Highlight:SetColorTexture(1, 1, 1, 0.25) end
                    if tab.TabBg then tab.TabBg:SetAlpha(0) end
                end
            end
        end
    end

    if _G.PaperDollFrameEquipSet then F.ReskinButton(_G.PaperDollFrameEquipSet) end
    if _G.PaperDollFrameSaveSet then F.ReskinButton(_G.PaperDollFrameSaveSet) end

    if _G.PaperDollFrame and _G.PaperDollFrame.EquipmentManagerPane then
        if _G.PaperDollFrame.EquipmentManagerPane.ScrollBar then
            F.ReskinTrimScroll(_G.PaperDollFrame.EquipmentManagerPane.ScrollBar)
        end

        if _G.PaperDollFrame.EquipmentManagerPane.ScrollBox then
            hooksecurefunc(_G.PaperDollFrame.EquipmentManagerPane.ScrollBox, 'Update', function(scrollBox)
                for i = 1, scrollBox.ScrollTarget:GetNumChildren() do
                    local child = select(i, scrollBox.ScrollTarget:GetChildren())
                    if child and child.icon and not child.styled then
                        if child.Stripe then F.HideObject(child.Stripe) end
                        if child.BgTop then child.BgTop:SetTexture('') end
                        if child.BgMiddle then child.BgMiddle:SetTexture('') end
                        if child.BgBottom then child.BgBottom:SetTexture('') end
                        F.ReskinIcon(child.icon)

                        if child.HighlightBar then
                            child.HighlightBar:SetColorTexture(1, 1, 1, 0.25)
                            child.HighlightBar:SetDrawLayer('BACKGROUND')
                        end
                        if child.SelectedBar then
                            child.SelectedBar:SetColorTexture(r, g, b, 0.25)
                            child.SelectedBar:SetDrawLayer('BACKGROUND')
                        end
                        if child.Check then
                            child.Check:SetAtlas('checkmark-minimal')
                        end

                        child.styled = true
                    end
                end
            end)
        end
    end

    if _G.GearManagerPopupFrame then
        F.ReskinIconSelector(_G.GearManagerPopupFrame)
    end

    if _G.PaperDollFrame and _G.PaperDollFrame.TitleManagerPane then
        if _G.PaperDollFrame.TitleManagerPane.ScrollBar then
            F.ReskinTrimScroll(_G.PaperDollFrame.TitleManagerPane.ScrollBar)
        end

        if _G.PaperDollFrame.TitleManagerPane.ScrollBox then
            hooksecurefunc(_G.PaperDollFrame.TitleManagerPane.ScrollBox, 'Update', function(scrollBox)
                for i = 1, scrollBox.ScrollTarget:GetNumChildren() do
                    local child = select(i, scrollBox.ScrollTarget:GetChildren())
                    if child and not child.styled then
                        child:DisableDrawLayer('BACKGROUND')
                        if child.Check then
                            child.Check:SetAtlas('checkmark-minimal')
                        end
                        child.styled = true
                    end
                end
            end)
        end
    end

    if _G.ReputationDetailCorner then _G.ReputationDetailCorner:Hide() end
    if _G.ReputationDetailDivider then _G.ReputationDetailDivider:Hide() end
    if _G.ReputationDetailFrame then
        _G.ReputationDetailFrame:SetPoint('TOPLEFT', _G.ReputationFrame, 'TOPRIGHT', -32, -16)
    end

    -- 声望状态条美化 (NDui 风格)
    local function UpdateFactionSkins()
        for i = 1, _G.GetNumFactions() do
            local statusbar = _G['ReputationBar' .. i .. 'ReputationBar']
            if statusbar then
                statusbar:SetStatusBarTexture(C.Assets.Textures.StatusbarNormal)

                if not statusbar.reskinned then
                    F.CreateBDFrame(statusbar, 0.25)
                    statusbar.reskinned = true
                end

                _G['ReputationBar' .. i .. 'Background']:SetTexture(nil)
                _G['ReputationBar' .. i .. 'ReputationBarHighlight1']:SetTexture(nil)
                _G['ReputationBar' .. i .. 'ReputationBarHighlight2']:SetTexture(nil)
                _G['ReputationBar' .. i .. 'ReputationBarAtWarHighlight1']:SetTexture(nil)
                _G['ReputationBar' .. i .. 'ReputationBarAtWarHighlight2']:SetTexture(nil)
                _G['ReputationBar' .. i .. 'ReputationBarLeftTexture']:SetTexture(nil)
                _G['ReputationBar' .. i .. 'ReputationBarRightTexture']:SetTexture(nil)
            end
        end
    end
    _G.ReputationFrame:HookScript('OnShow', UpdateFactionSkins)
    _G.ReputationFrame:HookScript('OnEvent', UpdateFactionSkins)

    -- 折叠按钮美化 (NDui 风格)
    for i = 1, _G.NUM_FACTIONS_DISPLAYED do
        F.ReskinCollapse(_G['ReputationBar' .. i .. 'ExpandOrCollapseButton'])
    end

    if _G.ReputationFrame then F.StripTextures(_G.ReputationFrame) end
    if _G.ReputationDetailFrame then
        F.StripTextures(_G.ReputationDetailFrame)
        F.SetBD(_G.ReputationDetailFrame)
    end
    if _G.ReputationDetailCloseButton then F.ReskinClose(_G.ReputationDetailCloseButton) end
    if _G.ReputationDetailInactiveCheckbox then F.ReskinCheckbox(_G.ReputationDetailInactiveCheckbox) end
    if _G.ReputationDetailMainScreenCheckbox then F.ReskinCheckbox(_G.ReputationDetailMainScreenCheckbox) end
    if _G.ReputationListScrollFrameScrollBar then F.ReskinScroll(_G.ReputationListScrollFrameScrollBar) end
    select(3, _G.ReputationDetailFrame:GetRegions()):Hide()

    if _G.ReputationDetailAtWarCheckbox then
        local atWarCheck = _G.ReputationDetailAtWarCheckbox
        F.ReskinCheckbox(atWarCheck)
        local atWarCheckTex = atWarCheck:GetCheckedTexture()
        atWarCheckTex:ClearAllPoints()
        atWarCheckTex:SetSize(26, 26)
        atWarCheckTex:SetPoint('CENTER')
    end

    -- 美化声望详情框架内的滚动条和背景
    if _G.ReputationDetailScrollFrameScrollBar then
        F.ReskinScroll(_G.ReputationDetailScrollFrameScrollBar)
    end
    if _G.ReputationDetailScrollFrame then
        F.CreateBDFrame(_G.ReputationDetailScrollFrame, 0.25)
    end

    -- TokenFrame
    -- 改进 Paragon 奖励图标样式
    if _G.ReputationFrame and _G.ReputationFrame.paragonFramesPool then
        hooksecurefunc(_G.ReputationFrame.paragonFramesPool, 'Acquire', function(self)
            for frame in self:EnumerateActive() do
                if frame and frame.Glow and not frame._styled then
                    frame.Glow:SetTexture(C.Assets.Textures.Glow)
                    frame.Check:SetTexture(C.Assets.Textures.Tick)
                    frame._styled = true
                end
            end
        end)
    end

    if _G.TokenFrame then
        F.StripTextures(_G.TokenFrame)
        if _G.TokenFrameCancelButton then F.ReskinButton(_G.TokenFrameCancelButton) end
        local weirdCloseBtn = select(4, _G.TokenFrame:GetChildren())
        if weirdCloseBtn then weirdCloseBtn:Hide() end
    end

    if _G.TokenFramePopupCorner then _G.TokenFramePopupCorner:Hide() end
    if _G.TokenFramePopup then
        _G.TokenFramePopup:SetPoint('TOPLEFT', _G.TokenFrame, 'TOPRIGHT', 3, -28)
        F.StripTextures(_G.TokenFramePopup)
        F.SetBD(_G.TokenFramePopup)
        if _G.TokenFramePopup.CloseButton then F.ReskinClose(_G.TokenFramePopup.CloseButton) end
        if _G.TokenFramePopup.InactiveCheckBox then F.ReskinCheckbox(_G.TokenFramePopup.InactiveCheckBox) end
        if _G.TokenFramePopup.BackpackCheckBox then F.ReskinCheckbox(_G.TokenFramePopup.BackpackCheckBox) end
    end

    if _G.TokenFrameContainerScrollBar then
        F.ReskinScroll(_G.TokenFrameContainerScrollBar)
    end

    local function updateTokenButtons()
        local buttons = _G.TokenFrameContainer and _G.TokenFrameContainer.buttons
        if not buttons then return end

        for i = 1, #buttons do
            local bu = buttons[i]
            if not bu.styled then
                bu.highlight:SetPoint('TOPLEFT', 1, 0)
                bu.highlight:SetPoint('BOTTOMRIGHT', -1, 0)
                bu.highlight.SetPoint = nop
                bu.highlight:SetColorTexture(r, g, b, 0.2)
                bu.highlight.SetTexture = nop

                if bu.categoryLeft then bu.categoryLeft:SetAlpha(0) end
                if bu.categoryRight then bu.categoryRight:SetAlpha(0) end
                if bu.categoryMiddle then bu.categoryMiddle:SetAlpha(0) end

                if bu.icon then
                    bu.bg = F.ReskinIcon(bu.icon)
                end

                if bu.expandIcon then
                    bu.expBg = F.CreateBDFrame(bu.expandIcon, 0, true)
                    bu.expBg:SetPoint('TOPLEFT', bu.expandIcon, -3, 3)
                    bu.expBg:SetPoint('BOTTOMRIGHT', bu.expandIcon, 3, -3)
                end

                bu.styled = true
            end

            if bu.isHeader then
                if bu.bg then bu.bg:Hide() end
                if bu.expBg then bu.expBg:Show() end
            else
                if bu.bg then bu.bg:Show() end
                if bu.expBg then bu.expBg:Hide() end
            end
        end
    end

    if _G.TokenFrame then
        _G.TokenFrame:HookScript('OnShow', updateTokenButtons)
    end
    hooksecurefunc('TokenFrame_Update', updateTokenButtons)
    if _G.TokenFrameContainer then
        hooksecurefunc(_G.TokenFrameContainer, 'update', updateTokenButtons)
    end

    if _G.SkillFrame then
        F.StripTextures(_G.SkillFrame)
        if _G.SkillListScrollFrameScrollBar then F.ReskinScroll(_G.SkillListScrollFrameScrollBar) end
        
        -- ElvUI 风格：隐藏 CancelButton（重复的关闭按钮）
        if _G.SkillFrameCancelButton then _G.SkillFrameCancelButton:Hide() end
        
        -- ElvUI 风格：处理 CollapseAllButton
        if _G.SkillFrameCollapseAllButton then
            F.ReskinCollapse(_G.SkillFrameCollapseAllButton)
            if _G.SkillFrameExpandTabLeft then
                _G.SkillFrameCollapseAllButton:SetPoint('LEFT', _G.SkillFrameExpandTabLeft, 'RIGHT', -40, -3)
            end
        end
        
        -- ElvUI 风格：禁用展开按钮框架的背景层
        if _G.SkillFrameExpandButtonFrame then
            _G.SkillFrameExpandButtonFrame:DisableDrawLayer('BACKGROUND')
        end

        if _G.SkillDetailScrollFrameScrollBar then
            F.ReskinScroll(_G.SkillDetailScrollFrameScrollBar)
        end
        if _G.SkillDetailScrollFrame then
            F.CreateBDFrame(_G.SkillDetailScrollFrame, 0.25)
        end

        if _G.SkillDetailStatusBar then
            F.StripTextures(_G.SkillDetailStatusBar)
            _G.SkillDetailStatusBar:SetParent(_G.SkillDetailScrollFrame)
            _G.SkillDetailStatusBar:SetStatusBarTexture(C.Assets.Textures.StatusbarNormal)
            F.CreateBDFrame(_G.SkillDetailStatusBar, 0.25)
            hooksecurefunc(_G.SkillDetailStatusBar, 'SetStatusBarColor', replaceBlueColor)
        end

        -- ElvUI 风格：处理技能取消学习按钮
        if _G.SkillDetailStatusBarUnlearnButton then
            F.ReskinButton(_G.SkillDetailStatusBarUnlearnButton)
            local bu = _G.SkillDetailStatusBarUnlearnButton
            bu.__bg = F.CreateBDFrame(bu)
            bu.__bg:SetInside(nil, 7, 7)
            bu:SetSize(26, 26)
            bu:SetPoint('LEFT', _G.SkillDetailStatusBarBorder or _G.SkillDetailStatusBar, 'RIGHT', 5, 0)
            bu:SetHitRectInsets(0, 0, 0, 0)
            local tex = bu:CreateTexture()
            tex:SetTexture(C.Assets.Textures.Close)
            tex:SetVertexColor(1, 0, 0)
            tex:SetAllPoints(bu.__bg)
        end

        for i = 1, _G.SKILLS_TO_DISPLAY do
            local name = 'SkillRankFrame'..i
            local bar = _G[name]
            local label = _G['SkillTypeLabel'..i]
            local border = _G[name..'Border']
            local background = _G[name..'Background']

            if bar then
                bar:SetStatusBarTexture(C.Assets.Textures.StatusbarNormal)
                F.CreateBDFrame(bar, 0.25)
                hooksecurefunc(bar, 'SetStatusBarColor', replaceBlueColor)
            end

            if border then border:SetAlpha(0) end
            if background then background:SetTexture(nil) end

            -- ElvUI 风格：处理技能类型标签
            if label then
                F.ReskinCollapse(label)
            end
        end
    end

    if _G.PetPaperDollFrame then
        F.StripTextures(_G.PetPaperDollFrame)
        if _G.PetPaperDollCloseButton then _G.PetPaperDollCloseButton:Hide() end

        if _G.PetPaperDollFrameExpBar then
            F.StripTextures(_G.PetPaperDollFrameExpBar)
            _G.PetPaperDollFrameExpBar:SetStatusBarTexture(C.Assets.Textures.StatusbarNormal)
            F.SetBD(_G.PetPaperDollFrameExpBar)
        end

        if _G.PetModelFrame then
            if F.ReskinRotationButtons then
                F.ReskinRotationButtons(_G.PetModelFrame)
            end
            _G.PetModelFrameRotateLeftButton:ClearAllPoints()
            _G.PetModelFrameRotateLeftButton:SetPoint('TOPLEFT', 3, -3)
            _G.PetModelFrameRotateRightButton:ClearAllPoints()
            _G.PetModelFrameRotateRightButton:SetPoint('TOPLEFT', _G.PetModelFrameRotateLeftButton, 'TOPRIGHT', 3, 0)
        end

        if _G.PetAttributesFrame then
            F.StripTextures(_G.PetAttributesFrame)
            F.CreateBDFrame(_G.PetAttributesFrame, 0.25)
        end

        for i = 1, 3 do
            local tab = _G['PetPaperDollFrameTab'..i]
            if tab then F.ReskinTab(tab) end
        end

        if _G.PetPaperDollFrameCompanionFrame then
            F.StripTextures(_G.PetPaperDollFrameCompanionFrame)
        end
        if _G.CompanionSummonButton then
            F.ReskinButton(_G.CompanionSummonButton)
        end
        if _G.CompanionModelFrame then
            if F.ReskinRotationButtons then
                F.ReskinRotationButtons(_G.CompanionModelFrame)
            end
        end
        if _G.CompanionPrevPageButton then F.ReskinArrow(_G.CompanionPrevPageButton, 'left') end
        if _G.CompanionNextPageButton then F.ReskinArrow(_G.CompanionNextPageButton, 'right') end

        for i = 1, 12 do
            local button = _G['CompanionButton' .. i]
            if button then
                button.bg = F.CreateBDFrame(button, 0.25)
                button:SetCheckedTexture(0)
                local activeTex = _G['CompanionButton' .. i .. 'ActiveTexture']
                if activeTex then activeTex:SetAlpha(0) end

                button:SetNormalTexture(136243)
                local nt = button:GetNormalTexture()
                if nt then
                    nt:SetTexCoord(x1, x2, y1, y2)
                    nt:SetInside(button.bg)
                end

                local dt = button:GetDisabledTexture()
                if dt then
                    dt:SetTexCoord(0.22, 0.75, 0.22, 0.75)
                    dt:SetInside(button.bg)
                end

                local hl = button:GetHighlightTexture()
                if hl then
                    hl:SetColorTexture(1, 1, 1, 0.25)
                    hl:SetInside(button.bg)
                end

                hooksecurefunc(button, 'SetChecked', updateCheckState)
            end
        end

        for i = 1, 5 do
            local bu = _G['PetMagicResFrame' .. i]
            if bu then
                bu:SetSize(25, 25)
                local icon = bu:GetRegions()
                if icon then
                    local a, b, _, _, _, _, c, d = icon:GetTexCoord()
                    icon:SetTexCoord(a + 0.2, c - 0.2, b + 0.018, d - 0.018)
                end
            end
        end

        -- 宠物抗性框架背景 (ElvUI 风格)
        if _G.PetResistanceFrame then
            local petResBG = F.CreateBDFrame(_G.PetResistanceFrame, 0.25)
            if petResBG and _G.PetMagicResFrame1 and _G.PetMagicResFrame5 then
                petResBG:SetPoint('TOPLEFT', _G.PetMagicResFrame1, -2, 2)
                petResBG:SetPoint('BOTTOMRIGHT', _G.PetMagicResFrame5, 2, -2)
            end
        end

        if _G.PetPaperDollPetInfo then
            local petInfo = _G.PetPaperDollPetInfo
            petInfo:SetPoint('TOPLEFT', _G.PetModelFrameRotateLeftButton, 'BOTTOMLEFT', 9, -3)
            petInfo:GetRegions():SetTexCoord(0.04, 0.15, 0.06, 0.30)
            petInfo:SetFrameLevel(petInfo:GetFrameLevel() + 2)
            petInfo:SetSize(24, 24)

            local function updateHappiness()
                local happiness = GetPetHappiness()
                local _, isHunterPet = HasPetUI()
                if not happiness or not isHunterPet then return end

                local texture = petInfo:GetRegions()
                if happiness == 1 then
                    texture:SetTexCoord(0.41, 0.53, 0.06, 0.3)
                elseif happiness == 2 then
                    texture:SetTexCoord(0.22, 0.345, 0.06, 0.3)
                elseif happiness == 3 then
                    texture:SetTexCoord(0.04, 0.15, 0.06, 0.3)
                end
            end
            petInfo:RegisterEvent('UNIT_HAPPINESS')
            petInfo:SetScript('OnEvent', updateHappiness)
            petInfo:SetScript('OnShow', updateHappiness)
        end
    end

    if not _G.PVPFrame.CloseButton then
        _G.PVPFrame.CloseButton = _G.PVPParentFrameCloseButton
    end
    F.ReskinPortraitFrame(_G.PVPFrame, 15, -15, -35, 73)

    if _G.PVPFrameToggleButton then F.ReskinArrow(_G.PVPFrameToggleButton, 'right') end

    for i = 1, 2 do
        local tab = _G['PVPParentFrameTab' .. i]
        if tab then F.ReskinTab(tab) end
    end

    for i = 1, 3 do
        local tName = 'PVPTeam' .. i
        F.StripTextures(_G[tName])
        F.CreateBDFrame(_G[tName .. 'Background'], 0.25)
    end

    F.ReskinPortraitFrame(_G.PVPTeamDetails, 12, -12, -5, 5)
    if _G.PVPTeamDetailsAddTeamMember then F.ReskinButton(_G.PVPTeamDetailsAddTeamMember) end
    if _G.PVPTeamDetailsToggleButton then F.ReskinArrow(_G.PVPTeamDetailsToggleButton, 'right') end

    for i = 1, 5 do
        F.StripTextures(_G['PVPTeamDetailsFrameColumnHeader' .. i])
    end

    local toggleButton = _G.GearManagerToggleButton
    if toggleButton then
        F.StripTextures(toggleButton)
        local function setupTexture(tex)
            tex:SetTexture('Interface\\PaperDollInfoFrame\\PaperDollSidebarTabs')
            tex:SetTexCoord(0.01562500, 0.53125000, 0.46875000, 0.60546875)
            tex:SetInside()
        end
        local icon = toggleButton:CreateTexture(nil, 'ARTWORK')
        setupTexture(icon)
        local hl = toggleButton:CreateTexture(nil, 'HIGHLIGHT')
        setupTexture(hl)
        hl:SetVertexColor(1, 0.8, 0)
    end

    if _G.GearManagerDialog then
        F.StripTextures(_G.GearManagerDialog)
        F.SetBD(_G.GearManagerDialog, nil, 5, -5, 0, 5)
        if _G.GearManagerDialogClose then F.ReskinClose(_G.GearManagerDialogClose, nil, -6, -9) end
        if _G.GearManagerDialogDeleteSet then F.ReskinButton(_G.GearManagerDialogDeleteSet) end
        if _G.GearManagerDialogEquipSet then F.ReskinButton(_G.GearManagerDialogEquipSet) end
        if _G.GearManagerDialogSaveSet then F.ReskinButton(_G.GearManagerDialogSaveSet) end

        for i = 1, _G.MAX_EQUIPMENT_SETS_PER_PLAYER do
            local button = _G['GearSetButton' .. i]
            if button then
                button.bg = F.CreateBDFrame(button, 0.25)
                button:DisableDrawLayer('BACKGROUND')
                button:SetCheckedTexture(0)
                hooksecurefunc(button, 'SetChecked', updateCheckState)

                local hl = button:GetHighlightTexture()
                if hl then
                    hl:SetColorTexture(1, 1, 1, 0.25)
                    hl:SetInside(button.bg)
                end

                local icon = button.icon
                if icon then
                    icon:SetTexCoord(x1, x2, y1, y2)
                    icon:SetInside(button.bg)
                end

                _G['GearSetButton' .. i .. 'Name']:SetFontObject(Game12Font)
                _G['GearSetButton' .. i .. 'Name']:SetWidth(50)
            end
        end
    end

    hooksecurefunc('PaperDollFrameItemFlyout_CreateButton', function()
        local button = _G.PaperDollFrameItemFlyout.buttons[#_G.PaperDollFrameItemFlyout.buttons]
        if button.bg then return end

        button:SetNormalTexture(0)
        button:SetPushedTexture(0)
        button:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
        button.bg = F.ReskinIcon(button.icon)
    end)

    if _G.PaperDollFrameItemFlyoutButtons then
        _G.PaperDollFrameItemFlyoutButtons.bg1:SetAlpha(0)
        _G.PaperDollFrameItemFlyoutButtons:DisableDrawLayer('ARTWORK')
        F.SetBD(_G.PaperDollFrameItemFlyoutButtons)
        hooksecurefunc(_G.PaperDollFrameItemFlyoutButtons, 'SetWidth', function(self, width, force)
            if force then return end
            self:SetWidth(width + 3, true)
        end)
    end

    if _G.GearManagerDialogPopup then
        F.StripTextures(_G.GearManagerDialogPopup)
        F.SetBD(_G.GearManagerDialogPopup, nil, 5, -6, 0, 5)
        _G.GearManagerDialogPopup:SetHeight(525)
        if _G.GearManagerDialogPopupScrollFrame then F.StripTextures(_G.GearManagerDialogPopupScrollFrame) end
        if _G.GearManagerDialogPopupScrollFrame then F.CreateBDFrame(_G.GearManagerDialogPopupScrollFrame, 0.25) end
        if _G.GearManagerDialogPopupScrollFrameScrollBar then F.ReskinScroll(_G.GearManagerDialogPopupScrollFrameScrollBar) end
        if _G.GearManagerDialogPopupOkayButton then F.ReskinButton(_G.GearManagerDialogPopupOkayButton) end
        if _G.GearManagerDialogPopupCancelButton then F.ReskinButton(_G.GearManagerDialogPopupCancelButton) end

        for i = 1, _G.NUM_GEARSET_ICONS_SHOWN do
            local bu = _G['GearManagerDialogPopupButton' .. i]
            if bu then
                bu:SetCheckedTexture(C.Assets.Textures.ButtonChecked)
                select(2, bu:GetRegions()):Hide()
                if bu.icon then bu.icon:SetInside() end
                F.ReskinIcon(bu.icon)
                local hl = bu:GetHighlightTexture()
                if hl then
                    hl:SetColorTexture(1, 1, 1, 0.25)
                    hl:SetInside()
                end
            end
        end
    end

    if _G.QuickJoinFrame then
        if _G.QuickJoinFrame.ScrollBar then F.ReskinTrimScroll(_G.QuickJoinFrame.ScrollBar) end
        if _G.QuickJoinFrame.JoinQueueButton then F.ReskinButton(_G.QuickJoinFrame.JoinQueueButton) end
    end

    if _G.QuickJoinRoleSelectionFrame then
        F.StripTextures(_G.QuickJoinRoleSelectionFrame)
        F.SetBD(_G.QuickJoinRoleSelectionFrame)
        if _G.QuickJoinRoleSelectionFrame.AcceptButton then F.ReskinButton(_G.QuickJoinRoleSelectionFrame.AcceptButton) end
        if _G.QuickJoinRoleSelectionFrame.CancelButton then F.ReskinButton(_G.QuickJoinRoleSelectionFrame.CancelButton) end
        if _G.QuickJoinRoleSelectionFrame.CloseButton then F.ReskinClose(_G.QuickJoinRoleSelectionFrame.CloseButton) end

        if _G.QuickJoinRoleSelectionFrame.RoleButtonTank then F.ReskinRole(_G.QuickJoinRoleSelectionFrame.RoleButtonTank, 'TANK') end
        if _G.QuickJoinRoleSelectionFrame.RoleButtonHealer then F.ReskinRole(_G.QuickJoinRoleSelectionFrame.RoleButtonHealer, 'HEALER') end
        if _G.QuickJoinRoleSelectionFrame.RoleButtonDPS then F.ReskinRole(_G.QuickJoinRoleSelectionFrame.RoleButtonDPS, 'DPS') end
    end

    -- 荣誉框架美化 (ElvUI 风格)
    if _G.HonorFrame then
        F.StripTextures(_G.HonorFrame)

        if _G.HonorFrameProgressBar then
            F.StripTextures(_G.HonorFrameProgressBar)
            _G.HonorFrameProgressBar:SetHeight(22)
            _G.HonorFrameProgressBar:SetParent(_G.HonorFrame)
            _G.HonorFrameProgressBar:SetStatusBarTexture(C.Assets.Textures.StatusbarNormal)
            F.SetBD(_G.HonorFrameProgressBar)
        end
    end
end)