local F, C, L = unpack(select(2, ...))

-- Fast Loot Module
-- 自动快速拾取战利品功能

local GetContainerNumFreeSlots = C_Container and C_Container.GetContainerNumFreeSlots or GetContainerNumFreeSlots

local internal = {
    isLooting = false,
    isHidden = false,
    isItemLocked = false
}

local LootF

local function ProcessLootItem(itemLink, itemQuantity)
    local itemFamily = GetItemFamily(itemLink)
    for i = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
        local free, bagFamily = GetContainerNumFreeSlots(i)
        if (not bagFamily or bagFamily == 0) or (itemFamily and bit.band(itemFamily, bagFamily) > 0) then
            if free > 0 then
                return true
            end
        end
    end
    local inventoryItemCount = GetItemCount(itemLink)
    if inventoryItemCount > 0 then
        local itemStackSize = select(8, GetItemInfo(itemLink))
        if itemStackSize and itemStackSize > 1 then
            local remainingSpace = (itemStackSize - inventoryItemCount) % itemStackSize
            if remainingSpace >= itemQuantity then
                return true
            end
        end
    end
    return false
end

local function LootItems(numItems)
    local lootmethodID = GetLootMethod()
    local lootThreshold = (lootmethodID == 0) and GetLootThreshold() or 10

    for i = numItems, 1, -1 do
        local itemLink = GetLootSlotLink(i)
        local slotType = GetLootSlotType(i)
        local quantity, _, quality, locked, isQuestItem = select(3, GetLootSlotInfo(i))

        if locked or (quality and quality >= lootThreshold) then
            internal.isItemLocked = true
        else
            if slotType ~= Enum.LootSlotType.Item or isQuestItem or ProcessLootItem(itemLink, quantity) then
                LootFrame.selectedQuality = quality
                LootFrame.selectedSlot = LootFrame.selectedSlot or 1
                LootSlot(i)

                if MasterLooterFrame and MasterLooterFrame:IsShown() then
                    MasterLooterFrame:Hide()
                else
                    numItems = numItems - 1
                end
            end
        end
    end

    if numItems > 0 then
        LootF:ShowLootFrame(true)
    end

    if IsFishingLoot() then
        PlaySound(SOUNDKIT.FISHING_REEL_IN, 'master')
    end
end

local function ShowLootFrame(show)
    if show then
        internal.isHidden = false
        LootFrame:SetFrameStrata('HIGH')
        LootFrame:SetParent(UIParent)

        if GetCVarBool('lootUnderMouse') then
            local x, y = GetCursorPosition()
            x = x / LootFrame:GetEffectiveScale()
            y = y / LootFrame:GetEffectiveScale()
            LootFrame:ClearAllPoints()
            LootFrame:SetPoint('TOPLEFT', UIParent, 'BOTTOMLEFT', x - 40, y + 20)
            LootFrame:GetCenter()
            LootFrame:Raise()
        else
            LootFrame:ClearAllPoints()
            LootFrame:SetPoint('TOPLEFT', UIParent, 'TOPLEFT', 20, -125)
        end
    else
        LootFrame:SetParent(LootF)
        internal.isHidden = true
    end
end

local function OnEvent(self, event, autoLoot, arg2)
    if event == 'LOOT_READY' or event == 'LOOT_OPENED' then
        if not internal.isLooting then
            internal.isLooting = true
            local numItems = GetNumLootItems()
            if numItems == 0 then
                return
            end

            if autoLoot or (autoLoot == nil and GetCVarBool('autoLootDefault') ~= IsModifiedClick('AUTOLOOTTOGGLE')) then
                LootItems(numItems)
            else
                ShowLootFrame(true)
            end
        end
    elseif event == 'LOOT_CLOSED' then
        internal.isLooting = false
        internal.isHidden = false
        internal.isItemLocked = false
        ShowLootFrame(false)
    elseif event == 'UI_ERROR_MESSAGE' then
        if tContains(({ERR_INV_FULL, ERR_ITEM_MAX_COUNT}), arg2) then
            if internal.isLooting and internal.isHidden then
                ShowLootFrame(true)
            end
        end
    end
end

local function ToggleFastLoot(enable)
    if enable then
        SetCVar('autoLootRate', '0')
        LootF:RegisterEvent('LOOT_READY')
        LootF:RegisterEvent('LOOT_OPENED')
        LootF:RegisterEvent('LOOT_CLOSED')
        LootF:RegisterEvent('UI_ERROR_MESSAGE')
    else
        SetCVar('autoLootRate', '150')
        LootF:UnregisterAllEvents()
        LootFrame:SetFrameStrata('HIGH')
        LootFrame:SetParent(UIParent)
        internal.isLooting = false
        internal.isHidden = false
        internal.isItemLocked = false
    end
end

function F:InitFastLoot()
    -- 检查设置是否启用快速拾取
    if not C.DB.Misc or not C.DB.Misc.FastLoot then
        return
    end

    -- 检查是否安装了 ElvUI 或 NDui，避免冲突
    if _G.ElvUI or _G.NDui then
        return
    end

    -- 创建拾取框架
    LootF = CreateFrame('Frame')
    LootF:SetToplevel(true)
    LootF:Hide()
    LootF:SetScript('OnEvent', OnEvent)

    -- 启用快速拾取
    ToggleFastLoot(true)
end

-- 提供一个函数供外部控制开关
F.ToggleFastLoot = ToggleFastLoot
