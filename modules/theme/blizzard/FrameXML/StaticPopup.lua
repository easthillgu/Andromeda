local F, C = unpack(select(2, ...))

local STATICPOPUP_NUMDIALOGS = _G.STATICPOPUP_NUMDIALOGS or 4

local function colorMinimize(f)
    if f:IsEnabled() then
        f.minimize:SetVertexColor(C.r, C.g, C.b)
    end
end

local function clearMinimize(f)
    f.minimize:SetVertexColor(1, 1, 1)
end

local function updateMinorButtonState(button)
    if button:GetChecked() then
        button.bg:SetBackdropColor(1, 0.8, 0, 0.25)
    else
        button.bg:SetBackdropColor(0, 0, 0, 0.25)
    end
end

tinsert(C.BlizzThemes, function()
    for i = 1, STATICPOPUP_NUMDIALOGS do
        local frame = _G['StaticPopup' .. i]
        local itemFrame = frame.ItemFrame
        local bu = itemFrame and itemFrame.Item
        local icon = _G['StaticPopup' .. i .. 'IconTexture']
        local close = _G['StaticPopup' .. i .. 'CloseButton']

        local gold = _G['StaticPopup' .. i .. 'MoneyInputFrameGold']
        local silver = _G['StaticPopup' .. i .. 'MoneyInputFrameSilver']
        local copper = _G['StaticPopup' .. i .. 'MoneyInputFrameCopper']

        if itemFrame and itemFrame.NameFrame then
            itemFrame.NameFrame:Hide()
        end

        if bu then
            bu:SetNormalTexture(0)
            bu:SetHighlightTexture(0)
            bu:SetPushedTexture(0)
            bu.bg = F.ReskinIcon(icon)
            F.ReskinIconBorder(bu.IconBorder)

            local bg = F.CreateBDFrame(bu, 0.25)
            bg:SetPoint('TOPLEFT', bu.bg, 'TOPRIGHT', 2, 0)
            bg:SetPoint('BOTTOMRIGHT', bu.bg, 115, 0)
        end

        if silver then silver:SetPoint('LEFT', gold, 'RIGHT', 1, 0) end
        if copper then copper:SetPoint('LEFT', silver, 'RIGHT', 1, 0) end

        F.StripTextures(frame)
        for j = 1, 4 do
            local button = _G['StaticPopup' .. i .. 'Button' .. j]
            if button then
                F.StripTextures(button)
                F.ReskinButton(button)
            end
        end
        F.SetBD(frame)
        F.ReskinClose(close)

        close.minimize = close:CreateTexture(nil, 'OVERLAY')
        close.minimize:SetSize(9, C.MULT)
        close.minimize:SetPoint('CENTER')
        close.minimize:SetTexture(C.Assets.Textures.Backdrop)
        close.minimize:SetVertexColor(1, 1, 1)
        close:HookScript('OnEnter', colorMinimize)
        close:HookScript('OnLeave', clearMinimize)

        if frame.EditBox then
            F.ReskinEditbox(frame.EditBox, 20)
            if frame.EditBox.NineSlice then
                frame.EditBox.NineSlice:SetAlpha(0)
            end
        end
        if gold then F.ReskinEditbox(gold) end
        if silver then F.ReskinEditbox(silver) end
        if copper then F.ReskinEditbox(copper) end
    end

    hooksecurefunc('StaticPopup_Show', function(which, _, _, data)
        local info = StaticPopupDialogs[which]

        if not info then
            return
        end

        local dialog = _G.StaticPopup_FindVisible(which, data)

        if not dialog then
            local index = 1
            if info.preferredIndex then
                index = info.preferredIndex
            end
            for i = index, STATICPOPUP_NUMDIALOGS do
                local frame = _G['StaticPopup' .. i]
                if not frame:IsShown() then
                    dialog = frame
                    break
                end
            end

            if not dialog and info.preferredIndex then
                for i = 1, info.preferredIndex do
                    local frame = _G['StaticPopup' .. i]
                    if not frame:IsShown() then
                        dialog = frame
                        break
                    end
                end
            end
        end

        if not dialog then
            return
        end

        if info.closeButton then
            local closeButton = _G[dialog:GetName() .. 'CloseButton']

            closeButton:SetNormalTexture(0)
            closeButton:SetPushedTexture(0)

            if info.closeButtonIsHide then
                if closeButton.pixels then
                    for _, pixel in pairs(closeButton.pixels) do
                        pixel:Hide()
                    end
                end
                if closeButton.minimize then
                    closeButton.minimize:Show()
                end
            else
                if closeButton.pixels then
                    for _, pixel in pairs(closeButton.pixels) do
                        pixel:Show()
                    end
                end
                if closeButton.minimize then
                    closeButton.minimize:Hide()
                end
            end
        end
    end)

    -- PVP ready dialog
    local PVPReadyDialog = _G.PVPReadyDialog
    if PVPReadyDialog then
        F.StripTextures(PVPReadyDialog)
        F.SetBD(PVPReadyDialog)
        if PVPReadyDialog.enterButton then F.ReskinButton(PVPReadyDialog.enterButton) end
        if PVPReadyDialog.hideButton then F.ReskinButton(PVPReadyDialog.hideButton) end
    end

    -- Pet battle queue popup
    if _G.PetBattleQueueReadyFrame then
        F.SetBD(_G.PetBattleQueueReadyFrame)
        if _G.PetBattleQueueReadyFrame.Art then
            F.CreateBDFrame(_G.PetBattleQueueReadyFrame.Art)
        end
        if _G.PetBattleQueueReadyFrame.Border then
            _G.PetBattleQueueReadyFrame.Border:Hide()
        end
        if _G.PetBattleQueueReadyFrame.AcceptButton then
            F.ReskinButton(_G.PetBattleQueueReadyFrame.AcceptButton)
        end
        if _G.PetBattleQueueReadyFrame.DeclineButton then
            F.ReskinButton(_G.PetBattleQueueReadyFrame.DeclineButton)
        end
    end

    -- PlayerReportFrame
    if _G.ReportFrame then
        F.StripTextures(_G.ReportFrame)
        F.SetBD(_G.ReportFrame)
        F.ReskinClose(_G.ReportFrame.CloseButton)
        if _G.ReportFrame.ReportButton then F.ReskinButton(_G.ReportFrame.ReportButton) end
        if _G.ReportFrame.CancelButton then F.ReskinButton(_G.ReportFrame.CancelButton) end
        if _G.ReportFrame.ReportingMajorCategoryDropdown then
            F.ReskinDropdown(_G.ReportFrame.ReportingMajorCategoryDropdown)
        end
        if _G.ReportFrame.Comment then
            F.StripTextures(_G.ReportFrame.Comment)
            F.ReskinEditbox(_G.ReportFrame.Comment)
        end

        hooksecurefunc(_G.ReportFrame, 'AnchorMinorCategory', function(self)
            if self.MinorCategoryButtonPool then
                for button in self.MinorCategoryButtonPool:EnumerateActive() do
                    if not button.styled then
                        F.StripTextures(button)
                        button.bg = F.CreateBDFrame(button, 0.25)
                        button:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
                        button:HookScript('OnClick', updateMinorButtonState)

                        button.styled = true
                    end

                    updateMinorButtonState(button)
                end
            end
        end)
    end
end)