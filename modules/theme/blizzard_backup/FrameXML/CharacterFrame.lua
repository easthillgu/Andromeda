local F, C = unpack(select(2, ...))

function F:ReskinIconSelector()
    F.StripTextures(self)
    F.SetBD(self):SetInside()
    F.StripTextures(self.BorderBox)
    F.StripTextures(self.BorderBox.IconSelectorEditBox, 2)
    F.ReskinEditbox(self.BorderBox.IconSelectorEditBox)
    F.StripTextures(self.BorderBox.SelectedIconArea.SelectedIconButton)
    F.ReskinIcon(self.BorderBox.SelectedIconArea.SelectedIconButton.Icon)
    F.ReskinButton(self.BorderBox.OkayButton)
    F.ReskinButton(self.BorderBox.CancelButton)
    F.ReskinTrimScroll(self.IconSelector.ScrollBar)

    hooksecurefunc(self.IconSelector.ScrollBox, 'Update', function(self)
        for i = 1, self.ScrollTarget:GetNumChildren() do
            local child = select(i, self.ScrollTarget:GetChildren())
            if child.Icon and not child.styled then
                child:DisableDrawLayer('BACKGROUND')
                child.SelectedTexture:SetColorTexture(1, 0.8, 0, 0.5)
                child.SelectedTexture:SetAllPoints(child.Icon)
                local hl = child:GetHighlightTexture()
                hl:SetColorTexture(1, 1, 1, 0.25)
                hl:SetAllPoints(child.Icon)
                F.ReskinIcon(child.Icon)

                child.styled = true
            end
        end
    end)
end

tinsert(C.BlizzThemes, function()
    if not _G.ANDROMEDA_ADB.ReskinBlizz then
        return
    end

    local r, g, b = C.r, C.g, C.b

    local function replaceBlueColor(bar, red, green, blue)
        if red == 0 and green == 0 and blue > 0.99 then
            bar:SetStatusBarColor(0, 0.6, 1, 0.5)
        end
    end

    local function replaceHonorIcon(texture, t1, t2)
        if texture.isCutting then
            return
        end
        texture.isCutting = true

        if t1 == 0.03125 and t2 == 0.59375 then
            local faction = UnitFactionGroup('player') or 'Horde'
            texture:SetTexture('Interface\\PVPFrame\\PVP-Currency-' .. faction)
        end
        texture:SetTexCoord(unpack(C.TEX_COORD))

        texture.isCutting = nil
    end

    F.ReskinPortraitFrame(_G.CharacterFrame)
    F.StripTextures(_G.CharacterFrameInsetRight)

    for i = 1, 4 do
        local tab = _G['CharacterFrameTab' .. i]
        if tab then
            F.ReskinTab(tab)
            if i ~= 1 then
                tab:ClearAllPoints()
                tab:SetPoint('TOPLEFT', _G['CharacterFrameTab' .. (i - 1)], 'TOPRIGHT', -10, 0)
            end
        end
    end

    _G.CharacterModelScene:DisableDrawLayer('BACKGROUND')
    _G.CharacterModelScene:DisableDrawLayer('BORDER')
    _G.CharacterModelScene:DisableDrawLayer('OVERLAY')

    -- [[ Item buttons ]]

    local function colourPopout(self)
        local aR, aG, aB
        local glow = self:GetParent().IconBorder

        if glow:IsShown() then
            aR, aG, aB = glow:GetVertexColor()
        else
            aR, aG, aB = r, g, b
        end

        self.arrow:SetVertexColor(aR, aG, aB)
    end

    local function clearPopout(self)
        self.arrow:SetVertexColor(1, 1, 1)
    end

    local function UpdateAzeriteItem(self)
        if not self.styled then
            self.AzeriteTexture:SetAlpha(0)
            self.RankFrame.Texture:SetTexture('')
            self.RankFrame.Label:ClearAllPoints()
            self.RankFrame.Label:SetPoint('TOPLEFT', self, 2, -1)
            self.RankFrame.Label:SetTextColor(1, 0.5, 0)

            self.styled = true
        end
    end

    local function UpdateAzeriteEmpoweredItem(self)
        self.AzeriteTexture:SetAtlas('AzeriteIconFrame')
        self.AzeriteTexture:SetInside()
        self.AzeriteTexture:SetDrawLayer('BORDER', 1)
    end

    local function UpdateHighlight(self)
        local highlight = self:GetHighlightTexture()
        highlight:SetColorTexture(1, 1, 1, 0.25)
        highlight:SetInside(self.bg)
    end

    local function UpdateCosmetic(self)
        local itemLink = GetInventoryItemLink('player', self:GetID())
        self.IconOverlay:SetShown(itemLink and IsCosmeticItem(itemLink))
    end

    local slots = {
        'Head',
        'Neck',
        'Shoulder',
        'Shirt',
        'Chest',
        'Waist',
        'Legs',
        'Feet',
        'Wrist',
        'Hands',
        'Finger0',
        'Finger1',
        'Trinket0',
        'Trinket1',
        'Back',
        'MainHand',
        'SecondaryHand',
        'Tabard',
    }

    for i = 1, #slots do
        local slot = _G['Character' .. slots[i] .. 'Slot']
        local cooldown = _G['Character' .. slots[i] .. 'SlotCooldown']

        F.StripTextures(slot)
        slot.icon:SetTexCoord(unpack(C.TEX_COORD))
        slot.icon:SetInside()
        slot.bg = F.CreateBDFrame(slot.icon, 0.25)
        slot.bg:SetFrameLevel(3)
        cooldown:SetInside()

        slot.ignoreTexture:SetTexture('Interface\\PaperDollInfoFrame\\UI-GearManager-LeaveItem-Transparent')
        slot.IconOverlay:SetInside()
        F.ReskinIconBorder(slot.IconBorder)

        local popout = slot.popoutButton
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

        popout:HookScript('OnEnter', clearPopout)
        popout:HookScript('OnLeave', colourPopout)

        hooksecurefunc(slot, 'DisplayAsAzeriteItem', UpdateAzeriteItem)
        hooksecurefunc(slot, 'DisplayAsAzeriteEmpoweredItem', UpdateAzeriteEmpoweredItem)
    end

    hooksecurefunc('PaperDollItemSlotButton_Update', function(button)
        -- also fires for bag slots, we don't want that
        if button.popoutButton then
            button.icon:SetShown(GetInventoryItemTexture('player', button:GetID()) ~= nil)
            colourPopout(button.popoutButton)
        end
        UpdateCosmetic(button)
        UpdateHighlight(button)
    end)

    -- [[ Stats pane ]]

    local pane = _G.CharacterStatsPane
    pane.ClassBackground:Hide()
    pane.ItemLevelFrame.Corruption:SetPoint('RIGHT', 22, -8)

    local categories = { pane.ItemLevelCategory, pane.AttributesCategory, pane.EnhancementsCategory }
    for _, category in pairs(categories) do
        category.Background:SetTexture('Interface\\LFGFrame\\UI-LFG-SEPARATOR')
        category.Background:SetTexCoord(0, 0.66, 0, 0.31)
        category.Background:SetVertexColor(r, g, b, 0.8)
        category.Background:SetPoint('BOTTOMLEFT', -30, -4)

        category.Title:SetTextColor(r, g, b)
    end

    -- [[ Sidebar tabs ]]

    if _G.PaperDollSidebarTabs.DecorRight then
        _G.PaperDollSidebarTabs.DecorRight:Hide()
    end

    for i = 1, #_G.PAPERDOLL_SIDEBARS do
        local tab = _G['PaperDollSidebarTab' .. i]

        if i == 1 then
            for i = 1, 4 do
                local region = select(i, tab:GetRegions())
                region:SetTexCoord(0.16, 0.86, 0.16, 0.86)
                region.SetTexCoord = nop
            end
        end

        tab.bg = F.CreateBDFrame(tab)
        tab.bg:SetPoint('TOPLEFT', 2, -3)
        tab.bg:SetPoint('BOTTOMRIGHT', 0, -2)

        tab.Icon:SetInside(tab.bg)
        tab.Hider:SetInside(tab.bg)
        tab.Highlight:SetInside(tab.bg)
        tab.Highlight:SetColorTexture(1, 1, 1, 0.25)
        tab.Hider:SetColorTexture(0.3, 0.3, 0.3, 0.4)
        tab.TabBg:SetAlpha(0)
    end

    -- [[ Equipment manager ]]

    F.ReskinButton(_G.PaperDollFrameEquipSet)
    F.ReskinButton(_G.PaperDollFrameSaveSet)
    F.ReskinTrimScroll(_G.PaperDollFrame.EquipmentManagerPane.ScrollBar)

    hooksecurefunc(_G.PaperDollFrame.EquipmentManagerPane.ScrollBox, 'Update', function(self)
        for i = 1, self.ScrollTarget:GetNumChildren() do
            local child = select(i, self.ScrollTarget:GetChildren())
            if child.icon and not child.styled then
                F.HideObject(child.Stripe)
                child.BgTop:SetTexture('')
                child.BgMiddle:SetTexture('')
                child.BgBottom:SetTexture('')
                F.ReskinIcon(child.icon)

                child.HighlightBar:SetColorTexture(1, 1, 1, 0.25)
                child.HighlightBar:SetDrawLayer('BACKGROUND')
                child.SelectedBar:SetColorTexture(r, g, b, 0.25)
                child.SelectedBar:SetDrawLayer('BACKGROUND')
                child.Check:SetAtlas('checkmark-minimal')

                child.styled = true
            end
        end
    end)

    F.ReskinIconSelector(_G.GearManagerPopupFrame)

    -- Title Pane
    F.ReskinTrimScroll(_G.PaperDollFrame.TitleManagerPane.ScrollBar)

    hooksecurefunc(_G.PaperDollFrame.TitleManagerPane.ScrollBox, 'Update', function(self)
        for i = 1, self.ScrollTarget:GetNumChildren() do
            local child = select(i, self.ScrollTarget:GetChildren())
            if not child.styled then
                child:DisableDrawLayer('BACKGROUND')
                child.Check:SetAtlas('checkmark-minimal')

                child.styled = true
            end
        end
    end)

    -- Reputation Frame
    _G.ReputationDetailFrame:SetPoint('TOPLEFT', _G.ReputationFrame, 'TOPRIGHT', 3, -28)

    local function updateReputationBars(self)
        for i = 1, self.ScrollTarget:GetNumChildren() do
            local child = select(i, self.ScrollTarget:GetChildren())
            local container = child and child.Container
            if container and not container.styled then
                F.StripTextures(container)
                if container.ExpandOrCollapseButton then
                    F.ReskinCollapse(container.ExpandOrCollapseButton)
                    container.ExpandOrCollapseButton.__texture:DoCollapse(child.isCollapsed)
                end
                if container.ReputationBar then
                    F.StripTextures(container.ReputationBar)
                    container.ReputationBar:SetStatusBarTexture(C.Assets.Textures.Backdrop)
                    F.CreateBDFrame(container.ReputationBar, 0.25)
                end

                container.styled = true
            end
        end
    end
    hooksecurefunc(_G.ReputationFrame.ScrollBox, 'Update', updateReputationBars)

    F.ReskinTrimScroll(_G.ReputationFrame.ScrollBar)
    F.StripTextures(_G.ReputationDetailFrame)
    F.SetBD(_G.ReputationDetailFrame)
    F.ReskinClose(_G.ReputationDetailCloseButton)
    F.ReskinCheckbox(_G.ReputationDetailInactiveCheckBox)
    F.ReskinCheckbox(_G.ReputationDetailMainScreenCheckBox)
    F.ReskinButton(_G.ReputationDetailViewRenownButton)

    local atWarCheck = _G.ReputationDetailAtWarCheckBox
    F.ReskinCheckbox(atWarCheck)
    local atWarCheckTex = atWarCheck:GetCheckedTexture()
    atWarCheckTex:ClearAllPoints()
    atWarCheckTex:SetSize(26, 26)
    atWarCheckTex:SetPoint('CENTER')

    -- Skill Frame
    if _G.SkillFrame then
        F.StripTextures(_G.SkillFrame)
        F.ReskinPortraitFrame(_G.SkillFrame)
        F.ReskinTrimScroll(_G.SkillListScrollFrameScrollBar)
        F.ReskinButton(_G.SkillFrameCancelButton)
        F.ReskinCollapse(_G.SkillFrameCollapseAllButton)
        F.StripTextures(_G.SkillFrameExpandButtonFrame)

        if _G.SkillDetailScrollFrame then
            F.ReskinTrimScroll(_G.SkillDetailScrollFrame.ScrollBar)
            F.CreateBDFrame(_G.SkillDetailScrollFrame, 0.25)
        end

        if _G.SkillDetailStatusBar then
            _G.SkillDetailStatusBarBorder:SetAlpha(0)
            _G.SkillDetailStatusBar:SetStatusBarTexture(C.Assets.Textures.Backdrop)
            F.CreateBDFrame(_G.SkillDetailStatusBar, 0.25)
            hooksecurefunc(_G.SkillDetailStatusBar, 'SetStatusBarColor', replaceBlueColor)
        end

        if _G.SkillDetailStatusBarUnlearnButton then
            local button = _G.SkillDetailStatusBarUnlearnButton
            F.ReskinButton(button)
            button:ClearAllPoints()
            button:SetPoint('LEFT', _G.SkillDetailStatusBar, 'RIGHT', 2, 0)
        end

        for i = 1, 12 do
            local skillTypeLabel = _G['SkillTypeLabel' .. i]
            if skillTypeLabel then
                F.ReskinCollapse(skillTypeLabel)
            end

            local name = 'SkillRankFrame' .. i
            local bar = _G[name]
            if bar then
                bar:SetStatusBarTexture(C.Assets.Textures.Backdrop)
                F.CreateBDFrame(bar, 0.25)
                hooksecurefunc(bar, 'SetStatusBarColor', replaceBlueColor)
            end

            local border = _G[name .. 'Border']
            if border then
                border:SetAlpha(0)
            end
        end

        hooksecurefunc(_G.SkillFrame.ScrollBox, 'Update', function(self)
            for i = 1, self.ScrollTarget:GetNumChildren() do
                local child = select(i, self.ScrollTarget:GetChildren())
                if child and not child.styled then
                    if child.AbilityBackground then
                        child.AbilityBackground:Hide()
                    end
                    if child.StatusBar then
                        F.StripTextures(child.StatusBar)
                        child.StatusBar:SetStatusBarTexture(C.Assets.Textures.Backdrop)
                        F.CreateBDFrame(child.StatusBar, 0.25)
                    end
                    if child.highlight then
                        child.highlight:SetColorTexture(1, 1, 1, 0.25)
                    end
                    child.styled = true
                end
            end
        end)

        for i = 1, _G.SKILL_FRAME_SKILL_TABS do
            local tab = _G['SkillFrameTab' .. i]
            if tab then
                F.ReskinTab(tab)
            end
        end
    end

    -- Token frame
    if _G.TokenFrame then
        F.StripTextures(_G.TokenFrame)
        F.ReskinButton(_G.TokenFrameCancelButton)

        for _, child in next, {_G.TokenFrame:GetChildren()} do
            if child:IsObjectType('Button') and child:GetName() and not child:GetName():match('Cancel') then
                child:Hide()
            end
        end

        if _G.TokenFramePopup then
            if _G.TokenFramePopupCorner then
                _G.TokenFramePopupCorner:Hide()
            end
            _G.TokenFramePopup:SetPoint('TOPLEFT', _G.TokenFrame, 'TOPRIGHT', 3, -28)
            F.StripTextures(_G.TokenFramePopup)
            F.SetBD(_G.TokenFramePopup)
            F.ReskinClose(_G.TokenFramePopupCloseButton)
            F.ReskinCheckbox(_G.TokenFramePopupInactiveCheckbox)
            F.ReskinCheckbox(_G.TokenFramePopupBackpackCheckbox)
        end

        F.ReskinTrimScroll(_G.TokenFrameContainerScrollBar)

        local function updateTokenButtons()
            local buttons = _G.TokenFrameContainer and _G.TokenFrameContainer.buttons
            if not buttons then
                return
            end

            for i = 1, #buttons do
                local bu = buttons[i]

                if not bu.styled then
                    bu.highlight:SetPoint('TOPLEFT', 1, 0)
                    bu.highlight:SetPoint('BOTTOMRIGHT', -1, 0)
                    bu.highlight.SetPoint = nop
                    bu.highlight:SetColorTexture(r, g, b, 0.2)
                    bu.highlight.SetTexture = nop

                    if bu.categoryLeft then
                        bu.categoryLeft:SetAlpha(0)
                    end
                    if bu.categoryRight then
                        bu.categoryRight:SetAlpha(0)
                    end
                    if bu.categoryMiddle then
                        bu.categoryMiddle:SetAlpha(0)
                    end

                    if bu.icon then
                        bu.bg = F.ReskinIcon(bu.icon)
                        hooksecurefunc(bu.icon, 'SetTexCoord', replaceHonorIcon)
                    end

                    if bu.expandIcon then
                        bu.expBg = F.CreateBDFrame(bu.expandIcon, 0, true)
                        bu.expBg:SetPoint('TOPLEFT', bu.expandIcon, -3, 3)
                        bu.expBg:SetPoint('BOTTOMRIGHT', bu.expandIcon, 3, -3)
                    end

                    bu.styled = true
                end

                if bu.isHeader then
                    if bu.bg then
                        bu.bg:Hide()
                    end
                    if bu.expBg then
                        bu.expBg:Show()
                    end
                else
                    if bu.bg then
                        bu.bg:Show()
                    end
                    if bu.expBg then
                        bu.expBg:Hide()
                    end
                end
            end
        end

        _G.TokenFrame:HookScript('OnShow', updateTokenButtons)
        hooksecurefunc('TokenFrame_Update', updateTokenButtons)
        if _G.TokenFrameContainer then
            hooksecurefunc(_G.TokenFrameContainer, 'update', updateTokenButtons)
        end
    end

    -- Quick Join
    F.ReskinTrimScroll(_G.QuickJoinFrame.ScrollBar)
    F.ReskinButton(_G.QuickJoinFrame.JoinQueueButton)

    F.SetBD(_G.QuickJoinRoleSelectionFrame)
    F.ReskinButton(_G.QuickJoinRoleSelectionFrame.AcceptButton)
    F.ReskinButton(_G.QuickJoinRoleSelectionFrame.CancelButton)
    F.ReskinClose(_G.QuickJoinRoleSelectionFrame.CloseButton)
    F.StripTextures(_G.QuickJoinRoleSelectionFrame)

    F.ReskinRole(_G.QuickJoinRoleSelectionFrame.RoleButtonTank, 'TANK')
    F.ReskinRole(_G.QuickJoinRoleSelectionFrame.RoleButtonHealer, 'HEALER')
    F.ReskinRole(_G.QuickJoinRoleSelectionFrame.RoleButtonDPS, 'DPS')
end)
