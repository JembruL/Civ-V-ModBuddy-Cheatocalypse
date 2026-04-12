-- Lua Script1
-- Author: CivicKr
-- DateCreated: 3/30/2026 11:57:55 AM
--------------------------------------------------------------

-- ===========================================================================
-- PARADROP OVERRIDE SYSTEM (DUAL LAYER FILTER)
-- Requirement:
-- 1. PROMOTION_PARADROP (engine hook)
-- 2. PROMOTION_CHEATO_PARADROP_FLAG (custom control)
-- 3. PROMOTION_CHEATO_MASTER_FLAG (system ownership)
-- ===========================================================================

local promoParadrop      = GameInfoTypes.PROMOTION_PARADROP
local promoFlag          = GameInfoTypes.PROMOTION_CHEATO_PARADROP_FLAG
local promoMaster        = GameInfoTypes.PROMOTION_CHEATO_MASTER_FLAG
local promoBlitz         = GameInfoTypes.PROMOTION_BLITZ

-- cache posisi sebelumnya biar bisa hitung distance
local lastPositions = {}
-- tambahan tracking move untuk validasi paradrop real
local lastMoves = {}

GameEvents.UnitPrekill.Add(function(playerID, unitID, unitType, bDelay, x, y)
    if lastPositions[playerID] then lastPositions[playerID][unitID] = nil end
    if lastMoves[playerID] then lastMoves[playerID][unitID] = nil end
end)

-- ===========================================================================
-- MAIN OVERRIDE + TRACK SYSTEM
-- NOTE: gunakan satu hook agar posisi lama terbaca sebelum di-update.
-- ===========================================================================
function ParadropOverride(playerID, unitID, x, y)

    local player = Players[playerID]
    if not player then return end

    if not player:IsHuman() then
        lastPositions[playerID] = lastPositions[playerID] or {}
        lastPositions[playerID][unitID] = {x = x, y = y}
        return
    end

    local unit = player:GetUnitByID(unitID)
    if not unit then return end

    local prev     = lastPositions[playerID] and lastPositions[playerID][unitID]
    local prevMoves = lastMoves[playerID] and lastMoves[playerID][unitID]

    if unit:IsHasPromotion(promoMaster)
    and unit:IsHasPromotion(promoParadrop)
    and unit:IsHasPromotion(promoFlag)
    and prev and prevMoves then

        local distance     = Map.PlotDistance(prev.x, prev.y, x, y)
        local currentMoves = unit:GetMoves()

        if distance >= 5 and currentMoves < prevMoves then

            -- STEP 1: Pastikan Blitz aktif dulu SEBELUM restore moves
            -- Ini yang membuka ranged attack setelah state reset
            if not unit:IsHasPromotion(promoBlitz) then
                unit:SetHasPromotion(promoBlitz, true)
            end

            -- STEP 2: Restore moves
            unit:SetMoves(unit:MaxMoves())

            -- STEP 3: Heal minor
            unit:ChangeDamage(-10)
        end
    end

    lastPositions[playerID] = lastPositions[playerID] or {}
    lastPositions[playerID][unitID] = {x = x, y = y}

    lastMoves[playerID] = lastMoves[playerID] or {}
    lastMoves[playerID][unitID] = unit:GetMoves()
end

GameEvents.UnitSetXY.Add(ParadropOverride)

-- ===========================================================================
-- CLEANUP SYSTEM (REMOVE BLITZ SETIAP TURN)
-- ===========================================================================
function CleanupParadropBoost(playerID)

    local player = Players[playerID]
    if not player or not player:IsHuman() then return end

    for unit in player:Units() do
        if unit:IsHasPromotion(promoBlitz)
        and unit:IsHasPromotion(promoMaster)
        and unit:IsHasPromotion(promoFlag) then
            unit:SetHasPromotion(promoBlitz, false)
        end
    end
end

GameEvents.PlayerDoTurn.Add(CleanupParadropBoost)