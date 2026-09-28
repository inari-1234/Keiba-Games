# Horse animation POC

This branch evaluates replacing the current shader-distorted static horse illustration with a baked 2D gallop cycle.

## Selected source for the first POC

- Quaternius — Ultimate Animated Animal Pack
- Horse model with authored `Gallop` clip
- CC0 1.0
- Official source: https://quaternius.com/packs/ultimateanimatedanimals.html
- Runtime mirror is pinned to BibliothecaDAO/eternum commit `a375655955d08b96201e40500a52ddc6a9278b48`
- Pinned runtime GLB SHA-256: `3cccb8c0ac6c77f7e6b59e2ee3743d148d4714a7b5a094258a36fa664fd602c5`

The mirror's provenance file records conversion from the official Quaternius Horse.gltf without changing the 50-joint skin, eight flat-color materials, or 13 authored clips.

## Why this is isolated from production

The current app draws the existing `HorseAvatarView` and applies `HorseMotion.metal` distortion. The POC does not replace that code yet.

GitHub Actions downloads the pinned CC0 GLB, verifies its SHA-256, renders 12 transparent side-profile Gallop frames in Blender, and produces contact sheets at 512 px, 96 px, and the app's current 76 px horse-size ceiling.

Only after the 76 px result is visually accepted should the baked frames be added to `Assets.xcassets` and `AnimatedHorseView` switched from shader deformation to frame animation.
