-- Party Frame Module
-- Note: Party frame implementation is located in units.lua
-- This file is kept for module structure consistency

local F, C = unpack(select(2, ...))
local UNITFRAME = F:GetModule('UnitFrame')

-- Party frame spawning and configuration functions are defined in:
-- modules/unitframe/units.lua
--
-- Key functions:
-- - UNITFRAME:SpawnParty() - Creates party frames
-- - UNITFRAME:CreateAndUpdatePartyHeader() - Updates party header configuration
-- - UNITFRAME:UpdatePartyElements() - Updates party frame elements
-- - UNITFRAME:UpdateAllHeaders() - Updates all header visibility
--
-- Party frame elements (defined in elements/ folder):
-- - CreateBackdrop, CreateHealthBar, CreatePowerBar
-- - CreatePortrait, CreateHealPrediction
-- - CreatePartyWatcher, CreateRaidAuras
-- - CreateTargetBorder, CreateThreatBorder
-- - CreateRangeCheck, CreateClickSets
-- - CreateRaidTargetIndicator, CreateReadyCheckIndicator
-- - CreateResurrectIndicator, CreateGroupRoleTag
-- - CreateGroupLeaderTag, CreatePhaseIndicator
-- - CreateSummonIndicator, CreateGroupNameTag