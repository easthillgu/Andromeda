local F, C = unpack(select(2, ...))

tinsert(C.BlizzThemes, function()
    if not _G.ANDROMEDA_ADB.ReskinBlizz then
        return
    end

    if _G.RaidInfoFrame.NineSlice then
        _G.RaidInfoFrame.NineSlice:SetAlpha(0)
    end
    if _G.RaidInfoFrame.SetBackdrop then
        _G.RaidInfoFrame:SetBackdrop(nil)
    end
    F.SetBD(_G.RaidInfoFrame)

    if _G.RaidFrameAllAssistCheckButton then
        F.ReskinCheckbox(_G.RaidFrameAllAssistCheckButton)
    end

    if _G.RaidInfoFrame.Header then
        F.StripTextures(_G.RaidInfoFrame.Header)
    end

    _G.RaidInfoFrame:SetPoint('TOPLEFT', _G.RaidFrame, 'TOPRIGHT', 1, -28)

    if _G.RaidInfoDetailFooter then
        _G.RaidInfoDetailFooter:Hide()
    end
    if _G.RaidInfoDetailHeader then
        _G.RaidInfoDetailHeader:Hide()
    end

    if _G.RaidFrameRaidInfoButton then
        F.ReskinButton(_G.RaidFrameRaidInfoButton)
    end
    if _G.RaidFrameConvertToRaidButton then
        F.ReskinButton(_G.RaidFrameConvertToRaidButton)
    end
    if _G.RaidInfoExtendButton then
        F.ReskinButton(_G.RaidInfoExtendButton)
    end
    if _G.RaidInfoCancelButton then
        F.ReskinButton(_G.RaidInfoCancelButton)
    end
    if _G.RaidInfoCloseButton then
        F.ReskinClose(_G.RaidInfoCloseButton)
    end
    if _G.RaidInfoFrame.ScrollBar then
        F.ReskinTrimScroll(_G.RaidInfoFrame.ScrollBar)
    end
    if _G.RaidParentFrameCloseButton then
        F.ReskinClose(_G.RaidParentFrameCloseButton)
    end

    F.ReskinPortraitFrame(_G.RaidParentFrame)

    if _G.RaidInfoInstanceLabel then
        local function handleHeader(header)
            F.StripTextures(header)
            local bg = F.CreateBDFrame(header, 0.25)
            bg:SetPoint('TOPLEFT', 2, 0)
            bg:SetPoint('BOTTOMRIGHT', -2, 0)
        end
        handleHeader(_G.RaidInfoInstanceLabel)
        handleHeader(_G.RaidInfoIDLabel)
    end
end)
