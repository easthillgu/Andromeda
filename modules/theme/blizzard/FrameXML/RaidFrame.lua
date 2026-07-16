local F, C = unpack(select(2, ...))

tinsert(C.BlizzThemes, function()
    if not _G.ANDROMEDA_ADB.ReskinBlizz then
        return
    end

    -- 参考 NDui：直接移除背景纹理，然后设置美化背景
    if _G.RaidInfoFrame then
        F.StripTextures(_G.RaidInfoFrame)
        F.SetBD(_G.RaidInfoFrame)
    end

    if _G.RaidFrameAllAssistCheckButton then
        F.ReskinCheckbox(_G.RaidFrameAllAssistCheckButton)
    end

    if _G.RaidInfoFrame then
        _G.RaidInfoFrame:SetPoint('TOPLEFT', _G.RaidFrame, 'TOPRIGHT', 1, -28)
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
    if _G.RaidInfoFrame and _G.RaidInfoFrame.ScrollBar then
        F.ReskinTrimScroll(_G.RaidInfoFrame.ScrollBar)
    end
    if _G.RaidParentFrameCloseButton then
        F.ReskinClose(_G.RaidParentFrameCloseButton)
    end

    if _G.RaidParentFrame then
        F.ReskinPortraitFrame(_G.RaidParentFrame)
    end

    if _G.RaidInfoInstanceLabel then
        local function handleHeader(header)
            F.StripTextures(header)
            local bg = F.CreateBDFrame(header, 0.25)
            bg:SetPoint('TOPLEFT', 2, 0)
            bg:SetPoint('BOTTOMRIGHT', -2, 0)
        end
        handleHeader(_G.RaidInfoInstanceLabel)
        if _G.RaidInfoIDLabel then
            handleHeader(_G.RaidInfoIDLabel)
        end
    end
end)