# Anims folder inspection (read-only audit)

Inspected from the repository's XML text assets on 2026-10-11. This report does not modify the source assets.

## `Anims/John Doe.rbxmx.txt`

- XML Roblox model; root Model name: `John Doe`.
- Contains 11 `KeyframeSequence` objects:
  - `Idle`
  - `Sprint`
  - `Walk`
  - `Stunned_Start`
  - `Stunned_Loop`
  - `Stunned_End`
  - `Execution_PlayerRig`
  - `Execution_KillerRig`
  - `Slash`
  - `Corrupt Energy`
  - `Digital Footprint`
- Parsed counts: 1,037 Keyframes, 8,372 Poses, 8 ParticleEmitters, 1 ScreenGui, 4 TextButtons.
- Also contains rig/pose names including `HumanoidRootPart`, `Torso`, `Left Leg`, `Right Leg`, `Left Arm`, `Right Arm`, `Head`, and claw-related pose names.

## `Anims/John Doe Kill Animations.rbxmx.txt`

- XML Roblox model; root Folder name: `John Doe Kill Animations`.
- Contains 8 `KeyframeSequence` objects:
  - `KillerExecution_Milestone4`
  - `KillerExecution_Screamer`
  - `VictimExecution_Screamer`
  - `KillerExecution_Milestone4Legacy`
  - `KillerExecution_Default`
  - `VictimExecution_Default`
  - `VictimExecution_Milestone4Legacy`
  - `VictimExecution_Milestone4`
- Parsed counts: 1,357 Keyframes, 9,994 Poses.
- Sequence metadata includes non-looping execution sequences and priority token 2 on the first inspected sequence.

## `Anims/motor6d template.rbxm`

- 99,194 bytes; Roblox binary model format.
- The connector can return a base64 representation, but this is not a plain XML dump. The Motor6D hierarchy has **not** been verified from the binary payload yet.

## Existing `System/John Doe.luau.txt` caution

The current script downloads external files and calls executor-only or restricted APIs such as `loadstring`, `game:HttpGet`, `replicatesignal`, `sethiddenproperty`, `setscriptable`, and attempts to manipulate simulation radius. It also contains fling-related logic and character joint-breaking behavior. This script is not a standard Roblox Studio LocalScript/ServerScript as-is.

## Next integration rule

Keep original RBXM assets unchanged. For an authorized Roblox Studio implementation, import the models in Studio, inspect their actual descendants, and use supported `Animator` / `AnimationTrack` workflows. Do not infer the binary template's contents or promise published-game playback without validating ownership/permissions and rig compatibility.
