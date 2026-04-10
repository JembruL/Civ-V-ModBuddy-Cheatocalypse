-- Lua Script1
-- Author: CivicKr
-- DateCreated: 3/29/2026 5:39:55 PM
--------------------------------------------------------------
print("Cheatocalypse Unit Systems Loaded")

local PROMO_ARTILLERY = GameInfoTypes.PROMOTION_ARTILLERY_FLAG
local PROMO_BUFF = GameInfoTypes.PROMOTION_ARTILLERY_BUFF

-- =========================
-- AURA SYSTEM
-- =========================
function System_ArtilleryAura(playerID)
    local player = Players[playerID]
    if not player then return end

	-- Panggil GameInfoTypes di dalam fungsi, dikasih pengaman biar gak crash
    local PROMO_ARTILLERY = GameInfoTypes.PROMOTION_ARTILLERY_FLAG
    local PROMO_BUFF = GameInfoTypes.PROMOTION_ARTILLERY_BUFF

    -- Kalau promosinya belum ke-load di XML, berhentiin scriptnya dengan aman
    if not PROMO_ARTILLERY or not PROMO_BUFF then return end

    -- CLEAR BUFF
    for unit in player:Units() do
        if unit:IsHasPromotion(PROMO_BUFF) then
            unit:SetHasPromotion(PROMO_BUFF, false)
        end
    end

    -- APPLY BUFF
    for unit in player:Units() do
        if unit:IsHasPromotion(PROMO_ARTILLERY) then

            local plot = unit:GetPlot()

            for i = 0, 5 do
                local adjPlot = Map.PlotDirection(plot:GetX(), plot:GetY(), i)

                if adjPlot then
                    local adjUnit = adjPlot:GetUnit(0)

                    if adjUnit and adjUnit:GetOwner() == playerID then
                        adjUnit:SetHasPromotion(PROMO_BUFF, true)
                    end
                end
            end

        end
    end
end

-- TRIGGER (OPTIMIZED)
GameEvents.UnitSetXY.Add(System_ArtilleryAura)
GameEvents.UnitCreated.Add(System_ArtilleryAura)