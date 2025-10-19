-- Silent DPS Bars - Retail Compatible
local addonName, SDB = ...

-- Namespace
SDB.frame = CreateFrame("Frame")
SDB.bar = nil
SDB.inCombat = false
SDB.totalDamage = 0
SDB.combatStart = 0

-- Initialize after PLAYER_LOGIN
SDB.frame:RegisterEvent("PLAYER_LOGIN")
SDB.frame:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_LOGIN" then
        SDB:Initialize()
    elseif event == "PLAYER_REGEN_DISABLED" then
        SDB:StartCombat()
    elseif event == "PLAYER_REGEN_ENABLED" then
        SDB:EndCombat()
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        SDB:OnCombatLog(CombatLogGetCurrentEventInfo())
    end
end)

-- Create the frame AFTER login
function SDB:Initialize()
    print("Silent DPS Bars initialized ✅")

    local f = CreateFrame("Frame", nil, UIParent)
    f:SetSize(300, 40)
    f:SetPoint("CENTER", 0, -100)
    f:SetBackdrop({ bgFile = "Interface/Tooltips/UI-Tooltip-Background" })
    f:SetBackdropColor(0, 0, 0, 0.7)

    local bar = CreateFrame("StatusBar", nil, f)
    bar:SetAllPoints()
    bar:SetStatusBarTexture("Interface/TargetingFrame/UI-StatusBar")
    bar:SetStatusBarColor(0.1, 0.6, 1)
    bar:SetMinMaxValues(0, 1)
    bar:SetValue(0)

    bar.text = bar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    bar.text:SetPoint("CENTER")
    bar.text:SetText("Waiting for combat...")

    self.bar = bar
    self.frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    self.frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    self.frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function SDB:StartCombat()
    self.totalDamage = 0
    self.combatStart = GetTime()
    self.inCombat = true
    self.bar.text:SetText("Combat started!")
end

function SDB:EndCombat()
    self.inCombat = false
    self.bar.text:SetText("Combat ended")
end

function SDB:OnCombatLog(...)
    if not self.inCombat then return end
    local _, subevent, _, sourceGUID, sourceName, _, _, _, _, _, _, _, _, _, amount = ...
    if sourceName == UnitName("player") then
        if subevent == "SWING_DAMAGE" or subevent == "SPELL_DAMAGE" or subevent == "RANGE_DAMAGE" then
            self.totalDamage = self.totalDamage + (amount or 0)
            local elapsed = GetTime() - self.combatStart
            local dps = self.totalDamage / elapsed
            local pct = math.min(dps / 100000, 1)
            self.bar:SetValue(pct)
            self.bar.text:SetText(string.format("DPS: %.1f", dps))
        end
    end
end
