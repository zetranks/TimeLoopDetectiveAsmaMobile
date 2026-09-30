# Android test build

This project is an offline gameplay prototype, not a finished commercial game. The Android build can be used to test the current prototype on a device after opening it in Unity.

## Configure

1. Install Unity 6 with Android Build Support, Android SDK & NDK Tools, and OpenJDK.
2. Open `unity/RebornEternalLoop` in Unity Hub.
3. Allow Unity Package Manager to resolve the manifest dependencies.
4. Use **Reborn Eternal Loop > Build Prototype Scene** to generate the arena scene.
5. Open `Assets/_Project/Scenes/Bootstrap.unity` and add it to **File > Build Profiles > Scene List** (or the equivalent Build Settings scene list in your installed Unity version).
6. Set the platform to Android. Set a unique application identifier under Player settings before making a store build.
7. Set orientation to Landscape for the current on-screen movement pad and action buttons.
8. Build an APK for direct device testing. Use a signed Android App Bundle (AAB) for Google Play later.

## Current controls

- Touch movement pad: move the slime.
- ATTACK: strike the Wraith when close enough.
- REWIND: reset the arena and increase the loop count.
- Progression (level, XP, loops, moon coins) is saved locally with PlayerPrefs.

## Known limitations

- This is an offline, single-player prototype. Multiplayer, cloud saves, accounts, matchmaking, moderation, purchases, and server authority are not implemented.
- The arena uses Unity primitive shapes. Character art, animation, sound, narrative campaign, kingdom construction, quests, and final boss content are not complete.
- The current prototype has not been compiled or device-tested in this environment. Resolve any Unity Console errors before building.
- PlayerPrefs is local prototype storage, not secure or suitable for competitive or paid progression.
