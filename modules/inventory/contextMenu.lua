local F, C, L = unpack(select(2, ...))
local INVENTORY = F:GetModule('Inventory')

-- 右键菜单上下文数据
INVENTORY.contextMenuData = {}

-- 装备到槽位
local function GetEquipSlot(itemID)
    local _, _, _, _, _, _, _, _, equipLoc = GetItemInfo(itemID)
    if not equipLoc then return end
    
    local slotMap = {
        ["INVTYPE_HEAD"] = INVSLOT_HEAD,
        ["INVTYPE_NECK"] = INVSLOT_NECK,
        ["INVTYPE_SHOULDER"] = INVSLOT_SHOULDER,
        ["INVTYPE_CLOAK"] = INVSLOT_BACK,
        ["INVTYPE_CHEST"] = INVSLOT_CHEST,
        ["INVTYPE_WRIST"] = INVSLOT_WRIST,
        ["INVTYPE_HAND"] = INVSLOT_HAND,
        ["INVTYPE_WAIST"] = INVSLOT_WAIST,
        ["INVTYPE_LEGS"] = INVSLOT_LEGS,
        ["INVTYPE_FEET"] = INVSLOT_FEET,
        ["INVTYPE_FINGER"] = {INVSLOT_FINGER1, INVSLOT_FINGER2},
        ["INVTYPE_TRINKET"] = {INVSLOT_TRINKET1, INVSLOT_TRINKET2},
        ["INVTYPE_WEAPON"] = {INVSLOT_MAINHAND, INVSLOT_OFFHAND},
        ["INVTYPE_WEAPONMAINHAND"] = INVSLOT_MAINHAND,
        ["INVTYPE_WEAPONOFFHAND"] = INVSLOT_OFFHAND,
        ["INVTYPE_HOLDABLE"] = INVSLOT_OFFHAND,
        ["INVTYPE_RANGED"] = INVSLOT_RANGED,
        ["INVTYPE_RANGEDRIGHT"] = INVSLOT_RANGED,
        ["INVTYPE_RELIC"] = INVSLOT_RANGED,
        ["INVTYPE_2HWEAPON"] = INVSLOT_MAINHAND,
        ["INVTYPE_THROWN"] = INVSLOT_RANGED,
        ["INVTYPE_TABARD"] = INVSLOT_TABARD,
        ["INVTYPE_SHIELD"] = INVSLOT_OFFHAND,
    }
    
    return slotMap[equipLoc]
end

local function EquipItem(bagId, slotId, itemID)
    local slot = GetEquipSlot(itemID)
    if not slot then return end
    
    if type(slot) == 'table' then
        slot = slot[1]
    end
    
    C_Container.UseContainerItem(bagId, slotId)
end

-- 删除物品
local function DeleteItem(bagId, slotId)
    C_Container.PickupContainerItem(bagId, slotId)
    DeleteCursorItem()
end

-- 物品锁
local function ToggleItemLock(bagId, slotId)
    C_Container.SetContainerItemLock(bagId, slotId, not C_Container.IsContainerItemLocked(bagId, slotId))
end

-- 创建链接
local function CreateItemLink(bagId, slotId)
    local link = C_Container.GetContainerItemLink(bagId, slotId)
    if link then
        ChatEdit_InsertLink(link)
    end
end

-- 背包右键菜单
INVENTORY.contextMenuBag = {
    {
        text = L['Open All Bags'],
        func = function() OpenAllBags() end,
        notCheckable = true,
    },
    {
        text = L['Close All Bags'],
        func = function() CloseAllBags() end,
        notCheckable = true,
    },
    {
        text = '',
        isTitle = true,
        notCheckable = true,
    },
    {
        text = L['Sort Bags'],
        func = function() INVENTORY:SortBags() end,
        notCheckable = true,
    },
    {
        text = L['Sort Bank'],
        func = function() INVENTORY:SortBankBags() end,
        notCheckable = true,
    },
}

-- 物品右键菜单
function INVENTORY:CreateItemContextMenu(bagId, slotId)
    local info = C_Container.GetContainerItemInfo(bagId, slotId)
    if not info then return end
    
    local itemID = info.itemID
    local link = info.hyperlink
    local isLocked = info.isLocked
    local isQuestItem = info.isQuestItem
    
    local menu = {}
    
    -- 装备物品
    if IsEquippableItem(itemID) then
        tinsert(menu, {
            text = L['Equip Item'],
            func = function() EquipItem(bagId, slotId, itemID) end,
            notCheckable = true,
        })
    end
    
    -- 使用物品
    if info.hasNoValue ~= true and (C_Container.IsContainerItemAnAddOnItem and not C_Container.IsContainerItemAnAddOnItem(bagId, slotId)) then
        tinsert(menu, {
            text = L['Use Item'],
            func = function() C_Container.UseContainerItem(bagId, slotId) end,
            notCheckable = true,
        })
    end
    
    -- 分隔线
    if #menu > 0 then
        tinsert(menu, { text = '', isTitle = true, notCheckable = true, })
    end
    
    -- 创建聊天链接
    tinsert(menu, {
        text = L['Create Link'],
        func = function() CreateItemLink(bagId, slotId) end,
        notCheckable = true,
    })
    
    -- 物品锁
    tinsert(menu, {
        text = isLocked and L['Unlock Item'] or L['Lock Item'],
        func = function() ToggleItemLock(bagId, slotId) end,
        notCheckable = true,
    })
    
    -- 自定义垃圾
    if not isQuestItem and itemID then
        local isCustomJunk = _G.ANDROMEDA_ADB['CustomJunkList'][itemID]
        tinsert(menu, {
            text = isCustomJunk and L['Remove from Junk List'] or L['Add to Junk List'],
            func = function()
                if _G.ANDROMEDA_ADB['CustomJunkList'][itemID] then
                    _G.ANDROMEDA_ADB['CustomJunkList'][itemID] = nil
                else
                    _G.ANDROMEDA_ADB['CustomJunkList'][itemID] = true
                end
                INVENTORY:UpdateAllBags()
            end,
            notCheckable = true,
        })
    end
    
    -- 自定义分组
    if itemID then
        local subMenu = {
            {
                text = _G.NONE,
                func = function()
                    C.DB['Inventory']['CustomItemsList'][itemID] = nil
                    INVENTORY:UpdateAllBags()
                end,
                notCheckable = true,
            }
        }
        for i = 1, 5 do
            tinsert(subMenu, {
                text = INVENTORY.GetCustomGroupTitle(i),
                func = function()
                    C.DB['Inventory']['CustomItemsList'][itemID] = i
                    INVENTORY:UpdateAllBags()
                end,
                notCheckable = true,
                checked = function() return C.DB['Inventory']['CustomItemsList'][itemID] == i end,
            })
        end
        
        tinsert(menu, {
            text = L['Move to Group'],
            notCheckable = true,
            hasArrow = true,
            menuList = subMenu,
        })
    end
    
    -- 分隔线
    tinsert(menu, { text = '', isTitle = true, notCheckable = true, })
    
    -- 删除物品
    if not isLocked and not isQuestItem then
        tinsert(menu, {
            text = L['Delete Item'],
            func = function() DeleteItem(bagId, slotId) end,
            notCheckable = true,
            colorCode = '|cffff0000',
        })
    end
    
    return menu
end

-- 显示右键菜单
function INVENTORY:ShowContextMenu(button, bagId, slotId)
    if button ~= 'RightButton' then return end
    
    local menu
    if bagId and slotId then
        menu = self:CreateItemContextMenu(bagId, slotId)
    elseif self.Bags and self.Bags:IsShown() then
        menu = self.contextMenuBag
    end
    
    if menu and #menu > 0 then
        EasyMenu(menu, F.EasyMenu, 'cursor', 0, 0, 'MENU', 1)
    end
end
