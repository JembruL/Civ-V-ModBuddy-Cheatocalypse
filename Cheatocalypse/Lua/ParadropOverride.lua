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

    -- FILTER LAYER (WAJIB DUA-DUANYA ADA + MASTER FLAG)
    if unit:IsHasPromotion(promoMaster)
    and unit:IsHasPromotion(promoParadrop)
    and unit:IsHasPromotion(promoFlag)
    and prev then

        local distance = Map.PlotDistance(prev.x, prev.y, x, y)

        -- threshold: dianggap paradrop kalau lompat jauh
        if distance >= 5 then
            -- reset movement biar bisa lanjut aksi
            unit:SetMoves(unit:MaxMoves())

            -- kasih blitz biar bisa attack setelah drop
            if not unit:IsHasPromotion(promoBlitz) then
                unit:SetHasPromotion(promoBlitz, true)
            end

            -- optional: heal dikit biar gak fragile
            unit:ChangeDamage(-10)
        end
    end

    lastPositions[playerID] = lastPositions[playerID] or {}
    lastPositions[playerID][unitID] = {x = x, y = y}
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
