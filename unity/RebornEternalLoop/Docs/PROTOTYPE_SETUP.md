# Prototype setup in Unity Editor

This source scaffold is separate from the Godot project. Unity scene and prefab assets are binary/editor-authored and should be created in Unity.

## 1. Create the scene
- Create a scene named `Bootstrap` under `Assets/_Project/Scenes`.
- Add a plane for the ground, directional light, and a camera.
- Add an empty `NetworkManager` GameObject.
- Add `NetworkManager` and `UnityTransport` components.
- Create a player prefab using a capsule with `NetworkObject`, `NetworkTransform`, and `NetworkPlayer`.
- Assign the player prefab in NetworkManager's Network Prefabs / Player Prefab settings.
- Configure the NetworkTransform to synchronize position and rotation.
- Add UI buttons that call `NetworkManager.Singleton.StartHost()` and `StartClient()` for local testing.

## 2. Test locally
Use Multiplayer Play Mode or two standalone clients. Verify that host and client can join and see each other's player. This movement script is a prototype; use the Input System and server-authoritative movement before production.

## 3. Add the next systems
1. Replace the capsule with an original rigged character and Animator.
2. Add enemy AI and server-authoritative combat.
3. Add idle rewards and character progression backed by a trusted server.
4. Add party, guild, and moderated chat services.
5. Add kingdom regions, mounts, and raid encounters.

## Mobile notes
Use URP, baked lighting where practical, texture compression, LODs, and a scalable quality setting. Test on real Android and iOS devices early. iOS builds require macOS with Xcode.
