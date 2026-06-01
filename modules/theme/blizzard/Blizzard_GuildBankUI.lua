local F, C = unpack(select(2, ...))

C.Themes['Blizzard_GuildBankUI'] = function()
    F.StripTextures(_G.GuildBankFrame)
    F.ReskinPortraitFrame(_G.GuildBankFrame)

    if _G.GuildBankFrame.Emblem then
        _G.GuildBankFrame.Emblem:Hide()
    end
    if _G.GuildBankFrame.MoneyFrameBG then
        _G.GuildBankFrame.MoneyFrameBG:Hide()
    end
    F.ReskinButton(_G.GuildBankFrame.WithdrawButton)
    F.ReskinButton(_G.GuildBankFrame.DepositButton)
    if C.IS_NEW_PATCH_10_1 then
        F.ReskinTrimScroll(_G.GuildBankFrame.Log.ScrollBar)
        F.ReskinTrimScroll(_G.GuildBankInfoScrollFrame.ScrollBar)
    else
        F.ReskinScroll(_G.GuildBankTransactionsScrollFrameScrollBar)
        F.ReskinScroll(_G.GuildBankInfoScrollFrameScrollBar)
    end
    F.ReskinButton(_G.GuildBankFrame.BuyInfo.PurchaseButton)
    F.ReskinButton(_G.GuildBankFrame.Info.SaveButton)
    F.ReskinEditbox(_G.GuildItemSearchBox)

    _G.GuildBankFrame.WithdrawButton:SetPoint('RIGHT', _G.GuildBankFrame.DepositButton, 'LEFT', -2, 0)

    for i = 1, 4 do
        local tab = _G['GuildBankFrameTab' .. i]
        F.ReskinTab(tab)

        if i ~= 1 then
            tab:SetPoint('LEFT', _G['GuildBankFrameTab' .. i - 1], 'RIGHT', -15, 0)
        end
    end

    if _G.GuildBankFrame.Columns then
        for i = 1, 7 do
            local column = _G.GuildBankFrame.Columns[i]
            if column then
                local region = column:GetRegions()
                if region then
                    region:Hide()
                end

                if column.Buttons then
                    for j = 1, 14 do
                        local button = column.Buttons[j]
                        if button then
                            button:SetNormalTexture(0)
                            button:SetPushedTexture(0)
                            local highlight = button:GetHighlightTexture()
                            if highlight then
                                highlight:SetColorTexture(1, 1, 1, 0.25)
                            end
                            if button.icon then
                                button.icon:SetTexCoord(unpack(C.TEX_COORD))
                                button.bg = F.CreateBDFrame(button, 0.3)
                                button.bg:SetBackdropColor(0.3, 0.3, 0.3, 0.3)
                            end
                            if button.searchOverlay then
                                button.searchOverlay:SetOutside()
                            end
                            if button.IconBorder then
                                F.ReskinIconBorder(button.IconBorder)
                            end
                        end
                    end
                end
            end
        end
    end

    for i = 1, 8 do
        local tab = _G['GuildBankTab' .. i]
        if tab then
            local button = tab.Button
            if button then
                local icon = button.IconTexture

                F.StripTextures(tab)
                button:SetNormalTexture(0)
                button:SetPushedTexture(0)
                local highlight = button:GetHighlightTexture()
                if highlight then
                    highlight:SetColorTexture(1, 1, 1, 0.25)
                end
                button:SetCheckedTexture(C.Assets.Textures.ButtonChecked)
                F.CreateBDFrame(button)
                if icon then
                    icon:SetTexCoord(unpack(C.TEX_COORD))
                end

                local a1, p, a2, x, y = button:GetPoint()
                if a1 and p and a2 then
                    button:SetPoint(a1, p, a2, x + C.MULT, y)
                end
            end
        end
    end

    if _G.GuildBankPopupFrame then
        F.ReskinIconSelector(_G.GuildBankPopupFrame)
    end
end
