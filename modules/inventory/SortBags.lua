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
    if classID == LE_ITEM_CLASS_QUESTITEM then return 0
    elseif classID == LE_ITEM_CLASS_KEY then return 1
    elseif classID == LE_ITEM_CLASS_TRADEGOODS then return 2
    elseif classID == LE_ITEM_CLASS_RECIPE then return 3
    elseif classID == LE_ITEM_CLASS_CONSUMABLE then return 4
    elseif classID == LE_ITEM_CLASS_GEM then return 5
    elseif classID == LE_ITEM_CLASS_GLYPH then return 6
    elseif classID == LE_ITEM_CLASS_PROJECTILE then return 7
    elseif classID == LE_ITEM_CLASS_MISCELLANEOUS then return 8
    elseif classID == LE_ITEM_CLASS_BATTLEPET then return 9
    elseif classID == LE_ITEM_CLASS_WEAPON then return 10
    elseif classID == LE_ITEM_CLASS_ARMOR then return 11
    elseif classID == LE_ITEM_CLASS_CONTAINER then return 12
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
    if a.key ~= b.key then return a.key < b.key end
    return (a.itemID or 0) < (b.itemID or 0)
end

-- ========== NDui 风格的 model+target+swap 算法 ==========

local function DoSort(containers)
    -- Phase 1: 构建 model（所有格子快照）
    local model = {}  -- {{bagID, slotID, key(nil=空), count}}
    for _, bagID in ipairs(containers) do
        local numSlots = GetContainerNumSlots(bagID)
        for slotID = 1, numSlots do
            local slot = {bagID = bagID, slotID = slotID, key = nil, count = 0}
            local itemID = GetSlotItemID(bagID, slotID)
            if itemID and itemID ~= 0 then
                local link = GetSlotItemLink(bagID, slotID)
                local quality, itemLevel, classID, subclassID, equipLoc
                if link then
                    _, _, quality, itemLevel, _, _, _, _, _, _, _, classID, subclassID, _, equipLoc = _G.GetItemInfo(link)
                end
                -- 复合 key: itemID + 品质 + 装等 + 类别（避免同名物品冲突）
                slot.key = ('%d:%d:%d:%d:%d:%d'):format(
                    itemID, quality or 0, itemLevel or 0,
                    classID or 0, subclassID or 0, equipLoc or 0
                )
                slot.count = GetSlotCount(bagID, slotID) or 1
            end
            tinsert(model, slot)
        end
    end

    -- Phase 2: 统计每种物品的总数量 + 排序
    local itemData = {}  -- key -> {total, sortKey, itemID}
    for _, slot in ipairs(model) do
        if slot.key then
            local d = itemData[slot.key]
            if not d then
                -- 从 key 中提取 itemID 用于最终比较
                local itemID = tonumber((slot.key:match('^(%d+):')))
                local quality, itemLevel, classID, subclassID, equipLoc = slot.key:match('^%d+:(%-?%d+):(%-?%d+):(%-?%d+):(%-?%d+):(%-?%d+)$')
                local sk = MakeSortKey(itemID, tonumber(quality), tonumber(itemLevel), tonumber(classID), tonumber(subclassID), tonumber(equipLoc))
                d = {total = 0, sortKey = sk, itemID = itemID}
                itemData[slot.key] = d
            end
            d.total = d.total + slot.count
        end
    end

    -- 排序物品类型列表
    local sortedTypes = {}
    for key, data in pairs(itemData) do
        tinsert(sortedTypes, {key = key, sortKey = data.sortKey, total = data.total, itemID = data.itemID})
    end
    table.sort(sortedTypes, CompareSortKeys)

    -- Phase 3: 按排序顺序分配 target 到格子
    -- 记录每种物品还剩余多少需要分配
    local remaining = {}
    for _, t in ipairs(sortedTypes) do
        remaining[t.key] = t.total
    end

    for _, slot in ipairs(model) do
        for _, t in ipairs(sortedTypes) do
            if remaining[t.key] > 0 then
                slot.targetKey = t.key
                slot.targetCount = remaining[t.key]  -- 分配全部剩余（非堆叠简化）
                remaining[t.key] = 0
                break
            end
        end
    end

    -- Phase 4: 循环移动，直到所有格子匹配 target
    local function MoveItem(srcSlot, dstSlot)
        if InCombatLockdown() then return end
        ClearCursor()
        PickupContainerItem(srcSlot.bagID, srcSlot.slotID)
        PickupContainerItem(dstSlot.bagID, dstSlot.slotID)

        -- 更新 model（与 NDui 一样，swap 后同步模型）
        if srcSlot.key == dstSlot.key then
            -- 同种物品合并
            local move = dstSlot.count + srcSlot.count
            srcSlot.count = 0
            srcSlot.key = nil
            dstSlot.count = move
        else
            -- 交换
            srcSlot.key, dstSlot.key = dstSlot.key, srcSlot.key
            srcSlot.count, dstSlot.count = dstSlot.count, srcSlot.count
        end
    end

    local moved
    repeat
        moved = false
        for _, dst in ipairs(model) do
            if dst.targetKey and (dst.key ~= dst.targetKey or not dst.key) then
                -- 找到有 targetKey 物品的源格子
                for _, src in ipairs(model) do
                    if src ~= dst and src.key == dst.targetKey and src.count > 0
                        and not (src.targetKey and src.key == src.targetKey and src.count <= src.targetCount)
                    then
                        MoveItem(src, dst)
                        moved = true
                        break
                    end
                end
            end
        end
    until not moved
end

-- Public API
function INVENTORY:SortBags()
    DoSort(BAG_CONTAINERS)
end

function INVENTORY:SortBankBags()
    DoSort(BANK_CONTAINERS)
end
