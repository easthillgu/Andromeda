local F, C = unpack(select(2, ...))

tinsert(C.BlizzThemes, function()
    F.SetBD(_G.TutorialFrame)

    if _G.TutorialFrameBackground then
        _G.TutorialFrameBackground:Hide()
        _G.TutorialFrameBackground.Show = nop
    end
    _G.TutorialFrame:DisableDrawLayer('BORDER')

    F.ReskinButton(_G.TutorialFrameOkayButton, true)
    F.ReskinClose(_G.TutorialFrameCloseButton)
    if _G.TutorialFramePrevButton then
        F.ReskinArrow(_G.TutorialFramePrevButton, 'left')
    end
    F.ReskinArrow(_G.TutorialFrameNextButton, 'right')

    _G.TutorialFrameOkayButton:ClearAllPoints()
    _G.TutorialFrameOkayButton:SetPoint('BOTTOMLEFT', _G.TutorialFrameNextButton, 'BOTTOMRIGHT', 10, 0)

    if _G.TutorialFramePrevButton then
    _G.TutorialFramePrevButton:SetScript('OnEnter', nil)
    end
    if _G.TutorialFrameNextButton then
    _G.TutorialFrameNextButton:SetScript('OnEnter', nil)
    end
    _G.TutorialFrameOkayButton.__bg:SetBackdropColor(0, 0, 0, 0.25)
    if _G.TutorialFramePrevButton then
        _G.TutorialFramePrevButton.__bg:SetBackdropColor(0, 0, 0, 0.25)
    end
    if _G.TutorialFrameNextButton then
        _G.TutorialFrameNextButton.__bg:SetBackdropColor(0, 0, 0, 0.25)
    end
end)
