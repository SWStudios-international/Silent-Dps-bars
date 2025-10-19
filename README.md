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


