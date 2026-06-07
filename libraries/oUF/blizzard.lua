local _, ns = ...
local oUF = ns.oUF

local wipe, next, type = wipe, next, type
local hooksecurefunc = hooksecurefunc

local InCombatLockdown = InCombatLockdown
local _G = _G

-- sourced from Blizzard_UnitFrame/TargetFrame.lua
local MAX_BOSS_FRAMES = 5 -- blizzard can spawn more than the default 5 apparently

-- sourced from Blizzard_FrameXMLBase/Shared/Constants.lua
local MEMBERS_PER_RAID_GROUP = MEMBERS_PER_RAID_GROUP or 5

-- sourced from Blizzard_CompactRaidFrames/CompactRaidFrameManager.lua
local CompactRaidFrameManager_SetSetting = CompactRaidFrameManager_SetSetting

local hookedFrames = {}
local hookedNameplates = {}
local isArenaHooked = false
local isBossHooked = false
local isPartyHooked = false

local hiddenParent = CreateFrame('Frame', nil, UIParent)
hiddenParent:SetAllPoints()
hiddenParent:Hide()

-- local function insecureHide(self)
-- 	self:Hide()
-- end

local looseFrames = {}

local watcher = CreateFrame('Frame')
watcher:RegisterEvent('PLAYER_REGEN_ENABLED')
watcher:SetScript('OnEvent', function()
	for frame in next, looseFrames do
		frame:SetParent(hiddenParent)
	end

	wipe(looseFrames)
end)

local function resetParent(self, parent)
	if(parent ~= hiddenParent) then
		if(InCombatLockdown() and self:IsProtected()) then
			looseFrames[self] = true
		else
			self:SetParent(hiddenParent)
		end
	end
end

local function handleFrame(baseName, doNotReparent, isNamePlate)
	local frame
	if(type(baseName) == 'string') then
		frame = _G[baseName]
	else
		frame = baseName
	end

	if(frame) then
		-- 跳过所有 CompactRaid 和 CompactParty 框架，避免干扰其正常工作
		local frameName = frame.GetName and frame:GetName()
		if frameName and (frameName:find('CompactRaid') or frameName:find('CompactParty')) then
			-- 为这些框架添加安全的空方法，防止 Blizzard 代码调用时出错
			frame.Show = function() end
			frame.SetSize = function() end
			frame.UpdateHeight = function() end
			frame.UpdateWidth = function() end
			frame.UpdateSize = function() end
			return
		end

		frame:UnregisterAllEvents()
		if(isNamePlate) then
			-- TODO: remove this once we can adjust hitrects for nameplates
			frame:SetAlpha(0)
		end
		
		-- 为框架添加安全的空方法，避免 Blizzard 的代码调用时出错
		if not frame.UpdateHeight then
			frame.UpdateHeight = function() end
		end
		if not frame.UpdateWidth then
			frame.UpdateWidth = function() end
		end
		if not frame.UpdateSize then
			frame.UpdateSize = function() end
		end

		if(not doNotReparent) then
			-- 使用 pcall 安全设置父框架
			local success, err = pcall(function()
				frame:SetParent(hiddenParent)
			end)
			if not success then
				-- 如果失败，尝试设置为不可见
				pcall(function() frame:SetAlpha(0) end)
			end

			if(not hookedFrames[frame]) then
				hooksecurefunc(frame, 'SetParent', resetParent)

				hookedFrames[frame] = true
			end
		end

		local health = frame.healthBar or frame.healthbar or frame.HealthBar or (frame.HealthBarsContainer and frame.HealthBarsContainer.healthBar)
		if(health) then
			health:UnregisterAllEvents()
		end

		local power = frame.manabar or frame.ManaBar
		if(power) then
			power:UnregisterAllEvents()
		end

		local castbar = frame.castBar or frame.spellbar or frame.CastingBarFrame
		if(castbar) then
			castbar:UnregisterAllEvents()
		end

		local altpowerbar = frame.powerBarAlt or frame.PowerBarAlt
		if(altpowerbar) then
			altpowerbar:UnregisterAllEvents()
		end

		local buffFrame = frame.BuffFrame or frame.AurasFrame
		if(buffFrame) then
			buffFrame:UnregisterAllEvents()
		end

		local petFrame = frame.petFrame or frame.PetFrame
		if(petFrame) then
			petFrame:UnregisterAllEvents()
		end

		local totFrame = frame.totFrame
		if(totFrame) then
			totFrame:UnregisterAllEvents()
		end

		local classPowerBar = frame.classPowerBar
		if(classPowerBar) then
			classPowerBar:UnregisterAllEvents()
		end

		local ccRemoverFrame = frame.CcRemoverFrame
		if(ccRemoverFrame) then
			ccRemoverFrame:UnregisterAllEvents()
		end

		local debuffFrame = frame.DebuffFrame
		if(debuffFrame) then
			debuffFrame:UnregisterAllEvents()
		end
	end
end

function oUF:DisableBlizzard(unit)
	if(not unit) then return end

	if(unit == 'player') then
		handleFrame(_G.PlayerFrame)
	elseif(unit == 'pet') then
		handleFrame(_G.PetFrame)
	elseif(unit == 'target') then
		handleFrame(_G.TargetFrame)
	elseif(unit == 'focus') then
		handleFrame(_G.FocusFrame)
	elseif(unit:match('boss%d?$')) then
		if(not isBossHooked) then
			isBossHooked = true

			-- it's needed because the layout manager can bring frames that are
			-- controlled by containers back from the dead when a user chooses
			-- to revert all changes
			-- for now I'll just reparent it, but more might be needed in the
			-- future, watch it
			handleFrame(_G.BossTargetFrameContainer)

			-- do not reparent frames controlled by containers, the vert/horiz
			-- layout code will go insane because it won't be able to calculate
			-- the size properly, 0 or negative sizes in turn will break the
			-- layout manager, fun...
			for i = 1, MAX_BOSS_FRAMES do
				handleFrame('Boss' .. i .. 'TargetFrame', true)
			end
		end
	elseif(unit:match('party%d?$')) then
		if(not isPartyHooked) then
			isPartyHooked = true

			-- 在 WoW Wrath Classic 中，_G.PartyFrame 可能不存在
			-- 团队框架由 CompactRaidFrameManager 管理
			if _G.PartyFrame then
				handleFrame(_G.PartyFrame)

				for frame in _G.PartyFrame.PartyMemberFramePool:EnumerateActive() do
					handleFrame(frame, true)
				end
			end

			-- CompactPartyFrame 由 DisableBlizzardRaid() 统一处理
		end
	elseif(unit:match('arena%d?$')) then
		if(not isArenaHooked) then
			isArenaHooked = true

			if _G.CompactArenaFrame then
				handleFrame(_G.CompactArenaFrame)

				for _, frame in next, _G.CompactArenaFrame.memberUnitFrames do
					handleFrame(frame, true)
				end
			end
		end
	end
end

-- 参考 NDui 的实现方式来隐藏 Blizzard Raid 框架
function oUF:DisableBlizzardRaid()
    -- 使用官方 API 隐藏管理器
    if CompactRaidFrameManager_SetSetting then
        CompactRaidFrameManager_SetSetting("IsShown", "0")
    end
    
    -- 隐藏 CompactRaidFrameManager
    if _G.CompactRaidFrameManager then
        _G.CompactRaidFrameManager:UnregisterAllEvents()
        _G.CompactRaidFrameManager:Hide()
        _G.CompactRaidFrameManager.Show = function() end
    end
    
    -- 隐藏 CompactRaidFrames
    if _G.CompactRaidFrameContainer then
        _G.CompactRaidFrameContainer:UnregisterAllEvents()
        _G.CompactRaidFrameContainer:Hide()
        _G.CompactRaidFrameContainer.Show = function() end
    end
    
    -- 隐藏 CompactPartyFrame
    if _G.CompactPartyFrame then
        _G.CompactPartyFrame:UnregisterAllEvents()
        _G.CompactPartyFrame:Hide()
        _G.CompactPartyFrame.Show = function() end
    end
end

function oUF:DisableBlizzardNamePlate(frame)
	if(not(frame and frame.UnitFrame)) then return end
	if(frame.UnitFrame:IsForbidden()) then return end

	if(not hookedNameplates[frame]) then
		-- BUG: the hit rect (for clicking) is tied to the original UnitFrame object on the
		--      nameplate, so we can't hide it. instead we force it to be invisible, and adjust
		--      the hit rect insets around it so it matches the nameplate object itself, but we
		--      do that in SpawnNamePlates instead
		-- TODO: remove this hack once we can adjust hitrects ourselves, coming in a later build
		local locked = false
		hooksecurefunc(frame.UnitFrame, 'SetAlpha', function(UnitFrame)
			if(locked or UnitFrame:IsForbidden()) then return end
			locked = true
			UnitFrame:SetAlpha(0)
			locked = false
		end)

		hookedNameplates[frame] = true
	end

	handleFrame(frame.UnitFrame, true, true)
end