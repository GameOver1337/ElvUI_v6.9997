local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local AP = E:NewModule('AltPowerBar', 'AceEvent-3.0')

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
	E:UpdatePositionMover(self.holder.mover)
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
		self.bar.statusFrame.text:SetAlpha(1)
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
	
	--Базовое позиционирование
	self:UpdateAltPowerBarPosition()
	self:ShowAltPowerText()
end

E:RegisterModule(AP:GetName()) 