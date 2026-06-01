local F, C, L = unpack(select(2, ...))
local INVENTORY = F:GetModule('Inventory')

-- 3.80.1: C_Container API with global fallback
local GetContainerNumSlots = C_Container.GetContainerNumSlots or _G.GetContainerNumSlots
local GetContainerItemInfo = C_Container.GetContainerItemInfo or _G.GetContainerItemInfo
local GetContainerItemLink = C_Container.GetContainerItemLink or _G.GetContainerItemLink
local PickupContainerItem = C_Container.PickupContainerItem or _G.PickupContainerItem

CreateFrame('GameTooltip', 'AndromedaSortBagsTooltip', nil, 'GameTooltipTemplate')

local BAG_CONTAINERS = {0, 1, 2, 3, 4}
local BANK_CONTAINERS = {-1, 5, 6, 7, 8, 9, 10, 11}

-- 3.80.1 compatible: use item class/subclass for categorization
-- avoids hardcoded item IDs that don't exist in Cataclysm
local function GetItemCategory(classID, subclassID, equipLoc)
    -- 0: Special/Quest items
    if classID == LE_ITEM_CLASS_QUESTITEM then
        return 0
    end
    -- 1: Key items
    if classID == LE_ITEM_CLASS_KEY then
        return 1
    end
    -- 2: Trade goods (reagents, materials)
    if classID == LE_ITEM_CLASS_TRADEGOODS then
        return 2
    end
    -- 3: Recipes
    if classID == LE_ITEM_CLASS_RECIPE then
        return 3
    end
    -- 4: Consumables (food, potions, flasks, bandages, etc)
    if classID == LE_ITEM_CLASS_CONSUMABLE then
        return 4
    end
    -- 5: Gems
    if classID == LE_ITEM_CLASS_GEM then
        return 5
    end
    -- 6: Glyphs
    if classID == LE_ITEM_CLASS_GLYPH then
        return 6
    end
    -- 7: Projectiles (arrows, bullets)
    if classID == LE_ITEM_CLASS_PROJECTILE then
        return 7
    end
    -- 8: Miscellaneous (mounts, pets, etc)
    if classID == LE_ITEM_CLASS_MISCELLANEOUS then
        return 8
    end
    -- 9: Battle pets
    if classID == LE_ITEM_CLASS_BATTLEPET then
        return 9
    end
    -- 10: Quest items
    if classID == LE_ITEM_CLASS_QUESTITEM then
        return 10
    end
    -- 11: Weapons
    if classID == LE_ITEM_CLASS_WEAPON then
        return 11
    end
    -- 12: Armor
    if classID == LE_ITEM_CLASS_ARMOR then
        return 12
    end
    -- 13: Containers (bags)
    if classID == LE_ITEM_CLASS_CONTAINER then
        return 13
    end

    return 99  -- unknown
end

local function GetItemInfo(bagID, slotID)
    local itemID = GetContainerItemInfo(bagID, slotID)  -- 裸数字，不是table
    if not itemID or itemID == 0 then return end
    local itemLink = GetContainerItemLink(bagID, slotID)
    if not itemLink then return end
    local _, _, quality, itemLevel, _, _, _, _, _, _, _, classID, subclassID, _, equipLoc = _G.GetItemInfo(itemLink)
    return {
        bagID = bagID,
        slotID = slotID,
        itemID = itemID,
        quality = quality,
        itemLevel = itemLevel,
        classID = classID,
        subclassID = subclassID,
        equipLoc = equipLoc,
    }
end

local function CompareItems(a, b)
    local catA = GetItemCategory(a.classID, a.subclassID, a.equipLoc)
    local catB = GetItemCategory(b.classID, b.subclassID, b.equipLoc)

    if catA ~= catB then
        return catA < catB
    end

    if a.quality ~= b.quality then
        return a.quality > b.quality
    end

    if a.itemLevel ~= b.itemLevel then
        return a.itemLevel > b.itemLevel
    end

    if a.classID ~= b.classID then
        return a.classID < b.classID
    end

    if a.subclassID ~= b.subclassID then
        return a.subclassID < b.subclassID
    end

    if a.equipLoc ~= b.equipLoc then
        return a.equipLoc < b.equipLoc
    end

    return a.itemID < b.itemID
end

local function GetItems(containers)
    local items = {}
    for _, bagID in ipairs(containers) do
        local numSlots = GetContainerNumSlots(bagID)
        for slotID = 1, numSlots do
            local item = GetItemInfo(bagID, slotID)
            if item then
                tinsert(items, item)
            end
        end
    end
    return items
end

-- 辅助：实时扫描找到匹配物品的当前位置
local function FindItemSlot(containers, itemID, skipBag, skipSlot)
    for _, bagID in ipairs(containers) do
        local numSlots = GetContainerNumSlots(bagID)
        for slotID = 1, numSlots do
            if bagID ~= skipBag or slotID ~= skipSlot then
                local curID = GetContainerItemInfo(bagID, slotID)  -- 裸数字
                if curID and curID == itemID then
                    return bagID, slotID
                end
            end
        end
    end
end

local function DoSort(containers)
    local items = GetItems(containers)
    table.sort(items, CompareItems)

    local slotIndex = 1
    for _, bagID in ipairs(containers) do
        local numSlots = GetContainerNumSlots(bagID)
        for slotID = 1, numSlots do
            if slotIndex > #items then return end

            local curID = GetContainerItemInfo(bagID, slotID)  -- 裸数字
            local targetItem = items[slotIndex]

            -- 目标位已有正确类型的物品，跳过
            if not (curID and curID == targetItem.itemID) then
                -- 实时扫描找到目标物品的当前位置
                local srcBag, srcSlot = FindItemSlot(containers, targetItem.itemID, bagID, slotID)
                if srcBag then
                    PickupContainerItem(srcBag, srcSlot)
                    PickupContainerItem(bagID, slotID)
                end
            end
            slotIndex = slotIndex + 1
        end
    end
end

-- Public API via module (3.80.1: no _G. override)
function INVENTORY:SortBags()
    DoSort(BAG_CONTAINERS)
end

function INVENTORY:SortBankBags()
    DoSort(BANK_CONTAINERS)
end
