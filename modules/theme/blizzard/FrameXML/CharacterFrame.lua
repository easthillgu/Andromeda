local F, C = unpack(select(2, ...))

function F:ReskinIconSelector()
    F.StripTextures(self)
    if not self then return end
    F.SetBD(self):SetInside()
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

    -- CharacterFrame portrait
    if _G.CharacterFrame then
        F.ReskinPortraitFrame(_G.CharacterFrame)
    end
    if _G.CharacterFrameInsetRight then
        F.StripTextures(_G.CharacterFrameInsetRight)
    end

    -- Tabs
    for i = 1, 5 do
        local tab = _G['CharacterFrameTab' .. i]
        if tab then
            F.ReskinTab(tab)
            if i ~= 1 then
                local prev = _G['CharacterFrameTab' .. (i - 1)]
                if prev then
                    tab:ClearAllPoints()
                    tab:SetPoint('TOPLEFT', prev, 'TOPRIGHT', -10, 0)
                end
            end
        end
    end

    -- 3.80.1: CharacterModelScene may not exist (Retail 3D model)
    if _G.CharacterModelScene then
        _G.CharacterModelScene:DisableDrawLayer('BACKGROUND')
        _G.CharacterModelScene:DisableDrawLayer('BORDER')
        _G.CharacterModelScene:DisableDrawLayer('OVERLAY')
    end

    -- [[ Item buttons ]]

    local function colourPopout(self)
        local aR, aG, aB = r, g, b
        local glow = self:GetParent().IconBorder
        if glow and glow:IsShown() then
            aR, aG, aB = glow:GetVertexColor()
        end
        if self.arrow then
            self.arrow:SetVertexColor(aR, aG, aB)
        end
    end

    local function clearPopout(self)
        if self.arrow then
            self.arrow:SetVertexColor(1, 1, 1)
        end
    end

    local function UpdateHighlight(self)
        local highlight = self:GetHighlightTexture()
        if highlight and self.bg then
            highlight:SetColorTexture(1, 1, 1, 0.25)
            highlight:SetInside(self.bg)
        end
    end

    -- 3.80.1: UpdateCosmetic removed — IsCosmeticItem not available
    local function UpdateCosmetic(self)
        -- no-op in 3.80.1
    end

    local slots = {
        'Head', 'Neck', 'Shoulder', 'Shirt', 'Chest', 'Waist', 'Legs', 'Feet',
        'Wrist', 'Hands', 'Finger0', 'Finger1', 'Trinket0', 'Trinket1',
        'Back', 'MainHand', 'SecondaryHand', 'Tabard', 'Ranged',
    }

    for i = 1, #slots do
        local slot = _G['Character' .. slots[i] .. 'Slot']
        if slot then  -- 3.80.1: skip nil slots, don't break

        -- NDui-style slot stripping (3.80.1: SetNormalTexture(nil) ignored, use Hide)
        local nt = slot:GetNormalTexture()
        if nt then nt:Hide() end
        local pt = slot:GetPushedTexture()
        if pt then pt:Hide() end
        local hl = slot:GetHighlightTexture()
        if hl then
            hl:SetColorTexture(1, 1, 1, 0.25)
        end
        -- Prevent Blizzard from restoring highlight texture
        slot.SetHighlightTexture = function() end

        if slot.icon then
            slot.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            slot.icon:SetInside()
        end

        -- bg surrounds the slot button (not just icon)
        slot.bg = F.CreateBDFrame(slot, 0.25)

        local cooldown = _G['Character' .. slots[i] .. 'SlotCooldown']
        if cooldown then
            cooldown:SetInside()
        end

        if slot.ignoreTexture then
            slot.ignoreTexture:SetTexture('Interface\\PaperDollInfoFrame\\UI-GearManager-LeaveItem-Transparent')
        end

        if slot.IconOverlay then
            slot.IconOverlay:SetInside()
        end

        if slot.IconBorder then
            F.ReskinIconBorder(slot.IconBorder)
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

            popout:HookScript('OnEnter', clearPopout)
            popout:HookScript('OnLeave', colourPopout)
        end
        end  -- if slot then
    end

    -- CharacterAmmoSlot (not in equipment slot loop)
    local ammoSlot = _G.CharacterAmmoSlot
    if ammoSlot then
        local ant = ammoSlot:GetNormalTexture()
        if ant then ant:Hide() end
        local apt = ammoSlot:GetPushedTexture()
        if apt then apt:Hide() end
        local hl = ammoSlot:GetHighlightTexture()
        if hl then hl:SetColorTexture(1, 1, 1, 0.25) end
        ammoSlot.SetHighlightTexture = function() end
        if _G.CharacterAmmoSlotIconTexture then
            _G.CharacterAmmoSlotIconTexture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            _G.CharacterAmmoSlotIconTexture:SetInside()
        end
        F.CreateBDFrame(ammoSlot, 0.25)
    end

    -- 3.80.1: slot textures re-created on frame show; hook OnShow to re-apply
    local function stripSlotTextures()
        for i = 1, #slots do
            local slot = _G['Character' .. slots[i] .. 'Slot']
            if slot then
                local nt = slot:GetNormalTexture()
                if nt then nt:Hide() end
                local pt = slot:GetPushedTexture()
                if pt then pt:Hide() end
            end
        end
    end
    _G.CharacterFrame:HookScript('OnShow', stripSlotTextures)
    -- called for ALL inventory slots; button.icon nil on non-equip slots crashes.
    -- Replaced with filtered + guarded version.
    hooksecurefunc('PaperDollItemSlotButton_Update', function(button)
        if not button or not button.popoutButton then return end
        -- 3.80.1: re-hide normal/pushed textures
        local nt = button:GetNormalTexture()
        if nt then nt:Hide() end
        if button.icon then
            button.icon:SetShown(GetInventoryItemTexture('player', button:GetID()) ~= nil)
        end
        if button.popoutButton then
            colourPopout(button.popoutButton)
        end
        UpdateCosmetic(button)
        UpdateHighlight(button)
    end)

    -- [[ Stats pane ]]

    local pane = _G.CharacterStatsPane
    if pane then
        if pane.ClassBackground then
            pane.ClassBackground:Hide()
        end
        -- 3.80.1: Corruption stat does not exist
        if pane.ItemLevelFrame and pane.ItemLevelFrame.Corruption then
            pane.ItemLevelFrame.Corruption:SetPoint('RIGHT', 22, -8)
        end

        local categories = { pane.ItemLevelCategory, pane.AttributesCategory, pane.EnhancementsCategory }
        for _, category in pairs(categories) do
            if category and category.Background then
                category.Background:SetTexture('Interface\\LFGFrame\\UI-LFG-SEPARATOR')
                category.Background:SetTexCoord(0, 0.66, 0, 0.31)
                category.Background:SetVertexColor(r, g, b, 0.8)
                category.Background:SetPoint('BOTTOMLEFT', -30, -4)
            end
            if category and category.Title then
                category.Title:SetTextColor(r, g, b)
            end
        end
    end

    -- [[ Sidebar tabs ]]

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

    -- [[ Equipment manager ]]

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

    -- Title Pane

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

    -- Reputation Frame

    if _G.ReputationFrame then
        if _G.ReputationDetailFrame then
            _G.ReputationDetailFrame:SetPoint('TOPLEFT', _G.ReputationFrame, 'TOPRIGHT', 3, -28)
        end

        local function updateReputationBars(scrollBox)
            for i = 1, scrollBox.ScrollTarget:GetNumChildren() do
                local child = select(i, scrollBox.ScrollTarget:GetChildren())
                local container = child and child.Container
                if container and not container.styled then
                    F.StripTextures(container)
                    if container.ExpandOrCollapseButton then
                        F.ReskinCollapse(container.ExpandOrCollapseButton)
                        if container.ExpandOrCollapseButton.__texture then
                            container.ExpandOrCollapseButton.__texture:DoCollapse(child.isCollapsed)
                        end
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

        if _G.ReputationFrame.ScrollBox then
            hooksecurefunc(_G.ReputationFrame.ScrollBox, 'Update', updateReputationBars)
        end

        if _G.ReputationFrame.ScrollBar then
            F.ReskinTrimScroll(_G.ReputationFrame.ScrollBar)
        end
    end

    if _G.ReputationDetailFrame then
        F.StripTextures(_G.ReputationDetailFrame)
        F.SetBD(_G.ReputationDetailFrame)
    end
    if _G.ReputationDetailCloseButton then F.ReskinClose(_G.ReputationDetailCloseButton) end
    if _G.ReputationDetailInactiveCheckBox then F.ReskinCheckbox(_G.ReputationDetailInactiveCheckBox) end
    if _G.ReputationDetailMainScreenCheckBox then F.ReskinCheckbox(_G.ReputationDetailMainScreenCheckBox) end
    -- 3.80.1: ViewRenownButton does not exist (Retail renown)
    if _G.ReputationDetailViewRenownButton then F.ReskinButton(_G.ReputationDetailViewRenownButton) end

    if _G.ReputationDetailAtWarCheckBox then
        local atWarCheck = _G.ReputationDetailAtWarCheckBox
        F.ReskinCheckbox(atWarCheck)
        local atWarCheckTex = atWarCheck:GetCheckedTexture()
        if atWarCheckTex then
            atWarCheckTex:ClearAllPoints()
            atWarCheckTex:SetSize(26, 26)
            atWarCheckTex:SetPoint('CENTER')
        end
    end

    -- Token frame

    if _G.TokenFramePopup then
        if _G.TokenFramePopup.CloseButton then
            F.ReskinClose(_G.TokenFramePopup.CloseButton)
        end
        if _G.TokenFramePopup.InactiveCheckBox then F.ReskinCheckbox(_G.TokenFramePopup.InactiveCheckBox) end
        if _G.TokenFramePopup.BackpackCheckBox then F.ReskinCheckbox(_G.TokenFramePopup.BackpackCheckBox) end
    end

    if _G.TokenFrame and _G.TokenFrame.ScrollBar then
        F.ReskinTrimScroll(_G.TokenFrame.ScrollBar)
    end

    if _G.TokenFrame and _G.TokenFrame.ScrollBox then
        hooksecurefunc(_G.TokenFrame.ScrollBox, 'Update', function(scrollBox)
            for i = 1, scrollBox.ScrollTarget:GetNumChildren() do
                local child = select(i, scrollBox.ScrollTarget:GetChildren())
                if child and child.Highlight and not child.styled then
                    if child.CategoryLeft then child.CategoryLeft:SetAlpha(0) end
                    if child.CategoryRight then child.CategoryRight:SetAlpha(0) end
                    if child.CategoryMiddle then child.CategoryMiddle:SetAlpha(0) end

                    child.Highlight:SetInside()
                    child.Highlight.SetPoint = nop
                    child.Highlight:SetColorTexture(1, 1, 1, 0.25)
                    child.Highlight.SetTexture = nop

                    if child.Icon then
                        child.bg = F.ReskinIcon(child.Icon)
                    end

                    if child.ExpandIcon then
                        child.expBg = F.CreateBDFrame(child.ExpandIcon, 0, true)
                        if child.expBg then
                            child.expBg:SetInside(child.ExpandIcon, 3, 3)
                        end
                    end

                    if child.Check then
                        child.Check:SetAtlas('checkmark-minimal')
                    end

                    child.styled = true
                end

                if child and child.isHeader then
                    if child.bg then child.bg:Hide() end
                    if child.expBg then child.expBg:Show() end
                elseif child then
                    if child.bg then child.bg:Show() end
                    if child.expBg then child.expBg:Hide() end
                end
            end
        end)
    end

    if _G.TokenFramePopup then
        F.StripTextures(_G.TokenFramePopup)
        F.SetBD(_G.TokenFramePopup)
    end

    -- Quick Join (3.80.1: may not exist)

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
end)
