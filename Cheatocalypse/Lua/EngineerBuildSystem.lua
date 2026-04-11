print("Cheatocalypse Engineer Build System Loaded")

local iUnitEngineer = GameInfoTypes.UNIT_CHEAT_ENGINEER
local promoMaster   = GameInfoTypes.PROMOTION_CHEATO_MASTER_FLAG
local pendingRestore = {}

local function RestoreEngineerMoves(unit)
    if not unit then return end
    local maxMoves = unit:MaxMoves()
    if maxMoves and maxMoves > 0 then
        unit:SetMoves(maxMoves)
    end
end

local function QueueRestore(playerID, unitID)
    pendingRestore[playerID] = pendingRestore[playerID] or {}
    pendingRestore[playerID][unitID] = Game.GetGameTurn()
end

local function ProcessPending(playerID)
    local pPlayer = Players[playerID]
    if not pPlayer or not pPlayer:IsHuman() then return end

    local bucket = pendingRestore[playerID]
    if not bucket then return end

    local currentTurn = Game.GetGameTurn()
    for unitID, turnID in pairs(bucket) do
        local unit = pPlayer:GetUnitByID(unitID)
        if unit and turnID == currentTurn then
            if unit:GetUnitType() == iUnitEngineer and unit:IsHasPromotion(promoMaster) then
                RestoreEngineerMoves(unit)
            end
        end
        bucket[unitID] = nil
    end
end

GameEvents.BuildFinished.Add(function(playerID, x, y, improvementType)
    local pPlayer = Players[playerID]
    if not pPlayer or not pPlayer:IsHuman() then return end

    for unit in pPlayer:Units() do
        if unit:GetUnitType() == iUnitEngineer
        and unit:IsHasPromotion(promoMaster)
        and unit:GetX() == x
        and unit:GetY() == y then
            QueueRestore(playerID, unit:GetID())
            RestoreEngineerMoves(unit)
            return
        end
    end
end)

GameEvents.UnitSelectionChanged.Add(function(playerID, unitID, isSelected)
    if not isSelected then return end
    local pPlayer = Players[playerID]
    if not pPlayer or not pPlayer:IsHuman() then return end

    local unit = pPlayer:GetUnitByID(unitID)
    if not unit then return end
    if unit:GetUnitType() ~= iUnitEngineer then return end
    if not unit:IsHasPromotion(promoMaster) then return end

    RestoreEngineerMoves(unit)
end)

GameEvents.PlayerDoTurn.Add(function(playerID)
    ProcessPending(playerID)
end)

