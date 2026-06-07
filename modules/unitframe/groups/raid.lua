-- Raid Frame Module
-- Note: Raid frame implementation is located in units.lua
-- This file is kept for module structure consistency

local F, C = unpack(select(2, ...))
local UNITFRAME = F:GetModule('UnitFrame')

-- Raid frame spawning and configuration functions are defined in:
-- modules/unitframe/units.lua
--
-- Key functions:
-- - UNITFRAME:SpawnRaid() - Creates raid frames
-- - UNITFRAME:CreateAndUpdateRaidHeader() - Updates raid header configuration
-- - UNITFRAME:UpdateRaidTeamIndex() - Updates team index display
-- - UNITFRAME:UpdateAllHeaders() - Updates all header visibility
--
-- Raid frame elements (defined in elements/ folder):
-- - CreateBackdrop, CreateHealthBar, CreatePowerBar
-- - CreateHealPrediction, CreateRaidAuras
-- - CreateTargetBorder, CreateThreatBorder
-- - CreateRangeCheck, CreateClickSets
-- - CreateRaidTargetIndicator, CreateReadyCheckIndicator
-- - CreateResurrectIndicator, CreateGroupRoleTag
-- - CreateGroupLeaderTag, CreatePhaseIndicator
-- - CreateSummonIndicator, CreateGroupNameTag