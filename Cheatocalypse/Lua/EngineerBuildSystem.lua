print("Cheatocalypse Engineer Build System Loaded")

local iUnitEngineer = GameInfoTypes.UNIT_CHEAT_ENGINEER
local promoMaster   = GameInfoTypes.PROMOTION_CHEATO_MASTER_FLAG

local function IsEligibleEngineer(unit)
    return unit
        and unit:GetUnitType() == iUnitEngineer
        and unit:IsHasPromotion(promoMaster)
end

local function RestoreEngineerMoves(unit)
    if not IsEligibleEngineer(unit) then return end
    local maxMoves = unit:MaxMoves()
    if maxMoves and maxMoves > 0 and unit:GetMoves() < maxMoves then
        unit:SetMoves(maxMoves)
    end
end

GameEvents.BuildFinished.Add(function(playerID, x, y, improvementType)
    local pPlayer = Players[playerID]
    if not pPlayer or not pPlayer:IsHuman() then return end

    for unit in pPlayer:Units() do
        if IsEligibleEngineer(unit)
        and unit:GetX() == x
        and unit:GetY() == y then
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
    RestoreEngineerMoves(unit)
end)

GameEvents.PlayerDoTurn.Add(function(playerID)
    local pPlayer = Players[playerID]
    if not pPlayer or not pPlayer:IsHuman() then return end

    for unit in pPlayer:Units() do
        RestoreEngineerMoves(unit)
    end
end)
