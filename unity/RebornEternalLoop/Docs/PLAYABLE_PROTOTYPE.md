# Playable prototype

## Create the first scene
1. Open `unity/RebornEternalLoop` in Unity 6.
2. Wait for package import and script compilation.
3. Select **Reborn Eternal Loop → Build Prototype Scene** from the Unity menu.
4. Open `Assets/_Project/Scenes/Bootstrap.unity` if it is not already open, then press **Play**.

## Current vertical slice
- WASD or arrow-key movement
- Space-bar close-range attack
- A respawning Loop Wraith enemy
- XP gain and level progression
- Health recovery on level-up
- R key time rewind, with the enemy gaining health each loop
- Basic on-screen status and control instructions

The scene builder uses primitive placeholder art. This is a local, single-player gameplay slice, not a finished online game. Multiplayer, persistence, touch controls, original character art, audio, quests, kingdom building, and production security remain future work. The prototype uses Unity's legacy keyboard input for desktop testing; set Active Input Handling to Both if the project's Input System setting prevents it from running.

## Next milestones
1. Replace primitives with original rigged characters and an anime-inspired environment.
2. Add touch joystick and action buttons for mobile.
3. Add server-authoritative networking and authenticated player profiles.
4. Implement idle rewards, inventory, evolution, kingdom systems, guilds, and chat.
5. Profile and test on target Android and iOS devices.