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
C.Themes["Blizzard_TradeSkillUI"] = function()
	B.ReskinPortraitFrame(TradeSkillFrame, 10, -10, -30, 70)
	B.ReskinScroll(TradeSkillListScrollFrameScrollBar)
	B.ReskinScroll(TradeSkillDetailScrollFrameScrollBar)
	B.Reskin(TradeSkillCreateAllButton)
	B.Reskin(TradeSkillCreateButton)
	B.Reskin(TradeSkillCancelButton)
	B.ReskinArrow(TradeSkillDecrementButton, "left")
	B.ReskinArrow(TradeSkillIncrementButton, "right")
	B.ReskinInput(TradeSkillInputBox)
	B.ReskinInput(TradeSkillFrameEditBox)
	TradeSkillFrameBottomLeftTexture:Hide()
	TradeSkillFrameBottomRightTexture:Hide()

	B.StripTextures(TradeSkillRankFrameBorder)
	B.StripTextures(TradeSkillRankFrame)
	TradeSkillRankFrame:SetStatusBarTexture(DB.bdTex)
	TradeSkillRankFrame.SetStatusBarColor = B.Dummy
	TradeSkillRankFrame:GetStatusBarTexture():SetGradient("VERTICAL", CreateColor(.1, .3, .9, 1), CreateColor(.2, .4, 1, 1))
	B.CreateBDFrame(TradeSkillRankFrame, .25)
	TradeSkillRankFrame:SetWidth(220)

	B.ReskinCollapse(TradeSkillCollapseAllButton)
	TradeSkillExpandButtonFrame:DisableDrawLayer("BACKGROUND")
	B.ReskinCheck(TradeSkillFrameAvailableFilterCheckButton)

	hooksecurefunc("TradeSkillFrame_Update", function()
		for i = 1, 22 do
			local bu = _G["TradeSkillSkill"..i]
			if bu and not bu.styled then
				B.ReskinCollapse(bu)
				bu.styled = true
			end
		end
	end)

	B.ReskinDropDown(TradeSkillSubClassDropdown)
	B.ReskinDropDown(TradeSkillInvSlotDropdown)

	B.StripTextures(TradeSkillDetailScrollChildFrame)
	B.StripTextures(TradeSkillSkillIcon)
	B.CreateBDFrame(TradeSkillSkillIcon)

	hooksecurefunc("TradeSkillFrame_SetSelection", function(id)
		local skillType = select(2, GetTradeSkillInfo(id))
		if skillType == "header" then return end

		local tex = TradeSkillSkillIcon:GetNormalTexture()
		if tex then
			tex:SetTexCoord(.08, .92, .08, .92)
		end

		local skillLink = GetTradeSkillItemLink(id)
		if skillLink then
			local quality = select(3, GetItemInfo(skillLink))
			if quality and quality > 1 then
				local r, g, b = GetItemQualityColor(quality)
				TradeSkillSkillName:SetTextColor(r, g, b)
			else
				TradeSkillSkillName:SetTextColor(1, 1, 1)
			end
		end
	end)

	for i = 1, MAX_TRADE_SKILL_REAGENTS do
		local icon = _G["TradeSkillReagent"..i.."IconTexture"]
		icon:SetTexCoord(.08, .92, .08, .92)
		B.CreateBDFrame(icon)

		local nameFrame = _G["TradeSkillReagent"..i.."NameFrame"]
		nameFrame:Hide()
		local bg = B.CreateBDFrame(nameFrame, .25)
		bg:SetPoint("TOPLEFT", icon, "TOPRIGHT", 3, C.MULT)
		bg:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 100, -C.MULT)
	end
end