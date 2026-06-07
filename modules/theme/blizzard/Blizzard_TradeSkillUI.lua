local F, C = unpack(select(2, ...))

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

	-- ElvUI 风格：处理等级进度条
	B.StripTextures(TradeSkillRankFrameBorder)
	B.StripTextures(TradeSkillRankFrame)
	TradeSkillRankFrame:SetSize(322, 16)
	TradeSkillRankFrame:ClearAllPoints()
	TradeSkillRankFrame:SetPoint('TOP', TradeSkillFrame, 'TOP', -10, -45)
	TradeSkillRankFrame:SetStatusBarTexture(DB.normTex)
	TradeSkillRankFrame:SetStatusBarColor(0.13, 0.35, 0.80)
	B.SetBD(TradeSkillRankFrame)

	-- ElvUI 风格：处理展开按钮框架
	B.StripTextures(TradeSkillExpandButtonFrame)

	-- ElvUI 风格：处理全部折叠按钮
	local collapseAllButton = TradeSkillCollapseAllButton
	if collapseAllButton then
		local normalTexture = collapseAllButton:GetNormalTexture()
		if normalTexture then
			normalTexture:SetPoint('LEFT', 3, 2)
			normalTexture:SetSize(15, 15)
		end
		collapseAllButton:SetHighlightTexture('')
		collapseAllButton:SetDisabledTexture([[Interface\Buttons\UI-MinusButton-Up]])
		local disabledTexture = collapseAllButton:GetDisabledTexture()
		if disabledTexture then
			disabledTexture:SetPoint('LEFT', 3, 2)
			disabledTexture:SetSize(15, 15)
			disabledTexture:SetDesaturated(true)
		end
		B.ReskinCollapse(collapseAllButton)
	end

	-- ElvUI 风格：处理下拉框位置
	B.ReskinDropDown(TradeSkillInvSlotDropdown, 110)
	TradeSkillInvSlotDropdown:ClearAllPoints()
	TradeSkillInvSlotDropdown:SetPoint('TOPRIGHT', TradeSkillFrame, 'TOPRIGHT', -32, -68)

	B.ReskinDropDown(TradeSkillSubClassDropdown, 110)
	TradeSkillSubClassDropdown:ClearAllPoints()
	TradeSkillSubClassDropdown:SetPoint('RIGHT', TradeSkillInvSlotDropdown, 'RIGHT', -120, 0)

	-- ElvUI 风格：处理标题文本位置
	TradeSkillFrameTitleText:ClearAllPoints()
	TradeSkillFrameTitleText:SetPoint('TOP', TradeSkillFrame, 'TOP', 0, -18)

	-- ElvUI 风格：处理技能列表按钮
	for i = 1, TRADE_SKILLS_DISPLAYED do
		local button = _G['TradeSkillSkill'..i]
		if button then
			B.ReskinCollapse(button)
			local normal = button:GetNormalTexture()
			if normal then
				normal:SetSize(14, 14)
				normal:SetPoint('LEFT', 2, 1)
			end

			local highlight = _G['TradeSkillSkill'..i..'Highlight']
			if highlight then
				highlight:SetTexture('')
			end
		end
	end

	B.StripTextures(TradeSkillDetailScrollFrame)
	B.StripTextures(TradeSkillListScrollFrame)
	B.StripTextures(TradeSkillDetailScrollChildFrame)

	B.ReskinCheck(TradeSkillFrameAvailableFilterCheckButton)

	-- ElvUI 风格：处理技能图标
	TradeSkillSkillIcon:SetSize(40, 40)
	TradeSkillSkillIcon:SetPoint('TOPLEFT', 2, -3)
	B.StripTextures(TradeSkillSkillIcon)
	B.SetBD(TradeSkillSkillIcon)

	-- ElvUI 风格：处理高亮纹理
	TradeSkillHighlight:SetTexture(C.Assets.Textures.Glow)
	TradeSkillHighlight:SetAlpha(0.3)

	-- ElvUI 风格：处理输入框尺寸
	TradeSkillInputBox:SetSize(36, 16)

	-- ElvUI 风格：处理材料图标
	for i = 1, MAX_TRADE_SKILL_REAGENTS do
		local icon = _G["TradeSkillReagent"..i.."IconTexture"]
		local count = _G["TradeSkillReagent"..i.."Count"]
		local nameFrame = _G["TradeSkillReagent"..i.."NameFrame"]

		if icon then
			B.ReskinIcon(icon)
			icon:SetDrawLayer('OVERLAY')
		end

		if count then
			count:SetDrawLayer('OVERLAY')
		end

		if nameFrame then
			nameFrame:SetAlpha(0)
		end
	end

	-- ElvUI 风格：处理技能选择时的品质颜色
	hooksecurefunc("TradeSkillFrame_SetSelection", function(id)
		local skillType = select(2, GetTradeSkillInfo(id))
		if skillType == "header" then return end

		local tex = TradeSkillSkillIcon:GetNormalTexture()
		if tex then
			tex:SetTexCoord(.08, .92, .08, .92)
		end

		local skillLink = GetTradeSkillItemLink(id)
		if skillLink then
			local quality = C_Item.GetItemQualityByID and C_Item.GetItemQualityByID(skillLink) or select(3, GetItemInfo(skillLink))
			if quality and quality > 1 then
				local r, g, b = GetItemQualityColor(quality)
				TradeSkillSkillIcon.__bg:SetBackdropBorderColor(r, g, b)
				TradeSkillSkillName:SetTextColor(r, g, b)
			else
				TradeSkillSkillIcon.__bg:SetBackdropBorderColor(0, 0, 0)
				TradeSkillSkillName:SetTextColor(1, 1, 1)
			end
		end

		-- ElvUI 风格：处理材料品质颜色
		for i = 1, GetTradeSkillNumReagents(id) do
			local reagentName, reagentTexture, reagentCount, playerReagentCount = GetTradeSkillReagentInfo(id, i)
			local reagentLink = GetTradeSkillReagentItemLink(id, i)

			if reagentLink then
				local icon = _G['TradeSkillReagent'..i..'IconTexture']
				local quality = C_Item.GetItemQualityByID and C_Item.GetItemQualityByID(reagentLink) or select(3, GetItemInfo(reagentLink))
				if quality and quality > 1 then
					local name = _G['TradeSkillReagent'..i..'Name']
					local r, g, b = GetItemQualityColor(quality)

					if icon and icon.__bg then
						icon.__bg:SetBackdropBorderColor(r, g, b)
					end

					if name then
						if playerReagentCount >= reagentCount then
							name:SetTextColor(r, g, b)
						else
							name:SetTextColor(0.5, 0.5, 0.5)
						end
					end
				else
					if icon and icon.__bg then
						icon.__bg:SetBackdropBorderColor(0, 0, 0)
					end
				end
			end
		end
	end)
end