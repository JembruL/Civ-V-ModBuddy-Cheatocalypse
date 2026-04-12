print("Cheatocalypse Engineer Build System Loaded")

local iUnitEngineer = GameInfoTypes.UNIT_CHEAT_ENGINEER
local promoMaster   = GameInfoTypes.PROMOTION_CHEATO_MASTER_FLAG

local function IsEligibleEngineer(unit)
    return unit
        and unit:GetUnitType() == iUnitEngineer
        and unit:IsHasPromotion(promoMaster)
end

-- =========================================================
-- HARD FORCE INSTANT BUILD
-- =========================================================
local function ForceInstantBuild(playerID, unit, plot)

    if not IsEligibleEngineer(unit) then return end

    local buildType = unit:GetBuildType()
    if not buildType then return end

    local buildInfo = GameInfo.Builds[buildType]
    if not buildInfo then return end

    local improvement = buildInfo.ImprovementType
    if not improvement then return end

    local improvementID = GameInfoTypes[improvement]
    if not improvementID then return end

    -- APPLY langsung improvement (skip progress system)
    plot:SetImprovementType(improvementID)

    -- optional: route support
    if buildInfo.RouteType then
        plot:SetRouteType(GameInfoTypes[buildInfo.RouteType])
    end
end

-- =========================================================
-- RESTORE MOVE (AUTHORITATIVE)
-- =========================================================
local function RestoreEngineerMoves(unit)
    if not IsEligibleEngineer(unit) then return end
    unit:SetMoves(unit:MaxMoves())
end

-- =========================================================
-- BUILD EVENT
-- =========================================================
GameEvents.BuildFinished.Add(function(playerID, unitID, x, y, buildType, bSucceeded)

    if not bSucceeded then return end

    local pPlayer = Players[playerID]
    if not pPlayer or not pPlayer:IsHuman() then return end

    local unit = pPlayer:GetUnitByID(unitID)
    if not IsEligibleEngineer(unit) then return end

    local plot = Map.GetPlot(x, y)
    if not plot then return end

    -- improvement sudah ditaruh engine karena build selesai
    -- cukup restore moves
    RestoreEngineerMoves(unit)
end)

-- =========================================================
-- SELECTION FIX (ANTI DESYNC)
-- =========================================================
GameEvents.UnitSelectionChanged.Add(function(playerID, unitID, isSelected)

    if not isSelected then return end

    local pPlayer = Players[playerID]
    if not pPlayer or not pPlayer:IsHuman() then return end

    local unit = pPlayer:GetUnitByID(unitID)
    RestoreEngineerMoves(unit)
end)

-- =========================================================
-- TURN SAFETY NET
-- =========================================================
GameEvents.PlayerDoTurn.Add(function(playerID)

    local pPlayer = Players[playerID]
    if not pPlayer or not pPlayer:IsHuman() then return end

    for unit in pPlayer:Units() do
        RestoreEngineerMoves(unit)
    end
end)