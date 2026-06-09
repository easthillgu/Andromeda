local F, C = unpack(select(2, ...))
local COMBAT = F:GetModule('Combat')
local oUF = F.Libs.oUF

local modifier
local mouseButton = '1'
local pending = {}

local function getModifierFromIndex(index)
    if index == 1 then
        return 'control'
    elseif index == 2 then
        return 'alt'
    elseif index == 3 then
        return 'shift'
    end
end

function COMBAT:Focuser_Setup(frame)
    if not C.DB.Combat.EasyFocusOnUnitframe then
        return
    end

    if not frame or frame.focuser then
        return
    end

    local name = frame.GetName and frame:GetName()
    if name and strmatch(name, 'oUF_NPs') then
        return
    end

    if not InCombatLockdown() then
        modifier = getModifierFromIndex(C.DB.Combat.EasyFocusKey)
        if modifier then
            frame:SetAttribute(modifier .. '-type' .. mouseButton, 'focus')
            frame.focuser = true
            pending[frame] = nil
        end
    else
        pending[frame] = true
    end
end

function COMBAT:Focuser_CreateFrameHook(name, _, template)
    if name and template == 'SecureUnitButtonTemplate' then
        COMBAT:Focuser_Setup(_G[name])
    end
end

function COMBAT:Focuser_OnEvent(event)
    if event == 'PLAYER_REGEN_ENABLED' then
        if next(pending) then
            for frame in next, pending do
                COMBAT:Focuser_Setup(frame)
            end
        end
    else
        for _, object in next, oUF.objects do
            if not object.focuser then
                COMBAT:Focuser_Setup(object)
            end
        end
    end
end

function COMBAT:EasyFocus()
    if not C.DB.Combat.EasyFocus then
        return
    end

    modifier = getModifierFromIndex(C.DB.Combat.EasyFocusKey)
    if not modifier then
        return
    end

    local f = CreateFrame('CheckButton', 'FocuserButton', _G.UIParent, 'SecureActionButtonTemplate')
    f:SetAttribute('type1', 'macro')
    f:SetAttribute('macrotext', '/focus mouseover')
    SetOverrideBindingClick(_G.FocuserButton, true, modifier .. '-BUTTON' .. mouseButton, 'FocuserButton')
    f:RegisterForClicks('LeftButtonDown')

    hooksecurefunc('CreateFrame', COMBAT.Focuser_CreateFrameHook)
    COMBAT:Focuser_OnEvent()
    F:RegisterEvent('PLAYER_REGEN_ENABLED', COMBAT.Focuser_OnEvent)
    F:RegisterEvent('GROUP_ROSTER_UPDATE', COMBAT.Focuser_OnEvent)
end
