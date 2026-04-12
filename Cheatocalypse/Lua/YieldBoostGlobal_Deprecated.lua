-- Lua Script1
-- Author: CivicKr
-- DateCreated: 4/4/2026 9:13:07 PM
--------------------------------------------------------------
-- YieldBoostGlobal.lua
-- GameEvents.CityYield TIDAK EXIST di Civ V.
-- Yield bonus sudah di-handle via XML Building_YieldChanges.
-- File ini sengaja dikosongkan untuk menghindari silent dead code.
print("YieldBoostGlobal: Yield handled via XML Building_YieldChanges. No Lua override needed.")

GameEvents.CityYield.Add(function(playerID, cityID, yieldType)
    local pPlayer = Players[playerID]
    if not pPlayer or not pPlayer:IsHuman() then return end

    local city = pPlayer:GetCityByID(cityID)
    if not city then return end

    if city:IsHasBuilding(GameInfoTypes.BUILDING_CHEATOCALYPSE_STATUE) then
        local base = city:GetBaseYieldRate(yieldType)
        if base and base > 0 then
            return base -- add +100% of BASE only (stack-safe)
        end
    end
end)