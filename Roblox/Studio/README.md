# Aizen Hub — Roblox Studio scaffold

This folder is a separate Roblox Studio addition; it does not replace the existing Orbit Pop web game.

## Install
1. Open your own Roblox experience in Studio.
2. Create a LocalScript in `StarterPlayer > StarterPlayerScripts`.
3. Copy `AizenHub.client.lua` into it.
4. In the `ANIMATIONS` table, replace the `0` placeholders with animation IDs you own or are authorized to use.
5. Test with both R6 and R15 rigs. Animation assets must be compatible with the character rig and permitted for the experience.

## Scope
- Aizen-inspired draggable local UI.
- Buttons for Idle, Pose, and Attack animations.
- Stops the previous selected track before playing another.
- Does not alter other players, apply fling/physics to other characters, or use executor-only APIs.

## HAT reanimation
HAT reanimation has not been embedded in this scaffold. This is a Studio-safe local animation starter, not a Delta executor script.
