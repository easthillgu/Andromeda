local F, C = unpack(select(2, ...))
local INVENTORY = F:GetModule('Inventory')

-- Custom filter list (manual overrides for specific items)
local CustomFilterList = {
    [37863] = false, -- 酒吧传送器 (not consumable)
    [187532] = false, -- 魂焰凿石器
    [141333] = true, -- 宁神圣典
    [141446] = true, -- 宁神书卷
    [153646] = true, -- 静心圣典
    [153647] = true, -- 静心书卷
    [161053] = true, -- 水手咸饼干
}

local function isCustomFilter(item)
    if not C.DB.Inventory.ItemFilter then return end
    return CustomFilterList[item.id]
end

-- Bag context helpers
local function isItemInBag(item)
    return item.bagId >= 0 and item.bagId <= 4
end

local function isItemInBagReagent(item)
    return item.bagId == 5
end

local function isItemInBank(item)
    return item.bagId == -1 or (item.bagId > 5 and item.bagId < 13)
end

-- Category: Junk (grey quality, vendorable)
local function isItemJunk(item)
    if not C.DB.Inventory.ItemFilter then return end
    if not C.DB.Inventory.FilterJunk then return end
    return item.quality and item.quality == Enum.ItemQuality.Poor and item.hasPrice
        and not INVENTORY:IsPetTrashCurrency(item.id)
end

-- Category: Equipment Set (part of item set)
local function isItemEquipSet(item)
    if not C.DB.Inventory.ItemFilter then return end
    if not C.DB.Inventory.FilterEquipSet then return end
    return item.isItemSet
end

-- Category: Equipment (weapons, armor with item level)
local iLvlClassIDs = {
    [Enum.ItemClass.Armor] = true,
    [Enum.ItemClass.Weapon] = true,
}
function INVENTORY:IsItemHasLevel(item)
    return iLvlClassIDs[item.classID]
end

local function isItemEquipment(item)
    if not C.DB.Inventory.ItemFilter then return end
    if not C.DB.Inventory.FilterEquipment then return end
    -- 3.80.1: ItemQuality uses Standard/Good, not Common/Uncommon
    return item.link and item.quality and item.quality > Enum.ItemQuality.Standard
        and INVENTORY:IsItemHasLevel(item)
end

-- Category: Consumable
local consumableIDs = {
    [Enum.ItemClass.Consumable] = true,
    [Enum.ItemClass.ItemEnhancement] = true,
}
local function isItemConsumable(item)
    if not C.DB.Inventory.ItemFilter then return end
    if not C.DB.Inventory.FilterConsumable then return end
    if isCustomFilter(item) == false then return end
    return isCustomFilter(item) or consumableIDs[item.classID]
end

-- Category: Legendary
local function isItemLegendary(item)
    if not C.DB.Inventory.ItemFilter then return end
    if not C.DB.Inventory.FilterLegendary then return end
    return item.quality and item.quality == Enum.ItemQuality.Legendary
end

-- Category: Collection (mounts, pets, toys)
local isPetToy = { [174925] = true }
local collectionIDs = {
    [Enum.ItemMiscellaneousSubclass.Mount] = Enum.ItemClass.Miscellaneous,
    [Enum.ItemMiscellaneousSubclass.CompanionPet] = Enum.ItemClass.Miscellaneous,
}
local function isMountOrPet(item)
    return not isPetToy[item.id] and item.subClassID
        and collectionIDs[item.subClassID] == item.classID
end

local petTrashCurrencies = { [3300] = true, [3670] = true, [6150] = true,
    [11944] = true, [25402] = true, [36812] = true, [62072] = true, [67410] = true }
function INVENTORY:IsPetTrashCurrency(itemID)
    return petTrashCurrencies[itemID]
end

local function isItemCollection(item)
    if not C.DB.Inventory.ItemFilter then return end
    if not C.DB.Inventory.FilterCollection then return end
    return item.id and C_ToyBox and C_ToyBox.GetToyInfo(item.id) or isMountOrPet(item)
end

-- Category: Empty slot gathering
local emptyBags = { [0] = true, [11] = true }
local function isEmptySlot(item)
    if not C.DB.Inventory.CombineFreeSlots then return end
    return INVENTORY.initComplete and not item.texture
        and emptyBags[INVENTORY.BagsType[item.bagId]]
end

-- Category: Trade Goods
local function isTradeGoods(item)
    if not C.DB.Inventory.ItemFilter then return end
    if not C.DB.Inventory.FilterTradeGoods then return end
    if isCustomFilter(item) == false then return end
    return item.classID == Enum.ItemClass.Tradegoods
end

-- Category: Quest Items
local function isQuestItem(item)
    if not C.DB.Inventory.ItemFilter then return end
    if not C.DB.Inventory.FilterQuestItem then return end
    return item.questID or item.isQuestItem
end

-- Category: BoE
local function isItemBOE(item)
    if not C.DB.Inventory.ItemFilter then return end
    if not C.DB.Inventory.FilterBOE then return end
    return item.bindOn and item.bindOn == 'equip' and INVENTORY:IsItemHasLevel(item)
end

-- Build and return all filter functions
function INVENTORY:GetFilters()
    local filters = {}

    filters.onlyBags = function(item)
        return isItemInBag(item) and not isEmptySlot(item)
    end
    filters.bagEquipment = function(item)
        return isItemInBag(item) and isItemEquipment(item)
    end
    filters.bagEquipSet = function(item)
        return isItemInBag(item) and isItemEquipSet(item)
    end
    filters.bagConsumable = function(item)
        return isItemInBag(item) and isItemConsumable(item)
    end
    filters.bagsJunk = function(item)
        return isItemInBag(item) and isItemJunk(item)
    end
    filters.bagCollection = function(item)
        return isItemInBag(item) and isItemCollection(item)
    end
    filters.bagGoods = function(item)
        return isItemInBag(item) and isTradeGoods(item)
    end
    filters.bagQuest = function(item)
        return isItemInBag(item) and isQuestItem(item)
    end
    filters.bagBOE = function(item)
        return isItemInBag(item) and isItemBOE(item)
    end

    filters.onlyBank = function(item)
        return isItemInBank(item) and not isEmptySlot(item)
    end
    filters.bankLegendary = function(item)
        return isItemInBank(item) and isItemLegendary(item)
    end
    filters.bankEquipment = function(item)
        return isItemInBank(item) and isItemEquipment(item)
    end
    filters.bankEquipSet = function(item)
        return isItemInBank(item) and isItemEquipSet(item)
    end
    filters.bankConsumable = function(item)
        return isItemInBank(item) and isItemConsumable(item)
    end
    filters.bankCollection = function(item)
        return isItemInBank(item) and isItemCollection(item)
    end
    filters.bankGoods = function(item)
        return isItemInBank(item) and isTradeGoods(item)
    end
    filters.bankQuest = function(item)
        return isItemInBank(item) and isQuestItem(item)
    end
    filters.bankBOE = function(item)
        return isItemInBank(item) and isItemBOE(item)
    end

    filters.onlyReagent = function(item)
        return item.bagId == -3 and not isEmptySlot(item)
    end
    filters.onlyBagReagent = function(item)
        return isItemInBagReagent(item) and not isEmptySlot(item)
    end

    return filters
end
