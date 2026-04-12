print("Cheatocalypse Core System Loaded")

local PROMO_MASTER = GameInfoTypes.PROMOTION_CHEATO_MASTER_FLAG
local BUILDING_STATUE = GameInfoTypes.BUILDING_CHEATOCALYPSE_STATUE

-- =========================================================
-- BLOCK AI TRAINING (BASED ON MASTER FLAG)
-- =========================================================
GameEvents.PlayerCanTrain.Add(function(playerID, unitType)
    local player = Players[playerID]
    if not player then return true end

    local unitInfo = GameInfo.Units[unitType]
    if not unitInfo then return true end

    -- hanya blok unit CHEATO untuk non-human; jangan blok seluruh barbarian
    for row in GameInfo.Unit_FreePromotions() do
        if row.UnitType == unitInfo.Type
        and row.PromotionType == "PROMOTION_CHEATO_MASTER_FLAG"
        and not player:IsHuman() then
            return false
        end
    end

    return true
end)

-- =========================================================
-- HARD KILL SAFETY (ANTI-SPAWN EDGE CASE)
-- =========================================================
GameEvents.UnitCreated.Add(function(playerID, unitID)
    local player = Players[playerID]
    if not player then return end

    local unit = player:GetUnitByID(unitID)
    if not unit then return end

    -- kalau unit punya MASTER FLAG tapi bukan human ? kill/purge
    if unit:IsHasPromotion(PROMO_MASTER)
    and not player:IsHuman() then
        unit:Kill()
    end
end)

-- =========================================================
-- BUILDING SECURITY (ANTI AI OWNERSHIP)
-- =========================================================
GameEvents.PlayerDoTurn.Add(function(playerID)
    local player = Players[playerID]
    if not player then return end
    if player:IsHuman() then return end

    for city in player:Cities() do
        if city:IsHasBuilding(BUILDING_STATUE) then
            city:SetNumRealBuilding(BUILDING_STATUE, 0)
        end
    end
end)