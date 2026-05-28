local F, C = unpack(select(2, ...))

tinsert(C.BlizzThemes, function()
    if not _G.ANDROMEDA_ADB.ReskinBlizz then
        return
    end

    _G.TradePlayerEnchantInset:Hide()
    _G.TradePlayerItemsInset:Hide()
    _G.TradeRecipientEnchantInset:Hide()
    _G.TradeRecipientItemsInset:Hide()
    _G.TradeRecipientBG:Hide()
    _G.TradeRecipientMoneyBg:Hide()
    _G.TradeRecipientBotLeftCorner:Hide()
    _G.TradeRecipientLeftBorder:Hide()

    if _G.TradePlayerItem7 then
        local region7 = select(4, _G.TradePlayerItem7:GetRegions())
        if region7 then region7:Hide() end
    end
    if _G.TradeRecipientItem7 then
        local region7 = select(4, _G.TradeRecipientItem7:GetRegions())
        if region7 then region7:Hide() end
    end

    F.ReskinPortraitFrame(_G.TradeFrame)
    if _G.TradeFrame.RecipientOverlay then
        _G.TradeFrame.RecipientOverlay:Hide()
    end
    F.ReskinButton(_G.TradeFrameTradeButton)
    F.ReskinButton(_G.TradeFrameCancelButton)

    -- Skip reskinning money editboxes as they are protected in secure frames
    -- F.ReskinEditbox(_G.TradePlayerInputMoneyFrameGold)
    -- F.ReskinEditbox(_G.TradePlayerInputMoneyFrameSilver)
    -- F.ReskinEditbox(_G.TradePlayerInputMoneyFrameCopper)

    -- Protected frames, skip SetPoint calls on money input frames
    -- _G.TradePlayerInputMoneyFrameSilver:SetPoint('LEFT', _G.TradePlayerInputMoneyFrameGold, 'RIGHT', 1, 0)
    -- _G.TradePlayerInputMoneyFrameCopper:SetPoint('LEFT', _G.TradePlayerInputMoneyFrameSilver, 'RIGHT', 1, 0)

    local function reskinButton(bu)
        if not bu then return end
        bu:SetNormalTexture(0)
        bu:SetPushedTexture(0)
        local hl = bu:GetHighlightTexture()
        if hl then
            hl:SetColorTexture(1, 1, 1, 0.25)
            hl:SetInside()
        end
        if bu.icon then
            bu.icon:SetTexCoord(unpack(C.TEX_COORD))
            bu.icon:SetInside()
        end
        if bu.IconOverlay then
            bu.IconOverlay:SetInside()
        end
        if bu.IconOverlay2 then
            bu.IconOverlay2:SetInside()
        end
        if bu.icon then
            bu.bg = F.CreateBDFrame(bu.icon, 0.25)
        end
        F.ReskinIconBorder(bu.IconBorder)
    end

    for i = 1, _G.MAX_TRADE_ITEMS do
        local playerSlotTex = _G['TradePlayerItem' .. i .. 'SlotTexture']
        if playerSlotTex then playerSlotTex:Hide() end
        local playerNameFrame = _G['TradePlayerItem' .. i .. 'NameFrame']
        if playerNameFrame then playerNameFrame:Hide() end
        local recipientSlotTex = _G['TradeRecipientItem' .. i .. 'SlotTexture']
        if recipientSlotTex then recipientSlotTex:Hide() end
        local recipientNameFrame = _G['TradeRecipientItem' .. i .. 'NameFrame']
        if recipientNameFrame then recipientNameFrame:Hide() end

        reskinButton(_G['TradePlayerItem' .. i .. 'ItemButton'])
        reskinButton(_G['TradeRecipientItem' .. i .. 'ItemButton'])
    end

    local tradeHighlights = {
        _G.TradeHighlightPlayer,
        _G.TradeHighlightPlayerEnchant,
        _G.TradeHighlightRecipient,
        _G.TradeHighlightRecipientEnchant,
    }
    for _, highlight in pairs(tradeHighlights) do
        if highlight then
            F.StripTextures(highlight)
            highlight:SetFrameStrata('HIGH')
            local bg = F.CreateBDFrame(highlight, 0.25)
            bg:SetBackdropColor(0, 1, 0, 0.15)
        end
    end
end)
