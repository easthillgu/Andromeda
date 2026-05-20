local F, C = unpack(select(2, ...))

local function reskinAuctionButtons(button, i)
    local bu = _G[button .. i]
    local it = _G[button .. i .. 'Item']
    local ic = _G[button .. i .. 'ItemIconTexture']

    if bu and it then
        it:SetNormalTexture(0)
        it:SetPushedTexture(0)
        local itemHL = it:GetHighlightTexture()
        if itemHL then
            itemHL:SetColorTexture(1, 1, 1, 0.25)
            itemHL:SetInside()
        end
        F.ReskinIcon(ic)
        if it.IconBorder then
            it.IconBorder:SetAlpha(0)
        end
        F.StripTextures(bu)

        local bg = F.CreateBDFrame(bu, 0.25)
        bg:SetPoint('TOPLEFT', ic, 'TOPRIGHT', 0, 0)
        bg:SetPoint('BOTTOMRIGHT', 0, 4)

        bu:SetHighlightTexture(C.Assets.Textures.Backdrop)
        local hl = bu:GetHighlightTexture()
        hl:SetVertexColor(C.r, C.g, C.b, 0.2)
        hl:SetInside(bg)
    end
end

C.Themes['Blizzard_AuctionUI'] = function()
    return  -- [3.80.1 DISABLED: all frames missing]
    local AuctionFrame = _G.AuctionFrame

    F.SetBD(AuctionFrame, nil, 2, -10, 0, 10)
    AuctionFrame:DisableDrawLayer('ARTWORK')
    _G.AuctionPortraitTexture:Hide()
    _G.AuctionFrameBot:Hide()

    F.StripTextures(_G.AuctionProgressFrame)
    F.SetBD(_G.AuctionProgressFrame)

    _G.AuctionProgressBar:SetStatusBarTexture(C.Assets.Textures.StatusbarNormal)
    F.CreateBDFrame(_G.AuctionProgressBar, 0.25)
    F.ReskinIcon(_G.AuctionProgressBar.Icon)
    _G.AuctionProgressBar.Text:SetPoint('CENTER', 0, 1)
    F.ReskinClose(_G.AuctionProgressFrameCancelButton)

    local auctionSorts = {
        _G.BrowseQualitySort,
        _G.BrowseLevelSort,
        _G.BrowseDurationSort,
        _G.BrowseHighBidderSort,
        _G.BrowseCurrentBidSort,
        _G.BidQualitySort,
        _G.BidLevelSort,
        _G.BidDurationSort,
        _G.BidBuyoutSort,
        _G.BidStatusSort,
        _G.BidBidSort,
        _G.AuctionsQualitySort,
        _G.AuctionsDurationSort,
        _G.AuctionsHighBidderSort,
        _G.AuctionsBidSort,
    }
    for _, tab in pairs(auctionSorts) do
        tab:DisableDrawLayer('BACKGROUND')
        local hl = tab:GetHighlightTexture()
        if hl then
            hl:SetColorTexture(C.r, C.g, C.b, 0.25)
        end
    end

    hooksecurefunc('FilterButton_SetUp', function(button)
        button:SetNormalTexture(0)
    end)

    local lastSkinnedTab = 1
    AuctionFrame:HookScript('OnShow', function()
        local tab = _G['AuctionFrameTab' .. lastSkinnedTab]
        while tab do
            F.ReskinTab(tab)
            lastSkinnedTab = lastSkinnedTab + 1
            tab = _G['AuctionFrameTab' .. lastSkinnedTab]
        end
    end)

    local abuttons = {
        'BrowseBidButton',
        'BrowseBuyoutButton',
        'BrowseCloseButton',
        'BrowseSearchButton',
        'BrowseResetButton',
        'BidBidButton',
        'BidBuyoutButton',
        'BidCloseButton',
        'AuctionsCloseButton',
        'AuctionsCancelAuctionButton',
        'AuctionsCreateAuctionButton',
        'AuctionsNumStacksMaxButton',
        'AuctionsStackSizeMaxButton',
    }
    for _, name in pairs(abuttons) do
        local button = _G[name]
        if button then
            F.ReskinButton(button)
        end
    end

    _G.BrowseSearchButton:SetPoint('TOPRIGHT', 25, -28)
    _G.BrowseCloseButton:ClearAllPoints()
    _G.BrowseCloseButton:SetPoint('BOTTOMRIGHT', _G.AuctionFrameBrowse, 'BOTTOMRIGHT', 66, 13)
    _G.BrowseBuyoutButton:ClearAllPoints()
    _G.BrowseBuyoutButton:SetPoint('RIGHT', _G.BrowseCloseButton, 'LEFT', -1, 0)
    _G.BidBuyoutButton:ClearAllPoints()
    _G.BidBuyoutButton:SetPoint('RIGHT', _G.BidCloseButton, 'LEFT', -1, 0)
    _G.BidBidButton:ClearAllPoints()
    _G.BidBidButton:SetPoint('RIGHT', _G.BidBuyoutButton, 'LEFT', -1, 0)
    _G.AuctionsCancelAuctionButton:ClearAllPoints()
    _G.AuctionsCancelAuctionButton:SetPoint('RIGHT', _G.AuctionsCloseButton, 'LEFT', -1, 0)

    for i = 1, _G.NUM_BROWSE_TO_DISPLAY do
        reskinAuctionButtons('BrowseButton', i)
    end

    for i = 1, _G.NUM_BIDS_TO_DISPLAY do
        reskinAuctionButtons('BidButton', i)
    end

    for i = 1, _G.NUM_AUCTIONS_TO_DISPLAY do
        reskinAuctionButtons('AuctionsButton', i)
    end

    F:RegisterEvent('NEW_AUCTION_UPDATE', function()
        local iconTexture = _G.AuctionsItemButton:GetNormalTexture()
        if iconTexture then
            iconTexture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            iconTexture:SetInside()
        end
        if _G.AuctionsItemButton.IconBorder then
            _G.AuctionsItemButton.IconBorder:SetTexture('')
        end
    end)

    F.CreateBDFrame(_G.AuctionsItemButton, 0.25)
    local _, AuctionsItemButtonNameFrame = _G.AuctionsItemButton:GetRegions()
    if AuctionsItemButtonNameFrame then
        AuctionsItemButtonNameFrame:Hide()
    end
    local hl = _G.AuctionsItemButton:GetHighlightTexture()
    hl:SetColorTexture(1, 1, 1, 0.25)
    hl:SetInside()

    F.ReskinClose(_G.AuctionFrameCloseButton)
    F.ReskinTrimScroll(_G.BrowseScrollFrameScrollBar)
    F.ReskinTrimScroll(_G.AuctionsScrollFrameScrollBar)
    F.ReskinTrimScroll(_G.BrowseFilterScrollFrameScrollBar)
    F.ReskinTrimScroll(_G.BidScrollFrameScrollBar)
    F.ReskinEditbox(_G.BrowseName)
    F.ReskinArrow(_G.BrowsePrevPageButton, 'left')
    F.ReskinArrow(_G.BrowseNextPageButton, 'right')
    F.ReskinCheckbox(_G.IsUsableCheckButton)
    F.ReskinCheckbox(_G.ShowOnPlayerCheckButton)
    F.ReskinRadio(_G.AuctionsShortAuctionButton)
    F.ReskinRadio(_G.AuctionsMediumAuctionButton)
    F.ReskinRadio(_G.AuctionsLongAuctionButton)
    F.ReskinDropdown(_G.BrowseDropdown)

    local inputs = {'BrowseMinLevel', 'BrowseMaxLevel', 'AuctionsStackSizeEntry', 'AuctionsNumStacksEntry'}
    for i = 1, #inputs do
        F.ReskinEditbox(_G[inputs[i]])
    end

    F.ReskinButton(_G.BrowsePriceOptionsButtonFrame.Button)

    F.StripTextures(_G.BrowsePriceOptionsFrame)
    F.SetBD(_G.BrowsePriceOptionsFrame)
    for _, child in next, {_G.BrowsePriceOptionsFrame:GetChildren()} do
        if child:IsObjectType('Button') then
            F.ReskinButton(child)
        elseif child:IsObjectType('CheckButton') then
            F.ReskinRadio(child)
        end
    end
end