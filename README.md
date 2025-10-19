====================================
              静雷
        Silent Thunder Studios
====================================

# Silent DPS Bars

A lightweight, performance-focused DPS and HPS tracker for World of Warcraft (Retail).  
Version 1 tracks the player's personal combat performance in real time using the combat log.  
The goal is to provide a simple, unobtrusive alternative to large meters like Recount or Details.

---

## Features

- Displays live DPS and HPS values for the player.
- Tracks total damage, total healing, and elapsed combat time.
- Updates automatically during combat.
- Minimal, movable frame.
- Slash command interface for control.

---

## Commands

All commands use `/sdb`:

| Command | Description |
|----------|--------------|
| `/sdb show`  | Shows the DPS/HPS frame. |
| `/sdb hide`  | Hides the DPS/HPS frame. |
| `/sdb reset` | Centers the frame on screen. |

---

## Installation

1. Download or clone this repository.
   ```bash
   git clone https://github.com/SWStudios-international/Silent-Dps-bars.git
2. Copy the folder SilentDPSBars into your WoW AddOns directory: World of Warcraft/_retail_/Interface/AddOns/
3. Verify the folder contains: SilentDPSBars.toc
main.lua
config.lua
4. Launch World of Warcraft and enable Silent DPS Bars in the AddOns menu.

How It Works

When combat starts (PLAYER_REGEN_DISABLED), the addon begins tracking:

Total damage done

Total healing done

Total missed attacks

When combat ends (PLAYER_REGEN_ENABLED), tracking pauses and the final totals remain displayed until the next fight.

Values are recalculated in real time using COMBAT_LOG_EVENT_UNFILTERED.

Technical Notes

Built for Retail WoW (Dragonflight / The War Within client).

Uses the modern BackdropTemplate and event-driven frame initialization.

SavedVariables: SilentDPSBarsDB

Frame name: SilentDPSBarsFrame

Memory and CPU footprint are minimal (<1 MB).

Known Limitations

Only tracks the player’s personal output.

Does not yet parse or rank party/raid members.

No in-game UI configuration.

No color or texture customization.

Roadmap

Multi-target / group tracking

UI customization window

Texture and font selection

Post-combat summary panel
