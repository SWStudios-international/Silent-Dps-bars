-- Silent DPS Bars (Fixed Initialization Build)
print("Silent DPS Bars: main.lua loaded ✅")

-----------------------------------------------------------
-- Saved Variables
-----------------------------------------------------------
SilentDPSBarsDB = SilentDPSBarsDB or {
    barColor = {r = 0.2, g = 0.6, b = 1, a = 1},
    textColor = {r = 1, g = 1, b = 1, a = 1},
    size = {w = 300, h = 40},
    pos = {x = 0, y = 0}
}

-----------------------------------------------------------
-- Initialization Function
-----------------------------------------------------------
local function InitializeSilentDPSBars()
    print("Silent DPS Bars: Initializing frames...")

    -- MAIN FRAME
    local frame = CreateFrame("Frame", "SilentDPSBarsFrame", UIParent)
    frame:SetSize(SilentDPSBarsDB.size.w, SilentDPSBarsDB.size.h)
    frame:SetPoint("CENTER", UIParent, "CENTER", SilentDPSBarsDB.pos.x, SilentDPSBarsDB.pos.y)
    frame:SetBackdrop({ bgFile = "Interface/Tooltips/UI-Tooltip-Background" })
    frame:SetBackdropColor(0, 0, 0.5, 0.7)
    frame:SetFrameStrata("TOOLTIP")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local _, _, _, x, y = self:GetPoint()
        SilentDPSBarsDB.pos.x, SilentDPSBarsDB.pos.y = x, y
    end)

    -- DPS BAR
    local bar = CreateFrame("StatusBar", nil, frame)
    bar:SetSize(SilentDPSBarsDB.size.w - 10, 20)
    bar:SetPoint("CENTER", 0, 0)
    bar:SetStatusBarTexture("Interface/TargetingFrame/UI-StatusBar")
    bar:SetStatusBarColor(0.2, 0.8, 1, 1)
    bar:SetMinMaxValues(0, 1)
    bar:SetValue(0)

    -- TEXT
    bar.text = bar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    bar.text:SetPoint("CENTER")
    bar.text:SetTextColor(1, 1, 1)
    bar.text:SetText("Silent DPS Bars Ready")

    frame:Show()

    -----------------------------------------------------------
    -- COMBAT TRACKING
    -----------------------------------------------------------
    local combatStart, totalDamage, lastUpdate = 0, 0, 0
    local inCombat = false

    local function updateBar()
        if not inCombat then return end
        local elapsed = GetTime() - combatStart
        local dps = (elapsed > 0) and (totalDamage / elapsed) or 0
        local pct = math.min(dps / 100000, 1)
        bar:SetValue(pct)
        bar.text:SetText(string.format("DPS: %.1f", dps))
    end

    frame:SetScript("OnUpdate", function(_, elapsed)
        lastUpdate = lastUpdate + elapsed
        if lastUpdate > 1 then
            lastUpdate = 0
            updateBar()
        end
    end)

    -----------------------------------------------------------
    -- EVENTS
    -----------------------------------------------------------
    frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

    frame:SetScript("OnEvent", function(_, event)
        if event == "PLAYER_REGEN_DISABLED" then
            totalDamage = 0
            combatStart = GetTime()
            inCombat = true
            bar:SetValue(0)
            bar.text:SetText("Combat Started")
            frame:SetBackdropColor(0, 0.5, 0, 0.7)
            print("Silent DPS Bars: Combat started!")

        elseif event == "PLAYER_REGEN_ENABLED" then
            inCombat = false
            bar.text:SetText("Combat Ended")
            frame:SetBackdropColor(0.5, 0, 0, 0.7)
            print("Silent DPS Bars: Combat ended!")

        elseif event == "COMBAT_LOG_EVENT_UNFILTERED" and inCombat then
            local info = { CombatLogGetCurrentEventInfo() }
            local subevent = info[2]
            local sourceName = info[5]
            if sourceName == UnitName("player") then
                local amount = tonumber(info[12]) or tonumber(info[13]) or tonumber(info[15]) or tonumber(info[16]) or 0
                if subevent == "SWING_DAMAGE" or subevent == "SPELL_DAMAGE" or subevent == "RANGE_DAMAGE" then
                    totalDamage = totalDamage + amount
                end
            end
        end
    end)

    -----------------------------------------------------------
    -- SLASH COMMAND
    -----------------------------------------------------------
    SLASH_SILENTDPSBARS1 = "/sdb"
    SlashCmdList["SILENTDPSBARS"] = function()
        print("|cff00ffffSilent DPS Bars|r active. Drag the bar to reposition.")
        frame:Show()
    end

    print("Silent DPS Bars: Initialization complete ✅")
end

-----------------------------------------------------------
-- Load Event Hook
-----------------------------------------------------------
local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", InitializeSilentDPSBars)
