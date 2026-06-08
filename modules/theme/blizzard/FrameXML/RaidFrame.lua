local F, C = unpack(select(2, ...))

tinsert(C.BlizzThemes, function()
    if not _G.ANDROMEDA_ADB.ReskinBlizz then
        return
    end

    F.StripTextures(_G.RaidInfoFrame)
    F.SetBD(_G.RaidInfoFrame)
    F.ReskinCheckbox(_G.RaidFrameAllAssistCheckButton)

    _G.RaidInfoFrame:SetPoint('TOPLEFT', _G.RaidFrame, 'TOPRIGHT', 1, -28)

    -- 隐藏可能存在的细节框架元素
    if _G.RaidInfoDetailFooter then _G.RaidInfoDetailFooter:Hide() end
    if _G.RaidInfoDetailHeader then _G.RaidInfoDetailHeader:Hide() end

    F.ReskinButton(_G.RaidFrameRaidInfoButton)
    F.ReskinButton(_G.RaidFrameConvertToRaidButton)
    F.ReskinButton(_G.RaidInfoExtendButton)
    F.ReskinButton(_G.RaidInfoCancelButton)
    F.ReskinClose(_G.RaidInfoCloseButton)
    F.ReskinTrimScroll(_G.RaidInfoFrame.ScrollBar)
    F.ReskinClose(_G.RaidParentFrameCloseButton)

    F.ReskinPortraitFrame(_G.RaidParentFrame)

    -- 处理标签框架（参考 NDui）
    if _G.RaidInfoInstanceLabel then
        local function handleHeader(header)
            if not header then return end
            F.StripTextures(header)
            local bg = F.CreateBDFrame(header, 0.25)
            bg:SetPoint('TOPLEFT', 2, 0)
            bg:SetPoint('BOTTOMRIGHT', -2, 0)
        end
        handleHeader(_G.RaidInfoInstanceLabel)
        handleHeader(_G.RaidInfoIDLabel)
    end
end)
