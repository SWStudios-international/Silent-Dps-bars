-- DPSBARS ADDON FOR WOW
-- Main.lua

-- Initialize or load saved settings
SilentDPSBarsDB = SilentDPSBarsDB or {
    barColor = {r=0, g=0, b=0, a=0.3},
    textColor = {r=1, g=1, b=1},
    size = {w=200, h=70},
    pos = {x=0, y=0}
}

-- yay a window
local frame = CreateFrame("Frame", "SilentDPSBarsFrame", UIParent)
frame:SetSize(SilentDPSBarsDB.size.w, SilentDPSBarsDB.size.h)
frame:SetPoint("CENTER", UIParent, "CENTER", SilentDPSBarsDB.pos.x, SilentDPSBarsDB.pos.y)
frame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background"})
frame:SetBackdropColor(
    SilentDPSBarsDB.barColor.r,
    SilentDPSBarsDB.barColor.g,
    SilentDPSBarsDB.barColor.b,
    SilentDPSBarsDB.barColor.a
)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local _, _, _, x, y = self:GetPoint()
    SilentDPSBarsDB.pos.x, SilentDPSBarsDB.pos.y = x, y
end)

-- Textfonts
frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
frame.text:SetPoint("CENTER")
frame.text:SetTextColor(
    SilentDPSBarsDB.textColor.r,
    SilentDPSBarsDB.textColor.g,
    SilentDPSBarsDB.textColor.b,
    1
)
frame.text:SetText("Silent DPS Bars\nDPS: 0 | HPS: 0 | Misses: 0")

-- a list of variables I think they're called
local combatStart, totalDamage, totalHealing, totalMisses = 0, 0, 0, 0
local inCombat, paused = false, false

-- other things
local function updateDisplay()
    local elapsed = (inCombat and (GetTime() - combatStart)) or 1
    local dps = totalDamage / elapsed
    local hps = totalHealing / elapsed
    frame.text:SetText(string.format("Silent DPS Bars\nDPS: %.1f | HPS: %.1f | Misses: %d", dps, hps, totalMisses))
end

local function applyColors()
    frame:SetBackdropColor(
        SilentDPSBarsDB.barColor.r,
        SilentDPSBarsDB.barColor.g,
        SilentDPSBarsDB.barColor.b,
        SilentDPSBarsDB.barColor.a
    )
    frame.text:SetTextColor(
        SilentDPSBarsDB.textColor.r,
        SilentDPSBarsDB.textColor.g,
        SilentDPSBarsDB.textColor.b,
        1
    )
end

-- Events
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

frame:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_REGEN_DISABLED" then
        totalDamage, totalHealing, totalMisses = 0, 0, 0
        combatStart = GetTime()
        inCombat, paused = true, false
        frame:Show()
    elseif event == "PLAYER_REGEN_ENABLED" then
        paused, inCombat = true, false
        frame.text:SetText("Silent DPS Bars\n(Combat paused)")
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" and inCombat then
        local _, subevent, _, sourceGUID, _, _, _, _, _, _, _, spellID, _, _, amount =
            CombatLogGetCurrentEventInfo()
        if sourceGUID == UnitGUID("player") then
            if subevent == "SWING_DAMAGE" then
                totalDamage = totalDamage + (amount or 0)
            elseif subevent == "SPELL_DAMAGE" or subevent == "RANGE_DAMAGE" then
                totalDamage = totalDamage + (amount or 0)
            elseif subevent == "SPELL_HEAL" then
                totalHealing = totalHealing + (amount or 0)
            elseif subevent == "SWING_MISSED" or subevent == "SPELL_MISSED" or subevent == "RANGE_MISSED" then
                totalMisses = totalMisses + 1
            end
            updateDisplay()
        end
    end
end)

-- Slash commands
SLASH_SILENTDPSBARS1 = "/sdb"
SlashCmdList["SILENTDPSBARS"] = function(msg)
    local cmd, a, b, c = strsplit(" ", msg)
    cmd = string.lower(cmd or "")
    if cmd == "reset" then
        totalDamage, totalHealing, totalMisses = 0, 0, 0
        frame.text:SetText("Silent DPS Bars\nDPS: 0 | HPS: 0 | Misses: 0")
        print("|cff00ff00Silent DPS Bars reset.|r")
    elseif cmd == "color" then
        SilentDPSBarsDB.barColor.r, SilentDPSBarsDB.barColor.g, SilentDPSBarsDB.barColor.b = tonumber(a) or 0, tonumber(b) or 0, tonumber(c) or 0
        applyColors()
        print("|cff00ff00Background color updated.|r")
    elseif cmd == "textcolor" then
        SilentDPSBarsDB.textColor.r, SilentDPSBarsDB.textColor.g, SilentDPSBarsDB.textColor.b = tonumber(a) or 1, tonumber(b) or 1, tonumber(c) or 1
        applyColors()
        print("|cff00ff00Text color updated.|r")
    elseif cmd == "alpha" then
        SilentDPSBarsDB.barColor.a = tonumber(a) or 0.3
        applyColors()
        print("|cff00ff00Transparency set to " .. SilentDPSBarsDB.barColor.a .. "|r")
    elseif cmd == "size" then
        local w, h = tonumber(a), tonumber(b)
        if w and h then
            frame:SetSize(w, h)
            SilentDPSBarsDB.size.w, SilentDPSBarsDB.size.h = w, h
            print(string.format("|cff00ff00Frame resized to %dx%d.|r", w, h))
        else
            print("|cffff0000Usage: /sdb size width height|r")
        end
    elseif cmd == "hide" then
        frame:Hide()
    elseif cmd == "show" then
        frame:Show()
    else
        print("|cff00ff00Silent DPS Bars commands:|r")
        print("/sdb reset - reset stats")
        print("/sdb color R G B - change background color (0-1)")
        print("/sdb textcolor R G B - change text color (0-1)")
        print("/sdb alpha A - set transparency (0-1)")
        print("/sdb size W H - resize frame")
        print("/sdb hide or /sdb show - toggle visibility")
    end
end
