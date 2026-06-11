local F, C, L = unpack(select(2, ...))
local INVENTORY = F:GetModule('Inventory')

local GetContainerNumSlots = C_Container.GetContainerNumSlots or _G.GetContainerNumSlots
local GetContainerItemInfo = C_Container.GetContainerItemInfo or _G.GetContainerItemInfo
local GetContainerItemLink = C_Container.GetContainerItemLink or _G.GetContainerItemLink
local PickupContainerItem = C_Container.PickupContainerItem or _G.PickupContainerItem
local IS_TABLE = C_Container ~= nil

local function GetSlotItemID(bagID, slotID)
    local r = GetContainerItemInfo(bagID, slotID)
    if not r then return end
    return IS_TABLE and r.itemID or r
end

local function GetSlotItemLink(bagID, slotID)
    if IS_TABLE then
        local r = GetContainerItemInfo(bagID, slotID)
        return r and r.hyperlink
    else
        return GetContainerItemLink(bagID, slotID)
    end
end

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

local function GetItemCategory(classID)
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

local function MakeSortKey(itemID, quality, itemLevel, classID, subclassID, equipLoc)
    local cat = GetItemCategory(classID, subclassID, equipLoc)
    return cat * 100000000
        + (quality and (4 - quality) or 3) * 10000000
        + (itemLevel and (999 - itemLevel) or 0) * 10000
        + (classID or 99) * 100
        + (subclassID or 0)
end

local function CompareSortKeys(a, b)
    if a.sortKey ~= b.sortKey then return a.sortKey < b.sortKey end
    return (a.itemID or 0) < (b.itemID or 0)
end

-- 单次移动：拿起→放下
local function MoveOne(srcBag, srcSlot, dstBag, dstSlot)
    ClearCursor()
    PickupContainerItem(srcBag, srcSlot)
    PickupContainerItem(dstBag, dstSlot)
end

-- 异步排序（模拟 Bagnon 的 delay 方式）
local sortTimer = nil
local sortState = nil

local function DoSort(containers)
    if InCombatLockdown() then return end

    -- 取消正在进行的排序
    if sortTimer then
        C_Timer.Cancel(sortTimer)
        sortTimer = nil
        sortState = nil
    end

    -- Phase 1: 收集
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
                    bagID = bagID, slotID = slotID, itemID = itemID,
                    quality = quality or 0, itemLevel = itemLevel or 0,
                    classID = classID or 0, subclassID = subclassID or 0,
                    equipLoc = equipLoc or 0,
                    sortKey = MakeSortKey(itemID, quality, itemLevel, classID, subclassID, equipLoc),
                })
            end
        end
    end

    if #items == 0 then return end

    -- Phase 2: 排序
    table.sort(items, CompareSortKeys)

    -- Phase 3: 槽位列表
    local slots = {}
    for _, bagID in ipairs(containers) do
        local numSlots = GetContainerNumSlots(bagID)
        for slotID = 1, numSlots do
            tinsert(slots, {bagID = bagID, slotID = slotID})
        end
    end

    -- 按当前位置建索引
    local bySlot = {}
    for i, item in ipairs(items) do
        bySlot[item.bagID * 1000 + item.slotID] = i
    end

    sortState = { items = items, slots = slots, bySlot = bySlot, index = 1, containers = containers }
    sortTimer = C_Timer.After(0.05, function() INVENTORY:SortBags_Step() end)
end

function INVENTORY:SortBags_Step()
    if InCombatLockdown() or not sortState then
        sortTimer = nil
        sortState = nil
        return
    end

    local items = sortState.items
    local slots = sortState.slots
    local bySlot = sortState.bySlot
    local N = #items

    -- 找下一个需要移动的物品
    while sortState.index <= N do
        local i = sortState.index
        local item = items[i]
        local target = slots[i]
        if item.bagID ~= target.bagID or item.slotID ~= target.slotID then
            -- 目标槽有物品吗？
            local occupantID = GetSlotItemID(target.bagID, target.slotID)
            if occupantID and occupantID ~= 0 then
                -- 三步交换
                local srcBag, srcSlot = item.bagID, item.slotID
                ClearCursor()
                PickupContainerItem(srcBag, srcSlot)
                PickupContainerItem(target.bagID, target.slotID)
                PickupContainerItem(srcBag, srcSlot)
                -- 更新位置追踪
                local j = bySlot[target.bagID * 1000 + target.slotID]
                if j then
                    items[j].bagID, items[j].slotID = srcBag, srcSlot
                    bySlot[srcBag * 1000 + srcSlot] = j
                end
                item.bagID, item.slotID = target.bagID, target.slotID
                bySlot[target.bagID * 1000 + target.slotID] = i
            else
                -- 目标为空，直接移动
                MoveOne(item.bagID, item.slotID, target.bagID, target.slotID)
                bySlot[item.bagID * 1000 + item.slotID] = nil
                item.bagID, item.slotID = target.bagID, target.slotID
                bySlot[target.bagID * 1000 + target.slotID] = i
            end

            sortState.index = i + 1
            sortTimer = C_Timer.After(0.05, function() INVENTORY:SortBags_Step() end)
            return
        end
        sortState.index = sortState.index + 1
    end

    -- Phase 5: 压缩填洞（单步执行，一次一个）
    if sortState.compacting == nil then
        sortState.compacting = true
        sortState.gap = 1
        sortState.fill = N + 1
    end

    while sortState.gap <= N and sortState.fill <= #slots do
        local gapSlot = slots[sortState.gap]
        if GetSlotItemID(gapSlot.bagID, gapSlot.slotID) then
            sortState.gap = sortState.gap + 1
        else
            while sortState.fill <= #slots do
                local fillSlot = slots[sortState.fill]
                if GetSlotItemID(fillSlot.bagID, fillSlot.slotID) then
                    MoveOne(fillSlot.bagID, fillSlot.slotID, gapSlot.bagID, gapSlot.slotID)
                    sortState.gap = sortState.gap + 1
                    sortState.fill = sortState.fill + 1
                    sortTimer = C_Timer.After(0.05, function() INVENTORY:SortBags_Step() end)
                    return
                end
                sortState.fill = sortState.fill + 1
            end
            break
        end
    end

    -- 完成
    sortTimer = nil
    sortState = nil
end

function INVENTORY:SortBags()
    DoSort(BAG_CONTAINERS)
end

function INVENTORY:SortBankBags()
    DoSort(BANK_CONTAINERS)
end