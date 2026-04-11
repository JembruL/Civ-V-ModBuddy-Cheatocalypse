print("Cheatocalypse Core System Loaded")

local PROMO_MASTER = GameInfoTypes.PROMOTION_CHEATO_MASTER_FLAG
local FEATURE_LOG_SECURITY = false

local MASTER_UNITS = {}
for row in GameInfo.Unit_FreePromotions() do
    if row.PromotionType == "PROMOTION_CHEATO_MASTER_FLAG" then
        MASTER_UNITS[row.UnitType] = true
    end
end

-- =========================================================
-- BLOCK AI TRAINING (BASED ON MASTER FLAG)
-- =========================================================
GameEvents.PlayerCanTrain.Add(function(playerID, unitType)
    local player = Players[playerID]
    if not player then return true end

    local unitInfo = GameInfo.Units[unitType]
    if unitInfo and MASTER_UNITS[unitInfo.Type] and not player:IsHuman() then
        if FEATURE_LOG_SECURITY then
            print("Cheatocalypse Security: blocked AI training", playerID, unitInfo.Type)
        end
        return false
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
        if FEATURE_LOG_SECURITY then
            print("Cheatocalypse Security: killed non-human cheat unit", playerID, unitID)
        end
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
-- STATUE BUFF AUTHORITY
-- =========================================================
-- IMPORTANT:
-- Statue buff (+25% strength, +200% XP, visibility bonus) tetap aktif
-- melalui PROMOTION_CHEATO_STATUE_BUFF di Lua/BuildingEffects.lua.
-- Hook duplikat di CoreSystem dihapus untuk mencegah stacking movement
-- (SetMoves + ChangeMoves) dan konflik sumber kebenaran.
