--[[
    compat.lua — Andromeda 3.80.1 Compatibility Layer
    为时光服 3.80.1 提供正式服 API 的 shim/stub
    所有补丁均为条件定义：仅在目标 API 不存在时才创建
]]

-- nop (许多文件引用)
if not _G.nop then _G.nop = function() end end

---------------------------------------------------------------------------
-- Enum.* 替换为数字常量
---------------------------------------------------------------------------
if not _G.Enum then
    _G.Enum = {}
end

-- ItemQuality (3.80.1 uses Standard/Good, not Common/Uncommon)
_G.Enum.ItemQuality = _G.Enum.ItemQuality or {
    Poor = 0,
    Common = 1,
    Uncommon = 2,
    Rare = 3,
    Epic = 4,
    Legendary = 5,
    Artifact = 6,
    Heirloom = 7,
}
_G.Enum.ItemQuality.Common = _G.Enum.ItemQuality.Common or _G.Enum.ItemQuality.Standard or 1
_G.Enum.ItemQuality.Uncommon = _G.Enum.ItemQuality.Uncommon or _G.Enum.ItemQuality.Good or 2

-- ItemClass
_G.Enum.ItemClass = _G.Enum.ItemClass or {
    Consumable = 0,
    Container = 1,
    Weapon = 2,
    Gem = 3,
    Armor = 4,
    Reagent = 5,
    Projectile = 6,
    Tradegoods = 7,
    ItemEnhancement = 8,
    Recipe = 9,
    CurrencyToken = 10,
    Quiver = 11,
    Questitem = 12,
    Key = 13,
    Miscellaneous = 15,
    Glyph = 16,
    Battlepet = 17,
    WoWToken = 18,
}

-- ItemGemSubclass
_G.Enum.ItemGemSubclass = _G.Enum.ItemGemSubclass or {
    Intellect = 0,
    Agility = 1,
    Strength = 2,
    Stamina = 3,
    Spirit = 4,
    Criticalstrike = 5,
    Mastery = 6,
    Haste = 7,
    Versatility = 8,
    Multistrike = 11,
    Artifactrelic = 12,
}

-- ItemMiscellaneousSubclass
_G.Enum.ItemMiscellaneousSubclass = _G.Enum.ItemMiscellaneousSubclass or {
    Junk = 0,
    Reagent = 1,
    CompanionPet = 2,
    Holiday = 3,
    Mount = 5,
    MountEquipment = 11,
}

-- PowerType
_G.Enum.PowerType = _G.Enum.PowerType or {
    Mana = 0,
    Rage = 1,
    Focus = 2,
    Energy = 3,
    ComboPoints = 4,
    Runes = 5,
    RunicPower = 6,
    SoulShards = 7,
    LunarPower = 8,
    HolyPower = 9,
    Alternate = 10,
    Maelstrom = 11,
    Chi = 12,
    Insanity = 13,
    ArcaneCharges = 16,
    Fury = 17,
    Pain = 18,
    Essence = 19,
}

-- TooltipDataType
_G.Enum.TooltipDataType = _G.Enum.TooltipDataType or {
    Item = 1,
    Spell = 2,
    Unit = 3,
    Corpse = 4,
    Object = 5,
    Currency = 6,
    BattlePet = 7,
    UnitAura = 8,
    AzeriteEssence = 9,
    CompanionPet = 10,
    Mount = 11,
    PetAction = 12,
    Achievement = 13,
    ItemInteraction = 15,
    BattlePetAbility = 17,
}

-- RafLinkType
_G.Enum.RafLinkType = _G.Enum.RafLinkType or {
    None = 0,
    Recruit = 1,
    Friend = 2,
    Both = 3,
}

---------------------------------------------------------------------------
-- CreateFromHex (正式服 10.1+)
---------------------------------------------------------------------------
if not _G.CreateFromHex then
    _G.CreateFromHex = function(hex)
        local r, g, b = 1, 1, 1
        if hex then
            local h = hex:gsub("#", "")
            if #h == 6 then
                r = tonumber(h:sub(1, 2), 16) / 255
                g = tonumber(h:sub(3, 4), 16) / 255
                b = tonumber(h:sub(5, 6), 16) / 255
            end
        end
        return _G.CreateColor(r, g, b)
    end
end

---------------------------------------------------------------------------
-- BackdropTemplateMixin (正式服 backdrop 系统, 仅定义 mixin 不包装全局函数)
---------------------------------------------------------------------------
if not _G.BackdropTemplateMixin then
    _G.BackdropTemplateMixin = {}
    function _G.BackdropTemplateMixin:OnBackdropLoaded() end
    function _G.BackdropTemplateMixin:OnBackdropSizeChanged() end
end

---------------------------------------------------------------------------
-- C_NamePlate stub (3.80.1 可能不存在部分方法)
---------------------------------------------------------------------------
if _G.C_NamePlate then
    if not _G.C_NamePlate.GetNamePlateEnemyClickThrough then
        _G.C_NamePlate.GetNamePlateEnemyClickThrough = function() return false end
    end
    if not _G.C_NamePlate.GetNamePlateFriendlyClickThrough then
        _G.C_NamePlate.GetNamePlateFriendlyClickThrough = function() return false end
    end
    if not _G.C_NamePlate.GetNamePlateSelfClickThrough then
        _G.C_NamePlate.GetNamePlateSelfClickThrough = function() return false end
    end
    if not _G.C_NamePlate.SetNamePlateEnemySize then
        _G.C_NamePlate.SetNamePlateEnemySize = function() end
    end
    if not _G.C_NamePlate.SetNamePlateFriendlySize then
        _G.C_NamePlate.SetNamePlateFriendlySize = function() end
    end
    if not _G.C_NamePlate.SetNamePlateEnemyClickThrough then
        _G.C_NamePlate.SetNamePlateEnemyClickThrough = function() end
    end
    if not _G.C_NamePlate.SetNamePlateFriendlyClickThrough then
        _G.C_NamePlate.SetNamePlateFriendlyClickThrough = function() end
    end
    if not _G.C_NamePlate.GetNamePlateForUnit then
        _G.C_NamePlate.GetNamePlateForUnit = function() return nil end
    end
    if not _G.C_NamePlate.GetNamePlates then
        _G.C_NamePlate.GetNamePlates = function() return {} end
    end
else
    _G.C_NamePlate = {
        GetNamePlateEnemyClickThrough = function() return false end,
        GetNamePlateFriendlyClickThrough = function() return false end,
        GetNamePlateSelfClickThrough = function() return false end,
        SetNamePlateEnemyClickThrough = function() end,
        SetNamePlateFriendlyClickThrough = function() end,
        SetNamePlateEnemySize = function() end,
        SetNamePlateFriendlySize = function() end,
        GetNamePlateForUnit = function() return nil end,
        GetNamePlates = function() return {} end,
    }
end

---------------------------------------------------------------------------
-- Retail-only globals (3.80.1 中不存在的全局函数)
---------------------------------------------------------------------------
if not _G.UnitNameplateShowsWidgetsOnly then
    _G.UnitNameplateShowsWidgetsOnly = function(unit) return false end
end
if not _G.IsCosmeticItem then
    _G.IsCosmeticItem = function(link) return false end
end

---------------------------------------------------------------------------
-- EasyMenu (3.80.1 中不存在，从 NDui 移植)
---------------------------------------------------------------------------
if not _G.EasyMenu then
    local function EasyMenu_Initialize(frame, level, menuList)
        for index = 1, #menuList do
            local value = menuList[index]
            if value.text then
                value.index = index
                UIDropDownMenu_AddButton(value, level)
            end
        end
    end
    _G.EasyMenu = function(menuList, menuFrame, anchor, x, y, displayMode, autoHideDelay)
        if displayMode == 'MENU' then
            menuFrame.displayMode = displayMode
        end
        UIDropDownMenu_Initialize(menuFrame, EasyMenu_Initialize, displayMode, nil, menuList)
        ToggleDropDownMenu(1, nil, menuFrame, anchor, x, y, menuList, nil, autoHideDelay)
    end
end

---------------------------------------------------------------------------
-- C_TooltipInfo stub
---------------------------------------------------------------------------
if not _G.C_TooltipInfo then
    _G.C_TooltipInfo = {}
end
if not _G.C_TooltipInfo.GetHyperlink then
    -- 3.80.1: C_TooltipInfo.GetHyperlink not available; stub returns nil.
    -- All callers (functions.lua x2, alreadyknown.lua x1) nil-guard this.
    _G.C_TooltipInfo.GetHyperlink = function()
        return nil
    end
end
if not _G.C_TooltipInfo.GetInventoryItem then
    _G.C_TooltipInfo.GetInventoryItem = function() return nil end
end
if not _G.C_TooltipInfo.GetBagItem then
    _G.C_TooltipInfo.GetBagItem = function() return nil end
end
if not _G.C_TooltipInfo.GetUnit then
    _G.C_TooltipInfo.GetUnit = function(unit) return nil end
end
if not _G.TooltipDataProcessor then
    _G.TooltipDataProcessor = {
        AddTooltipPostCall = function(dataType, func) end,
    }
end

---------------------------------------------------------------------------
-- C_Container stub（3.80.1 大部分已存在，仅补缺失方法）
---------------------------------------------------------------------------
if not _G.C_Container then
    _G.C_Container = {}
end
if not _G.C_Container.GetContainerItemEquipmentSetInfo then
    _G.C_Container.GetContainerItemEquipmentSetInfo = function(bagID, slotID)
        return false, nil
    end
end

---------------------------------------------------------------------------
-- C_Texture (正式服纹理 API)
---------------------------------------------------------------------------
if not _G.C_Texture then
    _G.C_Texture = {
        GetAtlasInfo = function(atlas)
            -- 在经典版中无法获取 atlas 信息，返回空
            return nil
        end,
    }
end

---------------------------------------------------------------------------
-- C_EquipmentSet
---------------------------------------------------------------------------
if not _G.C_EquipmentSet then
    _G.C_EquipmentSet = {
        GetEquipmentSetInfo = function(setID) return nil end,
        GetEquipmentSetIDs = function() return {} end,
    }
end

---------------------------------------------------------------------------
-- CooldownFrame_Set (新版替代 CooldownFrame_SetTimer)
---------------------------------------------------------------------------
if not _G.CooldownFrame_Set then
    _G.CooldownFrame_Set = function(self, start, duration, enable, forceShowDrawEdge, modRate)
        if _G.CooldownFrame_SetTimer then
            return _G.CooldownFrame_SetTimer(self, start, duration, enable, forceShowDrawEdge, modRate)
        end
    end
end

---------------------------------------------------------------------------
-- GetPhysicalScreenSize (3.80.1 中被移除，UIScale/constants 依赖)
---------------------------------------------------------------------------
if not _G.GetPhysicalScreenSize then
    _G.GetPhysicalScreenSize = function()
        local uiScale = _G.UIParent:GetEffectiveScale()
        return _G.UIParent:GetWidth() * uiScale, _G.UIParent:GetHeight() * uiScale
    end
end

---------------------------------------------------------------------------
-- SOUNDKIT stub（正式服音效枚举）
-- 对应的数字 ID 在正式服才存在，经典版中这些音效路径不同
-- 如果不播放则直接跳过
---------------------------------------------------------------------------
if not _G.SOUNDKIT then
    _G.SOUNDKIT = {
        IG_MAINMENU_OPTION = 0,
        IG_MAINMENU_OPTION_CHECKBOX_ON = 0,
        IG_BACKPACK_CLOSE = 0,
        IG_BACKPACK_OPEN = 0,
        UI_BUTTON_CLICK = 0,
        GS_TITLE_DROP = 0,
        GS_TITLE_OPTION_OK = 0,
        UI_BONUS_EVENT_SYSTEM_VIGNETTES = 0,
        -- unitframe target selection sounds
        IG_CREATURE_AGGRO_SELECT = 0,
        IG_CHARACTER_NPC_SELECT = 0,
        IG_CREATURE_NEUTRAL_SELECT = 0,
        INTERFACE_SOUND_LOST_TARGET_UNIT = 0,
    }
end

---------------------------------------------------------------------------
-- C_AddOns fallback
---------------------------------------------------------------------------
if not _G.C_AddOns then
    _G.C_AddOns = {}
end
if not _G.C_AddOns.GetAddOnMetadata then
    _G.C_AddOns.GetAddOnMetadata = _G.GetAddOnMetadata
end

---------------------------------------------------------------------------
-- IsAddOnLoaded (3.80.1 中被移除，ADDON_LOADED handler 依赖)
---------------------------------------------------------------------------
if not _G.IsAddOnLoaded then
    _G.IsAddOnLoaded = function(name)
        -- C_AddOns version first
        if _G.C_AddOns and _G.C_AddOns.IsAddOnLoaded then
            return _G.C_AddOns.IsAddOnLoaded(name)
        end
        -- Check global table existence as fallback
        if _G[name] then return true end
        -- Check uppercase variant
        if name:upper() and _G[name:upper()] then return true end
        return false
    end
end

---------------------------------------------------------------------------
-- C_FriendList stub (blizzard/colors.lua 用到)
---------------------------------------------------------------------------
if not _G.C_FriendList then
    _G.C_FriendList = {}
end
if not _G.C_FriendList.GetWhoInfo then
    _G.C_FriendList.GetWhoInfo = function(index)
        -- 3.80.1 中可能不存在，返回 nil 让调用方优雅降级
        return nil
    end
end
if not _G.C_FriendList.GetFriendInfoByIndex then
    _G.C_FriendList.GetFriendInfoByIndex = function(index)
        return nil
    end
end

---------------------------------------------------------------------------
-- C_BattleNet stub (blizzard/friendslist.lua 用到)
---------------------------------------------------------------------------
if not _G.C_BattleNet then
    _G.C_BattleNet = {}
end
if not _G.C_BattleNet.GetFriendAccountInfo then
    _G.C_BattleNet.GetFriendAccountInfo = function(index)
        return nil
    end
end

---------------------------------------------------------------------------
-- CreateFromMixins (正式服 mixin API, LibRangeCheck 用到)
---------------------------------------------------------------------------
if not _G.CreateFromMixins then
    _G.CreateFromMixins = function(...)
        local obj = {}
        for i = 1, select('#', ...) do
            local mixin = select(i, ...)
            if mixin then
                for k, v in pairs(mixin) do
                    obj[k] = v
                end
            end
        end
        return obj
    end
end

---------------------------------------------------------------------------
-- ObjectPoolMixin (retail pool system, LibCustomGlow 用到)
---------------------------------------------------------------------------
if not _G.ObjectPoolMixin then
    _G.ObjectPoolMixin = {}

    function _G.ObjectPoolMixin.OnLoad(pool, factory, resetter)
        pool.factory = factory
        pool.resetter = resetter
        pool.free = {}
    end

    function _G.ObjectPoolMixin.Acquire(pool)
        local obj = tremove(pool.free)
        if not obj and pool.factory then
            obj = pool.factory(pool)
        end
        return obj
    end

    function _G.ObjectPoolMixin.Release(pool, obj)
        if obj and pool.resetter then
            pool.resetter(pool, obj)
        end
        tinsert(pool.free, obj)
    end
end

-- 3.80.1: ObjectPoolMixin exists but missing EnumerateInactive/ReleaseAll, add unconditionally
if not _G.ObjectPoolMixin.EnumerateInactive then
    function _G.ObjectPoolMixin.EnumerateInactive(pool)
        return ipairs(pool.free)
    end
end
if not _G.ObjectPoolMixin.ReleaseAll then
    function _G.ObjectPoolMixin.ReleaseAll(pool)
        -- stub
    end
end

---------------------------------------------------------------------------
-- CreateTexturePool (retail, LibCustomGlow 用到)
---------------------------------------------------------------------------
if not _G.CreateTexturePool then
    _G.CreateTexturePool = function(parent, layer, num, init, resetter)
        local pool = _G.CreateFromMixins(_G.ObjectPoolMixin)
        _G.ObjectPoolMixin.OnLoad(pool, function()
            return parent:CreateTexture(nil, layer)
        end, resetter)
        return pool
    end
end

---------------------------------------------------------------------------
-- CreateFramePool (retail, LibCustomGlow 用到)
---------------------------------------------------------------------------
if not _G.CreateFramePool then
    _G.CreateFramePool = function(frameType, parent, template, resetter)
        local pool = _G.CreateFromMixins(_G.ObjectPoolMixin)
        _G.ObjectPoolMixin.OnLoad(pool, function()
            return _G.CreateFrame(frameType, nil, parent, template)
        end, resetter)
        return pool
    end
end

---------------------------------------------------------------------------
-- C_ChallengeMode stub (nameplate 用到)
---------------------------------------------------------------------------
if not _G.C_ChallengeMode then _G.C_ChallengeMode = {} end
if not _G.C_ChallengeMode.GetActiveKeystoneInfo then
    _G.C_ChallengeMode.GetActiveKeystoneInfo = function() return nil, {} end
end

---------------------------------------------------------------------------
-- C_CVar stub (nameplate 用到)
---------------------------------------------------------------------------
if not _G.C_CVar then
    _G.C_CVar = {}
end
if not _G.C_CVar.RegisterCVar then
    _G.C_CVar.RegisterCVar = function(name) end
end

---------------------------------------------------------------------------
-- LibActionButton retail API stubs
---------------------------------------------------------------------------
if not _G.IsCurrentAction then
    _G.IsCurrentAction = function(slot) return false end
end
if not _G.IsAttackAction then
    _G.IsAttackAction = function(slot) return false end
end
if not _G.IsEquippedAction then
    _G.IsEquippedAction = function(slot) return false end
end
if not _G.IsAutoRepeatAction then
    _G.IsAutoRepeatAction = function(slot) return false end
end
if not _G.IsUsableAction then
    _G.IsUsableAction = function(slot) return false end
end
if not _G.IsConsumableAction then
    _G.IsConsumableAction = function(slot) return false end
end

---------------------------------------------------------------------------
-- C_Garrison stub (6.0+, not in 3.80.1; Map minimap 用到)
---------------------------------------------------------------------------
if not _G.C_Garrison then
    _G.C_Garrison = {
        HasGarrison = function() return false end,
    }
end

---------------------------------------------------------------------------
-- C_QuestLog stubs (Retail quest API, 3.80.1 uses global equivalents)
---------------------------------------------------------------------------
if not _G.C_QuestLog then _G.C_QuestLog = {} end
if not _G.C_QuestLog.GetTitleForQuestID then
    _G.C_QuestLog.GetTitleForQuestID = function(questID)
        for i = 1, GetNumQuestLogEntries() do
            local title, _, _, _, _, _, _, id = GetQuestLogTitle(i)
            if id == questID then return title end
        end
        return nil
    end
end
if not _G.C_QuestLog.IsWorldQuest then
    _G.C_QuestLog.IsWorldQuest = function() return false end
end
if not _G.C_QuestLog.GetQuestTagInfo then
    _G.C_QuestLog.GetQuestTagInfo = function() return nil end
end
if not _G.C_QuestLog.GetLogIndexForQuestID then
    _G.C_QuestLog.GetLogIndexForQuestID = function(questID)
        for i = 1, GetNumQuestLogEntries() do
            local _, _, _, _, _, _, _, id = GetQuestLogTitle(i)
            if id == questID then return i end
        end
        return nil
    end
end
if not _G.C_QuestLog.GetInfo then
    _G.C_QuestLog.GetInfo = function(index)
        local title, level, _, _, _, isComplete, _, questID = GetQuestLogTitle(index)
        return {
            title = title,
            level = level,
            isComplete = isComplete,
            questID = questID,
            frequency = 0,
        }
    end
end
if not _G.C_QuestLog.GetNumQuestLogEntries then
    _G.C_QuestLog.GetNumQuestLogEntries = function() return GetNumQuestLogEntries() or 0 end
end
if not _G.C_QuestLog.GetQuestIDForLogIndex then
    _G.C_QuestLog.GetQuestIDForLogIndex = function(index)
        return select(8, GetQuestLogTitle(index))
    end
end
if not _G.C_QuestLog.IsComplete then
    _G.C_QuestLog.IsComplete = function(questID) return IsQuestComplete(questID) end
end

----------------------------------------------------------------------------
-- LE_QUEST_TAG_TYPE / LE_QUEST_FREQUENCY stubs (Retail-only constants)
----------------------------------------------------------------------------
if not _G.LE_QUEST_TAG_TYPE_PROFESSION then
    _G.LE_QUEST_TAG_TYPE_PROFESSION = 0
end
if not _G.LE_QUEST_FREQUENCY_DAILY then
    _G.LE_QUEST_FREQUENCY_DAILY = 1
end

---------------------------------------------------------------------------
-- GetSpecialization (3.80.1 missing, Cataclysm native API)
---------------------------------------------------------------------------
if not _G.GetSpecialization then
    _G.GetSpecialization = function() return nil end
end
