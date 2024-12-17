# Garry's Mod Survival Gamemode

This repository contains the source code for a Garry's Mod gamemode based on survival gameplay. The gamemode includes various systems such as character creation, admin commands, logging, and more.

**Note: This gamemode is a work in progress.**

### [`adminSystem`](adminSystem )

- **Purpose**: Contains the admin system for managing commands, logging, and user permissions.
- **Key Files**:
  - [`sh_admin_system.lua`](adminSystem/lua/autorun/sh_admin_system.lua ): Shared admin system definitions and utilities.

### [`characterCreator`](characterCreator )

- **Purpose**: Manages character creation and customization.
- **Key Files**:
  - [`sh_character_creator.lua`](characterCreator/lua/autorun/sh_character_creator.lua ): Shared character creation definitions and utilities.

### [`keyBinding`](keyBinding )

- **Purpose**: Manages key bindings for various actions.
- **Key Files**: Lua scripts for key binding configurations.

### [`log`](log )

- **Purpose**: Handles logging of various events and actions.
- **Key Files**: Shared logging definitions and utilities.

### [`networkVar`](networkVar )

- **Purpose**: Manages networked variables for player data.
- **Key Files**: Shared network variable definitions.

### [`pm_apo`](pm_apo )

- **Purpose**: Contains player models and related assets.
- **Key Files**:
  - [`addon.txt`](pm_apo/addon.txt ): Addon metadata.

### [`sql`](sql )

- **Purpose**: Manages SQL database interactions.
- **Key Files**: Server-side SQL logic.

### [`TODO.txt`](TODO.txt )

- **Purpose**: Contains a list of tasks and features to be implemented.
