local E, L, DF = unpack(select(2, ...))
local AP = E:NewModule('AltPowerBar', 'AceEvent-3.0', 'AceTimer-3.0')
local B = E:GetModule('Blizzard')

function AP:UpdateAltPowerBarPosition()
	if not self.bar then return end

	self.bar:ClearAllPoints()
	self.bar:SetPoint("CENTER", self.holder, "CENTER", 0, 0)
	self.bar:SetWidth(self.holder:GetWidth())
	self.bar:SetHeight(self.holder:GetHeight())
end

function AP:ToggleMovers()
	if self.holder and not InCombatLockdown() then
		--Функция для показа/скрытия фрейма-держателя
		E:ToggleMovers()
	end
end

function AP:UpdateMover()
	if not self.holder then return end

	--Обновляем размер мувера
	local width, height = 250, 25
	if self.bar and self.bar:IsShown() then
		width = self.bar:GetWidth() or width
		height = self.bar:GetHeight() or height
	end

	self.holder:Size(width, height)
	
	-- Fix UpdatePositionMover error
	if self.holder.mover and E.Movers then
		E:UpdateMover(self.holder.mover:GetName())
	end
end

function AP:ShowAltPowerText()
	if not self.bar then return end

	-- Make the text always visible (not just on mouseover)
	if self.bar.statusFrame and self.bar.statusFrame.text then
		self.bar.statusFrame.text:Show()

		-- Remove the OnEnter/OnLeave scripts that control text visibility
		if self.bar.statusFrame:GetScript("OnEnter") then
			self.bar.statusFrame:SetScript("OnEnter", nil)
		end
		if self.bar.statusFrame:GetScript("OnLeave") then
			self.bar.statusFrame:SetScript("OnLeave", nil)
		end

		-- Force text alpha to 1 (fully visible)
		if not self.bar.statusFrame.text.alphaHooked then
			self.bar.statusFrame.text:SetAlpha(1)
			
			-- Prevent the text from being hidden
			hooksecurefunc(self.bar.statusFrame.text, "Hide", function(text)
				text:Show()
			end)
			
			-- Also hook SetAlpha to prevent transparency
			hooksecurefunc(self.bar.statusFrame.text, "SetAlpha", function(text, alpha)
				if text.isSettingAlpha then return end
				if alpha < 1 then
					text.isSettingAlpha = true
					text:SetAlpha(1)
					text.isSettingAlpha = false
				end
			end)
			self.bar.statusFrame.text.alphaHooked = true
		end
	end
	
	-- Some alternative power bars may use different text elements
	for _, region in pairs({self.bar:GetRegions()}) do
		if region:IsObjectType("FontString") and not region.alphaHooked then
			region:Show()
			region:SetAlpha(1)
			
			-- Prevent the text from being hidden
			hooksecurefunc(region, "Hide", function(text)
				text:Show()
			end)
			
			-- Also hook SetAlpha to prevent transparency
			hooksecurefunc(region, "SetAlpha", function(text, alpha)
				if text.isSettingAlpha then return end
				if alpha < 1 then
					text.isSettingAlpha = true
					text:SetAlpha(1)
					text.isSettingAlpha = false
				end
			end)
			region.alphaHooked = true
		end
	end
end

function AP:Initialize()
	--Не создаем модуль, если фрейм не существует
	if not PlayerPowerBarAlt then return end

	--Создаем держатель для PlayerPowerBarAlt
	local holder = CreateFrame("Frame", "ElvUI_AltPowerBarHolder", E.UIParent)
	holder:Size(250, 25)
	holder:Point("TOP", E.UIParent, "TOP", 0, -120)
	holder:SetFrameStrata("LOW")
	holder:SetFrameLevel(10)

	--Привязываем бар к держателю
	self.holder = holder
	self.bar = PlayerPowerBarAlt

	--Создаем мувер
	E:CreateMover(holder, "AltPowerBarMover", L["Alternative Power"], nil, nil, nil, "ALL,GENERAL", nil, "misc,altPowerBar")

	--Подписываемся на события показа/скрытия бара
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateAltPowerBarPosition")
	self:RegisterEvent("UNIT_POWER_BAR_SHOW", "UpdateAltPowerBarPosition")
	self:RegisterEvent("UNIT_POWER_BAR_HIDE", "UpdateAltPowerBarPosition")

	--Хукаем функцию SetPoint, чтобы бар всегда был привязан к нашему держателю
	hooksecurefunc(PlayerPowerBarAlt, "SetPoint", function(_, _, parent)
		if parent ~= holder then
			AP:UpdateAltPowerBarPosition()
		end
	end)

	--Хукаем функцию Show, чтобы обновлять размер мувера
	hooksecurefunc(PlayerPowerBarAlt, "Show", function()
		AP:UpdateMover()
		AP:UpdateAltPowerBarPosition()
		AP:ShowAltPowerText()
	end)

	-- Make the text always visible when power value updates
	self:RegisterEvent("UNIT_POWER_UPDATE", "ShowAltPowerText")
	-- Additional events to ensure text stays visible
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "ShowAltPowerText")
	self:RegisterEvent("UPDATE_UI_WIDGET", "ShowAltPowerText")
	
	-- Use CreateFrame for a timer as a fallback if AceTimer isn't working
	self.textUpdateFrame = CreateFrame("Frame")
	self.textUpdateFrame:SetScript("OnUpdate", function(_, elapsed)
		self.elapsed = (self.elapsed or 0) + elapsed
		if self.elapsed > 1 then
			self.elapsed = 0
			AP:ShowAltPowerText()
		end
	end)
	
	-- Also try using the AceTimer if it's available
	if self.ScheduleRepeatingTimer then
		self:ScheduleRepeatingTimer("ShowAltPowerText", 1)
	end

	--Базовое позиционирование
	self:UpdateAltPowerBarPosition()
	self:ShowAltPowerText()
end

-- Create a stub function for the Blizzard module to avoid the error
function B:PositionAltPowerBar()
	-- This is just a stub function that does nothing
	-- The real implementation is now in the AP module
end

E:RegisterModule(AP:GetName())