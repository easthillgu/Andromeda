local F, C = unpack(select(2, ...))

local function reskinOptionCheck(button)
    if not button then return end  -- 3.80.1: nil guard
    F.ReskinCheckbox(button)
    if button.bg then
        button.bg:SetInside(button, 6, 6)
    end
end

tinsert(C.BlizzThemes, function()
    if not _G.ANDROMEDA_ADB.ReskinBlizz then
        return
    end

    if not C.HAS_EDIT_MODE then return end
    local frame = EditModeManagerFrame

    F.StripTextures(frame)
    F.SetBD(frame)
    F.ReskinClose(frame.CloseButton)
    F.ReskinButton(frame.RevertAllChangesButton)
    F.ReskinButton(frame.SaveChangesButton)
    F.ReskinDropdown(frame.LayoutDropdown)
    reskinOptionCheck(frame.ShowGridCheckButton.Button)
    reskinOptionCheck(frame.EnableSnapCheckButton.Button)
    reskinOptionCheck(frame.EnableAdvancedOptionsCheckButton.Button)
    F.ReskinStepperSlider(frame.GridSpacingSlider.Slider, true)
    if frame.Tutorial then
        frame.Tutorial.Ring:Hide()
    end

    local dialog = EditModeSystemSettingsDialog
    if dialog then
        F.StripTextures(dialog)
        F.SetBD(dialog)
        F.ReskinClose(dialog.CloseButton)
    end

    if frame.AccountSettings then
        frame.AccountSettings.SettingsContainer.BorderArt:Hide()
        F.CreateBDFrame(frame.AccountSettings.SettingsContainer, .25)
        F.ReskinTrimScroll(frame.AccountSettings.SettingsContainer.ScrollBar)
    end

    local function reskinOptionChecks(settings)
        for i = 1, settings:GetNumChildren() do
            local option = select(i, settings:GetChildren())
            if option.Button and not option.styled then
                reskinOptionCheck(option.Button)
                option.styled = true
            end
        end
    end

    hooksecurefunc(frame.AccountSettings, "OnEditModeEnter", function(self)
        local basicOptions = self.SettingsContainer.ScrollChild.BasicOptionsContainer
        if basicOptions then
            reskinOptionChecks(basicOptions)
        end

        local advancedOptions = self.SettingsContainer.ScrollChild.AdvancedOptionsContainer
        if advancedOptions then
            if advancedOptions.FramesContainer then
                reskinOptionChecks(advancedOptions.FramesContainer)
            end
            if advancedOptions.CombatContainer then
                reskinOptionChecks(advancedOptions.CombatContainer)
            end
            if advancedOptions.MiscContainer then
                reskinOptionChecks(advancedOptions.MiscContainer)
            end
        end
    end)

    if dialog then
        hooksecurefunc(dialog, "UpdateExtraButtons", function(self)
            local revertButton = self.Buttons and self.Buttons.RevertChangesButton
            if revertButton and not revertButton.styled then
                F.ReskinButton(revertButton)
                revertButton.styled = true
            end

            for button in self.pools:EnumerateActiveByTemplate("EditModeSystemSettingsDialogExtraButtonTemplate") do
                if not button.styled then
                    F.ReskinButton(button)
                    button.styled = true
                end
            end

            for check in self.pools:EnumerateActiveByTemplate("EditModeSettingCheckboxTemplate") do
                if not check.styled then
                    F.ReskinCheckbox(check.Button)
                    if check.Button.bg then
                        check.Button.bg:SetInside(nil, 6, 6)
                    end
                    check.styled = true
                end
            end

            for dropdown in self.pools:EnumerateActiveByTemplate("EditModeSettingDropdownTemplate") do
                if not dropdown.styled then
                    F.ReskinDropdown(dropdown.Dropdown)
                    dropdown.styled = true
                end
            end

            for slider in self.pools:EnumerateActiveByTemplate("EditModeSettingSliderTemplate") do
                if not slider.styled then
                    F.ReskinStepperSlider(slider.Slider, true)
                    slider.styled = true
                end
            end
        end)
    end

    -- Unsaved Changes dialog
    local unsavedDialog = EditModeUnsavedChangesDialog
    if unsavedDialog then
        F.StripTextures(unsavedDialog)
        F.SetBD(unsavedDialog)
        F.ReskinButton(unsavedDialog.SaveAndProceedButton)
        F.ReskinButton(unsavedDialog.ProceedButton)
        F.ReskinButton(unsavedDialog.CancelButton)
    end

    local function ReskinLayoutDialog(dialog)
        F.StripTextures(dialog)
        F.SetBD(dialog)
        F.ReskinButton(dialog.AcceptButton)
        F.ReskinButton(dialog.CancelButton)

        local check = dialog.CharacterSpecificLayoutCheckButton
        if check then
            F.ReskinCheckbox(check.Button)
            if check.Button.bg then
                check.Button.bg:SetInside(nil, 6, 6)
            end
        end

        local editbox = dialog.LayoutNameEditBox
        if editbox then
            F.ReskinEditbox(editbox)
            if editbox.bg then
                editbox.bg:SetPoint("TOPLEFT", -5, -5)
                editbox.bg:SetPoint("BOTTOMRIGHT", 5, 5)
            end
        end

        local importBox = dialog.ImportBox
        if importBox then
            F.StripTextures(importBox)
            F.CreateBDFrame(importBox, .25)
        end
    end

    ReskinLayoutDialog(EditModeNewLayoutDialog)
    ReskinLayoutDialog(EditModeImportLayoutDialog)
end)