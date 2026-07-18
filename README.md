# agentcube-doom

**Doomgeneric** port with a platform hook that streams every frame to an [AgentCube](https://github.com/a2u/agentcube-sim) display (simulator or real cube).

```
Doom (PC) → scale 240×240 → RGB565 → POST /api/v1/draw/frame → AgentCube
```

Based on [ozkl/doomgeneric](https://github.com/ozkl/doomgeneric). Local platform file: `doomgeneric_agentcube.c`.

## Why doomgeneric

Small platform API (`DG_DrawFrame`, `DG_GetKey`, …) — ideal for “PC plays, cube is the monitor”.

## Requirements (macOS)

```bash
brew install sdl2 curl
# optional sound:
# brew install sdl2_mixer
# make -f Makefile.agentcube WITH_SOUND=1
```

You need a Doom **IWAD** (not included). Shareware:

```bash
# example (check URL still works)
curl -L -o wads/doom1.wad \
  "https://distro.ibiblio.org/pub/linux/distributions/slitaz/sources/packages/d/doom1.wad"
```

Or copy your legal `doom1.wad` / `doom2.wad` into `wads/`.

## Build

```bash
cd doomgeneric-src/doomgeneric
make -f Makefile.agentcube -j$(sysctl -n hw.ncpu)
# binary: ./doomgeneric-agentcube
```

Or from repo root:

```bash
./scripts/build-macos.sh
```

## Run with AgentCube simulator

Terminal 1 — sim:

```bash
cd /path/to/agentcube-sim
python3 agentcube_sim.py
# open http://127.0.0.1:8765/screen
```

Terminal 2 — Doom:

```bash
export AGENTCUBE_HOST=127.0.0.1:8765
./doomgeneric-src/doomgeneric/doomgeneric-agentcube \
  -iwad wads/doom1.wad \
  -agentcube 127.0.0.1:8765
```

### Options

| Flag / env | Meaning |
|------------|---------|
| `-agentcube host:port` | Stream target (default `127.0.0.1:8765` or `AGENTCUBE_HOST`) |
| `-nostream` | Only local SDL window |
| `-nowindow` | Hidden SDL window (still needs video for events) |
| `-frameskip N` | Send every Nth frame (default 1) |
| `AGENTCUBE_FRAME_SKIP` | Same as frameskip |
| `AGENTCUBE_STREAM=0` | Disable stream |

Controls: arrows, Ctrl fire, Space use, Esc menu (classic Doom).

## Pipeline

1. Engine fills `DG_ScreenBuffer` (RGB888 `uint32`, default **640×400**).
2. `DG_DrawFrame` presents to SDL (optional).
3. Nearest-neighbour scale → **240×240**.
4. Convert to **RGB565 LE**.
5. `POST http://HOST/api/v1/draw/frame` with raw body (~115 200 bytes).

## Layout

```
agentcube-doom/
  README.md
  scripts/build-macos.sh
  wads/                 # gitignored — put IWAD here
  doomgeneric-src/      # vendored doomgeneric + our platform
    doomgeneric/
      doomgeneric_agentcube.c
      Makefile.agentcube
      doomgeneric-agentcube   # build output
```

## License

- Doomgeneric / Doom code: see `doomgeneric-src/LICENSE` (GPL-compatible Doom heritage).
- AgentCube platform glue in `doomgeneric_agentcube.c`: MIT (this project).
