local F, C = unpack(select(2, ...))

C.Themes['Blizzard_TalentUI'] = function()
    local r, g, b = C.r, C.g, C.b

    F.ReskinPortraitFrame(_G.PlayerTalentFrame)
    F.ReskinScroll(_G.PlayerTalentFrameScrollFrameScrollBar)

    for i = 1, 4 do
        local tab = _G['PlayerTalentFrameTab' .. i]
        if tab then
            F.ReskinTab(tab)
        end
    end

    F.StripTextures(_G.PlayerTalentFrameScrollFrame)

    for i = 1, _G.MAX_NUM_TALENTS do
        local talent = _G['PlayerTalentFrameTalent' .. i]
        local icon = _G['PlayerTalentFrameTalent' .. i .. 'IconTexture']
        if talent then
            F.StripTextures(talent)
            icon:SetTexCoord(.08, .92, .08, .92)
            F.CreateBDFrame(icon)
        end
    end

    F.StripTextures(_G.PlayerTalentFrameStatusFrame)
    F.StripTextures(_G.PlayerTalentFramePointsBar)
    F.ReskinButton(_G.PlayerTalentFrameActivateButton)

    F.StripTextures(_G.PlayerTalentFramePreviewBar)
    F.StripTextures(_G.PlayerTalentFramePreviewBarFiller)
    F.ReskinButton(_G.PlayerTalentFrameLearnButton)
    F.ReskinButton(_G.PlayerTalentFrameResetButton)

    _G.PlayerTalentFrameTalentPointsText:ClearAllPoints()
    _G.PlayerTalentFrameTalentPointsText:SetPoint('RIGHT', _G.PlayerTalentFramePointsBar, 'RIGHT', -12, 1)

    for i = 1, 3 do
        local tab = _G['PlayerSpecTab' .. i]
        if tab then
            tab:GetRegions():Hide()
            tab:SetCheckedTexture(C.Assets.Textures.ButtonChecked)
            tab:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
            tab:GetNormalTexture():SetTexCoord(unpack(C.TEX_COORD))
            F.CreateBDFrame(tab)
        end
    end
end