local F, C = unpack(select(2, ...))
local THEME = F:GetModule('Theme')

local function handleIcon(icon)
    if not icon then return end
    icon:SetTexCoord(unpack(C.TEX_COORD))
end

local function ReskinPallyPower()
    local PallyPower = _G.PallyPower
    if not PallyPower then return end

    local frame = _G.PallyPowerBlessingsFrame
    if not frame then return end

    F.StripTextures(frame)
    F.SetBD(frame)

    if _G.PallyPowerBlessingsFrameCloseButton then
        F.ReskinClose(_G.PallyPowerBlessingsFrameCloseButton)
    end

    if _G.PallyPowerBlessingsFrameAuraGroup1AuraHeaderIcon then
        F.ReskinIcon(_G.PallyPowerBlessingsFrameAuraGroup1AuraHeaderIcon)
    end

    local buttons = {
        'PallyPowerBlessingsFrameRefresh',
        'PallyPowerBlessingsFrameClear',
        'PallyPowerBlessingsFrameAutoAssign',
        'PallyPowerBlessingsFrameReport',
        'PallyPowerBlessingsFrameOptions',
    }
    for _, button in next, buttons do
        local bu = _G[button]
        if bu then
            F.ReskinButton(bu)
        end
    end

    for i = 1, _G.PALLYPOWER_MAXCLASSES do
        local icon = _G['PallyPowerBlessingsFrameClassGroup'..i..'ClassButtonIcon']
        if icon then
            F.ReskinIcon(icon)
        end
    end

    for i = 1, 15 do
        local frameName = 'PallyPowerBlessingsFramePlayer'..i
        handleIcon(_G[frameName..'Icon1'])
        handleIcon(_G[frameName..'Icon2'])
        handleIcon(_G[frameName..'Icon3'])
        handleIcon(_G[frameName..'Icon4'])
        handleIcon(_G[frameName..'Icon5'])
        handleIcon(_G[frameName..'Icon6'])
        handleIcon(_G[frameName..'AIcon1'])
        handleIcon(_G[frameName..'AIcon2'])
        handleIcon(_G[frameName..'AIcon3'])
        handleIcon(_G[frameName..'CIcon1'])
        handleIcon(_G[frameName..'CIcon2'])
        handleIcon(_G[frameName..'Aura1Icon'])

        for cNum = 1, _G.PALLYPOWER_MAXCLASSES do
            handleIcon(_G[frameName..'Class'..cNum..'Icon'])
        end
    end

    local icons = {
        'PallyPowerAutoIcon',
        'PallyPowerRFIcon',
        'PallyPowerRFIconSeal',
        'PallyPowerAuraIcon',
    }
    for _, icon in next, icons do
        handleIcon(_G[icon])
    end

    for cbNum = 1, _G.PALLYPOWER_MAXCLASSES do
        handleIcon(_G['PallyPowerC'..cbNum..'ClassIcon'])
        handleIcon(_G['PallyPowerC'..cbNum..'BuffIcon'])
        for pbNum = 1, _G.PALLYPOWER_MAXPERCLASS do
            handleIcon(_G['PallyPowerC'..cbNum..'P'..pbNum..'BuffIcon'])
        end
    end
end

THEME:RegisterSkin('PallyPower', ReskinPallyPower)