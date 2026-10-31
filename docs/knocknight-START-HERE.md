# KNOCKNIGHT: start here (Mac)

## One-time setup
1. Install **Cursor** (cursor.com) and **Roblox Studio** (create.roblox.com → Start Creating). Sign in to Studio.
2. On **github.com**, create a new empty repo called `knocknight`. **Don't** add a README, .gitignore or license. Copy its URL.
3. Make sure git can push from your Mac. The easiest way is `brew install gh`, then `gh auth login` (Cursor will tell you if this is needed).
4. Create an empty folder `knocknight`, then **File → Open Folder** in Cursor.
5. Put `knocknight-cursor-prompt.md` in that folder. Yes, give Cursor the **whole** design doc. It reads all of it but builds only one stage at a time.

## First message to paste into Cursor (Agent mode)
> Here's the design doc: @knocknight-cursor-prompt.md. Read all of it as the design bible. Do **Stage 0**, then **Stage 1 only** (playable Night 1), then stop and give me the test checklist. Ask me before anything that needs my Roblox account. My GitHub repo is `https://github.com/<you>/knocknight`.

## How to test each stage
1. In Cursor's terminal: `rojo serve` (leave it running).
2. Open `knocknight.rbxlx` in Studio, then **Plugins → Rojo → Connect**.
3. Press **Play (F5)** to test solo.
4. To test multiplayer, go to **Test → Clients and Servers → Local Server**, pick 2 (or 4) players, then **Start**.
5. Work through Cursor's checklist. Paste any errors from the Output window back into Cursor.

## Continue or fix
- If something's wrong, describe it, and Cursor fixes it within the same stage.
- If it's good, reply **"good, continue"**. Cursor then commits, pushes to GitHub, tags the stage (e.g. `night-1`) and starts the next stage. You can see each finished stage on GitHub.

## Demo and publish privately
1. In Studio: **File → Publish to Roblox** and keep the audience on **Playtest** (private).
2. Turn on DataStores: **Game Settings → Security → Enable Studio Access to API Services** (needed from Stage 2).
3. Let friends play:
   - **Collaborate** (top right in Studio) → **Early testers**: add up to 10 friends. They play in the Roblox app.
   - Or add them as collaborators and use **Test → Team Test**.
4. Re-publish after each approved stage.
5. Go **Public** only at the end (Stage 11), after the audience/maturity steps in Creator Hub.

**Tip:** Robux items (Stage 8) need you to create products and passes on the Creator Dashboard. Cursor will ask, and you paste the IDs.
