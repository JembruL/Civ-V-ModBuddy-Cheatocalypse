# Cheatocalypse (Civ V Mod) AA

A high-power Civilization V sandbox mod focused on **system stability**, **controlled cheat ownership**, and **anti-AI-abuse safeguards**.

## Current Implementation Status

### 1) Security Model (3 Layers)
- **Layer 1:** `player:IsHuman()`
- **Layer 2:** `PROMOTION_CHEATO_MASTER_FLAG`
- **Layer 3:** optional feature flags (example: security logging)

Active implementation in `Lua/CoreSystem.lua`:
- AI is blocked from training master units through `GameEvents.PlayerCanTrain`.
- Non-human master units are purged through `GameEvents.UnitCreated`.
- AI ownership of `BUILDING_CHEATOCALYPSE_STATUE` is cleaned up every turn.

### 2) Statue Buff Authority (anti-stacking)
- Single source of truth for statue buff is `Lua/BuildingEffects.lua`.
- Duplicate statue hook in `CoreSystem.lua` was removed to prevent movement stacking (`SetMoves` + `ChangeMoves`).
- `PROMOTION_CHEATO_STATUE_BUFF` remains active (strength/XP/visibility bonuses are defined in XML promotion data).

### 3) Engineer Build System (unit-scoped)
- Global `<Builds><Update Time="0"/>` overrides in `XML/Unit/Unit_Engineer.xml` were removed to avoid affecting all workers globally.
- Engineer behavior was moved to `Lua/EngineerBuildSystem.lua` via `GameEvents.BuildFinished`:
  - Only `UNIT_CHEAT_ENGINEER` + `PROMOTION_CHEATO_MASTER_FLAG` + human owner are processed.
  - Movement is restored to `MaxMoves()` after build completion, allowing same-turn chain actions.

### 4) Improvement & Vision Override
- `Lua/ImprovementMovesOverride.lua` now focuses on engineer vision override.
- Duplicate build-finished handler was removed from this file (moved to `EngineerBuildSystem.lua`).


# Compatibility
- Targeted for Civilization V (BNW) using event-driven Lua + XML database updates.
- In-game smoke testing is recommended after each event-hook change.
