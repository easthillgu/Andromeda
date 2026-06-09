local F, C = unpack(select(2, ...))

C.Themes['Blizzard_TrainerUI'] = function()
    local r, g, b = C.r, C.g, C.b

    F.ReskinPortraitFrame(_G.ClassTrainerFrame, 10, -5, -30, 70)

    if _G.ClassTrainerTrainButton then
        F.ReskinButton(_G.ClassTrainerTrainButton)
    end

    if _G.ClassTrainerCancelButton then
        F.ReskinButton(_G.ClassTrainerCancelButton)
    end

    if _G.ClassTrainerFrame.FilterDropdown then
        F.ReskinDropdown(_G.ClassTrainerFrame.FilterDropdown)
    elseif _G.ClassTrainerFrameFilterDropDown then
        F.ReskinDropdown(_G.ClassTrainerFrameFilterDropDown)
    end

    if _G.ClassTrainerListScrollFrameScrollBar then
        F.ReskinScroll(_G.ClassTrainerListScrollFrameScrollBar)
    elseif _G.ClassTrainerFrame.ScrollBar then
        F.ReskinTrimScroll(_G.ClassTrainerFrame.ScrollBar)
    end

    if _G.ClassTrainerDetailScrollFrame then
        F.ReskinScroll(_G.ClassTrainerDetailScrollFrameScrollBar)
        F.CreateBDFrame(_G.ClassTrainerDetailScrollFrame, 0.25)
    end

    if _G.ClassTrainerCollapseAllButton then
        F.ReskinCollapse(_G.ClassTrainerCollapseAllButton)
    end

    if _G.ClassTrainerExpandButtonFrame then
        _G.ClassTrainerExpandButtonFrame:DisableDrawLayer('BACKGROUND')
    end

    for i = 1, 11 do
        local bu = _G['ClassTrainerSkill' .. i]
        if bu then
            F.ReskinCollapse(bu)
        end
    end

    if _G.ClassTrainerSkillIcon then
        hooksecurefunc('ClassTrainer_SetSelection', function()
            local tex = _G.ClassTrainerSkillIcon:GetNormalTexture()
            if tex then
                tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            end
        end)
        F.StripTextures(_G.ClassTrainerSkillIcon)
        F.CreateBDFrame(_G.ClassTrainerSkillIcon)
    end

    if _G.ClassTrainerFrameSkillStepButtonIcon then
        local icbg = F.ReskinIcon(_G.ClassTrainerFrameSkillStepButtonIcon)
        local bg = F.CreateBDFrame(_G.ClassTrainerFrameSkillStepButton, 0.25)
        bg:SetPoint('TOPLEFT', icbg, 'TOPRIGHT', 1, 0)
        bg:SetPoint('BOTTOMRIGHT', icbg, 'BOTTOMRIGHT', 270, 0)

        _G.ClassTrainerFrameSkillStepButton:SetNormalTexture(0)
        _G.ClassTrainerFrameSkillStepButton:SetHighlightTexture(0)
        if _G.ClassTrainerFrameSkillStepButton.disabledBG then
            _G.ClassTrainerFrameSkillStepButton.disabledBG:SetTexture(0)
        end
        if _G.ClassTrainerFrameSkillStepButton.selectedTex then
            _G.ClassTrainerFrameSkillStepButton.selectedTex:SetInside(bg)
            _G.ClassTrainerFrameSkillStepButton.selectedTex:SetColorTexture(r, g, b, 0.25)
        end
    end

    if _G.ClassTrainerStatusBar then
        F.StripTextures(_G.ClassTrainerStatusBar)
        _G.ClassTrainerStatusBar:SetPoint('TOPLEFT', _G.ClassTrainerFrame, 'TOPLEFT', 64, -35)
        _G.ClassTrainerStatusBar:SetStatusBarTexture(C.Assets.Textures.Backdrop)
        _G.ClassTrainerStatusBar:GetStatusBarTexture():SetGradient('VERTICAL', CreateColor(0.1, 0.3, 0.9, 1), CreateColor(0.2, 0.4, 1, 1))
        F.CreateBDFrame(_G.ClassTrainerStatusBar, 0.25)
    end

    if _G.ClassTrainerStatusBarSkillRank then
        _G.ClassTrainerStatusBarSkillRank:ClearAllPoints()
        _G.ClassTrainerStatusBarSkillRank:SetPoint('CENTER', _G.ClassTrainerStatusBar, 'CENTER', 0, 0)
    end

    if _G.ClassTrainerFrame.ScrollBox then
        hooksecurefunc(_G.ClassTrainerFrame.ScrollBox, 'Update', function(self)
            for i = 1, self.ScrollTarget:GetNumChildren() do
                local button = select(i, self.ScrollTarget:GetChildren())
                if button and not button.styled then
                    if button.icon then
                        local icbg = F.ReskinIcon(button.icon)
                        local bg = F.CreateBDFrame(button, 0.25)
                        bg:SetPoint('TOPLEFT', icbg, 'TOPRIGHT', 1, 0)
                        bg:SetPoint('BOTTOMRIGHT', icbg, 'BOTTOMRIGHT', 253, 0)

                        if button.name then
                            button.name:SetParent(bg)
                            button.name:SetPoint('TOPLEFT', button.icon, 'TOPRIGHT', 6, -2)
                        end
                        if button.subText then
                            button.subText:SetParent(bg)
                        end
                        if button.money then
                            button.money:SetParent(bg)
                            button.money:SetPoint('TOPRIGHT', button, 'TOPRIGHT', 5, -8)
                        end
                        button:SetNormalTexture(0)
                        button:SetHighlightTexture(0)
                        if button.disabledBG then
                            button.disabledBG:SetTexture(0)
                        end
                        if button.selectedTex then
                            button.selectedTex:SetInside(bg)
                            button.selectedTex:SetColorTexture(r, g, b, 0.25)
                        end

                        button.styled = true
                    end
                end
            end
        end)
    end
end