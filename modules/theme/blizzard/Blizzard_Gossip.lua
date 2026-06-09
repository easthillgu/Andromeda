local F, C = unpack(select(2, ...))

tinsert(C.BlizzThemes, function()
    local gossipFrame = _G.GossipFrame
    if not gossipFrame then return end

    F.StripTextures(gossipFrame)
    F.SetBD(gossipFrame)

    -- Close button
    if gossipFrame.CloseButton then
        F.ReskinClose(gossipFrame.CloseButton)
    end

    -- Greeting panel
    local greetingPanel = gossipFrame.GreetingPanel
    if greetingPanel then
        F.StripTextures(greetingPanel)
        F.CreateBDFrame(greetingPanel)

        -- Scroll bar
        if greetingPanel.ScrollBar then
            F.ReskinTrimScroll(greetingPanel.ScrollBar)
        end

        -- Goodbye button
        if greetingPanel.GoodbyeButton then
            F.ReskinButton(greetingPanel.GoodbyeButton)
        end

        -- Process greeting buttons for text color
        if greetingPanel.ScrollBox then
            hooksecurefunc(greetingPanel.ScrollBox, 'Update', function(scrollBox)
                scrollBox:ForEachFrame(function(button)
                    if not button._andmSkinned then
                        if button.GreetingText then
                            button.GreetingText:SetTextColor(1, 1, 1)
                        end

                        local fontString = button.GetFontString and button:GetFontString()
                        if fontString then
                            fontString:SetTextColor(1, 1, 1)
                        end

                        button._andmSkinned = true
                    end
                end)
            end)
        end
    end

    -- ItemText frame (quest item pages)
    local itemTextFrame = _G.ItemTextFrame
    if itemTextFrame then
        F.StripTextures(itemTextFrame)
        F.CreateBDFrame(itemTextFrame)

        if _G.ItemTextScrollFrame then
            _G.ItemTextScrollFrame:DisableDrawLayer('ARTWORK')
            _G.ItemTextScrollFrame:DisableDrawLayer('BACKGROUND')
        end

        if _G.ItemTextScrollFrameScrollBar then
            F.ReskinScroll(_G.ItemTextScrollFrameScrollBar)
        end

        -- Next/Prev page buttons
        if _G.ItemTextNextPageButton then
            F.ReskinArrow(_G.ItemTextNextPageButton, 'right')
        end
        if _G.ItemTextPrevPageButton then
            F.ReskinArrow(_G.ItemTextPrevPageButton, 'left')
        end

        -- Close button
        if _G.ItemTextFrameCloseButton then
            F.ReskinClose(_G.ItemTextFrameCloseButton)
        end
    end

    -- Parchment remover (Andromeda style: hide parchment textures)
    if _G.ItemTextMaterialBotLeft then
        _G.ItemTextMaterialBotLeft:SetAlpha(0)
        _G.ItemTextMaterialBotRight:SetAlpha(0)
        _G.ItemTextMaterialTopLeft:SetAlpha(0)
        _G.ItemTextMaterialTopRight:SetAlpha(0)
    end

    if _G.QuestFont then
        _G.QuestFont:SetTextColor(1, 1, 1)
    end

    if gossipFrame.Background then
        gossipFrame.Background:Hide()
    end
end)
