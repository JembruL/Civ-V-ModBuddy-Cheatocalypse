print("Cheatocalypse Promotion Override Loaded")

-- =========================================================
-- CORE FILTER (HUMAN ONLY)
-- =========================================================
function IsHumanPlayer(playerID)
    local player = Players[playerID]
    return player and player:IsHuman()
end

-- =========================================================
-- PROMOTION REGISTRY (CENTRAL CONTROL)
-- =========================================================
local PROMO = {
    MASTER_FLAG    = GameInfoTypes.PROMOTION_CHEATO_MASTER_FLAG
}

-- =========================================================
-- SAFETY CHECK (ANTI-NULL / LOAD ORDER ISSUE)
-- =========================================================
for k, v in pairs(PROMO) do
    if not v then
        print("ERROR: Promotion missing ->", k)
        return
    end
end

-- =========================================================
-- PRE-CACHE CHEATO PROMOTIONS (CRITICAL FIX)
-- =========================================================
local CHEATO_PROMO_CACHE = {}

for promo in GameInfo.UnitPromotions() do
    if string.find(promo.Type, "PROMOTION_CHEATO_")
    and promo.Type ~= "PROMOTION_CHEATO_MASTER_FLAG"
    and promo.Type ~= "PROMOTION_CHEATO_STATUE_BUFF"
    and promo.Type ~= "PROMOTION_CHEATO_PARADROP_FLAG"
    then
        table.insert(CHEATO_PROMO_CACHE, promo.ID)
    end
end

-- =========================================================
-- UNIT VALIDATION (LAYER 2 FILTER)
-- =========================================================
function IsCheatUnit(unit)
    if not unit then return false end
    return unit:IsHasPromotion(PROMO.MASTER_FLAG)
end

-- =========================================================
-- SOFT PURGE (ANTI-AI ABUSE) - OPTIMIZED
-- =========================================================
function PurgeAI(playerID)

    local player = Players[playerID]
    if not player then return end
    if player:IsHuman() then return end

    for unit in player:Units() do

        -- gunakan cache, bukan scan semua promotion
        for i = 1, #CHEATO_PROMO_CACHE do
            local promoID = CHEATO_PROMO_CACHE[i]
            if unit:IsHasPromotion(promoID) then
                unit:SetHasPromotion(promoID, false)
            end
        end

        if unit:IsHasPromotion(PROMO.MASTER_FLAG) then
            unit:SetHasPromotion(PROMO.MASTER_FLAG, false)
        end
    end
end

-- =========================================================
-- AURA SYSTEM (ISOLATED) - OPTIMIZED
-- =========================================================
function System_CheatoAura(playerID)

    if not IsHumanPlayer(playerID) then return end

    local player = Players[playerID]
    if not player then return end

    -- CLEAR (optimized)
    for unit in player:Units() do
        if IsCheatUnit(unit) then

            for i = 1, #CHEATO_PROMO_CACHE do
                local promoID = CHEATO_PROMO_CACHE[i]
                if unit:IsHasPromotion(promoID) then
                    unit:SetHasPromotion(promoID, false)
                end
            end

        end
    end

    -- APPLY (no change, already optimal)
    for unit in player:Units() do
        if IsCheatUnit(unit) then

            local plot = unit:GetPlot()

            for i = 0, 5 do
                local adjPlot = Map.PlotDirection(plot:GetX(), plot:GetY(), i)

                if adjPlot then
                    --local adjUnit = adjPlot:GetUnit(0)
					-- Iterasi semua unit di plot:
					for i = 0, adjPlot:GetNumUnits() - 1 do
						local adjUnit = adjPlot:GetUnit(i)
						if adjUnit
						and adjUnit:GetOwner() == playerID
						and IsCheatUnit(adjUnit) then
							adjUnit:SetHasPromotion(GameInfoTypes.PROMOTION_CHEATO_UNIT_BUFF1, true)
						end
					end

                    if adjUnit
                    and adjUnit:GetOwner() == playerID
                    and IsCheatUnit(adjUnit) then

                        adjUnit:SetHasPromotion(GameInfoTypes.PROMOTION_CHEATO_UNIT_BUFF1, true)

                    end
                end
            end

        end
    end
end

-- =========================================================
-- GLOBAL SECURITY SWEEP
-- =========================================================
function GlobalSecuritySweep()

    for playerID = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
        PurgeAI(playerID)
    end

end

-- =========================================================
-- EVENT HOOKS
-- =========================================================
--GameEvents.UnitSetXY.Add(System_CheatoAura)
GameEvents.UnitCreated.Add(System_CheatoAura)
GameEvents.PlayerDoTurn.Add(System_CheatoAura)

GameEvents.PlayerDoTurn.Add(GlobalSecuritySweep)