local F, C = unpack(select(2, ...))

C.Themes['Blizzard_GlyphUI'] = function()
    F.StripTextures(_G.GlyphFrame)
    if _G.GlyphFrameBackground then
        _G.GlyphFrameBackground:Hide()
    end
end