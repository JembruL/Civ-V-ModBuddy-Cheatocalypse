-- Lua Script1
-- Author: CivicKr
-- DateCreated: 4/4/2026 8:51:04 PM
--------------------------------------------------------------
print("Cheatocalypse Building Effects System Loaded")

local PROMO_MASTER = GameInfoTypes.PROMOTION_CHEATO_MASTER_FLAG
local PROMO_BUFF   = GameInfoTypes.PROMOTION_CHEATO_STATUE_BUFF
local BUILDING_ID  = GameInfoTypes.BUILDING_CHEATOCALYPSE_STATUE

-- =========================================================
-- CHECK BUILDING EXISTENCE
-- =========================================================
function PlayerHasStatue(player)
    for city in player:Cities() do
        if city:IsHasBuilding(BUILDING_ID) then
            return true
        end
    end
    return false
end

-- =========================================================
-- APPLY GLOBAL BUFF
-- =========================================================
function ApplyStatueBuff(playerID)

    local player = Players[playerID]
    if not player then return end

    -- HARD FILTER
    if not player:IsHuman() then return end

    local hasStatue = PlayerHasStatue(player)

    for unit in player:Units() do
        if unit:IsHasPromotion(PROMO_MASTER) then

            if hasStatue then
                -- APPLY
                if not unit:IsHasPromotion(PROMO_BUFF) then
                    unit:SetHasPromotion(PROMO_BUFF, true)
                end

                -- +1 MOVE (hard inject)
                unit:SetMoves(unit:MaxMoves())

            else
                -- REMOVE
                if unit:IsHasPromotion(PROMO_BUFF) then
                    unit:SetHasPromotion(PROMO_BUFF, false)
                end
            end

        end
    end
end

GameEvents.PlayerDoTurn.Add(ApplyStatueBuff)
GameEvents.UnitCreated.Add(ApplyStatueBuff)