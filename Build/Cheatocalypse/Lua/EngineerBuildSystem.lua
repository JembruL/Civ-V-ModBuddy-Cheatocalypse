-- Lua Script1
-- Author: CivicKr
-- DateCreated: 4/10/2026 10:15:00 AM
--------------------------------------------------------------
print("Cheatocalypse Engineer Build System Loaded")

local iUnitEngineer = GameInfoTypes.UNIT_CHEAT_ENGINEER
local promoMaster   = GameInfoTypes.PROMOTION_CHEATO_MASTER_FLAG

-- =========================================================
-- BUILD FINISHED: UNIT-SCOPED INSTANT CHAIN
-- =========================================================
-- Catatan:
-- - Tidak menyentuh tabel Builds global (aman untuk semua worker lain).
-- - Engineer cheat yang valid langsung dipulihkan movement setelah build selesai,
--   sehingga bisa lanjut aksi/build lain pada turn yang sama.
GameEvents.BuildFinished.Add(function(playerID, x, y, improvementType)
    local pPlayer = Players[playerID]
    if not pPlayer or not pPlayer:IsHuman() then return end

    for unit in pPlayer:Units() do
        if unit:GetUnitType() == iUnitEngineer
        and unit:IsHasPromotion(promoMaster)
        and unit:GetX() == x
        and unit:GetY() == y then
            unit:SetMoves(unit:MaxMoves())
            return
        end
    end
end)