-- ParadropOverride.lua
-- Author: CivicKr
-- DateCreated: 3/30/2026
-- REWRITE: Blitz handling dipindah ke XML (PROMOTION_CHEATO_BLITZ_FLAG permanent)
--------------------------------------------------------------
print("Cheatocalypse Paradrop Override Loaded")

-- ===========================================================================
-- PARADROP OVERRIDE SYSTEM (DUAL LAYER FILTER)
-- Requirement:
-- 1. PROMOTION_PARADROP (engine hook - base requirement)
-- 2. PROMOTION_CHEATO_PARADROP_FLAG (custom control)
-- 3. PROMOTION_CHEATO_MASTER_FLAG (system ownership)
-- NOTE: Blitz sudah permanent via PROMOTION_CHEATO_BLITZ_FLAG di XML
--       Tidak perlu toggle runtime. CleanupParadropBoost dihapus.
-- ===========================================================================

local promoParadrop = GameInfoTypes.PROMOTION_PARADROP
local promoFlag     = GameInfoTypes.PROMOTION_CHEATO_PARADROP_FLAG
local promoMaster   = GameInfoTypes.PROMOTION_CHEATO_MASTER_FLAG

-- Nil check saat load — fail fast jika XML belum load
if not promoParadrop or not promoFlag or not promoMaster then
    print("ERROR: ParadropOverride — promotion ID missing, system aborted.")
    return
end

-- cache posisi sebelumnya untuk hitung distance
local lastPositions = {}
-- tracking moves sebelumnya untuk validasi paradrop real
local lastMoves     = {}

-- ===========================================================================
-- MEMORY CLEANUP (ANTI LEAK)
-- ===========================================================================
GameEvents.UnitPrekill.Add(function(playerID, unitID, unitType, bDelay, x, y)
    if lastPositions[playerID] then
        lastPositions[playerID][unitID] = nil
    end
    if lastMoves[playerID] then
        lastMoves[playerID][unitID] = nil
    end
end)

-- ===========================================================================
-- MAIN OVERRIDE + TRACK SYSTEM
-- Satu hook agar posisi lama terbaca sebelum di-update.
-- ===========================================================================
local function ParadropOverride(playerID, unitID, x, y)

    local player = Players[playerID]
    if not player then return end

    -- HARD FILTER: HUMAN ONLY
    -- AI tetap di-track posisinya agar tidak corrupt tabel saat switch
    if not player:IsHuman() then
        lastPositions[playerID] = lastPositions[playerID] or {}
        lastPositions[playerID][unitID] = {x = x, y = y}
        return
    end

    local unit = player:GetUnitByID(unitID)
    if not unit then return end

    -- Ambil data sebelumnya
    local prev      = lastPositions[playerID] and lastPositions[playerID][unitID]
    local prevMoves = lastMoves[playerID] and lastMoves[playerID][unitID]

    -- FILTER LAYER: wajib semua 3 promotion ada + data sebelumnya valid
    if unit:IsHasPromotion(promoMaster)
    and unit:IsHasPromotion(promoParadrop)
    and unit:IsHasPromotion(promoFlag)
    and prev and prevMoves then

        local distance     = Map.PlotDistance(prev.x, prev.y, x, y)
        local currentMoves = unit:GetMoves()

        -- VALID PARADROP DETECTION:
        -- 1. Lompat jauh (distance >= 5)
        -- 2. Moves berkurang drastis (engine consume setelah paradrop)
        if distance >= 5 and currentMoves < prevMoves then

            -- Restore movement penuh
            -- Blitz sudah permanent via XML, tidak perlu toggle
            unit:SetMoves(unit:MaxMoves())

            -- Minor heal sebagai reward paradrop
            unit:ChangeDamage(-10)

        end
    end

    -- Update tracking
    lastPositions[playerID] = lastPositions[playerID] or {}
    lastPositions[playerID][unitID] = {x = x, y = y}

    lastMoves[playerID] = lastMoves[playerID] or {}
    lastMoves[playerID][unitID] = unit:GetMoves()
end

GameEvents.UnitSetXY.Add(ParadropOverride)