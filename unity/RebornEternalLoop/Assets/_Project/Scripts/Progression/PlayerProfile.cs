using System;
using UnityEngine;

namespace RebornEternalLoop.Progression
{
    [Serializable]
    public sealed class PlayerProfile
    {
        public string playerName = "Wayfarer";
        public int level = 1;
        public int experience;
        public int moonCoins;
        public int rebirths;
        public int strength = 10;
        public int vitality = 100;
        public int unlockedZone;
    }

    /// <summary>Local prototype save. Do not use client data as authority for online rewards.</summary>
    public static class PlayerProfileStore
    {
        private const string Key = "REL_PLAYER_PROFILE_V1";
        public static PlayerProfile Load()
        {
            if (!PlayerPrefs.HasKey(Key)) return new PlayerProfile();
            try { return JsonUtility.FromJson<PlayerProfile>(PlayerPrefs.GetString(Key)) ?? new PlayerProfile(); }
            catch { return new PlayerProfile(); }
        }
        public static void Save(PlayerProfile profile)
        {
            if (profile == null) return;
            PlayerPrefs.SetString(Key, JsonUtility.ToJson(profile));
            PlayerPrefs.Save();
        }
        public static void Reset()
        {
            PlayerPrefs.DeleteKey(Key);
            PlayerPrefs.Save();
        }
    }
}