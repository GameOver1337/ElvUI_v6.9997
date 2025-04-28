local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule('Skins')

local function LoadSkin()
    if E.private.skins.blizzard.enable ~= true then return end
    if not StoreFrame then return end

    StoreFrame:StripTextures()
    StoreFrame:SetTemplate("Transparent")
    if StoreFrame.CloseButton then
        S:HandleCloseButton(StoreFrame.CloseButton)
    end

    -- Скин вкладок (если есть)
    for i = 1, 10 do
        local tab = _G["StoreFrameTab"..i]
        if tab then
            S:HandleTab(tab)
        end
    end

    -- Скин кнопок категорий слева
    for i = 1, 20 do
        local btn = _G["StoreCategoryButton"..i]
        if btn then
            btn:StripTextures()
            btn:SetTemplate("Default", true)
            btn:StyleButton()
        end
    end

    -- Скин карточек товаров
    for i = 1, 20 do
        local card = _G["StoreProductCard"..i]
        if card then
            card:StripTextures()
            card:SetTemplate("Default", true)
            card:StyleButton()
        end
    end

    -- Скин кнопок навигации (вперёд/назад)
    if StoreFrame.NextPageButton then
        S:HandleNextPrevButton(StoreFrame.NextPageButton)
    end
    if StoreFrame.PrevPageButton then
        S:HandleNextPrevButton(StoreFrame.PrevPageButton)
    end

    -- Скин кнопки покупки
    if StoreFrame.BuyNowButton then
        S:HandleButton(StoreFrame.BuyNowButton, true)
    end
end

S:RegisterSkin("Blizzard_StoreUI", LoadSkin) 