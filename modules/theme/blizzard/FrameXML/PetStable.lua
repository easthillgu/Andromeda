local F, C = unpack(select(2, ...))

tinsert(C.BlizzThemes, function()
    if not _G.ANDROMEDA_ADB.ReskinBlizz then
        return
    end

    local class = select(2, UnitClass('player'))
    if class ~= 'HUNTER' then
        return
    end

    if _G.PetStableBottomInset then _G.PetStableBottomInset:Hide() end
    if _G.PetStableLeftInset then _G.PetStableLeftInset:Hide() end
    if _G.PetStableModelShadow then _G.PetStableModelShadow:Hide() end
    if _G.PetStableModelRotateLeftButton then _G.PetStableModelRotateLeftButton:Hide() end
    if _G.PetStableModelRotateRightButton then _G.PetStableModelRotateRightButton:Hide() end
    if _G.PetStableFrameModelBg then _G.PetStableFrameModelBg:Hide() end
    if _G.PetStablePrevPageButtonIcon then _G.PetStablePrevPageButtonIcon:SetTexture('') end
    if _G.PetStableNextPageButtonIcon then _G.PetStableNextPageButtonIcon:SetTexture('') end

    F.ReskinPortraitFrame(_G.PetStableFrame)
    F.ReskinArrow(_G.PetStablePrevPageButton, 'left')
    F.ReskinArrow(_G.PetStableNextPageButton, 'right')
    F.ReskinIcon(_G.PetStableSelectedPetIcon)

    local numActive = _G.NUM_PET_ACTIVE_SLOTS
    if numActive then for i = 1, numActive do
        local bu = _G['PetStableActivePet' .. i]
        bu.Background:Hide()
        bu.Border:Hide()
        bu:SetNormalTexture(0)
        bu:SetPushedTexture(0)
        if bu.Checked then
            bu.Checked:SetTexture(C.Assets.Textures.ButtonChecked)
        end
        bu:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)

        _G['PetStableActivePet' .. i .. 'IconTexture']:SetTexCoord(unpack(C.TEX_COORD))
        F.CreateBDFrame(bu, 0.25)
    end end

    local numStable = _G.NUM_PET_STABLE_SLOTS
    if numStable then for i = 1, numStable do
        local bu = _G['PetStableStabledPet' .. i]
        bu:SetNormalTexture(0)
        bu:SetPushedTexture(0)
        if bu.Checked then
            bu.Checked:SetTexture(C.Assets.Textures.ButtonChecked)
        end
        bu:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
        bu:DisableDrawLayer('BACKGROUND')

        _G['PetStableStabledPet' .. i .. 'IconTexture']:SetTexCoord(unpack(C.TEX_COORD))
        F.CreateBDFrame(bu, 0.25)
    end end
end)