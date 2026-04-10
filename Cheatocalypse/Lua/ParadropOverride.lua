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
local promoExtParadrop   = GameInfoTypes.PROMOTION_EXTENDED_PARADROP
local promoFlag          = GameInfoTypes.PROMOTION_CHEATO_PARADROP_FLAG
local promoMaster        = GameInfoTypes.PROMOTION_CHEATO_MASTER_FLAG
local promoBlitz         = GameInfoTypes.PROMOTION_BLITZ
local promoEnemyLands    = GameInfoTypes.PROMOTION_ENEMY_LANDS

-- cache posisi sebelumnya biar bisa hitung distance
local lastPositions = {}

local function IsFriendZoneForCheatoUnit(player, unit)
    if not player or not unit then return false end
    if not unit:IsHasPromotion(promoMaster) then return false end
    if not unit:IsHasPromotion(promoFlag) then return false end
    return true
end

local function EnsureParadropAccess(playerID)
    local player = Players[playerID]
    if not player or not player:IsHuman() then return end

    for unit in player:Units() do
        if IsFriendZoneForCheatoUnit(player, unit) then
            if promoParadrop and not unit:IsHasPromotion(promoParadrop) then
                unit:SetHasPromotion(promoParadrop, true)
            end
            if promoEnemyLands and not unit:IsHasPromotion(promoEnemyLands) then
                unit:SetHasPromotion(promoEnemyLands, true)
            end
        end
    end
end

-- ===========================================================================
-- TRACK posisi unit setiap kali gerak
-- ===========================================================================
function TrackUnitPosition(playerID, unitID, x, y)
    lastPositions[playerID] = lastPositions[playerID] or {}
    lastPositions[playerID][unitID] = {x = x, y = y}
end

GameEvents.UnitSetXY.Add(TrackUnitPosition)
GameEvents.UnitSetXY.Add(function(playerID, unitID, x, y)
    EnsureParadropAccess(playerID)
end)
GameEvents.UnitCreated.Add(function(playerID, unitID)
    EnsureParadropAccess(playerID)
end)

-- ===========================================================================
-- MAIN OVERRIDE SYSTEM
-- ===========================================================================
function ParadropOverride(playerID, unitID, x, y)

    local player = Players[playerID]
    if not player then return end

    -- HARD FILTER: HUMAN ONLY
    if not player:IsHuman() then return end

    local unit = player:GetUnitByID(unitID)
    if not unit then return end

    if not IsFriendZoneForCheatoUnit(player, unit) then return end

    local hasParadropHook = unit:IsHasPromotion(promoParadrop)
    if promoExtParadrop then
        hasParadropHook = hasParadropHook or unit:IsHasPromotion(promoExtParadrop)
    end

    -- FILTER LAYER (WAJIB DUA-DUANYA ADA + MASTER FLAG)
    if not unit:IsHasPromotion(promoMaster) then return end
    if not hasParadropHook then return end
    if not unit:IsHasPromotion(promoFlag) then return end

    -- ambil posisi sebelumnya
    if not lastPositions[playerID] or not lastPositions[playerID][unitID] then
        return
    end

    local prev = lastPositions[playerID][unitID]
    local prevX = prev.x
    local prevY = prev.y
    local distance = Map.PlotDistance(prevX, prevY, x, y)

    if distance and distance >= 5
	and hasParadropHook
	and unit:IsHasPromotion(promoFlag)
	and unit:IsHasPromotion(promoMaster)
	and unit:GetMoves() == 0 then
		unit:SetMoves(unit:MaxMoves())
		if not unit:IsHasPromotion(promoBlitz) then
			unit:SetHasPromotion(promoBlitz, true)
		end
    unit:ChangeDamage(-10)
	end
end

GameEvents.UnitSetXY.Add(ParadropOverride)
GameEvents.PlayerDoTurn.Add(EnsureParadropAccess)

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
