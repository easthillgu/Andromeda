local F, C = unpack(select(2, ...))
local NAMEPLATE = F:GetModule('Nameplate')

function NAMEPLATE:UpdateSelectedChange()
    local element = self.SelectedIndicator
    local unit = self.unit

    if C.DB.Nameplate.ColoredTarget then
        NAMEPLATE.UpdateThreatColor(self, _, unit)
    end

    if not element then
        return
    end

    if UnitIsUnit(unit, 'target') and not UnitIsUnit(unit, 'player') then
        element:Show()
    else
        element:Hide()
    end
end

function NAMEPLATE:UpdateSelectedIndicatorColor(self, r, g, b)
    -- 3.80.1: bracket decorations removed, no vertex color to update
end

function NAMEPLATE:UpdateSelectedIndicatorVisibility()
    local element = self.SelectedIndicator
    local isNameOnly = self.plateType == 'NameOnly'

    if not element then
        return
    end

    if C.DB.Nameplate.SelectedIndicator then
        if isNameOnly then
            element.nameGlow:Show()
            element.Glow:Hide()
        else
            element.nameGlow:Hide()
            element.Glow:Show()
        end
        element:Show()
    else
        element:Hide()
    end
end

function NAMEPLATE:CreateSelectedIndicator(self)
    if not C.DB.Nameplate.SelectedIndicator then
        return
    end

    local color = C.DB.Nameplate.SelectedIndicatorColor
    local r, g, b = color.r, color.g, color.b

    local frame = CreateFrame('Frame', nil, self)
    frame:SetFrameStrata('BACKGROUND')
    frame:SetAllPoints()
    frame:Hide()

    frame.Glow = frame:CreateTexture(nil, 'BACKGROUND')
    frame.Glow:SetPoint('TOPLEFT', frame, 'BOTTOMLEFT')
    frame.Glow:SetPoint('TOPRIGHT', frame, 'BOTTOMRIGHT')
    frame.Glow:SetHeight(12)
    frame.Glow:SetTexture(C.Assets.Textures.Glow)
    frame.Glow:SetRotation(rad(180))
    frame.Glow:SetVertexColor(r, g, b)

    -- 3.80.1: bracket decorations (aggroL/aggroR) removed

    frame.nameGlow = frame:CreateTexture(nil, 'BACKGROUND', nil, -5)
    frame.nameGlow:SetSize(150, 80)
    frame.nameGlow:SetTexture('Interface\\GLUES\\Models\\UI_Draenei\\GenericGlow64')
    frame.nameGlow:SetVertexColor(0, 0.6, 1)
    frame.nameGlow:SetBlendMode('ADD')
    frame.nameGlow:SetPoint('CENTER', 0, 14)

    self.SelectedIndicator = frame
    self:RegisterEvent('PLAYER_TARGET_CHANGED', NAMEPLATE.UpdateSelectedChange, true)

    NAMEPLATE.UpdateSelectedIndicatorVisibility(self)
end
