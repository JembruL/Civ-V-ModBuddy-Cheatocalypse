-- Lua Script1
-- Author: CivicKr
-- DateCreated: 4/4/2026 10:00:17 PM
--------------------------------------------------------------
print("Production Boost Loaded")

function ApplyProductionBoost(playerID)

    local player = Players[playerID]
    if not player:IsHuman() then return end

    for city in player:Cities() do

        if city:IsHasBuilding(GameInfoTypes.BUILDING_CHEATOCALYPSE_STATUE) then

            --local base = city:GetProductionTimes100()
            --city:ChangeProduction(base / 2) -- +50%
			local base = city:GetProductionTimes100()
			city:ChangeProduction(math.floor(base / 200))  -- base/100 = production normal, /2 = +50%

        end

    end
end

GameEvents.PlayerDoTurn.Add(ApplyProductionBoost)