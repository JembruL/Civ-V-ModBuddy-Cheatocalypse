-- EngineerBuildSystem.lua (FIXED)
print("Cheatocalypse Engineer Build System Loaded")

local iUnitEngineer  = GameInfoTypes.UNIT_CHEAT_ENGINEER
local promoMaster    = GameInfoTypes.PROMOTION_CHEATO_MASTER_FLAG

-- Tabel pending restore: { [unitID] = playerID }
local pendingMoveRestore = {}

-- =========================================================
-- BUILD FINISHED HANDLER (hanya tandai, JANGAN restore di sini)
-- =========================================================
local function OnBuildFinished(playerID, unitID, x, y, buildType, bCancelled)

    if bCancelled then return end

    local player = Players[playerID]
    if not player then return end
    if not player:IsHuman() then return end  -- Layer 1

    local unit = player:GetUnitByID(unitID)
    if not unit then return end
    if unit:GetUnitType() ~= iUnitEngineer then return end
    if not unit:IsHasPromotion(promoMaster) then return end  -- Layer 2

    -- Tandai untuk restore di PlayerDoTurn berikutnya
    pendingMoveRestore[unitID] = playerID

    print(string.format("EngineerBuildSystem: Build selesai, unitID=%d ditandai untuk move restore", unitID))
end

-- =========================================================
-- DEFERRED RESTORE (dijalankan di awal giliran player)
-- =========================================================
local function OnPlayerDoTurn(playerID)

    local player = Players[playerID]
    if not player then return end
    if not player:IsHuman() then return end

    for unitID, ownerID in pairs(pendingMoveRestore) do

        if ownerID == playerID then

            local unit = player:GetUnitByID(unitID)

            if unit
            and unit:GetUnitType() == iUnitEngineer
            and unit:IsHasPromotion(promoMaster) then

                unit:SetMoves(unit:MaxMoves())
                print(string.format("EngineerBuildSystem: Moves restored untuk unitID=%d", unitID))

            end

            pendingMoveRestore[unitID] = nil
        end

    end
end

-- =========================================================
-- EVENT REGISTRATION (SATU KALI SAJA)
-- =========================================================
GameEvents.BuildFinished.Add(OnBuildFinished)
GameEvents.PlayerDoTurn.Add(OnPlayerDoTurn)