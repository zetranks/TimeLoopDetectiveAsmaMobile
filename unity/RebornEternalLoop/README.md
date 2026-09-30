# Reborn: Eternal Loop (Unity prototype)

An original 3D anime-inspired online idle RPG prototype. This project is intentionally separate from the existing Godot game in the repository.

## Prototype scope
- Unity 6 LTS, Universal Render Pipeline (URP)
- Networked player movement using Netcode for GameObjects
- Original fantasy setting and placeholder capsule visuals
- Starter combat and progression data models
- Mobile-ready input and UI direction

## Open in Unity
1. Install Unity Hub and a Unity 6 LTS editor with Android Build Support. Install iOS Build Support if building on macOS.
2. Open this folder as a Unity project.
3. Let Unity resolve packages, then open `Assets/_Project/Scenes/Bootstrap.unity` once created in the editor.
4. Create a NetworkManager scene object, assign UnityTransport, and configure a Player prefab with NetworkObject and NetworkTransform.
5. Add the scripts under `Assets/_Project/Scripts` to the matching objects.

This repository scaffold does not include Unity-generated scene, prefab, or binary art assets yet. Create those in the Unity editor as described in `Docs/PROTOTYPE_SETUP.md`.

## Networking
The first prototype uses Unity Netcode for GameObjects with Unity Transport. For a public release, use a dedicated authoritative server and validate progression, rewards, purchases, and chat server-side. Do not trust client-submitted currency or combat outcomes.

## Legal / IP
All characters, names, locations, and story elements should remain original. The game may use general genre mechanics, but must not include third-party franchise characters, logos, artwork, music, dialogue, or distinctive story elements without permission.
