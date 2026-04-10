-- Lua Script1
-- Author: CivicKr
-- DateCreated: 4/10/2026 10:15:00 AM
--------------------------------------------------------------
print("Cheatocalypse Engineer Build System Loaded")

local iUnitEngineer = GameInfoTypes.UNIT_CHEAT_ENGINEER
local promoMaster   = GameInfoTypes.PROMOTION_CHEATO_MASTER_FLAG
local pendingRestore = {}

local function PlotKey(x, y)
    return tostring(x) .. "," .. tostring(y)
end

local function RestoreEngineerMoves(unit)
    if not unit then return end
    local maxMoves = unit:MaxMoves()
    if maxMoves and maxMoves > 0 then
        unit:SetMoves(maxMoves)
        if unit:GetMoves() < maxMoves then
            unit:ChangeMoves(maxMoves)
        end
    end
end

-- =========================================================
-- BUILD FINISHED: UNIT-SCOPED INSTANT CHAIN
-- =========================================================
-- Catatan:
-- - Tidak menyentuh tabel Builds global (aman untuk semua worker lain).
-- - Engineer cheat yang valid langsung dipulihkan movement setelah build selesai,
--   sehingga bisa lanjut aksi/build lain pada turn yang sama.
GameEvents.BuildFinished.Add(function(playerID, x, y, improvementType)
    local pPlayer = Players[playerID]
    if not pPlayer or not pPlayer:IsHuman() then return end
    pendingRestore[playerID] = pendingRestore[playerID] or {}
    pendingRestore[playerID][PlotKey(x, y)] = Game.GetGameTurn()

    for unit in pPlayer:Units() do
        if unit:GetUnitType() == iUnitEngineer
        and unit:IsHasPromotion(promoMaster)
        and unit:GetX() == x
        and unit:GetY() == y then
            RestoreEngineerMoves(unit)
            return
        end
    end
end)

GameEvents.UnitSetXY.Add(function(playerID, unitID, x, y)
    local pPlayer = Players[playerID]
    if not pPlayer or not pPlayer:IsHuman() then return end

    local trackedPlots = pendingRestore[playerID]
    if not trackedPlots then return end

    local key = PlotKey(x, y)
    local turnMarked = trackedPlots[key]
    if not turnMarked or turnMarked ~= Game.GetGameTurn() then return end

    local unit = pPlayer:GetUnitByID(unitID)
    if not unit then return end
    if unit:GetUnitType() ~= iUnitEngineer then return end
    if not unit:IsHasPromotion(promoMaster) then return end

    RestoreEngineerMoves(unit)
    trackedPlots[key] = nil
end)

GameEvents.PlayerDoTurn.Add(function(playerID)
    if pendingRestore[playerID] then
        pendingRestore[playerID] = nil
    end
end)
