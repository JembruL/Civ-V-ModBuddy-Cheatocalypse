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
    unit:SetMoves(unit:MaxMoves())
end

-- =========================================================
-- BUILD EVENT — SIGNATURE BENAR
-- BuildFinished(playerID, x, y, buildType, bImprovement, bRoute, bClear)
-- TIDAK ada unitID, TIDAK ada bSucceeded
-- =========================================================
GameEvents.BuildFinished.Add(function(playerID, x, y, buildType, bImprovement, bRoute, bClear)

    print("BuildFinished fired: playerID="..tostring(playerID).." x="..tostring(x).." y="..tostring(y).." buildType="..tostring(buildType))

    local pPlayer = Players[playerID]
    if not pPlayer or not pPlayer:IsHuman() then return end

    -- cari engineer di koordinat build
    for unit in pPlayer:Units() do
        if IsEligibleEngineer(unit)
        and unit:GetX() == x
        and unit:GetY() == y then
            unit:SetMoves(unit:MaxMoves())
            unit:SetMoves(unit:MaxMoves())
            print("EngineerBuildSystem: Moves restored for unitID="..tostring(unit:GetID()))
            return
        end
    end
end)

-- =========================================================
-- SELECTION FIX
-- =========================================================
GameEvents.UnitSelectionChanged.Add(function(playerID, unitID, isSelected)
    if not isSelected then return end

    local pPlayer = Players[playerID]
    if not pPlayer or not pPlayer:IsHuman() then return end

    local unit = pPlayer:GetUnitByID(unitID)
    if not unit then return end

    if IsEligibleEngineer(unit) then
        print("UnitSelectionChanged: Engineer selected, moves before="..tostring(unit:GetMoves()))
        unit:SetMoves(unit:MaxMoves())
        print("UnitSelectionChanged: moves after="..tostring(unit:GetMoves()))
		-- Force UI refresh
        Events.SerialEventUnitInfoDirty()
    end
end)

-- PlayerDoTurn restore DIHAPUS PERMANEN
-- konflik dengan build state engine