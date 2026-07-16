local F, C = unpack(select(2, ...))

tinsert(C.BlizzThemes, function()
    local arFrame = _G.ArenaRegistrarFrame
    if not arFrame then return end

    F.StripTextures(arFrame)
    F.SetBD(arFrame)

    -- Close button
    if _G.ArenaRegistrarFrameCloseButton then
        F.ReskinClose(_G.ArenaRegistrarFrameCloseButton)
    end

    -- Greeting frame
    local greetingFrame = _G.ArenaRegistrarGreetingFrame
    if greetingFrame then
        F.StripTextures(greetingFrame)
    end

    -- Goodbye button
    if _G.ArenaRegistrarFrameGoodbyeButton then
        F.ReskinButton(_G.ArenaRegistrarFrameGoodbyeButton)
    end

    -- Team buttons
    if _G.MAX_TEAM_BORDERS then
        for i = 1, _G.MAX_TEAM_BORDERS do
            local btn = _G['ArenaRegistrarButton' .. i]
            if btn then
                F.ReskinButton(btn)
            end
        end
    end

    -- Purchase/Cancel buttons
    if _G.ArenaRegistrarFrameCancelButton then
        F.ReskinButton(_G.ArenaRegistrarFrameCancelButton)
    end
    if _G.ArenaRegistrarFramePurchaseButton then
        F.ReskinButton(_G.ArenaRegistrarFramePurchaseButton)
    end

    -- Edit box
    if _G.ArenaRegistrarFrameEditBox then
        F.ReskinEditbox(_G.ArenaRegistrarFrameEditBox)
    end

    -- PVP Banner Frame
    local pvpBanner = _G.PVPBannerFrame
    if pvpBanner then
        F.StripTextures(pvpBanner)
        F.SetBD(pvpBanner)

        -- Close button
        if _G.PVPBannerFrameCloseButton then
            F.ReskinClose(_G.PVPBannerFrameCloseButton)
        end

        -- Portrait
        if _G.PVPBannerFramePortrait then
            _G.PVPBannerFramePortrait:Hide()
        end

        -- Customization frames
        local customFrame = _G.PVPBannerFrameCustomizationFrame
        if customFrame then
            F.StripTextures(customFrame)
        end

        for i = 1, 2 do
            local custom = _G['PVPBannerFrameCustomization' .. i]
            local leftBtn = _G['PVPBannerFrameCustomization' .. i .. 'LeftButton']
            local rightBtn = _G['PVPBannerFrameCustomization' .. i .. 'RightButton']

            if custom then F.StripTextures(custom) end
            if leftBtn then F.ReskinArrow(leftBtn, 'left') end
            if rightBtn then F.ReskinArrow(rightBtn, 'right') end
        end

        -- Color picker buttons
        for i = 1, 3 do
            local picker = _G['PVPColorPickerButton' .. i]
            if picker then F.ReskinButton(picker) end
        end

        -- Accept/Cancel
        if _G.PVPBannerFrameAcceptButton then
            F.ReskinButton(_G.PVPBannerFrameAcceptButton)
        end
        if _G.PVPBannerFrameCancelButton then
            F.ReskinButton(_G.PVPBannerFrameCancelButton)
        end
    end
end)