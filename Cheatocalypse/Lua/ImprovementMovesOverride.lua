-- Lua Script1
-- Author: CivicKr
-- DateCreated: 4/6/2026 1:57:40 PM
--------------------------------------------------------------
local iUnitEngineer = GameInfoTypes.UNIT_CHEAT_ENGINEER
local promoMaster   = GameInfoTypes.PROMOTION_CHEATO_MASTER_FLAG

-- =========================================================
-- VISION OVERRIDE
-- =========================================================
local VISION_RADIUS = 5

GameEvents.PlayerDoTurn.Add(function(playerID)

	local pPlayer = Players[playerID]
	if not pPlayer then return end
	local teamID = pPlayer:GetTeam()

	-- HARD FILTER: HUMAN ONLY
	if not pPlayer:IsHuman() then return end

	for unit in pPlayer:Units() do
		if unit:GetUnitType() == iUnitEngineer then

			-- FIX: jangan return, cukup skip unit ini
			if unit:IsHasPromotion(promoMaster) then

				local ux = unit:GetX()
				local uy = unit:GetY()

				for dx = -VISION_RADIUS, VISION_RADIUS do
					for dy = -VISION_RADIUS, VISION_RADIUS do

						local plot = Map.GetPlot(ux + dx, uy + dy)
						if plot then
							plot:SetRevealed(teamID, true, false, -1)
						end

					end
				end

			end
		end
	end

end)
