-- Silent DPS Bars - Config.lua
-- Handles saved variables and user settings safely in Retail

-- Make sure our global table exists before we touch it
SilentDPSBarsDB = SilentDPSBarsDB or {}

-- Apply default settings only if they don’t exist yet
local defaults = {
    barColor = { r = 0.1, g = 0.1, b = 0.1, a = 0.6 },
    textColor = { r = 1, g = 1, b = 1 },
    size = { w = 250, h = 80 },
    pos = { x = 0, y = 0 },
}

for key, val in pairs(defaults) do
    if SilentDPSBarsDB[key] == nil then
        SilentDPSBarsDB[key] = val
    end
end

-- Convenience accessor functions
local function GetColor(which)
    local c = SilentDPSBarsDB[which]
    if not c then return 1, 1, 1, 1 end
    return c.r, c.g, c.b, c.a or 1
end

local function GetSize()
    local s = SilentDPSBarsDB.size
    return s.w or 200, s.h or 60
end

local function GetPosition()
    local p = SilentDPSBarsDB.pos
    return p.x or 0, p.y or 0
end

-- Expose to other files via the global addon table
local addonName, SDB = ...
SDB = SDB or {}
SDB.GetColor = GetColor
SDB.GetSize = GetSize
SDB.GetPosition = GetPosition

-- Debug print to confirm config initialized
print("🧩 Silent DPS Bars config loaded")
