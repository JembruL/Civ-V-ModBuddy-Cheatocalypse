local promoParadrop    = GameInfoTypes.PROMOTION_PARADROP
local promoExtParadrop = GameInfoTypes.PROMOTION_EXTENDED_PARADROP
local promoFlag        = GameInfoTypes.PROMOTION_CHEATO_PARADROP_FLAG
local promoMaster      = GameInfoTypes.PROMOTION_CHEATO_MASTER_FLAG
local promoBlitz       = GameInfoTypes.PROMOTION_BLITZ
local promoEnemyLands  = GameInfoTypes.PROMOTION_ENEMY_LANDS

local lastPositions = {}

local function IsCheatoParadropUnit(unit)
    if not unit then return false end
    return unit:IsHasPromotion(promoMaster) and unit:IsHasPromotion(promoFlag)
end

local function EnsureParadropAccess(playerID)
    local player = Players[playerID]
    if not player or not player:IsHuman() then return end

    for unit in player:Units() do
        if IsCheatoParadropUnit(unit) then
            if promoParadrop and not unit:IsHasPromotion(promoParadrop) then
                unit:SetHasPromotion(promoParadrop, true)
            end
            if promoEnemyLands and not unit:IsHasPromotion(promoEnemyLands) then
                unit:SetHasPromotion(promoEnemyLands, true)
            end
        end
    end
end

GameEvents.UnitCreated.Add(function(playerID, unitID)
    EnsureParadropAccess(playerID)
end)

GameEvents.PlayerDoTurn.Add(function(playerID)
    EnsureParadropAccess(playerID)
end)

GameEvents.UnitSetXY.Add(function(playerID, unitID, x, y)
    lastPositions[playerID] = lastPositions[playerID] or {}
    local prev = lastPositions[playerID][unitID]
    lastPositions[playerID][unitID] = { x = x, y = y }

    local player = Players[playerID]
    if not player or not player:IsHuman() then return end

    local unit = player:GetUnitByID(unitID)
    if not IsCheatoParadropUnit(unit) then return end
    if not prev then return end

    local distance = Map.PlotDistance(prev.x, prev.y, x, y)
    if not distance or distance < 5 then return end

    local hasAnyParadrop = unit:IsHasPromotion(promoParadrop)
    if promoExtParadrop then
        hasAnyParadrop = hasAnyParadrop or unit:IsHasPromotion(promoExtParadrop)
    end
    if not hasAnyParadrop then return end

    if unit:GetMoves() == 0 then
        unit:SetMoves(unit:MaxMoves())
        if promoBlitz and not unit:IsHasPromotion(promoBlitz) then
            unit:SetHasPromotion(promoBlitz, true)
        end
        unit:ChangeDamage(-10)
    end
end)

GameEvents.PlayerDoTurn.Add(function(playerID)
    local player = Players[playerID]
    if not player or not player:IsHuman() then return end

    for unit in player:Units() do
        if unit:IsHasPromotion(promoBlitz) and IsCheatoParadropUnit(unit) then
            unit:SetHasPromotion(promoBlitz, false)
        end
    end
end)

