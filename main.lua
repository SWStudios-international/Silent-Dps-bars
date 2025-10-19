-- Silent DPS Bars - main.lua
-- Personal DPS/HPS tracker (Retail-safe) V1

local addonName, SDB = ...
print(" **** Silent DPS Bars loaded, waiting for ADDON_LOADED")


local core = CreateFrame("Frame")
core:RegisterEvent("ADDON_LOADED")
core:RegisterEvent("PLAYER_REGEN_DISABLED")
core:RegisterEvent("PLAYER_REGEN_ENABLED")
core:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")


local totalDamage, totalHealing, combatStartTime = 0, 0, 0
local inCombat = false
local updateInterval, timeSinceLastUpdate = 1, 0

----------------------------------------------------------
-- Create Bars
----------------------------------------------------------
local function CreateBar(parent, color)
    local bar = CreateFrame("StatusBar", nil, parent, "BackdropTemplate")
    bar:SetSize(parent:GetWidth() - 10, (parent:GetHeight() / 2) - 5)
    bar:SetStatusBarTexture("Interface/TargetingFrame/UI-StatusBar")
    bar:SetBackdrop({ bgFile = "Interface/DialogFrame/UI-DialogBox-Background" })
    bar:SetBackdropColor(0, 0, 0, 0.7)
    bar:SetStatusBarColor(unpack(color))
    bar:SetMinMaxValues(0, 100)
    bar:SetValue(0)

    bar.text = bar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    bar.text:SetPoint("CENTER")
    bar.text:SetText("0")

    return bar
end

----------------------------------------------------------
-- On Load
----------------------------------------------------------
core:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        print("🟢 ADDON_LOADED fired for:", addonName)

        SilentDPSBarsDB = SilentDPSBarsDB or {}
        local w, h = SDB.GetSize()
        local x, y = SDB.GetPosition()
        local r, g, b, a = SDB.GetColor("barColor")

  
        local f = CreateFrame("Frame", "SilentDPSBarsFrame", UIParent, "BackdropTemplate")
        f:SetSize(w, h)
        f:SetPoint("CENTER", UIParent, "CENTER", x, y)
        f:SetFrameStrata("FULLSCREEN_DIALOG")
        f:SetBackdrop({ bgFile = "Interface/DialogFrame/UI-DialogBox-Background" })
        f:SetBackdropColor(r, g, b, a)
        f:Show()

        
        f.dpsBar = CreateBar(f, {1, 0.8, 0, 1})   
        f.dpsBar:SetPoint("TOP", f, "TOP", 0, -5)
        f.hpsBar = CreateBar(f, {0, 1, 0, 1})     
        f.hpsBar:SetPoint("TOP", f.dpsBar, "BOTTOM", 0, -5)

        SDB.frame = f

        ----------------------------------------------------------
        -- Slash Command Handler
        ----------------------------------------------------------
        SLASH_SDB1 = "/sdb"
        SlashCmdList["SDB"] = function(msg)
            msg = string.lower(msg or "")
            if msg == "hide" then
                f:Hide()
                print(" Silent DPS Bars hidden")
            elseif msg == "show" then
                f:Show()
                print(" Silent DPS Bars shown")
            elseif msg == "reset" then
                SilentDPSBarsDB.pos.x, SilentDPSBarsDB.pos.y = 0, 0
                f:ClearAllPoints()
                f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
                print(" Silent DPS Bars position reset")
            else
                print("|cff00ff00Silent DPS Bars Commands:|r")
                print("/sdb show - show frame")
                print("/sdb hide - hide frame")
                print("/sdb reset - center frame")
            end
        end

        print("Shashaw Silent DPS Bars initialized.")
    end

    ----------------------------------------------------------
    -- Combat State Tracking
    ----------------------------------------------------------
    if event == "PLAYER_REGEN_DISABLED" then
        inCombat = true
        combatStartTime = GetTime()
        totalDamage, totalHealing = 0, 0
    elseif event == "PLAYER_REGEN_ENABLED" then
        inCombat = false
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" and inCombat then
        local _, subEvent, _, srcGUID, _, _, _, _, _, _, _, amount, _, _, _, overheal = CombatLogGetCurrentEventInfo()
        if srcGUID == UnitGUID("player") then
            if subEvent == "SPELL_DAMAGE" or subEvent == "SWING_DAMAGE" or subEvent == "RANGE_DAMAGE" then
                totalDamage = totalDamage + (amount or 0)
            elseif subEvent == "SPELL_HEAL" or subEvent == "SPELL_PERIODIC_HEAL" then
                totalHealing = totalHealing + (amount or 0)
            end
        end
    end
end)

----------------------------------------------------------
-- OnUpdate: refresh bars each second
----------------------------------------------------------
core:SetScript("OnUpdate", function(self, elapsed)
    if not inCombat then return end
    timeSinceLastUpdate = timeSinceLastUpdate + elapsed
    if timeSinceLastUpdate >= updateInterval then
        timeSinceLastUpdate = 0
        local elapsedCombat = GetTime() - combatStartTime
        if elapsedCombat > 0 then
            local dps = totalDamage / elapsedCombat
            local hps = totalHealing / elapsedCombat

            local f = SDB.frame
            if f and f.dpsBar and f.hpsBar then
                f.dpsBar:SetMinMaxValues(0, math.max(1, dps * 1.25))
                f.dpsBar:SetValue(dps)
                f.dpsBar.text:SetText(string.format("DPS: %.1f", dps))

                f.hpsBar:SetMinMaxValues(0, math.max(1, hps * 1.25))
                f.hpsBar:SetValue(hps)
                f.hpsBar.text:SetText(string.format("HPS: %.1f", hps))
            end
        end
    end
end)
