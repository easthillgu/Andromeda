local F, C = unpack(select(2, ...))
local UNITFRAME = F:GetModule('UnitFrame')
local oUF = F.Libs.oUF

-- 3.80.1: Portrait material is provided by __bg (F.SetBD → CreateTex → BackdropStripes)
-- This dummy texture satisfies oUF's Portrait element requirement
function UNITFRAME:CreatePortrait(self)
    local portrait = self:CreateTexture(nil, 'BACKGROUND', nil, -1)
    portrait:Hide()
    portrait.customTexture = true
    self.Portrait = portrait
end

function UNITFRAME:UpdatePortrait()
    for _, frame in pairs(oUF.objects) do
        if C.DB.Unitframe.Portrait then
            if not frame:IsElementEnabled('Portrait') then
                frame:EnableElement('Portrait')
            end
        else
            if frame:IsElementEnabled('Portrait') then
                frame:DisableElement('Portrait')
            end
        end
    end
end
