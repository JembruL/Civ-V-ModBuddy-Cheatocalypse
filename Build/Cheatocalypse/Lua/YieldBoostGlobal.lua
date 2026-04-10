-- Lua Script1
-- Author: CivicKr
-- DateCreated: 4/4/2026 9:13:07 PM
--------------------------------------------------------------
print("Yield Boost Global Loaded")

local BUILDING_STATUE = GameInfoTypes.BUILDING_CHEATOCALYPSE_STATUE

GameEvents.PlayerDoTurn.Add(function(playerID)
    local pPlayer = Players[playerID]
    if not pPlayer or not pPlayer:IsHuman() then return end

    for city in pPlayer:Cities() do
        if city:IsHasBuilding(BUILDING_STATUE) then
            -- dummy building / mekanisme lain direkomendasikan jika ingin bonus yield dinamis
            -- jangan pakai GameEvents.CityYield (bukan Civ V API)
        end
    end
end)