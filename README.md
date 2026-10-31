# KNOCKNIGHT

Online co-op Halloween horror for 1–4 players. Survive as many nights as you can. Code on disk syncs into Roblox Studio with Rojo.

This repo is built in stages. Stage 0 is the toolchain and folder skeleton. Gameplay starts at Stage 1.

## Setup (Mac)

Tools are pinned in `rokit.toml` and installed with [Rokit](https://github.com/rojo-rbx/rokit). Homebrew and git are required.

```bash
# once per machine, if `rokit` is not on your PATH
curl -fsSL https://raw.githubusercontent.com/rojo-rbx/rokit/main/scripts/install.sh | sh
```

Open a new terminal, then from this folder:

```bash
rokit install
wally install
make sourcemap
make fmt
make lint
make build
```

`make build` writes `knocknight.rbxlx` (gitignored). `make serve` starts the Rojo sync server.

## Play in Studio

These steps need your Roblox account. The agent does not publish, upload, or install the Studio plugin unless you say so.

1. Install Roblox Studio for Mac from [create.roblox.com](https://create.roblox.com) and sign in.
2. Install the Rojo plugin from the Creator Store, or tell the agent it may run `rojo plugin install`.
3. Open `knocknight.rbxlx` in Studio.
4. In a terminal here, run `make serve` and leave it running.
5. In Studio: **Plugins → Rojo → Connect**.
6. **Play (F5)** for solo. For multiplayer: **Test → Clients and Servers → Local Server**, 2 or 4 players, then **Start**.
7. In Game Settings, set **Max Players** to 4 when you publish. That setting is not stored in this repo.

An edit to a `.luau` file should show up in Studio within about 2 seconds while Rojo is connected.

## Map

Stage 1 builds **Borgo Mezzanotte** in code (`src/server/Map/MapBuilder.luau`) when the server starts. That greybox is the source of truth and syncs through Rojo.

Geometry you sculpt by hand in Studio is not backed up until it is exported to `assets/*.rbxm` and committed. See `assets/README.md`.

## Stage list

| Stage | Scope |
| --- | --- |
| 0 | Toolchain, repo skeleton |
| 1 | Playable Night 1 |
| 2 | Camp leveling and ProfileStore |
| 3 | Night 2 grabbers |
| 4 | Night 3 lights out, 10 cameras |
| 5 | Night 4 mixed tells |
| 6 | Night 5 The Knock |
| 7 | Night 6 Air Raid |
| 8 | Candy shop and Robux cosmetics |
| 9 | Nights 7–10 and endless |
| 10 | Polish, audio, mobile, gamepad |
| 11 | Release prep |

Do not start the next stage until the current one is approved.

## Data and money

Stage 1 keeps player data in memory behind `DataService`. ProfileStore is installed for Stage 2 and is not called yet. DataStores in Studio need a private publish and **Game Settings → Security → Enable Studio Access to API Services**. That is a Stage 2 step.

Robux products use placeholder id `0` until you create them and paste the ids into `src/shared/Config/Monetization.luau`.
