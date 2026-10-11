# RobuBubble no-fling accessory setup (Roblox Studio)

This branch adds an authorized Studio-side accessory setup. It is not a Delta/executor script and does not implement hat reanimation, fling, character takeover, loadstring, or hidden executor APIs.

## Avatarında zaten takılı aksesuarlar için

Bu kullanımda katalogdan yeniden içe aktarmak yerine `Studio/AvatarOutfitPreview.server.lua` dosyasını kendi deneyiminde `ServerScriptService` altına normal bir `Script` olarak koy. Betik, oyuncunun mevcut `Humanoid:GetAppliedDescription()` görünümünden — avatarda zaten takılı aksesuarlar dahil — ayrı, sabit ve çarpışmasız bir önizleme rig'i üretir. Oyuncunun asıl karakterini değiştirmez ve onu kontrol etmez.

Bu **hat reanimate değildir** ve Delta/executor içinde çalışmak üzere tasarlanmamıştır. Oyuncunun mevcut aksesuarlarını yeniden kullanarak Studio'da güvenli bir görsel önizleme sağlar. Sadece kendi Roblox deneyiminde, önce özel Studio test oturumunda dene.

## Files

- `Studio/AvatarOutfitPreview.server.lua` — oyuncunun o anki avatar görünümünü (takılı aksesuarlar dahil) ayrı, sabit bir önizleme rig'ine aktarır.
- `Studio/AccessoryInstaller.lua` — run once from the Roblox Studio Command Bar in your own experience. It attempts to import the supplied catalog IDs into `ServerStorage/RobuBubbleAccessories`.
- `Studio/RobuBubbleAccessories.server.lua` — place this as a normal Script in `ServerScriptService`. It attaches the head accessory and attempts to attach the five neck accessories.
- `Studio/AnimsAudit.lua` — read-only audit utility for imported animation/model instances.
- `Anims/INSPECTION.md` — verified inventory of the text XML animation assets.

## Setup

1. Open your own Roblox Studio place.
2. Run `Studio/AccessoryInstaller.lua` in the Command Bar once. Studio/InsertService may refuse assets that are not insertable by your account; check Output warnings.
3. Inspect every imported Accessory under `ServerStorage/RobuBubbleAccessories`. If an ID inserts a Model rather than an Accessory, the importer deliberately skips it instead of guessing its structure.
4. Add `Studio/RobuBubbleAccessories.server.lua` as a Script under `ServerScriptService`.
5. Test in a private Studio session with R6 and R15 rigs, and inspect the placement before publishing.

## Limitations to validate

- The outfit preview mirrors the currently applied appearance into a separate rig; it does not transfer player control or play a custom animation.
- The head accessory uses `Humanoid:AddAccessory`; its Handle should have a suitable attachment for the rig.
- Neck placement uses the Handle's `Color` as a heuristic: grey → torso, black → legs, white → arms. Textures may not match `Handle.Color`; the script logs ambiguous colors instead of guessing.
- Left/right selection is a simple deterministic split based on the asset ID. Adjust target sides and `Offsets` in the server script after visually checking each actual mesh.
- The script does not hide or destroy the character's Head and does not remove Motor6Ds.
- Roblox animation playback still depends on rig compatibility and animation ownership/permissions. The existing `.rbxmx.txt` files are model XML data, not automatically playable published AnimationIds.

## Safety

No fling, no reanimation, no joint destruction, and no executor-only API calls are included.
