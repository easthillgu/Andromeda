local F, C = unpack(select(2, ...))

local function reskinFrameButton(self)
    for i = 1, self.ScrollTarget:GetNumChildren() do
        local child = select(i, self.ScrollTarget:GetChildren())
        if not child.styled then
            child:GetRegions():Hide()
            child:SetHighlightTexture(0)
            child.iconBorder:SetTexture('')
            child.selectedTexture:SetTexture('')

            local bg = F.CreateBDFrame(child, 0.25)
            bg:SetPoint('TOPLEFT', 3, -1)
            bg:SetPoint('BOTTOMRIGHT', 0, 1)
            child.bg = bg

            local icon = child.icon
            icon:SetSize(42, 42)
            icon.bg = F.ReskinIcon(icon)
            child.name:SetParent(bg)

            if child.DragButton then
                child.DragButton.ActiveTexture:SetTexture('')
                child.DragButton:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
                child.DragButton:GetHighlightTexture():SetAllPoints(icon)
            else
                child.dragButton.ActiveTexture:SetTexture('')
                if child.dragButton.levelBG then
                    child.dragButton.levelBG:SetAlpha(0)
                end
                if child.dragButton.level then
                    child.dragButton.level:SetFontObject(_G.GameFontNormal)
                    child.dragButton.level:SetTextColor(1, 1, 1)
                end
                child.dragButton:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
                child.dragButton:GetHighlightTexture():SetAllPoints(icon)
            end

            child.styled = true
        end
    end
end

C.Themes['Blizzard_Collections'] = function()
    local r, g, b = C.r, C.g, C.b

    local CollectionsJournal = _G.CollectionsJournal

    -- [[ General ]]

    CollectionsJournal.bg = F.ReskinPortraitFrame(CollectionsJournal) -- need this for Rematch skin
    for i = 1, 5 do
        local tab = _G['CollectionsJournalTab' .. i]
        F.ReskinTab(tab)
        if i ~= 1 then
            tab:ClearAllPoints()
            tab:SetPoint('TOPLEFT', _G['CollectionsJournalTab' .. (i - 1)], 'TOPRIGHT', -10, 0)
        end
    end

    -- [[ Mounts and pets ]] (3.80.1: Retail-only, nil guard)

    local PetJournal = _G.PetJournal
    local MountJournal = _G.MountJournal

    if PetJournal or MountJournal then
        if MountJournal then
            MountJournal.RightInset:Hide()
            MountJournal.MountDisplay.YesMountsTex:SetAlpha(0)
            MountJournal.MountDisplay.NoMountsTex:SetAlpha(0)
            MountJournal.MountDisplay.ShadowOverlay:Hide()
        end
        if PetJournal then
            PetJournal.LeftInset:Hide()
            PetJournal.RightInset:Hide()
            if PetJournal.PetCardInset then
                PetJournal.PetCardInset:Hide()
            end
            if PetJournal.loadoutBorder then
                PetJournal.loadoutBorder:Hide()
            end
            if _G.PetJournalTutorialButton then
                _G.PetJournalTutorialButton.Ring:Hide()
            end
        end

        if MountJournal then
            F.StripTextures(MountJournal.MountCount)
            F.CreateBDFrame(MountJournal.MountCount, 0.25)
            F.CreateBDFrame(MountJournal.MountDisplay.ModelScene, 0.25)
            F.ReskinIcon(MountJournal.MountDisplay.InfoButton.Icon)
            F.ReskinButton(_G.MountJournalMountButton)
            F.ReskinTrimScroll(MountJournal.ScrollBar)
            hooksecurefunc(MountJournal.ScrollBox, 'Update', reskinFrameButton)
        end

        if PetJournal then
            F.StripTextures(PetJournal.PetCount)
            F.CreateBDFrame(PetJournal.PetCount, 0.25)
            PetJournal.PetCount:SetWidth(140)
            F.ReskinButton(_G.PetJournalSummonButton)
            F.ReskinButton(_G.PetJournalFindBattle)
        end

        if MountJournal then
            hooksecurefunc('MountJournal_InitMountButton', function(button)
                if not button.bg then
                    return
                end

                button.icon:SetShown(button.index ~= nil)

                if button.selectedTexture:IsShown() then
                    button.bg:SetBackdropColor(r, g, b, 0.25)
                else
                    button.bg:SetBackdropColor(0, 0, 0, 0.25)
                end

                if button.DragButton.ActiveTexture:IsShown() then
                    button.icon.bg:SetBackdropBorderColor(1, 0.8, 0)
                else
                    button.icon.bg:SetBackdropBorderColor(0, 0, 0)
                end
            end)

            F.ReskinEditbox(_G.MountJournalSearchBox)
            F.ReskinDropdown(_G.MountJournalFilterButton)

            if MountJournal.MountDisplay and MountJournal.MountDisplay.ModelScene then
                F.ReskinArrow(MountJournal.MountDisplay.ModelScene.RotateLeftButton, 'left')
                F.ReskinArrow(MountJournal.MountDisplay.ModelScene.RotateRightButton, 'right')

                local togglePlayer = MountJournal.MountDisplay.ModelScene.TogglePlayer
                if togglePlayer then
                    F.ReskinCheckbox(togglePlayer)
                    togglePlayer:SetSize(28, 28)
                end
            end

            F.StripTextures(MountJournal.BottomLeftInset)
            local bg = F.CreateBDFrame(MountJournal.BottomLeftInset, 0.25)
            if bg then
                bg:SetPoint('TOPLEFT', 3, 0)
                bg:SetPoint('BOTTOMRIGHT', -24, 2)
            end

            if _G.MountJournalFilterButton and MountJournal.LeftInset then
                _G.MountJournalFilterButton:SetPoint('TOPRIGHT', MountJournal.LeftInset, -5, -8)
            end
        end

        if PetJournal then
            F.ReskinTrimScroll(PetJournal.ScrollBar)
            hooksecurefunc(PetJournal.ScrollBox, 'Update', reskinFrameButton)
            hooksecurefunc('PetJournal_InitPetButton', function(button)
                if not button.bg then
                    return
                end
                local index = button.index
                if not index then
                    return
                end

                local petID, _, isOwned = C_PetJournal.GetPetInfoByIndex(index)
                if petID and isOwned then
                    local rarity = select(5, C_PetJournal.GetPetStats(petID))
                    if rarity then
                        local r, g, b = GetItemQualityColor(rarity - 1)
                        button.name:SetTextColor(r, g, b)
                    else
                        button.name:SetTextColor(1, 1, 1)
                    end
                else
                    button.name:SetTextColor(0.5, 0.5, 0.5)
                end

                if button.selectedTexture:IsShown() then
                    button.bg:SetBackdropColor(r, g, b, 0.25)
                else
                    button.bg:SetBackdropColor(0, 0, 0, 0.25)
                end

                if button.dragButton.ActiveTexture:IsShown() then
                    button.icon.bg:SetBackdropBorderColor(1, 0.8, 0)
                else
                    button.icon.bg:SetBackdropBorderColor(0, 0, 0)
                end
            end)

            F.ReskinEditbox(_G.PetJournalSearchBox)
            F.ReskinDropdown(_G.PetJournalFilterButton)

            if _G.PetJournalFilterButton then
                _G.PetJournalFilterButton:SetPoint('TOPRIGHT', _G.PetJournalLeftInset, -5, -8)
            end
            if _G.PetJournalTutorialButton then
                _G.PetJournalTutorialButton:SetPoint('TOPLEFT', PetJournal, 'TOPLEFT', -14, 14)
            end
        end

        local function reskinToolButton(button)
            if not button then return end
            local border = _G[button:GetName() .. 'Border']
            if border then
                border:Hide()
            end
            button:SetPushedTexture(0)
            button:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
            F.ReskinIcon(button.texture)
        end

        if PetJournal then
            reskinToolButton(_G.PetJournalHealPetButton)

            if _G.PetJournalLoadoutBorderSlotHeaderText then
                _G.PetJournalLoadoutBorderSlotHeaderText:SetParent(PetJournal)
                _G.PetJournalLoadoutBorderSlotHeaderText:SetPoint('CENTER', _G.PetJournalLoadoutBorderTop, 'TOP', 0, 4)
            end

            reskinToolButton(_G.PetJournalSummonRandomFavoritePetButton)
        end

        -- Favourite mount button
        if MountJournal then
            reskinToolButton(_G.MountJournalSummonRandomFavoriteButton)

            local movedButton
            MountJournal:HookScript('OnShow', function()
                if not InCombatLockdown() and not movedButton and _G.MountJournalSummonRandomFavoriteButton then
                    _G.MountJournalSummonRandomFavoriteButton:SetPoint('TOPRIGHT', -10, -26)
                    movedButton = true
                end
            end)
        end

        -- Pet card
        local card = _G.PetJournalPetCard
        if card then
            if _G.PetJournalPetCardBG then
                _G.PetJournalPetCardBG:Hide()
            end
            if card.PetInfo then
                if card.PetInfo.levelBG then
                    card.PetInfo.levelBG:SetAlpha(0)
                end
                if card.PetInfo.qualityBorder then
                    card.PetInfo.qualityBorder:SetAlpha(0)
                end
                if card.PetInfo.level then
                    card.PetInfo.level:SetFontObject(_G.GameFontNormal)
                card.PetInfo.level:SetTextColor(1, 1, 1)
            end

            card.PetInfo.icon.bg = F.ReskinIcon(card.PetInfo.icon)
        end
        if card.AbilitiesBG1 then
            card.AbilitiesBG1:SetAlpha(0)
        end
        if card.AbilitiesBG2 then
            card.AbilitiesBG2:SetAlpha(0)
        end
        if card.AbilitiesBG3 then
            card.AbilitiesBG3:SetAlpha(0)
        end

        F.CreateBDFrame(card, 0.25)

        if card.xpBar then
            for i = 2, 12 do
                select(i, card.xpBar:GetRegions()):Hide()
            end

            card.xpBar:SetStatusBarTexture(C.Assets.Textures.Backdrop)
            F.CreateBDFrame(card.xpBar, 0.25)
        end

        if _G.PetJournalPetCardHealthFramehealthStatusBarLeft then
            _G.PetJournalPetCardHealthFramehealthStatusBarLeft:Hide()
        end
        if _G.PetJournalPetCardHealthFramehealthStatusBarRight then
            _G.PetJournalPetCardHealthFramehealthStatusBarRight:Hide()
        end
        if _G.PetJournalPetCardHealthFramehealthStatusBarMiddle then
            _G.PetJournalPetCardHealthFramehealthStatusBarMiddle:Hide()
        end
        if _G.PetJournalPetCardHealthFramehealthStatusBarBGMiddle then
            _G.PetJournalPetCardHealthFramehealthStatusBarBGMiddle:Hide()
        end

        if card.HealthFrame and card.HealthFrame.healthBar then
            card.HealthFrame.healthBar:SetStatusBarTexture(C.Assets.Textures.Backdrop)
            F.CreateBDFrame(card.HealthFrame.healthBar, 0.25)
        end

        for i = 1, 6 do
            local bu = card['spell' .. i]
            if bu then
                F.ReskinIcon(bu.icon)
            end
        end

        hooksecurefunc('PetJournal_UpdatePetCard', function(self)
            local border = self.PetInfo.qualityBorder
            local r, g, b

            if border and border:IsShown() then
                r, g, b = self.PetInfo.qualityBorder:GetVertexColor()
            else
                r, g, b = 0, 0, 0
            end

            if self.PetInfo.icon.bg then
                self.PetInfo.icon.bg:SetBackdropBorderColor(r, g, b)
            end
        end)
    end

    -- Pet loadout

    if PetJournal.Loadout then
        for i = 1, 3 do
            local bu = PetJournal.Loadout['Pet' .. i]

        _G['PetJournalLoadoutPet' .. i .. 'BG']:Hide()

        bu.iconBorder:SetAlpha(0)
        bu.qualityBorder:SetTexture('')
        bu.levelBG:SetAlpha(0)
        bu.helpFrame:GetRegions():Hide()
        bu.dragButton:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)

        bu.level:SetFontObject(_G.GameFontNormal)
        bu.level:SetTextColor(1, 1, 1)

        bu.icon.bg = F.ReskinIcon(bu.icon)

        bu.setButton:GetRegions():SetPoint('TOPLEFT', bu.icon, -5, 5)
        bu.setButton:GetRegions():SetPoint('BOTTOMRIGHT', bu.icon, 5, -5)

        F.CreateBDFrame(bu, 0.25)

        for i = 2, 12 do
            select(i, bu.xpBar:GetRegions()):Hide()
        end

        bu.xpBar:SetStatusBarTexture(C.Assets.Textures.Backdrop)
        F.CreateBDFrame(bu.xpBar, 0.25)

        F.StripTextures(bu.healthFrame.healthBar)
        bu.healthFrame.healthBar:SetStatusBarTexture(C.Assets.Textures.Backdrop)
        F.CreateBDFrame(bu.healthFrame.healthBar, 0.25)

        for j = 1, 3 do
            local spell = bu['spell' .. j]

            spell:SetPushedTexture(0)
            spell:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
            spell.selected:SetTexture(C.Assets.Textures.ButtonPushed)
            spell:GetRegions():Hide()

            local flyoutArrow = spell.FlyoutArrow
            F.SetupArrow(flyoutArrow, 'down')
            flyoutArrow:SetSize(14, 14)
            flyoutArrow:SetTexCoord(0, 1, 0, 1)

            F.ReskinIcon(spell.icon)
        end
        end
    end

    if PetJournal.Loadout then
        hooksecurefunc('PetJournal_UpdatePetLoadOut', function()
            for i = 1, 3 do
                local bu = PetJournal.Loadout['Pet' .. i]

                bu.icon.bg:SetShown(not bu.helpFrame:IsShown())
                bu.icon.bg:SetBackdropBorderColor(bu.qualityBorder:GetVertexColor())

                bu.dragButton:SetEnabled(not bu.helpFrame:IsShown())
            end
        end)
    end

    if PetJournal.SpellSelect then
        PetJournal.SpellSelect.BgEnd:Hide()
        PetJournal.SpellSelect.BgTiled:Hide()

        for i = 1, 2 do
            local bu = PetJournal.SpellSelect['Spell' .. i]

            bu:SetCheckedTexture(C.Assets.Textures.ButtonPushed)
            bu:SetPushedTexture(0)
            bu:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)

            F.ReskinIcon(bu.icon)
        end
    end
    end -- 3.80.1: closes if MountJournal then
    end -- 3.80.1: if PetJournal or MountJournal

    -- [[ Toy box ]] (3.80.1: Retail-only, nil guard)

    if _G.ToyBox then
        local ToyBox = _G.ToyBox
        local iconsFrame = ToyBox.iconsFrame

        F.StripTextures(iconsFrame)
        F.ReskinEditbox(ToyBox.searchBox)
        F.ReskinDropdown(_G.ToyBoxFilterButton)
        F.ReskinArrow(ToyBox.PagingFrame.PrevPageButton, 'left')
        F.ReskinArrow(ToyBox.PagingFrame.NextPageButton, 'right')

        -- Progress bar
        local progressBar = ToyBox.progressBar
        if progressBar then
            if progressBar.border then
                progressBar.border:Hide()
            end
            progressBar:DisableDrawLayer('BACKGROUND')
            progressBar.text:SetPoint('CENTER', 0, 1)
            progressBar:SetStatusBarTexture(C.Assets.Textures.Backdrop)
            F.CreateBDFrame(progressBar, 0.25)
        end

        -- Toys!

        local function changeTextColor(text)
            if text.isSetting then
                return
            end
            text.isSetting = true

            local bu = text:GetParent()
            local itemID = bu.itemID

            if PlayerHasToy(itemID) then
                local quality = select(3, GetItemInfo(itemID))
                if quality then
                    local r, g, b = GetItemQualityColor(quality)
                    text:SetTextColor(r, g, b)
                else
                    text:SetTextColor(1, 1, 1)
                end
            else
                text:SetTextColor(0.5, 0.5, 0.5)
            end

            text.isSetting = nil
        end

        local buttons = ToyBox.iconsFrame
        for i = 1, 18 do
            local bu = buttons['spellButton' .. i]
            local ic = bu.iconTexture

            bu:SetPushedTexture(0)
            bu:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
            bu:GetHighlightTexture():SetAllPoints(ic)
            bu.cooldown:SetAllPoints(ic)
            bu.slotFrameCollected:SetTexture('')
            bu.slotFrameUncollected:SetTexture('')
            F.ReskinIcon(ic)

            hooksecurefunc(bu.name, 'SetTextColor', changeTextColor)
            hooksecurefunc(bu.name, 'SetTextColor', changeTextColor)
        end
    end -- 3.80.1: if _G.ToyBox

    -- [[ Heirlooms ]] (3.80.1: Retail-only, nil guard)

    if _G.HeirloomsJournal then
        local HeirloomsJournal = _G.HeirloomsJournal
        local icons = HeirloomsJournal.iconsFrame

        F.StripTextures(icons)
        F.ReskinEditbox(_G.HeirloomsJournalSearchBox)
        F.ReskinDropdown(_G.HeirloomsJournalClassDropDown)
        F.ReskinDropdown(HeirloomsJournal.FilterButton)
        F.ReskinArrow(HeirloomsJournal.PagingFrame.PrevPageButton, 'left')
        F.ReskinArrow(HeirloomsJournal.PagingFrame.NextPageButton, 'right')

        hooksecurefunc(HeirloomsJournal, 'UpdateButton', function(_, button)
            if button.level then
                button.level:SetFontObject('GameFontWhiteSmall')
            end
            if button.special then
                button.special:SetTextColor(1, 0.8, 0)
            end
        end)

        -- Progress bar
        local hjprogressBar = HeirloomsJournal.progressBar
        if hjprogressBar then
            if hjprogressBar.border then
                hjprogressBar.border:Hide()
            end
            hjprogressBar:DisableDrawLayer('BACKGROUND')
            hjprogressBar.text:SetPoint('CENTER', 0, 1)
            hjprogressBar:SetStatusBarTexture(C.Assets.Textures.Backdrop)
            F.CreateBDFrame(hjprogressBar, 0.25)
        end

        -- Buttons
        hooksecurefunc('HeirloomsJournal_UpdateButton', function(button)
            if not button.styled then
                local ic = button.iconTexture

                button.slotFrameCollected:SetTexture('')
                button.slotFrameUncollected:SetTexture('')
                if button.levelBackground then
                    button.levelBackground:SetAlpha(0)
                end
                button:SetPushedTexture(0)
                button:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
                button:GetHighlightTexture():SetAllPoints(ic)

                button.iconTextureUncollected:SetTexCoord(unpack(C.TEX_COORD))
                button.bg = F.ReskinIcon(ic)

                if button.level then
                    button.level:ClearAllPoints()
                    button.level:SetPoint('BOTTOM', 0, 1)

                    local newLevelBg = button:CreateTexture(nil, 'OVERLAY')
                    newLevelBg:SetColorTexture(0, 0, 0, 0.5)
                    newLevelBg:SetPoint('BOTTOMLEFT', button, 'BOTTOMLEFT', 4, 5)
                    newLevelBg:SetPoint('BOTTOMRIGHT', button, 'BOTTOMRIGHT', -4, 5)
                    newLevelBg:SetHeight(11)
                    button.newLevelBg = newLevelBg
                end

                button.styled = true
            end

            if button.iconTexture:IsShown() then
                button.name:SetTextColor(1, 1, 1)
                button.bg:SetBackdropBorderColor(0, 0.8, 1)
                if button.newLevelBg then
                    button.newLevelBg:Show()
                end
            else
                button.name:SetTextColor(0.5, 0.5, 0.5)
                button.bg:SetBackdropBorderColor(0, 0, 0)
                if button.newLevelBg then
                    button.newLevelBg:Hide()
                end
            end
        end)

        hooksecurefunc(HeirloomsJournal, 'LayoutCurrentPage', function()
            for i = 1, #HeirloomsJournal.heirloomHeaderFrames do
                local header = HeirloomsJournal.heirloomHeaderFrames[i]
                if not header.styled then
                    header.text:SetTextColor(1, 1, 1)
                    F.SetFontSize(header.text, 16)

                    header.styled = true
                end
            end

            for i = 1, #HeirloomsJournal.heirloomEntryFrames do
                local button = HeirloomsJournal.heirloomEntryFrames[i]

                if button.iconTexture:IsShown() then
                    button.name:SetTextColor(1, 1, 1)
                    if button.bg then
                        button.bg:SetBackdropBorderColor(0, 0.8, 1)
                    end
                    if button.newLevelBg then
                        button.newLevelBg:Show()
                    end
                else
                    button.name:SetTextColor(0.5, 0.5, 0.5)
                    if button.bg then
                        button.bg:SetBackdropBorderColor(0, 0, 0)
                    end
                    if button.newLevelBg then
                        button.newLevelBg:Hide()
                    end
                end
            end
        end)
    end -- 3.80.1: if _G.HeirloomsJournal

    -- [[ WardrobeCollectionFrame ]] (3.80.1: Retail-only, nil guard)

    if _G.WardrobeCollectionFrame then
        local WardrobeCollectionFrame = _G.WardrobeCollectionFrame
        local ItemsCollectionFrame = WardrobeCollectionFrame.ItemsCollectionFrame

        F.StripTextures(ItemsCollectionFrame)
        F.ReskinDropdown(WardrobeCollectionFrame.FilterButton)
        F.ReskinDropdown(_G.WardrobeCollectionFrameWeaponDropDown)
        F.ReskinEditbox(_G.WardrobeCollectionFrameSearchBox)

        for index = 1, 2 do
            local tab = _G['WardrobeCollectionFrameTab' .. index]
            if tab then
                F.ReskinTab(tab)
            end
        end

        hooksecurefunc(WardrobeCollectionFrame, 'SetTab', function(self, tabID)
            for index = 1, 2 do
                local tab = _G['WardrobeCollectionFrameTab' .. index]
                if tab and tab.bg then
                    if tabID == index then
                        tab.bg:SetBackdropColor(C.r, C.g, C.b, 0.25)
                    else
                        tab.bg:SetBackdropColor(0, 0, 0, 0.25)
                    end
                end
            end
        end)

        F.ReskinArrow(ItemsCollectionFrame.PagingFrame.PrevPageButton, 'left')
        F.ReskinArrow(ItemsCollectionFrame.PagingFrame.NextPageButton, 'right')
        ItemsCollectionFrame.BGCornerTopLeft:SetAlpha(0)
        ItemsCollectionFrame.BGCornerTopRight:SetAlpha(0)

        -- 3.80.1: Wardrobe/Transmog Retail-only, nil guard the entire section

        local wcprogressBar = WardrobeCollectionFrame.progressBar
        if wcprogressBar then
            wcprogressBar:DisableDrawLayer('BACKGROUND')
            local region = select(2, wcprogressBar:GetRegions())
            if region then
                region:Hide()
            end
            wcprogressBar.text:SetPoint('CENTER', 0, 1)
            wcprogressBar:SetStatusBarTexture(C.Assets.Textures.Backdrop)
            F.CreateBDFrame(wcprogressBar, 0.25)
        end

        -- ItemSetsCollection
        local SetsCollectionFrame = WardrobeCollectionFrame.SetsCollectionFrame
        if SetsCollectionFrame then
            SetsCollectionFrame.LeftInset:Hide()
            SetsCollectionFrame.RightInset:Hide()
            F.CreateBDFrame(SetsCollectionFrame.Model, 0.25)

            F.ReskinTrimScroll(SetsCollectionFrame.ListContainer.ScrollBar)
            hooksecurefunc(SetsCollectionFrame.ListContainer.ScrollBox, 'Update', function(self)
                for i = 1, self.ScrollTarget:GetNumChildren() do
                    local child = select(i, self.ScrollTarget:GetChildren())
                    if not child.styled and child.Icon then
                        child.Background:Hide()
                        child.HighlightTexture:SetTexture('')
                        child.Icon:SetSize(42, 42)
                        F.ReskinIcon(child.Icon)
                        child.IconCover:SetOutside(child.Icon)

                        child.SelectedTexture:SetDrawLayer('BACKGROUND')
                        child.SelectedTexture:SetColorTexture(r, g, b, 0.25)
                        child.SelectedTexture:ClearAllPoints()
                        child.SelectedTexture:SetPoint('TOPLEFT', 4, -2)
                        child.SelectedTexture:SetPoint('BOTTOMRIGHT', -1, 2)
                        F.CreateBDFrame(child.SelectedTexture, 0.25)

                        child.styled = true
                    end
                end
            end)

            local DetailsFrame = SetsCollectionFrame.DetailsFrame
            if DetailsFrame then
                DetailsFrame.ModelFadeTexture:Hide()
                DetailsFrame.IconRowBackground:Hide()
                F.ReskinFilterButton(DetailsFrame.VariantSetsButton, 'Down')

                hooksecurefunc(SetsCollectionFrame, 'SetItemFrameQuality', function(_, itemFrame)
                    local ic = itemFrame.Icon
                    if not ic.bg then
                        ic.bg = F.ReskinIcon(ic)
                    end
                    itemFrame.IconBorder:SetTexture('')

                    if itemFrame.collected then
                        -- 3.80.1: C_TransmogCollection Retail-only
                        if C_TransmogCollection then
                            local sourceInfo = C_TransmogCollection.GetSourceInfo(itemFrame.sourceID)
                            if sourceInfo then
                                local quality = sourceInfo.quality
                                local color = C.QualityColors[quality or 1]
                                ic.bg:SetBackdropBorderColor(color.r, color.g, color.b)
                            end
                        end
                    else
                        ic.bg:SetBackdropBorderColor(0, 0, 0)
                    end
                end)

                local SetsTransmogFrame = WardrobeCollectionFrame.SetsTransmogFrame
                if SetsTransmogFrame then
                    F.StripTextures(SetsTransmogFrame)
                    F.ReskinArrow(SetsTransmogFrame.PagingFrame.PrevPageButton, 'left')
                    F.ReskinArrow(SetsTransmogFrame.PagingFrame.NextPageButton, 'right')
                end
            end
        end

        -- [[ Wardrobe ]]
        local WardrobeFrame = _G.WardrobeFrame
        local WardrobeTransmogFrame = _G.WardrobeTransmogFrame

        if WardrobeTransmogFrame then
            F.StripTextures(WardrobeTransmogFrame)
            F.ReskinPortraitFrame(WardrobeFrame)
            F.ReskinButton(WardrobeTransmogFrame.ApplyButton)
            if WardrobeTransmogFrame.SpecButton then
                F.StripTextures(WardrobeTransmogFrame.SpecButton)
                F.ReskinArrow(WardrobeTransmogFrame.SpecButton, 'down')
                WardrobeTransmogFrame.SpecButton:SetPoint('RIGHT', WardrobeTransmogFrame.ApplyButton, 'LEFT', -3, 0)
            end
            F.ReskinCheckbox(WardrobeTransmogFrame.ToggleSecondaryAppearanceCheckbox)

            local modelScene = WardrobeTransmogFrame.ModelScene
            if modelScene then
                modelScene.ClearAllPendingButton:DisableDrawLayer('BACKGROUND')

                local slots = { 'Head', 'Shoulder', 'Chest', 'Waist', 'Legs', 'Feet', 'Wrist', 'Hands', 'Back', 'Shirt', 'Tabard', 'MainHand', 'SecondaryHand' }
                for i = 1, #slots do
                    local slot = modelScene[slots[i] .. 'Button']
                    if slot then
                        slot.Border:Hide()
                        F.ReskinIcon(slot.Icon)
                        slot:SetHighlightTexture(C.Assets.Textures.Backdrop)
                        local hl = slot:GetHighlightTexture()
                        hl:SetVertexColor(1, 1, 1, 0.25)
                        hl:SetAllPoints(slot.Icon)
                    end
                end
            end
        end

        -- Outfit Frame
        if _G.WardrobeOutfitDropDown then
            F.ReskinButton(_G.WardrobeOutfitDropDown.SaveButton)
            F.ReskinDropdown(_G.WardrobeOutfitDropDown)
            _G.WardrobeOutfitDropDown:SetHeight(32)
            _G.WardrobeOutfitDropDown.SaveButton:SetPoint('LEFT', _G.WardrobeOutfitDropDown, 'RIGHT', -13, 2)
        end
    end -- 3.80.1: closes if WardrobeCollectionFrame

    -- HPetBattleAny
    local reskinHPet
    CollectionsJournal:HookScript('OnShow', function()
        if not IsAddOnLoaded('HPetBattleAny') then
            return
        end
        if not reskinHPet then
            if _G.HPetInitOpenButton then
                F.ReskinButton(_G.HPetInitOpenButton)
            end
            if _G.HPetAllInfoButton then
                F.StripTextures(_G.HPetAllInfoButton)
                F.ReskinButton(_G.HPetAllInfoButton)
            end

            if _G.PetJournalBandageButton then
                _G.PetJournalBandageButton:SetPushedTexture(0)
                _G.PetJournalBandageButton:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
                _G.PetJournalBandageButtonBorder:Hide()
                _G.PetJournalBandageButton:SetPoint('TOPRIGHT', _G.PetJournalHealPetButton, 'TOPLEFT', -3, 0)
                _G.PetJournalBandageButton:SetPoint('BOTTOMLEFT', _G.PetJournalHealPetButton, 'BOTTOMLEFT', -35, 0)
                F.ReskinIcon(_G.PetJournalBandageButtonIcon)
            end
            reskinHPet = true
        end
    end)
end)
