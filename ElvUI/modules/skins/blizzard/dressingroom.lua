local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true then return end
	if not DressUpFrame then return end

	DressUpFrame:StripTextures()
	DressUpFrame:SetTemplate("Transparent")
	if DressUpFrameCloseButton then
		S:HandleCloseButton(DressUpFrameCloseButton)
	end

	-- Кнопки управления (если есть)
	if DressUpFrameResetButton then
		S:HandleButton(DressUpFrameResetButton)
	end
	if DressUpFrameCancelButton then
		S:HandleButton(DressUpFrameCancelButton)
	end

	-- Кнопки навигации (если есть)
	if DressUpFrame.OutfitDropDown then
		S:HandleDropDownBox(DressUpFrame.OutfitDropDown)
	end
	if DressUpFrame.LinkButton then
		S:HandleButton(DressUpFrame.LinkButton)
	end
end

S:RegisterSkin("Blizzard_DressUpFrame", LoadSkin)