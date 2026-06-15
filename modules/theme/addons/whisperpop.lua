local F, C = unpack(select(2, ...))
local THEME = F:GetModule('Theme')

function THEME:ReskinWhisperPop()
    if not C_AddOns.IsAddOnLoaded('WhisperPop') then
        return
    end

    if not _G.ANDROMEDA_ADB.ReskinWhisperPop then
        return
    end

    if _G.WhisperPopFrame then
        F.StripTextures(_G.WhisperPopFrame)
        F.SetBD(_G.WhisperPopFrame)
    end

    if _G.WhisperPopMessageFrame then
        F.StripTextures(_G.WhisperPopMessageFrame)
        F.SetBD(_G.WhisperPopMessageFrame)
    end

    if _G.WhisperPopScrollingMessageFrameButtonDown then
        F.ReskinArrow(_G.WhisperPopScrollingMessageFrameButtonDown)
    end

    if _G.WhisperPopScrollingMessageFrameButtonEnd then
        F.ReskinArrow(_G.WhisperPopScrollingMessageFrameButtonEnd)
    end

    if _G.WhisperPopScrollingMessageFrameButtonUp then
        F.ReskinArrow(_G.WhisperPopScrollingMessageFrameButtonUp)
    end

    if _G.WhisperPopScrollingMessageFrameButtonDown and _G.WhisperPopScrollingMessageFrameButtonEnd then
        _G.WhisperPopScrollingMessageFrameButtonDown:SetPoint('BOTTOM', _G.WhisperPopScrollingMessageFrameButtonEnd, 'TOP', 0, 0)
    end

    if _G.WhisperPopScrollingMessageFrameButtonUp and _G.WhisperPopScrollingMessageFrameButtonDown then
        _G.WhisperPopScrollingMessageFrameButtonUp:SetPoint('BOTTOM', _G.WhisperPopScrollingMessageFrameButtonDown, 'TOP', 0, 0)
    end

    if _G.WhisperPopMessageFrameProtectCheck then
        F.ReskinCheckbox(_G.WhisperPopMessageFrameProtectCheck)
    end

    if _G.WhisperPopFrameConfig then
        F.ReskinButton(_G.WhisperPopFrameConfig)
    end

    if _G.WhisperPopNotifyButton then
        F.ReskinButton(_G.WhisperPopNotifyButton)
    end

    if _G.WhisperPopFrameListScrollBar then
        F.ReskinScroll(_G.WhisperPopFrameListScrollBar)
    end

    local closeButtons = {
        _G.WhisperPopFrameListDelete,
        _G.WhisperPopFrameTopCloseButton,
        _G.WhisperPopMessageFrameTopCloseButton,
    }

    for _, button in pairs(closeButtons) do
        if button then
            F.ReskinClose(button)
        end
    end
end