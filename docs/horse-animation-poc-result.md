# Horse animation POC — validation result

Date: 2026-09-28  
Branch: `candidate/horse-animation-poc`  
Validated commit: `eb762c31e12a82562ea96f72084bf7ecbab637ac`  
GitHub Actions run: `36430419432` — SUCCESS  
Artifact: `horse-animation-poc` / ID `10973720441`

## Result

Quaternius Ultimate Animated Animal Pack / Horse is accepted as the **motion-source candidate** for the next race-animation prototype.

This is not approval to replace the production horse artwork unchanged.

### Verified

- Source model is pinned and SHA-256 verified.
- License provenance is CC0 1.0.
- Imported horse contains authored `Gallop` and `Gallop_Jump` clips.
- Blender 4.0.2 headless import and rendering succeed on GitHub Actions.
- The selected `Gallop_AnimalArmature` action renders as a 12-frame transparent cycle.
- 512 px, 96 px and 76 px review sheets are generated.
- 76 px matches the current `RaceLiveView` horse-size ceiling.
- Automated motion check detects meaningful frame-to-frame change.
- The current iOS app does not need to ship the GLB; final runtime can remain 2D.

### POC metrics

- Authored action range: 0.0–14.4000005722 frames
- Render FPS: 24
- Preview frames: 12
- Alpha coverage: 0.1012–0.1154
- Consecutive-frame mean difference: 2.9823–7.0555
- Authored loop endpoint mean difference: 2.4559

## Visual gate

The horse gait remains legible at 76 px, but the raw Quaternius render is only a horse. It does not yet reproduce the game's jockey, racing silks, saddlecloth/number presentation, or final kawaii art direction.

Therefore production `AnimatedHorseView` and `HorseMotion.metal` remain unchanged at this gate.

## Next prototype

Build an offline composite source:

1. Quaternius Horse + authored Gallop.
2. CC0 humanoid base character for the jockey.
3. Seated/riding pose anchored to the horse saddle region.
4. Jockey helmet and racing-silk colors.
5. Render the combined subject from the same locked side camera.
6. Review at 76 px before changing the SwiftUI race view.

Quaternius Universal Base Characters and Universal Animation Library are suitable CC0 inputs for this rider prototype; the latter includes sitting animations and shares the publisher's retargetable humanoid workflow.

## Promotion rule

Do not replace the production horse renderer until a combined horse+jockey 76 px preview is visually accepted and the candidate app passes its existing build/tests.
