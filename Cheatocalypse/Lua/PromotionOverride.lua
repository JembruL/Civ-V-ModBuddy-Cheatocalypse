-- Lua Script1
-- Author: CivicKr
-- DateCreated: 3/30/2026 1:14:58 PM
--------------------------------------------------------------
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
-- UNIT VALIDATION (LAYER 2 FILTER)
-- =========================================================
function IsCheatUnit(unit)
    if not unit then return false end
    return unit:IsHasPromotion(PROMO.MASTER_FLAG)
end

-- =========================================================
-- HELPER: DETECT ALL CHEATO PROMOTIONS (AUTO SCALING)
-- =========================================================
function IsCheatoPromotion(promoType)
    return string.find(promoType, "PROMOTION_CHEATO_") ~= nil
end

-- =========================================================
-- SOFT PURGE (ANTI-AI ABUSE)
-- =========================================================
function PurgeAI(playerID)

    local player = Players[playerID]
    if not player then return end
    if player:IsHuman() then return end

    for unit in player:Units() do

        -- only if unit own Cheatocalypse system
        if unit:IsHasPromotion(PROMO.MASTER_FLAG) then

            for promo in GameInfo.UnitPromotions() do
                if IsCheatoPromotion(promo.Type) 
				and promo.Type ~= "PROMOTION_CHEATO_MASTER_FLAG"
				and promo.Type ~= "PROMOTION_CHEATO_STATUE_BUFF"   
				and promo.Type ~= "PROMOTION_CHEATO_PARADROP_FLAG" 
				then
                    if unit:IsHasPromotion(promo.ID) then
                        unit:SetHasPromotion(promo.ID, false)
                    end
                end
            end

        end
    end
end

-- =========================================================
-- AURA SYSTEM (ISOLATED)
-- =========================================================
function System_CheatoAura(playerID)

    if not IsHumanPlayer(playerID) then return end

    local player = Players[playerID]
    if not player then return end

    -- CLEAR (remove all CHEATO buffs first)
    for unit in player:Units() do
        if IsCheatUnit(unit) then

            for promo in GameInfo.UnitPromotions() do
                if IsCheatoPromotion(promo.Type)
                and promo.Type ~= "PROMOTION_CHEATO_MASTER_FLAG" 
				and promo.Type ~= "PROMOTION_CHEATO_STATUE_BUFF"   
				and promo.Type ~= "PROMOTION_CHEATO_PARADROP_FLAG"
				then

                    if unit:IsHasPromotion(promo.ID) then
                        unit:SetHasPromotion(promo.ID, false)
                    end

                end
            end

        end
    end

    -- APPLY (example: apply BUFF1 as base aura)
    for unit in player:Units() do
        if IsCheatUnit(unit) then

            local plot = unit:GetPlot()

            for i = 0, 5 do
                local adjPlot = Map.PlotDirection(plot:GetX(), plot:GetY(), i)

                if adjPlot then
                    local adjUnit = adjPlot:GetUnit(0)

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
GameEvents.UnitSetXY.Add(System_CheatoAura)
GameEvents.UnitCreated.Add(System_CheatoAura)
GameEvents.PlayerDoTurn.Add(System_CheatoAura)

GameEvents.PlayerDoTurn.Add(GlobalSecuritySweep)