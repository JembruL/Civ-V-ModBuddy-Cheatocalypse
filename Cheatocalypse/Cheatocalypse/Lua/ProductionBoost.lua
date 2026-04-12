-- Lua Script1
-- Author: CivicKr
-- DateCreated: 4/4/2026 10:00:17 PM
--------------------------------------------------------------
print("Production Boost Loaded")

function ApplyProductionBoost(playerID)

    local player = Players[playerID]
    if not player then return end
    if not player:IsHuman() then return end

    for city in player:Cities() do

        if city:IsHasBuilding(GameInfoTypes.BUILDING_CHEATOCALYPSE_STATUE) then

            local base = city:GetProductionTimes100()
            -- base/100 = production asli, *0.5 = 50%, *100 = kembali ke Times100 unit
            city:ChangeProduction(math.floor(base / 200))
            -- Ini BENAR secara matematis: base/100 * 0.5 = base/200
            -- Tapi ChangeProduction menerima unit normal (bukan Times100)
            -- Jadi: math.floor(base / 100) * 0.5 = math.floor(base / 200) ✓

        end

    end
end

GameEvents.PlayerDoTurn.Add(ApplyProductionBoost)