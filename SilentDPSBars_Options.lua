-- Silent DPS Bars - Options (Retail + Classic safe)
-- Adds RGB color customization and opacity control

local addonName, SDB = ...
local optionsFrame

SilentDPSBarsDB = SilentDPSBarsDB or {}
SilentDPSBarsDB.colors = SilentDPSBarsDB.colors or {
    dps = {1, 0.8, 0},
    hps = {0, 1, 0},
    bg  = {0.1, 0.1, 0.1, 0.7},
}

----------------------------------------------------------
-- Helper to update frame colors live
----------------------------------------------------------
local function ApplyBarColors()
    if not SDB.frame then return end
    local dpsR, dpsG, dpsB = unpack(SilentDPSBarsDB.colors.dps)
    local hpsR, hpsG, hpsB = unpack(SilentDPSBarsDB.colors.hps)
    local bgR, bgG, bgB, bgA = unpack(SilentDPSBarsDB.colors.bg)

    SDB.frame.dpsBar:SetStatusBarColor(dpsR, dpsG, dpsB, 1)
    SDB.frame.hpsBar:SetStatusBarColor(hpsR, hpsG, hpsB, 1)
    SDB.frame:SetBackdropColor(bgR, bgG, bgB, bgA)
end

----------------------------------------------------------
-- Create the options panel
----------------------------------------------------------
local function CreateOptionsPanel()
    if optionsFrame then return optionsFrame end

    optionsFrame = CreateFrame("Frame", "SilentDPSBarsOptionsPanel", UIParent)
    optionsFrame.name = "Silent DPS Bars"

    local title = optionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Silent DPS Bars Settings")

    local subtext = optionsFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    subtext:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subtext:SetText("Customize colors and opacity for your DPS/HPS bars.")

    ------------------------------------------------------
    -- Background Opacity Slider
    ------------------------------------------------------
    local alphaSlider = CreateFrame("Slider", "SDBAlphaSlider", optionsFrame, "OptionsSliderTemplate")
    alphaSlider:SetPoint("TOPLEFT", subtext, "BOTTOMLEFT", 0, -40)
    alphaSlider:SetMinMaxValues(0, 1)
    alphaSlider:SetValueStep(0.05)
    alphaSlider:SetObeyStepOnDrag(true)
    alphaSlider:SetWidth(200)
    alphaSlider:SetValue(SilentDPSBarsDB.colors.bg[4] or 0.7)
    _G[alphaSlider:GetName() .. "Low"]:SetText("0")
    _G[alphaSlider:GetName() .. "High"]:SetText("1")
    _G[alphaSlider:GetName() .. "Text"]:SetText("Background Opacity")

    alphaSlider:SetScript("OnValueChanged", function(self, value)
        SilentDPSBarsDB.colors.bg[4] = value
        ApplyBarColors()
    end)

    ------------------------------------------------------
    -- RGB Color Sliders Helper
    ------------------------------------------------------
    local function CreateRGBSliders(labelText, colorTable, offsetY, callback)
        local frame = CreateFrame("Frame", nil, optionsFrame)
        frame:SetPoint("TOPLEFT", subtext, "BOTTOMLEFT", 0, offsetY)
        frame:SetSize(300, 80)

        local label = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        label:SetPoint("TOPLEFT", 0, 0)
        label:SetText(labelText)

        local colors = {"R", "G", "B"}
        for i, key in ipairs(colors) do
            local slider = CreateFrame("Slider", nil, frame, "OptionsSliderTemplate")
            slider:SetPoint("TOPLEFT", 0, -20 * i)
            slider:SetMinMaxValues(0, 1)
            slider:SetValueStep(0.01)
            slider:SetWidth(200)
            slider:SetObeyStepOnDrag(true)
            slider:SetValue(colorTable[i] or 1)
            _G[slider:GetName() .. "Low"]:SetText("0")
            _G[slider:GetName() .. "High"]:SetText("1")
            _G[slider:GetName() .. "Text"]:SetText(key)

            slider:SetScript("OnValueChanged", function(_, val)
                colorTable[i] = val
                if callback then callback() end
            end)
        end
    end

    ------------------------------------------------------
    -- DPS / HPS / Background color sliders
    ------------------------------------------------------
    CreateRGBSliders("DPS Bar Color", SilentDPSBarsDB.colors.dps, -140, ApplyBarColors)
    CreateRGBSliders("HPS Bar Color", SilentDPSBarsDB.colors.hps, -260, ApplyBarColors)
    CreateRGBSliders("Background Color", SilentDPSBarsDB.colors.bg, -380, ApplyBarColors)

    return optionsFrame
end

----------------------------------------------------------
-- Register with WoW’s settings system
----------------------------------------------------------
local function RegisterOptions()
    local panel = CreateOptionsPanel()

    if Settings and Settings.RegisterAddOnCategory then
        local category = Settings.RegisterCanvasLayoutCategory(panel, "Silent DPS Bars")
        category.ID = "Silent DPS Bars"
        Settings.RegisterAddOnCategory(category)
    else
        InterfaceOptions_AddCategory(panel)
    end
end

----------------------------------------------------------
-- Slash Command Hook
----------------------------------------------------------
SLASH_SDB1 = "/sdb"
SlashCmdList["SDB"] = function(msg)
    msg = string.lower(msg or "")
    if msg == "ui" then
        RegisterOptions()
        if Settings and Settings.OpenToCategory then
            Settings.OpenToCategory("Silent DPS Bars")
        else
            InterfaceOptionsFrame_OpenToCategory("Silent DPS Bars")
        end
    elseif msg == "show" and SDB.frame then
        SDB.frame:Show()
    elseif msg == "hide" and SDB.frame then
        SDB.frame:Hide()
    elseif msg == "reset" and SDB.frame then
        SilentDPSBarsDB.pos = {x = 0, y = 0}
        SDB.frame:ClearAllPoints()
        SDB.frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    else
        print("Silent DPS Bars Commands:")
        print("/sdb show  - show frame")
        print("/sdb hide  - hide frame")
        print("/sdb reset - center frame")
        print("/sdb ui    - open settings window")
    end
end

----------------------------------------------------------
-- Auto-register on load
----------------------------------------------------------
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(_, _, name)
    if name == addonName then
        RegisterOptions()
    end
end)
--========================================================
-- Settings Registration for Retail API (10.0+)
--========================================================
local function RegisterSilentDPSBarsOptions()
    -- create a dummy frame if not already created
    if not SilentDPSBarsOptionsFrame then
        local f = CreateFrame("Frame", "SilentDPSBarsOptionsFrame", UIParent)
        f.name = "Silent DPS Bars"
        local title = f:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
        title:SetPoint("TOPLEFT", 16, -16)
        title:SetText("Silent DPS Bars")
        local sub = f:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        sub:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
        sub:SetText("Configuration coming soon. Use /sdb commands for now.")
    end

    -- register in new settings system (Retail)
    if Settings and Settings.RegisterAddOnCategory then
        local category = Settings.RegisterCanvasLayoutCategory(SilentDPSBarsOptionsFrame, "Silent DPS Bars")
        category.ID = "Silent DPS Bars"
        Settings.RegisterAddOnCategory(category)
        print("|cff00ff00Silent DPS Bars|r: Settings registered in AddOns menu.")
    else
        -- Classic fallback
        InterfaceOptions_AddCategory(SilentDPSBarsOptionsFrame)
    end
end

-- register once ADDON_LOADED fires
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(_, _, name)
    if name == "SilentDPSBars" then
        RegisterSilentDPSBarsOptions()
    end
end)
