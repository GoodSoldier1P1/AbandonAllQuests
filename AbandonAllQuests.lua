print("Loaded AbandonAllQuests.lua")

local addonName = "AbandonAllQuests"
local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")

-- Helper: abandon all quests
local function AbandonAllQuests()
    local numEntries = GetNumQuestLogEntries()
    for i = numEntries, 1, -1 do
        local title, _, _, isHeader = GetQuestLogTitle(i)
        if not isHeader then
            SelectQuestLogEntry(i)
            SetAbandonQuest()
            AbandonQuest()
            print("Abandoned quest: " .. (title or "Unknown Quest"))
        end
    end
end

-- Confirmation popup
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

-- LDB Minimap Button
local minimapLauncher = LDB:NewDataObject(addonName, {
    type = "launcher",
    text = "Abandon All Quests",
    icon = "Interface\\AddOns\\AbandonAllQuests\\AbandonAllQuests.tga", -- path to icon file

    OnClick = function(_, button)
        if button == "LeftButton" then
            StaticPopup_Show("CONFIRM_ABANDON_ALL_QUESTS")
        elseif button == "RightButton" then
            -- Just show the panel manually
            if settingsPanel then
                InterfaceOptionsFrame_OpenToFrame(settingsPanel) -- This might still fail...
                ShowUIPanel(settingsPanel) -- This works if the above fails
            end
        end
    end,    
       

    OnTooltipShow = function(tooltip)
        tooltip:AddLine("Abandon All Quests")
        tooltip:AddLine("Left-Click: Abandon all quests")
        tooltip:AddLine("Right-Click: Open settings (coming soon)")
    end,
})

-- Slash commands (global)
local buttonVisible = true
SLASH_ABANDONALL1 = "/abandonall"
SLASH_ABANDONALL2 = "/aaq"
SlashCmdList["ABANDONALL"] = function(msg)
    msg = msg:lower()
    if msg == "togglebutton" or msg == "tb" then
        buttonVisible = not buttonVisible
        if abandonButton and QuestLogFrame:IsShown() then
            if buttonVisible then abandonButton:Show() else abandonButton:Hide() end
        end
        print("Abandon All Quests button is now " .. (buttonVisible and "visible" or "hidden") .. ".")
    elseif msg == "" then
        StaticPopup_Show("CONFIRM_ABANDON_ALL_QUESTS")
    else
        print("|cffffcc00[AbandonAllQuests]|r Unknown command. Try:")
        print("/abandonall or /aaq — Confirm and abandon all quests.")
        print("/abandonall togglebutton or /aaq tb — Toggle the button visibility.")
    end
end

-- Addon loaded handler
local abandonButton
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(_, event, name)
    if name ~= addonName then return end

    -- Saved vars
    if not AAQDB then AAQDB = {} end
    if AAQDB.minimap == nil then AAQDB.minimap = { hide = false } end

    -- Register minimap icon
    if not LDBIcon:IsRegistered(addonName) then
        LDBIcon:Register(addonName, minimapLauncher, AAQDB.minimap)
    end

    -- Create quest log button
    abandonButton = CreateFrame("Button", "AbandonAllQuestsButton", QuestLogFrame, "UIPanelButtonTemplate")
    abandonButton:SetSize(160, 25)
    abandonButton:SetText("Abandon All Quests")
    abandonButton:SetPoint("TOPRIGHT", -150, -40)
    abandonButton:SetScript("OnClick", function()
        StaticPopup_Show("CONFIRM_ABANDON_ALL_QUESTS")
    end)
    abandonButton:Hide()

    QuestLogFrame:HookScript("OnShow", function()
        if buttonVisible then abandonButton:Show() end
    end)
    QuestLogFrame:HookScript("OnHide", function()
        abandonButton:Hide()
    end)

    print("Abandon All Quests addon loaded. Use /abandonall or click the minimap icon.")
end)


-- Create Settings Panel
local settingsPanel = CreateFrame("Frame", "AbandonAllQuestsOptionsPanel", UIParent)
settingsPanel.name = "Abandon All Quests"

local title = settingsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("Abandon All Quests")

-- Checkbox (we'll init it later after ADDON_LOADED)
local checkbox = CreateFrame("CheckButton", "AAQ_ShowMinimapCheckbox", settingsPanel, "InterfaceOptionsCheckButtonTemplate")
checkbox:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -10)
checkbox.Text:SetText("Show Minimap Button")

-- Register panel early so it's in Interface -> AddOns
InterfaceOptions_AddCategory(settingsPanel)

-- Hook this into ADDON_LOADED block
f:HookScript("OnEvent", function(_, _, name)
    if name ~= addonName then return end

    -- Safe checkbox init after vars are loaded
    checkbox:SetChecked(not AAQDB.minimap.hide)
    checkbox:SetScript("OnClick", function(self)
        local checked = self:GetChecked()
        AAQDB.minimap.hide = not checked
        if checked then
            LDBIcon:Show(addonName)
        else
            LDBIcon:Hide(addonName)
        end
    end)
end)


SLASH_AAQ1 = "/aaq"
SlashCmdList["AAQ"] = function(msg)
    print("Abandon All Quests addon is working. Message: " .. msg)
end


-- Create options panel frame
local settingsPanel = CreateFrame("Frame", "AbandonAllQuestsSettingsPanel", UIParent)
settingsPanel.name = "Abandon All Quests"

local title = settingsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("Abandon All Quests")

-- Add it to the Interface Options
InterfaceOptions_AddCategory(settingsPanel)

