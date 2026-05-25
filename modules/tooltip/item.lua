local F, C, L = unpack(select(2, ...))
local TOOLTIP = F:GetModule('Tooltip')

local expansionList = {
    [0] = _G.EXPANSION_NAME0,
    [1] = _G.EXPANSION_NAME1,
    [2] = _G.EXPANSION_NAME2,
    [3] = _G.EXPANSION_NAME3,
    -- 3.80.1: EXPANSION_NAME4-9 are Retail-only (WoD→TWW), nil
}

local function addLinesForItem(self)
    if not C.DB.Tooltip.ShowItemInfo then
        return
    end
    if C.DB.Tooltip.ShowItemInfoByAlt and not IsAltKeyDown() then
        return
    end

    local _, link = self:GetItem()
    if not link then
        return
    end

    local bagCount = GetItemCount(link)
    local bankCount = GetItemCount(link, true) - bagCount
    local itemStackCount = select(8, GetItemInfo(link))
    local itemSellPrice = select(11, GetItemInfo(link))
    local expacID = select(15, GetItemInfo(link))

    if bankCount > 0 then
        self:AddDoubleLine(_G.BAGSLOT .. '/' .. _G.BANK .. ':', bagCount .. '/' .. bankCount, 0.5, 0.8, 1, 1, 1, 1)
    elseif bagCount > 1 then
        self:AddDoubleLine(_G.BAGSLOT .. ':', bagCount, 0.5, 0.8, 1, 1, 1, 1)
    end

    if itemStackCount and itemStackCount > 1 then
        self:AddDoubleLine(L['Stack Cap'] .. ':', itemStackCount, 0.5, 0.8, 1, 1, 1, 1)
    end

    if itemSellPrice and itemSellPrice > 0 then
        self:AddDoubleLine(_G.AUCTION_PRICE .. ':', GetMoneyString(itemSellPrice, true), 0.5, 0.8, 1, 1, 1, 1)
    end

    if expacID and expansionList[expacID] then
        self:AddDoubleLine(L['Expansion'] .. ':', expansionList[expacID], 0.5, 0.8, 1)
    end
end

function TOOLTIP:ItemInfo()
    _G.ITEM_CREATED_BY = ''

    _G.GameTooltip:HookScript('OnTooltipSetItem', function(self)
        if self:IsForbidden() then
            return
        end
        addLinesForItem(self)
    end)

    _G.ItemRefTooltip:HookScript('OnTooltipSetItem', function(self)
        if self:IsForbidden() then
            return
        end
        addLinesForItem(self)
    end)
end
