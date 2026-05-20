local F, C = unpack(select(2, ...))

-- NDui → Andromeda compat shim
-- 3.80.1 Texture:SetColorTexture polyfill (handles both (r,g,b,a) and (color,a) signatures)
do
    local tex = UIParent:CreateTexture(nil, "ARTWORK")
    local mt = tex and getmetatable(tex)
    if mt and mt.__index and mt.__index.SetColorTexture and not mt.__index.__SetColorTexture_patched then
        mt.__index.__SetColorTexture_patched = true
        local orig = mt.__index.SetColorTexture
        mt.__index.SetColorTexture = function(self, r, g, b, a)
            if type(r) == "number" and type(g) == "number" and type(b) == "number" then
                local ok = pcall(orig, self, r, g, b, a)
                if not ok then
                    orig(self, CreateColor(r, g, b, a or 1))
                end
            else
                orig(self, r, g)
            end
        end
    end
end

local B = {}
setmetatable(B, {__index = F})
-- Name mismatches
B.Reskin = F.ReskinButton
B.ReskinCheck = F.ReskinCheckbox
B.ReskinDropDown = F.ReskinDropdown
B.ReskinEditBox = F.ReskinEditbox
B.ReskinInput = F.ReskinEditbox
B.Dummy = function() end

-- NDui config compat
C.db = C.db or {}
C.db.Skins = {BlizzardSkins = _G.ANDROMEDA_ADB and _G.ANDROMEDA_ADB.ReskinBlizz ~= false}
C.db.Bags = {Enable = false}
C.db.Nameplate = {Enable = false}

local DB = {
    r = C.r, g = C.g, b = C.b,
    bdTex = C.Assets.Textures.Backdrop,
    TexCoord = C.TEX_COORD,
    isDeveloper = false,
    pushedTex = C.Assets.Textures.ButtonPushed,
    normTex = C.Assets.Textures.StatusbarNormal,
    closeTex = C.Assets.Textures.Close,
    ClassColors = RAID_CLASS_COLORS,
    QualityColors = ITEM_QUALITY_COLORS,
}
tinsert(C.BlizzThemes, function()
	-- BattlefieldFrame
	if BattlefieldFrame then
		B.ReskinPortraitFrame(BattlefieldFrame, 15, -15, -35, 73)
		B.Reskin(BattlefieldFrameJoinButton)
		B.Reskin(BattlefieldFrameCancelButton)
		B.Reskin(BattlefieldFrameGroupJoinButton)
		B.ReskinScroll(BattlefieldFrameTypeScrollFrameScrollBar)
		BattlefieldFrameBGTex:Hide()
		B.CreateBDFrame(BattlefieldFrameInfoScrollFrame, .25)
	end

	-- WorldStateScoreFrame
	B.ReskinPortraitFrame(WorldStateScoreFrame, 13, -15, -90, 70)
	B.ReskinScroll(WorldStateScoreScrollFrameScrollBar)
	WorldStateScoreScrollFrameScrollBar:SetPoint("TOPLEFT", WorldStateScoreScrollFrame, "TOPRIGHT", 38, -16) -- don't overlay with scroll buttons
	for i = 1, 3 do
		B.ReskinTab(_G["WorldStateScoreFrameTab"..i])
	end
	B.Reskin(WorldStateScoreFrameLeaveButton)

	-- ArenaFrame
	if ArenaFrame then
		B.ReskinPortraitFrame(ArenaFrame, 15, -15, -35, 73)
		B.Reskin(ArenaFrameJoinButton)
		B.Reskin(ArenaFrameCancelButton)
		B.Reskin(ArenaFrameGroupJoinButton)

		-- Temp fix for ArenaFrame label
		local relF, parent, relT, x, y = ArenaFrameFrameLabel:GetPoint()
		if parent == BattlefieldFrame then
			ArenaFrameFrameLabel:SetPoint(relF, ArenaFrame, relT, x, y)
		end
	end

	-- ArenaRegistrarFrame
	ArenaAvailableServicesText:SetTextColor(1, 1, 1)
	ArenaAvailableServicesText:SetShadowColor(0, 0, 0)

	B.ReskinPortraitFrame(ArenaRegistrarFrame, 15, -15, -30, 65)
	B.StripTextures(ArenaRegistrarGreetingFrame)
	ArenaRegistrarFrameEditBox:SetHeight(20)
	ArenaRegistrarFrameEditBox:DisableDrawLayer("BACKGROUND")
	B.ReskinEditBox(ArenaRegistrarFrameEditBox)
	B.Reskin(ArenaRegistrarFrameGoodbyeButton)
	B.Reskin(ArenaRegistrarFramePurchaseButton)
	B.Reskin(ArenaRegistrarFrameCancelButton)
end)