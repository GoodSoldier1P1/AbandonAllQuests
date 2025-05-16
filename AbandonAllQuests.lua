local addonName = "AbandonAllQuests"

-- Helper function to abandon all quests
local function AbandonAllQuests()
    local numEntries = GetNumQuestLogEntries()
    for i = numEntries, 1, -1 do
        local title, _, _, isHeader = GetQuestLogTitle(i)
        if not isHeader then
            SelectQuestLogEntry(i)
            SetAbandonQuest()
            AbandonQuest()
            print("Abandoned quest: " .. (title or "Unknown Quests"))
        end
    end
end


-- Popup Dialog for Confirmation
StaticPopupDialogs["CONFIRM_ABANDON_ALL_QUESTS"] = {
    text = "Are you absolutely sure you want to abandon ALL quests?\nThis cannot be undone.",
    button1 = "Yes, Abandon All!",
    button2 = "NO! I Want My Quests! (Cancel)",
    OnAccept = AbandonAllQuests,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

-- Frame to wait for the addon to load
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")

local abandonButton -- Forward Declare So We Can Toggle It
local buttonVisible = true -- Button Shown By Default

f:SetScript("OnEvent", function(self, event, name)
    if name ~= addonName then return end
    
    print("Abandon All Quests addon Loaded. Use /abandonall or the button in the Quest Log.")

    -- Create the Button
    abandonButton = CreateFrame("Button", "AbandonAllQuestsButton", QuestLogFrame, "UIPanelButtonTemplate")
    abandonButton:SetSize(160, 25)
    abandonButton:SetText("Abandon All Quests")
    abandonButton:SetPoint("TOPRIGHT", -60, -30)

    abandonButton:SetScript("OnClick", function()
        StaticPopup_Show("CONFIRM_ABANDON_ALL_QUESTS")
    end)


    -- Show/Hide with Quest Log
    abandonButton:Hide()
    QuestLogFrame:HookScript("OnShow", function() if buttonVisible then abandonButton:Show() end end)
    QuestLogFrame:HookScript("OnHide", function() abandonButton:Hide() end)


    -- Slash command to trigger abandon
    SLASH_ABANDON_ALL_1 = "/abandonall"
    SlashCmdList["ABANDONALL"] = function()
        StaticPopup_Show("CONFIRM_ABANDON_ALL_QUESTS")
    end


    -- Slash command to taoggle the button visibility
    SLASH_TOGGLE_AAQ_B1 = "/aaq"
    SlashCmdList["TOGGLEAAQB"] = function(msg)
        msg = msg:lower()
        if msg == "togglebutton" then
            buttonVisible = not buttonVisible
            if buttonVisible and QuestLogFrame:IsShown() then
                abandonButton:Show()
            else
                abandonButton:Hide()
            end
            print("Abandon All Quests button is now " .. (buttonVisible and "visible" or "hidden") .. ".")
        else
            print("Usage: /aaq togglebutton")
        end
    end
end)