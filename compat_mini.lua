-- compat_mini.lua — minimal compatibility stubs for 3.80.1
-- Full compat.lua disabled due to Lua Taint causing Internal Auction Error

-- _G.nop (used extensively in theme files)
if not _G.nop then _G.nop = function() end end

-- Enum.ItemQuality aliases (3.80.1 uses Standard/Good, not Common/Uncommon)
_G.Enum.ItemQuality.Common = _G.Enum.ItemQuality.Common or _G.Enum.ItemQuality.Standard or 1
_G.Enum.ItemQuality.Uncommon = _G.Enum.ItemQuality.Uncommon or _G.Enum.ItemQuality.Good or 2

-- IsAddOnLoaded (3.80.1 native in C_AddOns namespace, all references migrated)

-- C_ChallengeMode (minimap.lua)
if not _G.C_ChallengeMode then _G.C_ChallengeMode = {} end
if not _G.C_ChallengeMode.GetActiveKeystoneInfo then
    _G.C_ChallengeMode.GetActiveKeystoneInfo = function() return nil, {} end
end

-- C_QuestLog (quest.lua, others)
_G.C_QuestLog = _G.C_QuestLog or {}
_G.C_QuestLog.GetNumQuestLogEntries = _G.C_QuestLog.GetNumQuestLogEntries or function() return GetNumQuestLogEntries() or 0 end
_G.C_QuestLog.GetQuestIDForLogIndex = _G.C_QuestLog.GetQuestIDForLogIndex or function(index)
    local _, _, _, _, _, _, _, questID = GetQuestLogTitle(index)
    return questID
end
_G.C_QuestLog.GetInfo = _G.C_QuestLog.GetInfo or function(index)
    local title, level, _, _, _, isComplete, _, questID = GetQuestLogTitle(index)
    return { title = title, level = level, isComplete = isComplete, questID = questID, frequency = 0 }
end
_G.C_QuestLog.IsComplete = _G.C_QuestLog.IsComplete or function(questID) return IsQuestComplete(questID) end
_G.C_QuestLog.IsWorldQuest = _G.C_QuestLog.IsWorldQuest or function() return false end
_G.C_QuestLog.GetQuestTagInfo = _G.C_QuestLog.GetQuestTagInfo or function() return nil end

-- EasyMenu (minimap.lua, 3.80.1 removed from global scope)
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
        if displayMode == 'MENU' then menuFrame.displayMode = displayMode end
        UIDropDownMenu_Initialize(menuFrame, EasyMenu_Initialize, displayMode, nil, menuList)
        ToggleDropDownMenu(1, nil, menuFrame, anchor, x, y, menuList, nil, autoHideDelay)
    end
end
