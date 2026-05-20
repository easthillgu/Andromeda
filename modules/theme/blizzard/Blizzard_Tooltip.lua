local F, C = unpack(select(2, ...))

tinsert(C.BlizzThemes, function()
    -- 3.80.1: skin GameTooltip status bar
    local statusBar = _G.GameTooltipStatusBar
    if statusBar then
        statusBar:SetStatusBarTexture(C.Assets.Textures.StatusbarNormal)
        F.CreateBDFrame(statusBar)
    end

    -- ItemRef close button
    if _G.ItemRefCloseButton then
        F.ReskinClose(_G.ItemRefCloseButton)
    end

    -- Embedded ItemTooltip icon
    local embeddedTT = _G.EmbeddedItemTooltip
    if embeddedTT and embeddedTT.ItemTooltip then
        if embeddedTT.ItemTooltip.Icon then
            F.ReskinIcon(embeddedTT.ItemTooltip.Icon)
        end
    end

    -- Skin various tooltip frames
    local tooltips = {
        _G.ItemRefTooltip,
        _G.ItemRefShoppingTooltip1,
        _G.ItemRefShoppingTooltip2,
        _G.FriendsTooltip,
        _G.EmbeddedItemTooltip,
        _G.ReputationParagonTooltip,
        _G.GameTooltip,
        _G.WorldMapTooltip,
        _G.ShoppingTooltip1,
        _G.ShoppingTooltip2,
        _G.QuickKeybindTooltip,
        _G.LibDBIconTooltip,
        _G.SettingsTooltip,
    }

    for _, tt in pairs(tooltips) do
        if tt then
            F.CreateBDFrame(tt)
        end
    end
end)
