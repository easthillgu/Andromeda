local F, C = unpack(select(2, ...))

-- 3.80.1: adapted from NDui approach — hook InitButtons + buttonPool
C.Themes['Blizzard_GameMenu'] = nil
do
    local function skinMenu()
        if not _G.ANDROMEDA_ADB.ReskinBlizz then return end
        local GameMenuFrame = _G.GameMenuFrame
        F.StripTextures(GameMenuFrame.Header)
        F.SetBD(GameMenuFrame)
        GameMenuFrame.Border:Hide()

        hooksecurefunc(GameMenuFrame, 'InitButtons', function(self)
            if not self.buttonPool then return end
            for button in self.buttonPool:EnumerateActive() do
                if not button.styled then
                    F.ReskinButton(button)
                    button.styled = true
                end
            end
        end)
    end
    if _G.GameMenuFrame then skinMenu() else F.RegisterEvent('PLAYER_LOGIN', skinMenu) end
end
