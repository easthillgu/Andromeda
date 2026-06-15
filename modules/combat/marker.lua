local F, C = unpack(select(2, ...))
local COMBAT = F:GetModule('Combat')

local raidTargetColors = {
    { 1, 0.92, 0 },
    { 0.98, 0.57, 0 },
    { 0.83, 0.22, 0.9 },
    { 0.04, 0.95, 0 },
    { 0.7, 0.82, 0.875 },
    { 0, 0.71, 1 },
    { 1, 0.24, 0.168 },
    { 0.98, 0.98, 0.98 },
}

local function createMenuList()
    local menuList = {
        {
            text = _G.RAID_TARGET_NONE,
            func = function()
                SetRaidTarget('target', 0)
            end,
        },
    }

    for i = 1, 8 do
        local color = raidTargetColors[i]
        tinsert(menuList, {
            text = F:RgbToHex(color[1], color[2], color[3]) .. _G['RAID_TARGET_' .. i] .. ' ' .. _G.ICON_LIST[i] .. '12|t',
            func = function()
                SetRaidTarget('target', i)
            end,
        })
    end

    return menuList
end

local menuList = createMenuList()

local function getModifiedKey()
    local index = C.DB.Combat.EasyMarkKey
    if index == 1 then
        return IsControlKeyDown()
    elseif index == 2 then
        return IsAltKeyDown()
    elseif index == 3 then
        return IsShiftKeyDown()
    end
    return false
end

local function canMarkUnit()
    if not IsInGroup() then
        return true
    end
    if not IsInRaid() then
        return true
    end
    return UnitIsGroupLeader('player') or UnitIsGroupAssistant('player')
end

local function onWorldFrameClick(_, btn)
    if btn ~= 'LeftButton' or not getModifiedKey() or not UnitExists('mouseover') then
        return
    end

    if not canMarkUnit() then
        return
    end

    local ricon = GetRaidTargetIndex('mouseover')
    for i = 1, 8 do
        menuList[i + 1].checked = ricon == i
    end
    F.ShowEasyMenu(menuList, F.EasyMenu, 'cursor', 0, 0, 'MENU', 1)
end

function COMBAT:EasyMark()
    if not C.DB.Combat.EasyMark then
        return
    end

    _G.WorldFrame:HookScript('OnMouseDown', onWorldFrameClick)
end
