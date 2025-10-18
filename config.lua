-- Silent DPS Bars Configuration UI

local panel = CreateFrame("Frame", "SilentDPSBarsConfig", InterfaceOptionsFramePanelContainer)
panel.name = "Silent DPS Bars"

panel.title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
panel.title:SetPoint("TOPLEFT", 16, -16)
panel.title:SetText("Silent DPS Bars Settings")

-- opaque 
local alphaSlider = CreateFrame("Slider", "SDBAlphaSlider", panel, "OptionsSliderTemplate")
alphaSlider:SetWidth(200)
alphaSlider:SetHeight(16)
alphaSlider:SetMinMaxValues(0, 1)
alphaSlider:SetValueStep(0.05)
alphaSlider:SetPoint("TOPLEFT", 20, -60)
alphaSlider:SetValue(SilentDPSBarsDB.barColor.a)
SDBAlphaSliderText:SetText("Background Transparency")
SDBAlphaSliderLow:SetText("0")
SDBAlphaSliderHigh:SetText("1")
alphaSlider:SetScript("OnValueChanged", function(self, value)
    SilentDPSBarsDB.barColor.a = value
    SilentDPSBarsFrame:SetBackdropColor(
        SilentDPSBarsDB.barColor.r,
        SilentDPSBarsDB.barColor.g,
        SilentDPSBarsDB.barColor.b,
        value
    )
end)

-- uWu size
local widthSlider = CreateFrame("Slider", "SDBWidthSlider", panel, "OptionsSliderTemplate")
widthSlider:SetWidth(200)
widthSlider:SetHeight(16)
widthSlider:SetMinMaxValues(100, 500)
widthSlider:SetValueStep(10)
widthSlider:SetPoint("TOPLEFT", 20, -110)
widthSlider:SetValue(SilentDPSBarsDB.size.w)
SDBWidthSliderText:SetText("Frame Width")
SDBWidthSliderLow:SetText("100")
SDBWidthSliderHigh:SetText("500")
widthSlider:SetScript("OnValueChanged", function(self, value)
    SilentDPSBarsDB.size.w = value
    SilentDPSBarsFrame:SetWidth(value)
end)

local heightSlider = CreateFrame("Slider", "SDBHeightSlider", panel, "OptionsSliderTemplate")
heightSlider:SetWidth(200)
heightSlider:SetHeight(16)
heightSlider:SetMinMaxValues(50, 200)
heightSlider:SetValueStep(5)
heightSlider:SetPoint("TOPLEFT", 20, -160)
heightSlider:SetValue(SilentDPSBarsDB.size.h)
SDBHeightSliderText:SetText("Frame Height")
SDBHeightSliderLow:SetText("50")
SDBHeightSliderHigh:SetText("200")
heightSlider:SetScript("OnValueChanged", function(self, value)
    SilentDPSBarsDB.size.h = value
    SilentDPSBarsFrame:SetHeight(value)
end)

-- Color picker button
local colorButton = CreateFrame("Button", "SDBColorPicker", panel, "UIPanelButtonTemplate")
colorButton:SetPoint("TOPLEFT", 20, -210)
colorButton:SetSize(140, 22)
colorButton:SetText("Change Background Color")
colorButton:SetScript("OnClick", function()
    local r, g, b = SilentDPSBarsDB.barColor.r, SilentDPSBarsDB.barColor.g, SilentDPSBarsDB.barColor.b
    ColorPickerFrame.func = function()
        local newR, newG, newB = ColorPickerFrame:GetColorRGB()
        SilentDPSBarsDB.barColor.r, SilentDPSBarsDB.barColor.g, SilentDPSBarsDB.barColor.b = newR, newG, newB
        SilentDPSBarsFrame:SetBackdropColor(newR, newG, newB, SilentDPSBarsDB.barColor.a)
    end
    ColorPickerFrame:SetColorRGB(r, g, b)
    ColorPickerFrame:Show()
end)

-- Register the panel
InterfaceOptions_AddCategory(panel)
