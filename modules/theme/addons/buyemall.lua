local F, C = unpack(select(2, ...))
local THEME = F:GetModule('Theme')

function THEME:ReskinBuyEmAll()
    if not C_AddOns.IsAddOnLoaded('BuyEmAll') then
        return
    end

    if not _G.ANDROMEDA_ADB.ReskinBuyEmAll then
        return
    end

    if _G.BuyEmAllFrame then
        F.StripTextures(_G.BuyEmAllFrame)
        F.SetBD(_G.BuyEmAllFrame)
    end

    if _G.BuyEmAllStackButton then
        F.ReskinButton(_G.BuyEmAllStackButton)
    end

    if _G.BuyEmAllMaxButton then
        F.ReskinButton(_G.BuyEmAllMaxButton)
    end

    if _G.BuyEmAllCancelButton then
        F.ReskinButton(_G.BuyEmAllCancelButton)
    end

    if _G.BuyEmAllOkayButton then
        F.ReskinButton(_G.BuyEmAllOkayButton)
    end
end