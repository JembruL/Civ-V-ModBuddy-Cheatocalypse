-- Lua Script1
-- Author: CivicKr
-- DateCreated: 4/4/2026 9:13:07 PM
--------------------------------------------------------------
print("Yield Boost Global Loaded")

GameEvents.CityYield.Add(function(playerID, cityID, yieldType)
    local pPlayer = Players[playerID]
    if not pPlayer:IsHuman() then return end

    local city = pPlayer:GetCityByID(cityID)
    if not city then return end

    if city:IsHasBuilding(GameInfoTypes.BUILDING_CHEATOCALYPSE_STATUE) then
        return city:GetYieldRate(yieldType) -- +100%
    end
end)