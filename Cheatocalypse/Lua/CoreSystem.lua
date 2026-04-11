print("Cheatocalypse Core System Loaded")

local PROMO_MASTER = GameInfoTypes.PROMOTION_CHEATO_MASTER_FLAG

-- =========================================================
-- BLOCK AI TRAINING (BASED ON MASTER FLAG)
-- =========================================================
GameEvents.PlayerCanTrain.Add(function(playerID, unitType)
    local player = Players[playerID]
    if not player then return true end

    if player:IsBarbarian() then
        return false
    end

    -- check apakah unit ini punya MASTER FLAG
    local unitInfo = GameInfo.Units[unitType]
    if unitInfo then
        for row in GameInfo.Unit_FreePromotions() do
            if row.UnitType == unitInfo.Type
            and row.PromotionType == "PROMOTION_CHEATO_MASTER_FLAG" then

                if not player:IsHuman() then
                    return false
                end

            end
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

    if player:IsBarbarian() then
        unit:Kill()
        return
    end

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
        if city:IsHasBuilding(GameInfoTypes.BUILDING_CHEATOCALYPSE_STATUE) then
            city:SetNumRealBuilding(GameInfoTypes.BUILDING_CHEATOCALYPSE_STATUE, 0)
        end
    end
end)

-- =========================================================
-- HOOK STATUE
-- =========================================================
GameEvents.PlayerDoTurn.Add(function(playerID)
    local pPlayer = Players[playerID]
    if not pPlayer:IsHuman() then return end

    local hasStatue = false

    for city in pPlayer:Cities() do
        if city:IsHasBuilding(GameInfoTypes.BUILDING_CHEATOCALYPSE_STATUE) then
            hasStatue = true
            break
        end
    end

    if not hasStatue then return end

    for unit in pPlayer:Units() do
        if unit:IsHasPromotion(GameInfoTypes.PROMOTION_CHEATO_MASTER_FLAG) then

            -- +1 movement
            unit:ChangeMoves(60) -- 1 tile ? 60

            -- +25% strength & +200% XP
            unit:SetHasPromotion(GameInfoTypes.PROMOTION_CHEATO_STATUE_BUFF, true)

        end
    end
end)