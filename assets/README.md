# Assets

Runtime code builds the Stage 1 greybox. Drop exported models here when a stage needs them (`*.rbxm`).

## Outlines

Two methods, on purpose:

1. **Characters (heroes and monsters).** A `Highlight` with `FillTransparency = 1`, `OutlineTransparency = 0`, `OutlineColor = #1A1020`, `DepthMode = Occluded`. Roblox only shows about 31 Highlights per client, so the client enables Highlights on the 12 nearest characters.
2. **Static props.** Inverted hull: a duplicate mesh scaled up 3–4%, black, normals facing inward, modeled in Blender. Do not put Highlights on every prop.

No ripped sprites, meme audio, or brainrot AI images. Sounds and decals stay as ids in `src/shared/Config` until you upload originals.
