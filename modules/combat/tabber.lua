local F, C = unpack(select(2, ...))
local COMBAT = F:GetModule('Combat')

local RTB_Fail = false
local RTB_DefaultKey = true

local function GetTargetKeys()
    local TargetKey = GetBindingKey('TARGETNEARESTENEMYPLAYER') or GetBindingKey('TARGETNEARESTENEMY')
    local LastTargetKey = GetBindingKey('TARGETPREVIOUSENEMYPLAYER') or GetBindingKey('TARGETPREVIOUSENEMY')

    if not TargetKey and RTB_DefaultKey then
        TargetKey = 'TAB'
    end
    if not LastTargetKey and RTB_DefaultKey then
        LastTargetKey = 'SHIFT-TAB'
    end

    return TargetKey, LastTargetKey
end

local function SetTabBindings(isPVP)
    local BindSet = GetCurrentBindingSet()
    if BindSet ~= 1 and BindSet ~= 2 then
        return false
    end

    if InCombatLockdown() then
        RTB_Fail = true
        return false
    end

    local TargetKey, LastTargetKey = GetTargetKeys()
    if not TargetKey then
        return true
    end

    local CurrentBind = GetBindingAction(TargetKey)
    local targetAction = isPVP and 'TARGETNEARESTENEMYPLAYER' or 'TARGETNEARESTENEMY'
    local lastAction = isPVP and 'TARGETPREVIOUSENEMYPLAYER' or 'TARGETPREVIOUSENEMY'

    if CurrentBind == targetAction then
        return true
    end

    local Success = SetBinding(TargetKey, targetAction)
    if LastTargetKey then
        SetBinding(LastTargetKey, lastAction)
    end

    if Success then
        SaveBindings(BindSet)
        RTB_Fail = false
    else
        RTB_Fail = true
    end

    return Success
end

local function IsInPVPZone()
    local PVPType = GetZonePVPInfo()
    local _, ZoneType = IsInInstance()
    return ZoneType == 'arena' or ZoneType == 'pvp' or PVPType == 'combat'
end

local function OnEvent(self, event, ...)
    if event == 'CHAT_MSG_SYSTEM' then
        if ... == _G.ERR_DUEL_REQUESTED then
            SetTabBindings(true)
        end
        return
    end

    if event == 'PLAYER_REGEN_ENABLED' and RTB_Fail then
        SetTabBindings(IsInPVPZone())
        return
    end

    SetTabBindings(IsInPVPZone() or event == 'DUEL_REQUESTED')
end

function COMBAT:SmartTab()
    if not C.DB.Combat.SmartTab then
        return
    end

    F:RegisterEvent('PLAYER_ENTERING_WORLD', OnEvent)
    F:RegisterEvent('ZONE_CHANGED_NEW_AREA', OnEvent)
    F:RegisterEvent('PLAYER_REGEN_ENABLED', OnEvent)
    F:RegisterEvent('DUEL_REQUESTED', OnEvent)
    F:RegisterEvent('DUEL_FINISHED', OnEvent)
    F:RegisterEvent('CHAT_MSG_SYSTEM', OnEvent)
end
