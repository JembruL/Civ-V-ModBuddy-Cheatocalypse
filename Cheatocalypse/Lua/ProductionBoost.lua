-- Lua Script1
-- Author: CivicKr
-- DateCreated: 4/4/2026 10:00:17 PM
--------------------------------------------------------------
print("Production Boost Loaded")

function ApplyProductionBoost(playerID)

    local player = Players[playerID]
    if not player or not player:IsHuman() then return end

    for city in player:Cities() do

        if city:IsHasBuilding(GameInfoTypes.BUILDING_CHEATOCALYPSE_STATUE) then

            local baseTimes100 = city:GetProductionTimes100()
			local base = math.floor(baseTimes100 / 100)
			city:ChangeProduction(math.floor(base * 0.5))

        end

    end
end

GameEvents.PlayerDoTurn.Add(ApplyProductionBoost)