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

-- ===========================================================================
-- MAIN OVERRIDE + TRACK SYSTEM
-- NOTE: gunakan satu hook agar posisi lama terbaca sebelum di-update.
-- ===========================================================================
function ParadropOverride(playerID, unitID, x, y)

    local player = Players[playerID]
    if not player then return end

    -- HARD FILTER: HUMAN ONLY
    if not player:IsHuman() then
        lastPositions[playerID] = lastPositions[playerID] or {}
        lastPositions[playerID][unitID] = {x = x, y = y}
        return
    end

    local unit = player:GetUnitByID(unitID)
    if not unit then return end

    local prev = nil
    if lastPositions[playerID] then
        prev = lastPositions[playerID][unitID]
    end

    -- ambil move sebelumnya
    local prevMoves = nil
    if lastMoves[playerID] then
        prevMoves = lastMoves[playerID][unitID]
    end

    -- FILTER LAYER (WAJIB DUA-DUANYA ADA + MASTER FLAG)
    if unit:IsHasPromotion(promoMaster)
    and unit:IsHasPromotion(promoParadrop)
    and unit:IsHasPromotion(promoFlag)
    and prev and prevMoves then

        local distance = Map.PlotDistance(prev.x, prev.y, x, y)
        local currentMoves = unit:GetMoves()

        -- =========================================================
        -- FIX: VALID PARADROP DETECTION
        -- SYARAT:
        -- 1. lompat jauh (distance)
        -- 2. move berkurang drastis (engine consume)
        -- =========================================================
        if distance >= 5 and currentMoves < prevMoves then

            -- reset movement
			unit:SetMoves(unit:MaxMoves())

			-- HARD RESET COMBAT STATE (CRITICAL FIX)
			unit:SetHasPromotion(promoBlitz, false)
			unit:SetHasPromotion(promoBlitz, true)

			-- optional heal
			unit:ChangeDamage(-10)
        end
    end

    -- update posisi terakhir
    lastPositions[playerID] = lastPositions[playerID] or {}
    lastPositions[playerID][unitID] = {x = x, y = y}

    -- update move terakhir
    lastMoves[playerID] = lastMoves[playerID] or {}
    lastMoves[playerID][unitID] = unit:GetMoves()
end

GameEvents.UnitSetXY.Add(ParadropOverride)

-- ===========================================================================
-- CLEANUP SYSTEM (REMOVE BLITZ SETIAP TURN)
-- ===========================================================================
function CleanupParadropBoost(playerID)

    local player = Players[playerID]
    if not player then return end

    -- HARD FILTER: HUMAN ONLY
    if not player:IsHuman() then return end

    for unit in player:Units() do
        if unit:IsHasPromotion(promoBlitz) then

            -- hanya unit dalam ecosystem Cheatocalypse
            if unit:IsHasPromotion(promoMaster)
            and unit:IsHasPromotion(promoFlag) then

                unit:SetHasPromotion(promoBlitz, false)

            end
        end
    end
end

GameEvents.PlayerDoTurn.Add(CleanupParadropBoost)