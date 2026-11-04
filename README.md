# My First RPG

[![Godot Engine](https://img.shields.io/badge/Godot-4.x-478cbf?logo=godotengine&logoColor=white)](https://godotengine.org/)
[![Physics](https://img.shields.io/badge/Physics-Godot%20Jolt%203D-ff5500)](https://github.com/godot-jolt/godot-jolt)
[![Renderer](https://img.shields.io/badge/Renderer-GL%20Compatibility-green)](#tech-stack)
[![Game Jam](https://img.shields.io/badge/Event-The%20Worst%20Game%20Jam-red)](#concept)
[![Git LFS](https://img.shields.io/badge/Assets-Git%20LFS-blue?logo=git-lfs)](https://git-lfs.com/)

> **A satirical, deliberately frustrating first-person 3D RPG set in a collapsed nation, crafted for *"The Worst Game Jam"*.*

---

## 📖 Concept & Lore

Following a catastrophic monetary crisis, the nation has collapsed into total lawlessness. The streets are ruled by chaotic mobs fighting over scarce rations, governed only by brute strength and tribalism.

You play as **Tegar**, a former member of the remnants of law enforcement who was knocked unconscious in building ruins after a brutal mob confrontation. Awaking with amnesia, your only connection to your identity is your smartphone—which contains the final dying wish of your grandmother:

> *"Tegar, become a Hero."*

As Tegar steps out into the ruins, the trauma and stress flood back, fracturing his psyche into conflicting voices. Each voice offers a radically different philosophical definition of what a "Hero" truly is. Your choices determine which voice you heed, leading to four distinct, comedic, and non-linear endings.

---

## 🤪 Deliberately "Worst" Features

As an entry for **The Worst Game Jam**, the game incorporates intentional design obstacles designed to test the player's patience and sanity:

* **Cursed Input Mapping**:
  * Movement is mapped to **Z, X, C, V** instead of standard WASD!
  * **W, A, S, D** are actually hotkeys for your 4 inventory slots!
* **Combat Captcha Popups**:
  * Interacting with the world has a random chance of triggering a full-screen **Captcha verification**.
  * While solving the captcha, player movement is locked—**but the game does NOT pause**, leaving you completely vulnerable to enemy beatdowns!
* **Unpausable "Pause" Menu**:
  * Pressing `Escape` does not pause the world. It merely shows a volume slider and a timer revealing when the next erratic auto-save will occur.
* **Chaotic Auto-Save**:
  * No manual saving. Progress is saved at randomized, unpredictable intervals.
  * Dying restarts you from your last erratic save point.
* **Whispers of Thought**:
  * Internal voices banter, dispute definitions of heroism, and deliver patronizing praise for trivial actions.

---

## 🎯 Multiple Endings (The 4 Paths to Heroism)

The game features an open city map that can be explored freely. How you interpret the grandmother's wish dictates your quest line:

| Ending | Quest | Objective |
| :--- | :--- | :--- |
| 🛡️ **Sovereign Ending** (*The Savior*) | Save the Nation | Eliminate 50 enemies roaming the city ruins to violently restore peace. |
| 📻 **Popular Ending** (*The Influencer*) | Become Popular | Navigate to the central radio tower and switch on all 4 broadcasting transmitters. |
| ✈️ **Escape Ending** (*The Deserter*) | Self-Preservation | Travel to the abandoned airport, complete platforming challenges, and catch an escape flight abroad. |
| 🏍️ **True Ending** (*The Dutiful Grandson*) | Return to Family | Scavenge a canister of fuel, repair Tegar's broken motorbike at the spawn point, and ride home to look after grandpa. |

---

## 🎮 Controls

| Action | Key / Input | Notes |
| :--- | :--- | :--- |
| **Move Forward** | `X` | *Not W!* |
| **Move Backward** | `C` | *Not S!* |
| **Move Left** | `Z` | *Not A!* |
| **Move Right** | `V` | *Not D!* |
| **Jump** | `Right Shift` | Platforming & climbing |
| **Look Around** | `Mouse` | First-Person Camera |
| **Attack / Use Item** | `Left Click` | Swings weapon / consumes items |
| **Interact / Pick Up** | `P` | Scavenge items, press switches (Chance of Captcha!) |
| **Drop Held Item** | `O` | Drops the currently equipped item |
| **Select Inventory Slot 1** | `W` | Replaces usual move forward key |
| **Select Inventory Slot 2** | `A` | Replaces usual move left key |
| **Select Inventory Slot 3** | `S` | Replaces usual move backward key |
| **Select Inventory Slot 4** | `D` | Replaces usual move right key |
| **Pause / Menu** | `Escape` | Does *not* pause the world simulation |

---

## 🛠️ Architecture & Systems

* **Engine & Compatibility**: Godot 4.x with **GL Compatibility** renderer for broad cross-platform support across lower-spec hardware without requiring Vulkan.
* **Physics Engine**: [Godot Jolt 3D](https://github.com/godot-jolt/godot-jolt) physics integration.
* **Data-Driven Inventory**: Built with custom `ItemData` resources (`.tres`) managing icons, stats, and specialized interactions.
* **Event-Driven Architecture**: Fully decoupled communication through an autoloaded `EventBus` singleton (`EventBus.gd`).
* **Cinematics**: Full-motion video cutscenes (`.ogv`) streamed via `VideoStreamPlayer` for all ending sequences.

---

## 📁 Project Structure

```text
my-first-rpg/
├── assets/                  # 3D models (.glb), textures, audio, and cutscene videos (.ogv)
├── src/
│   ├── animation/           # Cutscene playback controller & ending sequence logic
│   ├── autoload/            # Global singletons (EventBus, VoiceManager)
│   ├── core/                # Core components (HealthComponent, SaveSystem)
│   ├── entities/
│   │   ├── enemy/           # Enemy AI, spawner, and enemy scenes
│   │   └── player/          # First-person character controller, inventory, viewmodel
│   ├── items/               # Interactable item bases and specialized pickable objects
│   ├── quests/              # Quests logic (Radio towers, Motorbike, Airport, Enemy counter)
│   ├── resources/           # Item data definitions (.tres)
│   ├── ui/                  # Captcha popup, Ending victory screens, HUD, and Pause menu
│   └── world/               # Game scenes (introduction_scene, main_world, test_world)
├── project.godot            # Godot engine project configuration
└── docs.md                  # Detailed design specifications and developer guides
```

---

## 🚀 Getting Started

### Prerequisites

1. **[Godot Engine 4.3+](https://godotengine.org/download)** (Standard Version).
2. **[Git LFS](https://git-lfs.com/)** (Required for 3D models and video assets).
3. **Godot Jolt Plugin** (Configured as the active 3D physics engine).

### Clone & Setup

```bash
# 1. Clone the repository
git clone https://github.com/Fahmi-mi/my-first-rpg.git
cd my-first-rpg

# 2. Pull all Git LFS binary assets (Crucial!)
git lfs install
git lfs pull

# 3. Open project in Godot
godot --editor project.godot
```

> [!IMPORTANT]
> Always execute `git lfs pull` after cloning or pulling new commits to ensure all `.glb` 3D models and `.ogv` video files are downloaded properly.

---

## 📦 Building / Exporting

1. Open the project in the Godot Editor.
2. Navigate to **Editor** $\rightarrow$ **Manage Export Templates...** and ensure templates are downloaded.
3. Open **Project** $\rightarrow$ **Export...**.
4. Select or add your target platform (e.g., **Windows Desktop** or **Linux/X11**).
5. In the preset's **Resources** tab:
   * Set **Export Mode** to *Export all resources in the project*.
   * In **Filters to export non-resource files/folders**, add: `*.ogv, *.glb, *.png, *.jpg, *.svg`.
6. Click **Export Project** and specify the output destination.

Alternatively, build via CLI:
```bash
# Export release for Linux
godot --headless --export-release "Linux/X11" build/linux/my-first-rpg.x86_64

# Export release for Windows
godot --headless --export-release "Windows Desktop" build/windows/my-first-rpg.exe
```

---

## 👥 Credits

Developed with ❤️ and pure spite for **The Worst Game Jam**.
