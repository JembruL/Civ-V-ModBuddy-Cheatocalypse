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

local processedThisTurn = {}
GameEvents.PlayerDoTurn.Add(function(playerID)
    -- Reset guard di awal turn baru
    processedThisTurn[playerID] = {}
end)

-- =========================================================
-- BUILD EVENT — SIGNATURE BENAR
-- BuildFinished(playerID, x, y, buildType, bImprovement, bRoute, bClear)
-- TIDAK ada unitID, TIDAK ada bSucceeded
-- =========================================================
GameEvents.BuildFinished.Add(function(playerID, x, y, buildType, bCancelled)
    if bCancelled then return end
    
    local pPlayer = Players[playerID]
    if not pPlayer or not pPlayer:IsHuman() then return end
    
    -- GUARD: hanya proses sekali per unit per build event
    local plot = Map.GetPlot(x, y)
    if not plot then return end
    
    local unit = plot:GetUnit()  -- atau iterate units di plot
    if not unit then return end
    
    local unitID = unit:GetID()
    
    -- Cek guard
    if not processedThisTurn[playerID] then
        processedThisTurn[playerID] = {}
    end
    
    local guardKey = unitID .. "_" .. x .. "_" .. y
    if processedThisTurn[playerID][guardKey] then
        print("EngineerBuildSystem: Double-fire blocked for unitID=" .. unitID)
        return
    end
    processedThisTurn[playerID][guardKey] = true
    
    -- ... lanjut logic normal
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