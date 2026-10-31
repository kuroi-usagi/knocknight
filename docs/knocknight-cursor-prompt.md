# KNOCKNIGHT: build brief for Cursor's agent (Roblox, Mac)

> Paste this whole file into Cursor's agent chat (Agent mode) at the root of an empty folder named `knocknight/`. **Work in stages (see §0): build one stage, stop, give me a test checklist, and wait for my "good, continue" before the next stage. On approval, commit and push to my GitHub repo.** **Ask me (the user) before you do anything that needs my Roblox account**, such as publishing, creating Game Passes or Developer Products, uploading assets, changing Creator Dashboard settings, or installing a Studio plugin from the Creator Store. Show me what you need and wait. Don't guess IDs. Use clearly marked placeholders instead.

---

## 0. HOW TO WORK: STAGED BUILD (read this first)

**Treat this whole document as the design bible.** Read all of it so the architecture is right from day one: config-driven numbers, a server-authoritative state machine, room for every monster and system. But **implement ONLY the current stage.** Don't build features from later stages early; leave clean extension points (stub modules with `-- TODO(Stage N)`) instead.

### The loop for every stage
1. **Build** only what that stage lists in the table below.
2. **Self-check:** run `stylua .` then `selene src`, and fix every error. Make sure `rojo build -o knocknight.rbxlx` succeeds.
3. **STOP and hand me a test checklist** (no more than 15 lines) with:
   - how to start: run `rojo serve` in Cursor's terminal → open/refresh `knocknight.rbxlx` in Studio → Plugins → Rojo → **Connect**
   - **Play (F5)** for solo, then **Test → Clients and Servers → Local Server, 2 players** (also 4 for multiplayer stages)
   - 5–10 concrete things to check, each with the expected result (for example "Close the West door: power drain shows 2 bars; door blocks Boneca")
   - known issues and debug-panel shortcuts
4. **Wait.** Don't start the next stage until I reply **"good, continue"** (or similar). If I report bugs, fix them in the same stage and give me the checklist again.
5. **When I approve:**
   - add a CHANGELOG entry
   - `git add -A`, then `git commit -m "Stage N: <summary>"`
   - `git push`
   - optionally `git tag stage-N` (and a night tag such as `night-1`) followed by `git push --tags`
   - then tell me the commit hash
   - Never force-push and never rewrite pushed history. Never commit secrets, `.rbxl`/`.rbxlx` builds, or `Packages/`.

### Stages
| Stage | Scope | Done when (acceptance) | Tag |
|---|---|---|---|
| **0: Toolchain + repo** | §2 setup: Rokit (rojo, wally, stylua, selene), `wally install`, §3 folder skeleton, `default.project.json`, `selene.toml`, `stylua.toml`. `git init -b main`; a `.gitignore` covering `Packages/ ServerPackages/ DevPackages/ sourcemap.json *.rbxl *.rbxlx *.rbxl.lock *.rbxlx.lock .DS_Store roblox.toml.local`; a README (setup, `rojo serve`, the manual Studio steps, the stage list). **Ask me for my GitHub repo URL**, then `git remote add origin <URL>`, make the first commit, and `git push -u origin main`. If the push fails on auth, tell me to run `gh auth login` (or set up an SSH key) myself. Don't handle my credentials. | An edit to a `.luau` file in Cursor shows up in Studio within 2 s; lint/format pass; the repo on GitHub shows the skeleton | `stage-0` |
| **1: Playable Night 1** | Simple in-place Lobby (ready pads) → Camp (20 s timer only; no leveling yet) → Night 1 Roam (150 s, 3 fuses, Candy pickups shown but not saved) → Last Call → Defend 12–6 AM (West/East doors, hall lights, Vent and Skylight as closed props only, power system per §7, **at least 4 camera feeds**, breaker panel) → Dawn or Game Over → back to Camp. **Night 1 monsters only** (Boneca Ambalabu, Lirili Larila, Chimpanzini banana form) with their tells and counters. **One jump scare** at minimum (Boneca's), ideally one per Night 1 monster. Heroes: Pip minimum, ideally all 4 at skill rank 1. Courage, downed state, revive (hold E 3 s), and ghost-spectate. **Map:** Borgo Mezzanotte greybox with all districts blocked out, plus core art (outlines via Highlight, palette, lighting, ColorCorrection/Bloom, fonts). First-night hint. Debug panel. Multiplayer works for 1–4 players with shared power and tasks. No DataStore yet (keep in-memory stubs behind the `DataService` interface). | Can win at 6 AM and lose by power-out or a team wipe; every tell plays before an attack; numbers match §7/§10 (Night 1 row); a Local Server with 2 players (and 4) has no errors in the Output window | `stage-1`, `night-1` |
| **2: Camp leveling + persistence** | §11 XP/levels/ranks/passive picker, Camp UI (level, XP, next unlock), Candy, revive token (Candy); ProfileStore persistence per §4.3, bestNight, Studio `DEV_` store. Needs "Enable Studio Access to API Services" (I do that; it requires a first private publish, see "Demo & deploy" below). | Rejoining restores data; the XP curve unit test passes; session lock blocks a double load | `stage-2` |
| **3: Night 2: grabbers** | Patapim, Cappuccino Assassino, the red-flash grab system, Marrow's Shove (full), Night 2 row | Each new monster's tell → counter → result works, shown with `DebugSpawn` | `stage-3`, `night-2` |
| **4: Night 3: lights out** | La Vaca Saturno Saturnita (eclipse, stare meter), Chimpanzini Buff form and peels, all 10 camera feeds | Night 3 row | `night-3` |
| **5: Night 4: mixed tells** | Tralalero (Beach Hut cam, sprint), Ballerina Cappuccina (marks) and the Coffee Clan synergy | Speed check: base Marrow can't outrun Tralalero; leveled players can | `night-4` |
| **6: Night 5: The Knock** | Tung Tung Tung Sahur mini-boss, Answer Bell, Front Door, Curfew hunter, banner | Knock timing per §9.1; an early ring counts as a miss | `night-5` |
| **7: Night 6: Air Raid** | Bombardiro + Gusini (skylight, vent, searchlight, ink-pies), the Feud | Night 6 row | `night-6` |
| **8: Shop + Robux** | §12 Candy shop, cosmetics, Moon Coins dev products, game passes, ProcessReceipt idempotency. **Ask me** to create the products and passes, and use placeholder IDs until I paste the real ones. | The same PurchaseId twice grants once; Studio test purchases work; nothing affects stats | `stage-8` |
| **9: Nights 7–10 + endless** | Encore modifiers, Eclipse Night mini-boss (N10), the §10 endless formula, mini-boss rotation (Air Raid at N15, optional Grand Knock at N20), Frigo/Trippi optional | Simulated Night 30 has no errors and AI caps at 20 | `night-10` |
| **10: Polish + art/audio/UI pass** | Full §5 art, all §13 screens, §14 audio, Reduced Scares, mobile and gamepad, optional leaderboard and Lobby place (§16), anti-exploit audit (§17), performance (§18) | 60 fps on my Mac in a 4-player local server; a 2-hour playtest has no server errors | `stage-10` |
| **11: Release prep** | Publish checklists (§21), drafted maturity answers, thumbnail/icon list, balance pass | I publish | `v1.0` |

If a stage is too big to test comfortably, split it (1a/1b) and tell me before you start.

### Demo & deploy (I do these steps; you remind me at the right stage)
- **Local testing:** Studio **Play** (F5) for solo; **Test → Clients and Servers → Local Server** with 2–4 players for multiplayer. No publishing is needed for Stage 1.
- **First private publish (before Stage 2):** **File → Publish to Roblox** creates the experience. Keep the audience set to **Playtest** (Roblox's current name for the old "Private" setting) and don't make it Public yet. Then go to Game Settings → Security → **Enable Studio Access to API Services**; DataStores in Studio need it.
- **Demo to friends:**
  - Click **Collaborate** (top right of Studio) → **Early testers** and add up to 10 friends. They can play the Playtest build in the Roblox app, with a preview watermark. You can also manage this in Creator Hub → Creations → (game) → Configure → Permissions.
  - Or add them as **collaborators** (Team Create) and use **Test → Team Test** to play together inside Studio.
  - Re-publish (File → Publish to Roblox) after each approved stage so testers get the latest build.
- **Going public later (Stage 11):** finish the audience/maturity flow in Creator Hub (Manage Audience), then switch from Playtest to **Public**.
- Git is the source of truth for code. The published place is just a build. Map geometry edited in Studio must be exported into `assets/*.rbxm` (or kept synced via Rojo) and committed, or it isn't backed up. Remind me of this at every stage hand-off.

---

## 1. Role and goal

You are a senior Roblox engineer and game designer working in Luau. Build **KNOCKNIGHT**, an online co-op Halloween horror survival game for 1–4 players per server. The goal is to see **how many nights in a row** a team can survive.

- **Inspiration:** Five Nights at Freddy's (FNAF) for the defend-the-room tension (doors, cameras, limited power, monster AI levels that rise each night, jump scares). Cuphead for the **1930s rubber-hose cartoon look**. These are **inspiration only**. Don't copy any character, sprite, sound, UI layout, font file or asset from either franchise. FNAF belongs to Scott Cawthon. Cuphead belongs to StudioMDHR.
- **Monsters:** characters from the "Italian brainrot" meme universe, rebuilt as original cartoon models from Roblox parts and meshes. Each one gets an AI behavior, a readable tell, a counter, and a jump scare. All of them are built from config so they can be renamed or reskinned later (see §15, IP risk).
- **Players:** four original survivor heroes (Pip, Marrow, Wick, Nim). They are limbless cartoon characters with big heads, floating gloves and shoes, and thick outlines, set on a candy-colored Halloween night.
- **Tone:** spooky-silly, **no gore** (no blood, wounds or body horror). Jump scares should be loud and sudden but cartoon. Aim for a **Mild** maturity label on Roblox.
- **Score:** nights survived in a row. Death keeps your level but resets the night counter.

Where this brief gives a number, use it. Every tunable value goes in `src/shared/Config/*.luau` so I can rebalance without touching logic.

---

## 2. Tech stack and Mac setup (Stage 0)

**Target:** Roblox Studio for macOS (native Apple Silicon), Luau with `--!strict` where practical, and Cursor as the editor. Code lives on disk and syncs into Studio through **Rojo 7**.

### 2.1 Toolchain (Rokit-managed)
1. Check for Homebrew and git (`brew --version`, `git --version`). If either is missing, tell me the install command and ask before running it.
2. Install **Rokit** (the Rojo team's toolchain manager; it replaces Aftman/Foreman):
   `curl -fsSL https://raw.githubusercontent.com/rojo-rbx/rokit/main/scripts/install.sh | sh`, then restart the shell.
3. In the repo, run `rokit init`, then `rokit add rojo-rbx/rojo`, `rokit add UpliftGames/wally`, `rokit add JohnnyMorganz/StyLua`, `rokit add Kampfkarren/selene`, `rokit add JohnnyMorganz/wally-package-types`, and finally `rokit install`. Pin exact versions in `rokit.toml`. Use the latest Rojo 7.x; Roblox's docs show 7.6.1 at the time of writing. If Rokit fails, Aftman is an acceptable fallback, but say so.
4. Create `wally.toml` and run `wally install`. Before adding a package, check its current name and version on wally.run. Suggested packages:
   - **ProfileStore** (by loleris) for session-locked player data. If it isn't on Wally, vendor it into `src/server/Vendor/` with its license.
   - **Promise** (evaera)
   - **Signal** (sleitnick or stravant GoodSignal)
   - **Janitor** or Trove for cleanup
   - Optional: **TestEZ** or Jest-Lua for tests (dev dependency)
   - Avoid big frameworks (Knit and similar). Keep the architecture plain and explicit.
5. Run `rojo sourcemap default.project.json -o sourcemap.json` and wally-package-types so the Luau LSP gets types.
6. Add a `selene.toml` with `std = "roblox"` and a `stylua.toml` (tabs, column width 120). Add a `Makefile` or `scripts/` with `fmt`, `lint`, `serve`, `build` and `sourcemap`.
7. Cursor extensions to recommend in `.vscode/extensions.json`: **Luau Language Server** (JohnnyMorganz), **Selene**, **StyLua**, and **Rojo** if it's available in Cursor's marketplace. If it isn't, the CLI is enough.
8. Git: follow the Stage 0 row in §0 (`git init -b main`, `.gitignore`, README, my GitHub remote, first push).

### 2.2 Manual steps for me (list these clearly; don't do them yourself)
1. Install **Roblox Studio for Mac** from create.roblox.com and sign in.
2. Install the **Rojo plugin**. Either you run `rojo plugin install` once I say OK, or I install it from the Creator Store.
3. Open the place: `rojo build -o knocknight.rbxlx`, open that file in Studio, run `rojo serve` in Cursor's terminal, then click **Plugins → Rojo → Connect** in Studio.
4. Publish once (File → Publish to Roblox) so the experience gets a universe ID. Then go to **Game Settings → Security → Enable Studio Access to API Services**. DataStores don't work in Studio playtests without this.
5. Later, in Stage 8: create Game Passes and Developer Products on the **Creator Dashboard → Creations → (experience) → Monetization**. I'll paste the IDs into `src/shared/Config/Monetization.luau`.
6. Fill in the **Maturity & Compliance questionnaire** (Creator Dashboard → Audience) before going public.

---

## 3. Repo structure

```
knocknight/
  rokit.toml  wally.toml  default.project.json  selene.toml  stylua.toml  README.md
  src/
    server/                         -> ServerScriptService.Server
      Main.server.luau              (bootstraps services in order)
      Services/
        GameStateService.luau       (state machine)
        NightService.luau           (roam + defend timers, hour clock, tasks)
        PowerService.luau           (power pool, drains, blackouts)
        SafeRoomService.luau        (doors, lights, cameras, hatch, vent, answer bell)
        MonsterDirector.luau        (spawns, AI levels, movement rolls)
        PlayerStateService.luau     (courage/HP, downed, revive, spectate)
        SkillService.luau           (server-validated skills + cooldowns)
        ProgressionService.luau     (XP, levels, ranks, passives)
        DataService.luau            (ProfileStore wrapper, schema, migration)
        ShopService.luau            (Candy shop, cosmetics, revive token)
        MonetizationService.luau    (ProcessReceipt, game passes)
        LeaderboardService.luau     (OrderedDataStore best night; stretch)
        AntiExploitService.luau
      Monsters/
        MonsterBase.luau            (shared FSM, pathing, grab, jump scare trigger)
        TungTungTungSahur.luau  BallerinaCappuccina.luau  CappuccinoAssassino.luau
        TralaleroTralala.luau  BombardiroCrocodilo.luau  BombombiniGusini.luau
        BrrBrrPatapim.luau  LiriliLarila.luau  ChimpanziniBananini.luau
        BonecaAmbalabu.luau  LaVacaSaturnoSaturnita.luau
    client/                         -> StarterPlayer.StarterPlayerScripts.Client
      Main.client.luau
      Controllers/ (InputController, CameraFeedController, JumpScareController,
                    HUDController, CampUIController, ShopUIController, SpectateController,
                    AudioController, PostFXController, TellFXController)
      UI/ (one ModuleScript per screen; build UI in code or from .rbxm in assets/)
    shared/                         -> ReplicatedStorage.Shared
      Config/ (Game.luau, Nights.luau, Monsters.luau, Heroes.luau, Progression.luau,
               Shop.luau, Monetization.luau, Audio.luau, Palette.luau)
      Net/Remotes.luau             (single place that defines every remote + payload types)
      Types.luau  Util/ (Rng.luau, Timer.luau, Validate.luau)
  assets/ (rbxm models: map chunks, monster rigs, hero rigs; documented in assets/README.md)
  tests/  (pure-logic unit tests for Power, AI rolls, XP curve, receipt idempotency)
```

`default.project.json` maps `Packages` to ReplicatedStorage.Packages and `ServerPackages` to ServerScriptService.ServerPackages. Keep the map geometry in Studio (or in `.rbxm` chunks under `assets/`) and code on disk. Workspace geometry doesn't sync from disk unless you choose `.rbxm` chunks. Tell me which approach you picked.

---

## 4. Architecture

### 4.1 Server-authoritative state machine
`GameStateService` is the single source of truth. It replicates its state through a `StateChanged` RemoteEvent and attributes on a `ReplicatedStorage.GameState` Folder.

```
Lobby ──(all ready or 30 s countdown with ≥1 ready)──► Camp
Camp  ──(20 s timer; +10 s if anyone has the shop open, max 40 s)──► Night.Roam
Night.Roam (150 s) ──(Midnight Bell)──► Night.LastCall (20 s) ──► Night.Defend (6 "hours" × 60 s = 360 s)
Night.Defend ──(6 AM reached and ≥1 player alive)──► Dawn (8 s: banner, XP, Candy) ──► Camp (night+1)
Any Night state ──(all players downed/ghost)──► GameOver (12 s: summary, best saved) ──► Camp (night=1)
```
- The night counter is per server run. Every player present at dawn gets credit for that night. A player who joins mid-night spectates until the next Camp.
- Use one `Timer` util that runs on the server clock. Clients get `endsAt = workspace:GetServerTimeNow() + duration` and count down locally.

### 4.2 Remotes and validation
- Define every remote in `shared/Net/Remotes.luau`: `RequestAction` (RemoteEvent, enum action plus small payload), `RequestSkill`, `RequestShop`, `RequestCamera`, `StateChanged`, `JumpScare`, `TellFX`, `Toast`. Use a RemoteFunction only for the shop catalog fetch.
- The server validates every call:
  - type checks on every field
  - the player is alive and in the right state
  - distance checks (interactions ≤ 10 studs; safe-room controls require the player to be inside the SafeRoom region)
  - cooldowns kept on the server
  - a rate limit of 20 requests per second per player per remote. Drop anything over the limit and count strikes; after 3 strikes in 60 s, log it and ignore the player for 5 s.
- The client never decides damage, grabs, power, door state, XP, Candy or purchases.

### 4.3 Persistence (DataStore)
- Use **ProfileStore** (session-locked) with key `Player_<UserId>`. If you can't use ProfileStore, implement `UpdateAsync` with a session lock field (`lockedBy = game.JobId`, `lockedAt`) that expires after 30 min, plus exponential backoff retries (5 tries: 1, 2, 4, 8, 16 s).
- Schema v1:
  ```lua
  { version=1, level=1, xp=0, passives={}, candy=0, stars=0,
    bestNight=0, bestNightHero="", totalNights=0,
    ownedCosmetics={}, equipped={gloves="",shoes="",lantern=""}, reviveTokens=0,
    purchaseHistory={},  -- [PurchaseId]=true, keep last 200
    settings={reducedScares=false, sfx=1, music=0.7} }
  ```
- Save on dawn, on game over, on purchase, on leave and in `BindToClose`, plus autosave every 120 s. Write a migration function for future versions.

### 4.4 Monster AI
- `MonsterBase` runs a finite state machine: `Dormant → Roam → Investigate → Stalk → Windup → Attack → Recover` (and `Retreat`). Every monster's tell plays during `Windup` and is the player's counter window.
- **AI level 0–20, FNAF-style.** Each monster has a `moveInterval` (seconds). Every interval the server rolls `rng:NextInteger(1,20)`; if `roll <= aiLevel`, the monster advances one node along its route, or one behavior step. AI 0 means it never moves. AI 20 means it moves every interval. AI levels come from `Config/Nights.luau` and can rise during the night at 2 AM and 4 AM, as in FNAF.
- **Roam phase (open map):** monsters chase players using `PathfindingService:CreatePath` with an agent sized per monster. Recompute the path every 0.5 s while chasing and every 2 s while roaming. Only one `ComputeAsync` runs per monster at a time. Fall back to a direct `MoveTo` when there's line of sight and the target is under 12 studs away. Call `SetNetworkOwner(nil)` on monster assemblies. Perception: sight cone 90° and 60 studs (raycast for line of sight); hearing radius 25 studs when a player sprints and 40 studs when a skill makes noise.
- **Defend phase (safe room):** monsters move along authored **node graphs** (Folder of Attachments named `CAM_x` nodes → `DOOR_W` / `DOOR_E` / `VENT` / `SKYLIGHT` / `FRONT`). Movement uses the AI rolls, not pathfinding. This keeps behavior readable on cameras.
- Per-player scaling: `effectiveAI = clamp(baseAI + (playerCount-1), 0, 20)`. Roam monster count gets +1 for 3 and 4 players.
- Seed the RNG per night so issues can be reproduced. Log `seed` in the debug overlay.

---

## 5. Art direction: Cuphead-inspired, original assets

- **Look:** 1930s rubber-hose animation. Bouncy, squash-and-stretch idles (tween Size/CFrame on a 0.5 s sine loop), "pie-cut" eyes (black disc with a wedge cut out, made as a Decal or SurfaceGui), white four-finger gloves, oversized shoes, grinning mouths. Monsters should look like they belong on a vintage cartoon reel, not like the AI images.
- **Construction:** low-poly MeshParts or Parts with **SmoothPlastic** and flat colors, simple painted textures (I'll upload those), no realistic materials.
- **Thick outlines:** a `Highlight` on each hero and monster (`FillTransparency = 1`, `OutlineTransparency = 0`, `OutlineColor = #1A1020`, `DepthMode = Occluded`). Roblox caps visible Highlights at about 31 per client, so the client enables Highlights only on the 12 nearest characters. Static props get the inverted-hull method instead: a duplicate mesh scaled up 3–4% with a black, inward-facing material, modeled in Blender. Document both methods.
- **Palette** (`Config/Palette.luau`): Pumpkin #FF7A1A, Candy Pink #FF5FA2, Ghost Mint #7CF5C8, Grape Night #3A1F5C, Ink #1A1020, Cream Paper #F6E7C1, Lantern Gold #FFC94A, Danger Red #FF2E3A (used *only* for grab flashes and the knock-charge warning).
- **Lighting:** `Lighting.Technology = Future` (fall back to ShadowMap on low-end devices automatically). Night ClockTime 0.5, Ambient #2A1840, OutdoorAmbient #3A2A5A, Atmosphere density 0.35 tinted grape. Point lights from jack-o'-lanterns and streetlamps.
- **Post FX:** ColorCorrection (Saturation 0.25, Contrast 0.15, TintColor #FFF1D6 for a warm vintage-film look), Bloom (Intensity 0.6, Threshold 1.2), and a light vignette. Add a full-screen **film grain and scratch overlay**: ImageLabel with a tiled noise texture whose offset jitters at 12 fps, transparency 0.88, and an off switch in Settings. Add a quick "iris-in/iris-out" circle wipe for transitions, the 1930s cartoon way.
- **Fonts:** built-in Roblox fonts only. Titles in `Enum.Font.Creepster` or `LuckiestGuy`, body text in `FredokaOne`/`Fredoka`, numbers in `Bangers`. Text gets a thick UIStroke (2–3 px, Ink).
- **Heroes are limbless:** a custom `StarterCharacter` rig with Head (2× scale), a small torso "bean", and two floating gloves and two floating shoes welded to invisible limb parts so animations still drive them. Keep the default Humanoid so movement and pathing work. The design must be original (not Rayman-like specifics: no hoodie or hair tuft lookalike).

---

## 6. The map: **Borgo Mezzanotte** ("Midnight Village")

A compact cartoon Italian hill town on Halloween night, about 400×400 studs, with every district built from a monster's meme lore. Cobblestones, string lights, a giant cartoon moon, and the distant drum of the night watch. In the center is **Il Rifugio**, a trattoria cellar that serves as the safe room.

| District / room | Derived from | Roam-phase content |
|---|---|---|
| **Piazza della Campana** (bell square, center) | Night-watch drum / bell (Tung) | The Midnight Bell tolls here; the Rifugio entrance; the camp at day |
| **Caffè Cappuccino** (café + dance studio upstairs) | Ballerina & Cappuccino Assassino (the "Coffee Clan") | Fuse box #1; espresso-machine steam vents; mirrored dance floor |
| **Lungomare Tralala** (boardwalk + beach huts) | Tralalero (beach, sneakers, speed) | Long straight runs (danger for slow heroes); Candy caches |
| **Aeroporto Coccodrillo** (rickety airfield, hangar) | Bombardiro Crocodilo & Bombombini Gusini | Fuse box #2 in the control tower; searchlights sweep |
| **Bosco Patapim** (dense cartoon forest) | Brr Brr Patapim (forest guardian with big feet) | Tree-disguise ambushes; Lantern Oil pickups |
| **Serra Lirilì** (desert greenhouse with cacti and clocks) | Lirili Larila (cactus-elephant, stops time) | Ticking clocks; Fuse box #3 |
| **Mercato Banana** (night market) | Chimpanzini Bananini | Banana crates (some are monsters); food stall Candy |
| **Via della Pioggia + Stazione di Servizio** (rainy street + gas station) | Boneca Ambalabu (frozen mid-walk on a rainy street; the oil-leak backstory) | Permanent cartoon rain; tire tracks; oil puddles (slippery) |
| **Osservatorio Saturno** (hilltop observatory) | La Vaca Saturno Saturnita (cosmic cow) | Star map task; the lights-out events start here |

**Il Rifugio (safe room) layout, FNAF-style:** a round cellar with **West Door** (from the café hall), **East Door** (from the boardwalk hall), a **Vent** (floor grate), a **Skylight Hatch** (roof) and the **Front Door** (stairs to the piazza, the knock door). It also holds a **camera desk** with 10 feeds (CAM 1 Piazza, 2 Café, 3 Dance Studio, 4 Boardwalk, 5 Beach Huts, 6 Hangar, 7 Forest Edge, 8 Greenhouse, 9 Market, 10 Rainy Street), plus a **breaker panel** and the **Answer Bell**.

---

## 7. Night structure and the power system

### 7.1 Roam (150 s), "Restore the village"
- Tasks are shared by the team:
  - **3 fuse boxes**: hold E for 4 s each, which plays a loud spark sound with a 30-stud noise radius.
  - **Lantern Oil**: 6 cans spawn and each gives +1 lantern charge, shared.
  - **Door Planks**: 4 spawn and each gives one West or East door +15% durability.
  - **Candy**: 20 pickups spread around the map, each worth 1 Candy.
- **Starting defend power = 40% + 20% per fuse restored**, so all three fuses gives 100%.
- 2–4 monsters roam, depending on the night (see §10).
- At 150 s the **Midnight Bell** tolls. **Last Call** gives 20 s to reach the Rifugio. Anyone still outside afterwards is hunted by a "Curfew" Tung Tung Tung Sahur at speed 30 until they get inside or are downed. This mechanic is *derived* from Tung's lore: he comes for those who don't answer the call.

### 7.2 Defend (12 AM → 6 AM, 60 s per hour = 360 s)
- **Power pool, drained per second while active:**
  - Base: 0.10%
  - Each closed door (West/East/Front): +0.25%
  - Vent grate closed: +0.15%
  - Skylight hatch closed: +0.20%
  - Each player viewing cameras: +0.12%
  - Each hall light on: +0.10%
  - Lantern Flash inside the room: 0%, but uses a charge
- **Power hits 0 → Blackout:** doors open, cameras go dark, and Saturnita's eclipse music plays. Players have **15–25 s** (random) before a forced attack. They can survive only by reaching 6 AM, or with Marrow's Brace or Wick's lantern (see the heroes).
- **Door durability:** monsters banging on a closed door do 8–20% per hit. At 0% the door jams open for 10 s.
- **Breaker panel:** after a lights-out event, one player holds E for 3 s to restore it. During those 3 s that player can't do anything else.
- **Hall lights** (FNAF door lights) show what is standing at West or East. A light auto-shuts after 3 s.
- Cameras show an interference "static wipe" for 0.4 s when switching feeds, so camera use has a cost.
- **AI ramps at 2 AM and 4 AM:** +1 AI for every active monster, +2 from night 6 onward.

---

## 8. Survivor roster (original heroes)

Base Roblox WalkSpeed is 16. "Courage" is HP in hearts. Losing all hearts means you are **Downed** (no gore: you turn into a dazed, swirly-eyed ghost-outline).

| Hero | Speed / Sprint | Courage | Identity |
|---|---|---|---|
| **Pip**: a pumpkin-headed bellhop with a hand bell | 20 / 26 | 2 | Fastest, fragile |
| **Marrow**: a big friendly skull-gourd in a sweater | 14 / 18 | 4 | Slow tank |
| **Wick**: a candle-headed kid with a lantern | 16 / 22 | 3 | Scout and info |
| **Nim**: a jittery bat-imp wearing two left shoes | 17 / 23 (with stumbles) | 3 | Trickster |

Sprint uses a stamina bar of 100 that drains 20 per second and regenerates 15 per second after 1 s. Being hit gives 1.5 s of invulnerability and knocks the player back 8 studs.

### Skills (rank 1 → rank 5; ranks unlock at levels 2–5)
- **Pip, Bell Dash** (Q): dashes 12 studs in 0.25 s. If the dash hits a monster **during its Windup tell**, it stuns that monster for 2.0 s (+0.25 s per rank, so 3.0 s at rank 5). Outside the windup it doesn't stun. Cooldown 14 s (−1.5 s per rank, so 8 s at rank 5). **Defend bonus:** Pip's ring counts as the **Answer Bell** from anywhere in the Rifugio, with a 1.5 s window instead of 1.0 s. Has no effect on Chimpanzini in Buff form.
- **Marrow, Shove** (Q): breaks a grab **only during the red flash** (0.40 s window, +0.05 s per rank). Shoving early leaves Marrow stuck for 1 s. Out of a grab, it pushes a monster back 10 studs (no stun). Cooldown 10 s (8 s at rank 3+). **Defend, Brace** (hold F at a door): that door drains half power and takes half bang damage, but Marrow can't move.
- **Wick, Lantern Flash** (Q): for 4 s (+0.5 s per rank) it shows a glowing safe path to the nearest objective or the Rifugio, reveals hidden items, and **reveals disguised or invisible monsters** (Patapim, Assassino). The cost is that **every monster within 80 studs turns toward Wick** and gains Investigate on Wick's position. Uses 1 lantern charge; the team starts with 2. Cooldown 12 s. **Defend:** a flash lights one hallway for 3 s with no power cost, and a flashed monster at a door retreats one node (Saturnita excepted).
- **Nim, Candy Decoy** (Q): throws a candy that pulls the attention of every chaser within 40 studs for 4 s (+0.5 s per rank). Then Nim automatically does a **fake-out hop**: a 6-stud sideways hop with 1.5 s of untargetability. **Fails if Nim is already grabbed.** Cooldown 15 s (−1.5 s per rank). Thrown between Tralalero and Bombardiro, it **triggers the Feud** (see the bestiary). **Defend:** dropped in the Vent, it lures vent crawlers back one node. Passive "two left shoes": every 6–9 s Nim veers 15° for 0.3 s (a cosmetic wobble that is never lethal); Nim's footsteps are 30% quieter.

### Passives (one pick from 3 random options at every level-up; most stack ×3)
- Fleet Feet: +1 WalkSpeed
- Deep Breath: +15 stamina
- Brave Heart: +1 Courage (max 1 stack)
- Quick Hands: tasks 15% faster
- Light Sleeper: tells show 0.15 s earlier
- Penny Pincher: −5% camera drain
- Second Wind: revive teammates in 2.25 s instead of 3
- Sweet Tooth: +10% Candy
- Night Owl: +5% starting power

---

## 9. Monster bestiary (10 core + 2 optional)

**Lore notes:** this is a community-made, AI-generated meme universe with no official canon. Lore below marked *(reported)* comes from press or fan wikis. Everything under Behavior, Tell, Counter and Scare is **derived for this game**. **Never use the original viral audio or lyrics.** The Tralalero and Bombardiro audio contains blasphemy and references to bombing civilians in Gaza. Use original sound design and short **original** name-chants only. Each monster's `displayName` and model are config-driven (§15).

Speeds are in studs per second during the roam phase. "Grab" means a 1.2 s hold with a **red flash at 0.6–1.0 s** (Marrow's window). A completed grab removes 1 Courage.

### 9.1 Tung Tung Tung Sahur: **mini-boss (Night 5) and Curfew hunter**
- **Lore (reported):** an Indonesian-made character (creator Noxa, February 2025). He is a wooden *kentongan* slit-drum figure holding a bat. The original narration says he is a terrifying anomaly who only appears at sahur, and that if someone is called three times and doesn't answer, he comes to their house. "Tung tung tung" imitates the drumbeat that wakes people for the pre-dawn meal.
- **Look:** a tall rubber-hose log with pie-cut eyes, a wide carved grin, white gloves and a cartoon bat (a rolled newspaper style, not a weapon). He bobs on every beat.
- **Behavior:**
  - **Curfew** (any night, during Last Call): speed 30 and ignores AI rolls.
  - **Night 5 mini-boss:** he patrols the piazza cameras, then comes to the **Front Door**. Each **knock cycle** is three "TUNG" knocks 1.5 s apart, a 1.0 s silence, then a **Charge**.
  - The 1.0 s silence after the third knock is the **answer window**. Someone must ring the **Answer Bell** (or Pip's bell from anywhere), and he retreats for 40–60 s.
  - With no answer and the Front Door closed, the charge does 35% door damage and drains 6% power.
  - With no answer and the Front Door open, he jump scares the nearest player and downs them.
  - Every 4th cycle doubles the knocks: three, a pause, then three more. Only the final silence counts.
- **Tell:** a drum knock that shakes the screen, with dust falling from the ceiling. During the silence the door handle glows **Danger Red** and his eye shines under the door.
- **Counter:** ring at the right time. Ringing early (before the 3rd knock) **counts as not answering**. Closing the door covers a missed ring at a power cost.
- **Jump scare:** the door bursts into cartoon splinters, and his face fills the screen with the grin stretched wide. Three fast drum hits, a 0.8 s rubber-hose "boing", then a fade to dazed stars.
- **Audio:** an original deep log-drum sample (Roblox library or my own recording), plus a breathy *original* whispered chant "tung… tung… tung… sahur".

### 9.2 Ballerina Cappuccina: **the Music-Box Marker** (Night 4+)
- **Lore (reported):** a ballerina in a tutu and pointe shoes with a cappuccino mug for a head. In the original clip she pirouettes. She is described as the wife of Cappuccino Assassino and the sister of Espressona Signora, and her chant says she "loves music, la la la".
- **Look:** a porcelain cup head with foam hair in a bun, a pink tutu and spindly rubber-hose legs.
- **Behavior:** a "musical statues" hunter.
  - While her music-box tune plays (6–10 s), she pirouettes toward the nearest player at speed 14 and is harmless.
  - When the music **stops** (3 s), she freezes and **watches**. Any player who moves more than 2 studs, sprints, or (during defend) **switches camera feeds** is **Marked** for 20 s.
  - Marked players are top priority for **Cappuccino Assassino**, the "Coffee Clan" synergy, and the Assassino gets +3 AI against them.
  - In defend she drifts across camera feeds and only approaches the doors while her music plays.
- **Tell:** the music winds down with a slowing music-box creak 1.0 s before it stops. A steaming swirl rises from her cup.
- **Counter:** stand still or hold the current camera. Wick's Flash on her while frozen **clears all marks**.
- **Jump scare:** she spins into the camera at full speed, foam spraying like cartoon whipped cream, then a sharp "mi-mi-MI!" soprano sting (original).
- **Audio:** an original public-domain-style music-box waltz; shuffling pointe-shoe taps.

### 9.3 Cappuccino Assassino: **the Steam Stalker** (Night 2+)
- **Lore (reported):** an assassin with a cappuccino-cup head and blades for limbs, shown as a takeaway cup with ninja trappings. He is "lightning fast," married to Ballerina Cappuccina, and in fan lore holds a grudge against Bombardiro Crocodilo.
- **Look:** a to-go cup with a lid "mask", a long scarf, and **butter-knife** cartoon arms (blunt, comedic).
- **Behavior:**
  - **Roam:** invisible beyond 15 studs, leaving only a faint steam trail. He stalks for 6–12 s, then dashes at speed 34 for 1.0 s, then **grabs** (red flash).
  - **Defend:** a fast door attacker. He appears at West or East and attacks 3.0 s later.
- **Tell:** a kettle-whistle pitch that rises over 1.2 s before the dash, with steam puffing from the ground where he's standing. In defend, the hall light shows a cup silhouette.
- **Counter:** Wick's Flash reveals him and cancels the dash. Pip's Bell Dash during the whistle stuns him. Marrow's Shove breaks the grab. In defend, close the door within 3 s and he leaves after 2 bangs.
- **Jump scare:** the lid pops off and a geyser of steam forms a screaming cartoon face, while the scarf whips across the screen.
- **Audio:** a kettle whistle, a coffee-grinder rattle and a soft sliding step.

### 9.4 Tralalero Tralala: **the Sneaker Sprinter** (Night 4+)
- **Lore (reported):** the first viral character, a shark with three legs in blue sneakers, described as superhumanly fast and a great jumper. Fan lore gives him a "legendary rivalry" with Bombardiro Crocodilo. **The original audio is offensive. Don't use it.**
- **Look:** a grinning cartoon shark standing upright on three legs in chunky **unbranded** sneakers. No swoosh logo, because Nike is a trademark.
- **Behavior:**
  - **Roam:** a Foxy-style rusher. He idles in a Beach Hut (CAM 5). Each AI success raises his "wind-up" stage (0→3). At stage 3 he **sprints** down the boardwalk at speed **23 on night 4**, +0.5 per night after, capped at 28. A base Pip at 20/26 sprint can outrun him only while stamina lasts. Base Marrow cannot, which is the "level up by night 4" pressure. He slides on oil puddles.
  - **Defend:** at stage 3 he races the East hall and arrives in 2.5 s. Watching CAM 5 freezes his stage progress, as in FNAF's Pirate Cove.
- **Tell:** sneaker squeaks and his dorsal fin peeking from the hut curtain (stage 2), then a loud rubber squeal (sprint start).
- **Counter:** break line of sight around corners (he turns badly: turn rate 90° per second), close the East door, or keep CAM 5 watched. **Feud:** if Tralalero and Bombardiro are both within 30 studs of a Candy Decoy or each other while chasing, they **fight each other for 10 s** in a cartoon dust cloud with stars and gloves poking out. Both are stunned and target no one.
- **Jump scare:** shark jaws open wide to show rows of rounded cartoon teeth, a sneaker kicks the camera, then a crowd of squeaks.
- **Audio:** squeaky sneakers, wave splashes and an original nonsense whistle "tra-la-la" (only the name syllables, original melody).

### 9.5 Bombardiro Crocodilo (+ brother Bombombini Gusini): **the Air Raid** (Night 6+, mini-boss Night 15)
- **Lore (reported):** a crocodile head on a WWII-era twin-prop bomber body. His brother is Bombombini Gusini, a goose with jet wings, and fan lore says Gusini later turned on the crocs. **The original narration references bombing civilians in Gaza and Palestine. Don't use it or reference real conflicts.** In this game his "bombs" are cartoon **ink-pie bombs**: paint splats that slow and blind. Nothing explodes violently.
- **Look:** a toy-like biplane-croc with a big toothy grin, goggles and spinning propellers. Gusini is a goose-jet with a helmet.
- **Behavior:**
  - **Roam:** flies a figure-eight over the map. When a searchlight cone (radius 10) catches a player for 1.5 s, he drops 3 ink-pies on them (cartoon fuse bombs, 2 s fall). A hit means 3 s of slow (×0.6) and an ink-blinded screen edge. **No Courage damage**, but the slow is often lethal next to other monsters.
  - **Defend:** goes for the **Skylight Hatch**. Each AI success moves him closer (4 stages). At stage 4 he dives. If the hatch is closed, it takes 30% damage. If it's open, he jump scares a random player in the room.
  - **Gusini:** a fast vent attacker (moveInterval 4 s) who comes up through the floor vent.
- **Tell:** a propeller drone that rises in pitch with each stage, and the searchlight sweeps across the skylight glass (stage 3). Gusini gives a **honk** in the vent ducts 2 s before he arrives.
- **Counter:** close the hatch at stage 3 or 4, close the vent at the honk, avoid searchlights, use the Feud with Tralalero, or Nim's decoy in the vent for Gusini.
- **Jump scare:** a croc snout bursts through, propeller wind blows the HUD sideways, and a cartoon pie hits the screen.
- **Audio:** prop engine, falling-bomb slide whistle and a goose honk. All original or from the Roblox library.

### 9.6 Brr Brr Patapim: **the Forest Disguise** (Night 2+)
- **Lore (reported):** a proboscis-monkey and tree hybrid with enormous feet who guards the forest. Fan lore mentions a hat holding a blue frog named Slim.
- **Look:** a tree trunk body, a long droopy nose, leafy brows and gigantic cartoon feet in the roots.
- **Behavior:**
  - **Roam:** **disguised as one of 30 forest trees**. When a player passes within 8 studs, he **grabs** (red flash).
  - Every 25 s he relocates to a different tree, but only while no one has line of sight.
  - **Defend:** walks the forest edge (CAM 7) to the West door and bangs slowly but hard (20% per bang).
- **Tell:** "brr brr" leaf-shiver sound when you're within 15 studs, and **two big toes** stick out of the roots (the only visual difference from real trees).
- **Counter:** watch for toes. Wick's Flash reveals him. Marrow's Shove breaks the grab. The West door repels him after 3 bangs.
- **Jump scare:** the tree's bark peels open into a monkey grin, the nose swings into the camera and leaves explode.
- **Audio:** rustling, a woody "patapim-patapam" stomp and a rubbery "brrr" lip-trill (original).

### 9.7 Lirili Larila: **the Clock Stopper** (Night 1+, low AI on Night 1)
- **Lore (reported):** a cactus-elephant hybrid in sandals, often described in fan lore as able to **stop time** and as avoiding direct fights.
- **Look:** a green cactus-skinned elephant, spines as tufts of cartoon fuzz, slap-slap sandals and a pocket watch on a chain.
- **Behavior:**
  - **Roam:** a slow walker (speed 9). Every 18–25 s she raises her pocket watch: a **Time Stop** that **freezes any player in her line of sight within 40 studs for 2.5 s** while other monsters keep moving. She never attacks directly; she only makes openings for the others.
  - **Defend:** a **Freeze Controls** event. The doors, hatch and vent buttons stay locked in their current state for 4 s.
- **Tell:** three loud clock **ticks** (1.5 s), then the screen turns sepia at the edges.
- **Counter:** get out of her line of sight during the ticks (her cone is narrow, 60°). In defend, close the doors you'll need *before* the 3rd tick.
- **Jump scare** (rare, only when she's the attacker during a blackout): her trunk curls around the camera, a clock face spins, and a loud "LIRILÌ!" with a gong.
- **Audio:** clock tick, sandal slap and an original whistled "lirilì larilà".

### 9.8 Chimpanzini Bananini: **the Indestructible Peel** (Night 1 Banana form; Night 3+ Buff form)
- **Lore (reported):** a green chimpanzee inside a banana. Described as "indestructible", and in many clips he turns muscular when the peel comes off.
- **Look:** a banana with a chimp face. In Buff form the peel flops open to show a huge rubber-hose muscle chimp.
- **Behavior:**
  - **Banana form:** hides among market crates (speed 0) and pops out to chase slowly (speed 12) for 5 s.
  - **Buff form** (Night 3+): after peeling, chases at speed 18 and **cannot be stunned or shoved** (indestructible). He drops peels while running.
  - **Defend:** a **vent crawler** who also bangs the East door.
- **Tell:** a squelchy peel-rip sound and the peel landing on the floor (1.0 s before Buff form). In the vent, a banana smell icon and a "shlorp".
- **Counter:** make him **slip on his own peels**. A player who jumps over a peel he's following trips him for 3 s. Doors and the vent grate stop him. Skills that stun don't work on him.
- **Jump scare:** the peel flips over the camera like a curtain, then a chimp roar and a muscle-flex freeze-frame.
- **Audio:** chimp hoots, peel squelch and heavy thumps.

### 9.9 Boneca Ambalabu: **the Frozen Walker** (Night 1+)
- **Lore (reported):** a frog head on a car-tire body with long human legs, usually shown frozen mid-stride on a rainy street with eerie music. The name comes from an Indonesian sound. Fan lore includes an oil-leak car backstory and an accidental win over Frigo Camelo.
- **Look:** a big glossy frog head, a tire body with a hubcap belly and long legs in boots.
- **Behavior:** **moves only when unobserved**, Weeping-Angel style.
  - **Roam:** if no player has him on screen (frustum check plus a line-of-sight raycast), he walks at speed 16, or **rolls** at 26 downhill on the rainy street.
  - **Defend:** he advances one node per AI success **only when his current feed isn't being watched**. With 2+ players, assign a "watcher" role.
- **Tell:** rain gets louder and you hear tire squeal while he's moving. On cameras his head is turned a little more each time.
- **Counter:** keep eyes on him (screen or camera) and close the door when he's in the hallway.
- **Jump scare:** he's suddenly inches from the lens with a frog tongue slap and a tire screech.
- **Audio:** rain, a slow violin drone (original), and a croaky "ambalabù" (original).

### 9.10 La Vaca Saturno Saturnita: **the Eclipse** (Night 3 lights-out; mini-boss Night 10)
- **Lore (reported):** a cow fused with Saturn's rings, standing on human feet, usually shown as a still, staring image. Fan lore gives her "black hole" attacks against Frigo Camelo and others.
- **Look:** a round spotted cow body ringed by glowing planetary rings, tiny feet and a calm, unblinking stare.
- **Behavior:**
  - **Lights-out bringer:** every 45–70 s (Night 3+) she triggers **Eclipse**. The map or room drops to 10% light for 12 s and drains 5% power.
  - **Stare meter:** looking at her (on screen or camera) fills a stare meter. At 100% she takes **one step** closer and the meter resets.
  - **Roam:** a slow drifter at speed 8 that **pulls** players within 15 studs toward her (a 6 stud/s vortex). Reaching her costs 1 Courage.
  - **Night 10 mini-boss "Eclipse Night":** the whole night has 3 phases. In phase 1 every hour has an Eclipse. In phase 2 she appears at the Skylight and pulls power (+0.3%/s) until the breaker is reset (3 s hold). In phase 3, after 5 AM, there's a 30 s Total Eclipse: cameras are off and only Wick's lantern and the hall lights work.
- **Tell:** a low cosmic hum, then her rings glow and the stars come out on the skybox 2 s before the Eclipse.
- **Counter:** reset the breaker, look away (Ballerina punishes moving, Saturnita punishes staring: a deliberate conflict), and save power for the eclipses.
- **Jump scare:** her rings spin into a black-and-white spiral that fills the screen, then a slow "moo" (low and pitched down) that turns into a cartoon thunderclap.
- **Audio:** theremin-style hum, ring whoosh and a pitched moo.

### 9.11 Optional / stretch monsters
- **Frigo Camelo** (fridge-camel who wanders in the rain; fan lore gives him ice powers): **freezes a door** in its current state for 10 s, and you defrost it by holding E for 2 s. Use him as a Night 7+ modifier.
- **Trippi Troppi** (shrimp-cat or bear-fish, whose design varies by video): a gluttonous **Candy thief** that steals uncollected roam Candy and Lantern Oil.

---

## 10. Night-by-night escalation (endless)

AI levels (0–20) at 12 AM. They get +1 at 2 AM and 4 AM (+2 from Night 6). "R" means a roam-phase hunter that night.

| Night | Theme | Active monsters (start AI) | Notes |
|---|---|---|---|
| 1 | **Slow grinners**: one tell each | Boneca 3 (R), Lirili 2, Chimp-Banana 2 (R) | First-night control hints. 2 roamers. Speed cap 16 |
| 2 | **Grabbers + red flash** | +Patapim 4 (R), +Assassino 3 | Shove tutorial toast on first grab |
| 3 | **Lights out** | +Saturnita 4, Chimp gets Buff form | Eclipse every 60–70 s |
| 4 | **Mixed tells / speed check** | +Tralalero 5 (R), +Ballerina 4; others +2 | Tralalero speed 23 |
| 5 | **Mini-boss: The Knock** | Tung Tung Tung Sahur (knock cycle every 40–60 s) + any 3 others at 5 | Banner "SURVIVED THE KNOCK" |
| 6 | **Air Raid** | +Bombardiro 5, +Gusini 4; all others 6 | 3 roamers |
| 7 | Encore I | all 10 at 7, Frigo modifier optional | random 1 "Encore modifier" |
| 8 | Encore II | all at 8, Tung visits at 3 AM | |
| 9 | Encore III | all at 9 | 4 roamers |
| 10 | **Mini-boss: Eclipse Night** (Saturnita, 3 phases) | others at 9 | banner + title "Eclipse Survivor" |
| 11+ | Endless | `AI = min(20, 9 + floor((N-10)/2))`; +1 Encore modifier per 3 nights | mini-boss rotation every 5 nights: 15 Air Raid (Bombardiro + Gusini + forced Feud chance), 20 **Grand Knock** (optional boss: a house-sized Tung, phase 1 knock-charge, phase 2 grab flashes through the walls, phase 3 lights-out), 25 The Knock, 30 Eclipse, … |

**Encore modifiers** (random, shown at Camp):
- Rainy Night: Boneca everywhere
- Decaf: −20% power, stamina regen +20%
- Double Shot: Assassino ×2
- Tide's Out: Tralalero cap +2
- Frozen Fridge: Frigo Camelo on
- Peel Panic: peels everywhere

**Design decision:** there's **no game-ending final boss**. Escalation is endless with rotating mini-bosses, and the user's house-sized knocker becomes the optional "Grand Knock" every 20 nights. Beating any mini-boss puts a server-wide banner with the team's names over the piazza.

---

## 11. Camp progression and economy

- **Camp** (day, 20 s; +10 s if any player has the shop open, 40 s max; Ready-up skips the timer when everyone is ready): a sunny version of the piazza with a campfire. Players can swap heroes, use the shop and buy a revive token. The screen shows level, XP bar, next unlock, Candy and the next night's modifier.
- **XP per night survived** = `60 + 40 × N`. Plus 15 per task, 30 per revive, and 25 for a no-hit night. A player downed that night gets 50%.
- **XP to reach level L+1** = `100 + 50 × (L−1)`. Levels: L2 100, L3 +150, L4 +200, L5 +250, … The **level cap is 25**.
  - Sanity check: a decent player hits L2 after Night 1, L3 after N2, L4 after N3, and L5 around N4, so leveling keeps pace with the Night 4 speed check.
- **Levels 2–5** unlock skill ranks 2–5, plus a passive pick. **Levels 6–25** each give a passive pick, and titles come at L10, L15, L20 and L25.
- **Death:** level, XP, passives and Candy are kept, and **the night counter resets to 1** for the server team.
- **Best record:** `bestNight` saves when a night completes. Saving reaching Night 10 is a special milestone badge (optional BadgeService badge, created by me).
- **Candy** (soft currency) per night survived = `10 × N`, plus 1 per Candy pickup. The Sweet Tooth passive adds a percentage.
- **Camp revive token:** 150 Candy, at most **one carried** and one used per night. It instantly revives you once when downed. **Candy only. Never sold for Robux.**

---

## 12. Shop and Robux monetization (cosmetics only)

**Rule:** Robux never buys power, XP, levels, revive tokens, skill ranks or stats. Cosmetics only. No paid random items or loot boxes.

### 12.1 Candy shop (examples)
- **Gloves:** Polka-Dot (120), Skeleton Bones (250), Spider Silk (400)
- **Shoes:** Spat Shoes (120), Pumpkin Clogs (250), Bat Wings (400)
- **Lantern skins:** Jack-o'-Lantern (200), Moon Jar (350), Candy Corn (500)
- **Revive token:** 150

### 12.2 Robux: premium currency "Moon Coins" (Developer Products, repeatable)
| Product | Robux | Coins |
|---|---|---|
| Handful of Moon Coins | 25 R$ | 100 |
| Bag of Moon Coins | 99 R$ | 450 |
| Cauldron of Moon Coins | 249 R$ | 1,200 |

Moon Coins buy **only** cosmetics:
- **Premium gloves/shoes sets:** "Vintage Reel" sepia set, 300 coins; "Neon Ghost" set, 400 coins
- **Lantern "Haunted Gramophone":** 350 coins
- **Victory dances / dawn emotes:** 150 coins
- **Camp banners:** 100 coins

### 12.3 Game Passes (one-time, cosmetic)
- **Rubber-Hose Classic Pack** (black-and-white 1930s filter on your own hero, plus white gloves): 149 R$
- **Supporter Lantern** (gold, with sparkle trail): 99 R$
- **Extra Outfit Slots** (save 5 loadouts): 49 R$

All prices sit in `Config/Monetization.luau` as `productId = 0 -- TODO(user): paste ID` placeholders. Treat 0 as "not for sale" and hide it in the UI.

### 12.4 Implementation
- Set `MarketplaceService.ProcessReceipt` **exactly once** in `MonetizationService`. For each receipt:
  1. Load the player's profile. If the player isn't in the server or the profile isn't loaded, return `NotProcessedYet`.
  2. **Idempotency:** if `purchaseHistory[receipt.PurchaseId]` exists, return `PurchaseGranted`.
  3. Grant the coins, write `purchaseHistory[PurchaseId] = true`, and **save** (ProfileStore/UpdateAsync). Return `PurchaseGranted` only after a successful commit. Otherwise return `NotProcessedYet`.
  4. Use a handler table keyed by productId; an unknown id returns `NotProcessedYet` and warns.
- Game passes: check `UserOwnsGamePassAsync` on join (pcall + cache) and grant again on `PromptGamePassPurchaseFinished` (with a server re-check). Never trust the client.
- Prompts come from the client with `PromptProductPurchase`, but the grant comes **only** from ProcessReceipt. Don't use `PromptProductPurchaseFinished` to grant.
- Show the price from `GetProductInfo` (pcall, cached for 10 min), falling back to the config price.

---

## 13. UI screens

1. **Title/Lobby:** logo with iris-in, Play (Ready), Hero select (4 cards with speed/courage/skill in one line), Shop, Settings, best night.
2. **Camp HUD:** timer, level and XP bar, "Next unlock: Bell Dash Rank 3 at L4", Candy and Moon Coins, modifier card, Ready button.
3. **Night HUD (Roam):** clock, task tracker (fuses 0/3, oil, planks), courage hearts, stamina, skill button with cooldown ring, teammate markers, Last Call siren banner.
4. **Night HUD (Defend):** clock (12 AM–6 AM), power % with usage bars (1–5 like FNAF), door/hatch/vent toggles (keyboard: A/D doors, W hatch, S vent, F front, Space cameras, 1–0 feeds, E Answer Bell), a camera monitor overlay with a feed map, and a door durability bar per door.
5. **First-night hint** (Night 1 only, dismissable): "Watch, listen, close the door, then save power. Each monster tells you before it strikes."
6. **Pause:** one sentence per skill timing, for example "Bell Dash stuns only while the monster is winding up (yellow glow)." and "Shove works only during the red flash; too early and you're stuck for 1 s."
7. **Downed/Spectate:** a bleed-out ring (20 s), "Teammate can revive (hold E 3 s)". As a ghost you cycle through teammates or **camera feeds** and can **Ping** a monster (1 per 10 s) so it shows for living players.
8. **Dawn:** 6 AM chime, "NIGHT N SURVIVED", XP and Candy tally, level-up passive picker (3 cards).
9. **Game Over:** nights reached, best, per-player stats (tasks, revives, closest call), "Back to Camp."
10. **Shop:** tabs for Candy, Moon Coins, Passes; try-on preview in a ViewportFrame.
11. **Settings:** Reduced Scares (no screen shake, scares at 50% volume, no flashes), film grain toggle, SFX/Music sliders, camera sensitivity.
12. **Leaderboard** (stretch): top 50 by best night, then level, showing name, hero and level. Also a physical board in the piazza.

Mobile and gamepad support: use ContextActionService with on-screen buttons for skills and safe-room controls.

---

## 14. Audio direction

- Use only the **Roblox Creator Store audio** (licensed music and SFX) or **original** recordings I upload. Never rip TikTok or meme audio. The viral Tralalero and Bombardiro audio contains offensive content.
- **Music:** 1930s-style hot jazz and ragtime for Camp (light, bouncy). Defend gets low tension drones that thicken with each hour. Each mini-boss gets its own stinger.
- **Name chants:** short, **original**, playful whispered or sung versions of the monster names only (for example "tra-la-la", "tung… tung… tung…"), recorded by me or made with any TTS whose license allows commercial use. Nothing else from the original narrations.
- **Every tell has a unique sound** that is audible over the music: duck the music by −6 dB when a tell plays, and use 3D positional audio (RollOffMaxDistance 60) so players can tell direction.
- **Jump scare mix:** peak at about −3 dBFS and max 1.2 s long. With Reduced Scares on, cut 6 dB and remove the screen flash.

---

## 15. Rules, safety, IP

- **Roblox Community Standards:** no gore, blood, dismemberment or realistic violence. Grabs are cartoon holds. "Downed" is a dazed ghost-outline. No real-world conflict, religion or slur references. Never show the controversial original meme lyrics.
- **Maturity:** Roblox's questionnaire treats jump scares, creepy NPCs and suspense as **Mild** fear (realistic gore would push it to Moderate). Expect "Mild"; tell me if the design drifts toward Moderate.
- **Photosensitivity:** no full-screen flashes faster than 3 per second.
- **IP:**
  - Cuphead: style inspiration only. No copied characters, mugs, fonts, cards, UI layouts or music. Keep the art original.
  - FNAF: mechanics are inspiration only. Use no names like "Freddy's" or original assets.
  - Brainrot characters: who owns them is **legally unsettled as of Oct 2026**.
    - The licensing agency Mementum Lab claims rights for Tung Tung Tung Sahur's creator (Noxa) and has sent a cease-and-desist over his use in *Steal a Brainrot*. That game pulled him, and a US federal case (Spyder Games et al. v. Mementum Lab, N.D. Cal.) is ongoing, with motions to dismiss set for hearing **Dec 9, 2026**.
    - An EU trademark for "Tung Tung Tung Sahur" has been granted, and many more brainrot-name trademark applications have been filed.
  - Therefore: build every monster's **name, model, chant and icon from `Config/Monsters.luau`** with a `useParodyNames` flag that switches to original stand-in names (for example "Knock-Knock Log", "Sneaker Shark", "Prop-Croc", "Cup Ninja", "Pirouette Cup", "Tree Toes", "Clock Cactus", "Peel Brute", "Tire Frog", "Ring Cow"). Don't put brainrot names in the experience title, thumbnails or product names.
  - Don't use any brainrot AI images as textures.
  - Hero design must stay original (floating gloves and shoes are generic cartoon conventions, but avoid copying any specific existing character).

---

## 16. Multiplayer rules

- `Players.MaxPlayers = 4` (set in Game Settings, which I'll do).
- **Stages 1–9** use a single place: whoever is in the server is the team.
- **Stretch (Stage 10):** a separate Lobby place with up to 4 party pads that uses `TeleportService:ReserveServer` and teleports the party, using `TeleportOptions` + `SetTeleportData` for hero choice. Teleports can't be tested in Studio, so add a mocked path.
- **Downed:** a 20 s bleed-out. A teammate holds E for 3 s within 6 studs to revive the player at 1 Courage. Revives are blocked while the reviver is grabbed. If nobody revives in time, the player becomes a **Ghost** for the rest of the night (spectate plus Ping) and respawns at Camp.
- **Defend roles** are suggested by the UI, not forced: Doors (West/East), Cameras, Vent/Hatch.
- **Shared** things: power, the night counter, Candy pickups (each pickup gives 1 Candy to everyone), tasks. **Individual** things: courage, XP, levels, cosmetics.
- Solo players get 1.25× more task time and a +10% starting power bonus.
- **Leaving mid-night:** that player keeps XP earned so far (saved), and the team continues. If the last player leaves, the server closes.

---

## 17. Anti-exploit

- The server owns all state. The client sends **intents** only, such as `ToggleDoor("West")`, `UseSkill()`, `ViewCam(4)`, `Interact(objectId)`.
- Validate state, alive status, position (the safe-room Region3 or OverlapParams check), distance, cooldown and rate limit.
- Movement sanity: every 1 s, compare position deltas against `WalkSpeed × 1.5 + 6`. Rubber-band and flag after 3 violations. WalkSpeed is always set by the server, and if the client changes it, the server corrects it.
- Monster hits are decided by the server (distance ≤ 5 studs plus state `Attack`).
- Only the server writes to DataStores and Candy/XP. Purchases go only through ProcessReceipt.
- Never put secrets in ReplicatedStorage. Sanitize every string sent to the server (shop item ids must exist in config).

---

## 18. Performance budget

- **Target:** 60 fps on an M1 Mac, 30+ fps on a mid-range phone.
  - Under 25k parts in the map.
  - `StreamingEnabled = true` (persistent models: Rifugio, piazza).
  - Union and mesh reuse.
  - At most 8 active pathfinding monsters, plus a staggered AI tick (each monster updates on a 0.1 s offset).
- Camera feeds: render each feed as a **ViewportFrame** of a cloned low-detail room, or move a single client Camera with a static overlay. Prefer moving the real camera to fixed CFrames. One feed renders at a time.
- Pool particles and sounds. Clean up with Janitor. No `while true do wait()` loops: use `RunService.Heartbeat` with accumulators, or `task.delay`.
- Highlights limited to 12 (see §5).

---

## 19. Build plan

The build plan, the scope per stage, the acceptance criteria and the git/tag steps all live in **§0 (Staged build)**; that table is the only milestone list. Other things that apply to every stage:
- Keep the debug overlay (state, night, hour, power, AI levels, RNG seed) working in every stage.
- Every new monster gets a `DebugSpawn` scenario that shows tell → counter → result → jump scare.
- Every stage hand-off includes: the test checklist, lint/format results, a CHANGELOG entry, and (after my approval) the commit hash and tag.
- Monetization is only built in Stage 8, even though §12 is written up front.

---

## 20. Testing in Studio (Mac)

- **Single player:** Play (F5).
- **Multiplayer:** Test tab → Clients and Servers → Local Server, **2–4 players**. Studio opens one server window and N client windows. Use this for revives, spectate, shared power and the Answer Bell timing.
- Add a **Debug panel** (only for my UserId, or when `RunService:IsStudio()`) with these controls: set night, set AI for a monster, spawn a monster at a node, skip to an hour, infinite power, force Eclipse/Knock, grant XP/Candy, wipe my data (a Studio-only DataStore key prefix `DEV_`).
- DataStores in Studio need API access enabled (§2.2). Use a separate store name in Studio (`KN_Player_DEV`) so testing never touches live data.
- Unit-test pure modules (power math, AI rolls, XP curve, receipt idempotency) with TestEZ or Jest-Lua run through Studio, or with Lune if you set it up.

---

## 21. Publishing steps (I do these; you prepare the checklists)

1. In Studio: **File → Publish to Roblox** (first time: create a new experience named "KNOCKNIGHT", genre Horror). Keep the audience on **Playtest** (formerly "Private") while testing, and invite friends as Early testers (see §0, Demo & deploy).
2. **Game Settings:** Max players 4. Enable Studio API Services. Avatar: R15, with my custom StarterCharacter used for everyone.
3. **Creator Dashboard → Monetization:** create the 3 Developer Products and 3 Game Passes with icons (512×512). Copy the IDs into `Config/Monetization.luau`, then republish.
4. Upload sounds, decals and meshes (I approve each upload). Assets go through moderation before they show in game.
5. **Manage Audience / Maturity & Compliance:** Roblox is rolling out a one-question path to a 16+ "Content May Vary" label (announced Oct 2026). For younger audiences and a precise label, complete the full questionnaire honestly (fear: jump scares, creepy characters; no blood or gore). The expected label is Mild.
6. Set the description (no brainrot names if `useParodyNames` is on), thumbnails and icon. Then make it Public.
7. After launch, watch the Developer Console, the Error Report, and DataStore and receipt logs.

---

## 22. Working rules for you, Cursor

- **Ask me before:** running installers that need sudo, installing the Studio plugin, publishing, uploading assets, creating products or passes, editing Creator Dashboard settings, or anything that touches my Roblox account or spends Robux.
- Keep all numbers in Config modules. When you change a number from this brief, say so in the CHANGELOG.
- Prefer small, typed ModuleScripts (`--!strict`) and pure functions for game math so they can be unit tested.
- When lore is unclear, keep the behaviors in §9 as written. They are game design derived from the memes, not canon.
- Start with **Stage 0**. When it's done, show me the folder tree, the commands you ran and the push result, then do **Stage 1 only**, then stop with the test checklist and wait for "good, continue".
- Git: commit and push **only after I approve a stage**. Use clear messages (`Stage 1: playable Night 1 (lobby, camp, roam, defend, 3 monsters, 4 heroes, 1-4P)`). Never force-push, never commit secrets or builds, and ask me before any destructive git operation.
