local F, C, L = unpack(select(2, ...))
local INVENTORY = F:GetModule('Inventory')

-- 3.80.1: C_Container API with global fallback (returns table {itemID,stackCount,hyperlink,...})
local GetContainerNumSlots = C_Container.GetContainerNumSlots or _G.GetContainerNumSlots
local GetContainerItemInfo = C_Container.GetContainerItemInfo or _G.GetContainerItemInfo
local GetContainerItemLink = C_Container.GetContainerItemLink or _G.GetContainerItemLink
local PickupContainerItem = C_Container.PickupContainerItem or _G.PickupContainerItem
local IS_TABLE = C_Container ~= nil

-- 统一取 itemID（兼容 table 和裸数字）
local function GetSlotItemID(bagID, slotID)
    local r = GetContainerItemInfo(bagID, slotID)
    if not r then return end
    return IS_TABLE and r.itemID or r
end

-- 统一取 itemLink
local function GetSlotItemLink(bagID, slotID)
    if IS_TABLE then
        local r = GetContainerItemInfo(bagID, slotID)
        return r and r.hyperlink
    else
        return GetContainerItemLink(bagID, slotID)
    end
end

-- 统一取 stackCount
local function GetSlotCount(bagID, slotID)
    if IS_TABLE then
        local r = GetContainerItemInfo(bagID, slotID)
        return r and r.stackCount or 0
    else
        return select(2, GetContainerItemInfo(bagID, slotID)) or 0
    end
end

local BAG_CONTAINERS = {0, 1, 2, 3, 4}
local BANK_CONTAINERS = {-1, 5, 6, 7, 8, 9, 10, 11}

-- 排序优先级：大类 (cat) → 品质↓ → 装等↓ → classID → subclassID → equipLoc → itemID
local function GetItemCategory(classID, subclassID, equipLoc)
    if classID == Enum.ItemClass.Questitem then return 0
    elseif classID == Enum.ItemClass.Key then return 1
    elseif classID == Enum.ItemClass.Tradegoods then return 2
    elseif classID == Enum.ItemClass.Recipe then return 3
    elseif classID == Enum.ItemClass.Consumable then return 4
    elseif classID == Enum.ItemClass.Gem then return 5
    elseif classID == Enum.ItemClass.Glyph then return 6
    elseif classID == Enum.ItemClass.Projectile then return 7
    elseif classID == Enum.ItemClass.Miscellaneous then return 8
    elseif classID == Enum.ItemClass.Battlepet then return 9
    elseif classID == Enum.ItemClass.Weapon then return 10
    elseif classID == Enum.ItemClass.Armor then return 11
    elseif classID == Enum.ItemClass.Container then return 12
    end
    return 99
end

-- 生成排序 key（用于 table.sort 比较）
local function MakeSortKey(itemID, quality, itemLevel, classID, subclassID, equipLoc)
    local cat = GetItemCategory(classID, subclassID, equipLoc)
    return cat * 100000000
        + (quality and (4 - quality) or 3) * 10000000   -- 品质降序
        + (itemLevel and (999 - itemLevel) or 0) * 10000 -- 装等降序
        + (classID or 99) * 100
        + (subclassID or 0)
end

-- 比较两个 sortKey
local function CompareSortKeys(a, b)
    if a.sortKey ~= b.sortKey then return a.sortKey < b.sortKey end
    return (a.itemID or 0) < (b.itemID or 0)
end

-- 简单实用的排序算法
local function DoSort(containers)
    -- Phase 1: 收集所有物品信息
    local items = {}
    for _, bagID in ipairs(containers) do
        local numSlots = GetContainerNumSlots(bagID)
        for slotID = 1, numSlots do
            local itemID = GetSlotItemID(bagID, slotID)
            if itemID and itemID ~= 0 then
                local link = GetSlotItemLink(bagID, slotID)
                local quality, itemLevel, classID, subclassID, equipLoc
                if link then
                    _, _, quality, itemLevel, _, _, _, _, _, _, _, classID, subclassID, _, equipLoc = _G.GetItemInfo(link)
                end
                tinsert(items, {
                    bagID = bagID,
                    slotID = slotID,
                    itemID = itemID,
                    quality = quality or 0,
                    itemLevel = itemLevel or 0,
                    classID = classID or 0,
                    subclassID = subclassID or 0,
                    equipLoc = equipLoc or 0,
                    sortKey = MakeSortKey(itemID, quality, itemLevel, classID, subclassID, equipLoc),
                    count = GetSlotCount(bagID, slotID) or 1
                })
            end
        end
    end

    -- Phase 2: 排序物品
    table.sort(items, CompareSortKeys)

    -- Phase 3: 分配目标位置（按bags顺序排列）
    local slots = {}
    for _, bagID in ipairs(containers) do
        local numSlots = GetContainerNumSlots(bagID)
        for slotID = 1, numSlots do
            tinsert(slots, {bagID = bagID, slotID = slotID})
        end
    end

    -- Phase 4: 移动物品到正确位置
    local itemIndex = 1
    for _, slot in ipairs(slots) do
        if itemIndex > #items then break end
        
        local targetItem = items[itemIndex]
        if targetItem.bagID ~= slot.bagID or targetItem.slotID ~= slot.slotID then
            -- 检查目标位置是否是空的
            local currentItemID = GetSlotItemID(slot.bagID, slot.slotID)
            if not currentItemID or currentItemID == 0 then
                -- 目标位置是空的，直接移动
                if not InCombatLockdown() then
                    ClearCursor()
                    PickupContainerItem(targetItem.bagID, targetItem.slotID)
                    PickupContainerItem(slot.bagID, slot.slotID)
                end
                -- 更新items表中更新位置
                targetItem.bagID = slot.bagID
                targetItem.slotID = slot.slotID
            else
                -- 目标位置有物品，交换位置
                local swapItem = nil
                -- 找到目标位置物品在items表中的索引
                for j, item in ipairs(items) do
                    if item.bagID == slot.bagID and item.slotID == slot.slotID then
                        swapItem = item
                        break
                    end
                end
                
                if swapItem then
                    if not InCombatLockdown() then
                        ClearCursor()
                        PickupContainerItem(targetItem.bagID, targetItem.slotID)
                        PickupContainerItem(slot.bagID, slot.slotID)
                    end
                    -- 交换位置信息
                    targetItem.bagID, swapItem.bagID = swapItem.bagID, targetItem.bagID
                    targetItem.slotID, swapItem.slotID = swapItem.slotID, targetItem.slotID
                end
            end
        end
        itemIndex = itemIndex + 1
    end
end

-- Public API
function INVENTORY:SortBags()
    DoSort(BAG_CONTAINERS)
end

function INVENTORY:SortBankBags()
    DoSort(BANK_CONTAINERS)
end
