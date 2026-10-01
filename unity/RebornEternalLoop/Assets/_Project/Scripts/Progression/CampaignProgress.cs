using System;
using UnityEngine;

namespace RebornEternalLoop
{
    /// <summary>
    /// Local campaign progression for the offline vertical slice. Rewards are deliberately
    /// client-local and must be moved to a trusted backend before online competitive play.
    /// </summary>
    public sealed class CampaignProgress : MonoBehaviour
    {
        [Serializable]
        private class SaveData
        {
            public int chapter = 1;
            public int defeatedWraiths;
            public int claimedChapter = 1;
            public int essence;
        }

        [SerializeField] private int defeatsPerChapter = 5;
        [SerializeField] private int chapterReward = 25;
        private SaveData data;
        private const string Key = "REL_CAMPAIGN_V1";

        public int Chapter { get { return data.chapter; } }
        public int DefeatedWraiths { get { return data.defeatedWraiths; } }
        public int Essence { get { return data.essence; } }
        public int DefeatsRequired { get { return Mathf.Max(1, defeatsPerChapter); } }
        public event Action<int> ChapterCompleted;

        private void Awake()
        {
            data = PlayerPrefs.HasKey(Key)
                ? JsonUtility.FromJson<SaveData>(PlayerPrefs.GetString(Key))
                : new SaveData();
            if (data == null) data = new SaveData();
            data.chapter = Mathf.Max(1, data.chapter);
            data.defeatedWraiths = Mathf.Max(0, data.defeatedWraiths);
            data.claimedChapter = Mathf.Max(1, data.claimedChapter);
            data.essence = Mathf.Max(0, data.essence);
        }

        public void RegisterWraithDefeat()
        {
            data.defeatedWraiths++;
            if (data.defeatedWraiths >= DefeatsRequired && data.claimedChapter < data.chapter)
            {
                data.claimedChapter = data.chapter;
                data.essence += chapterReward;
                ChapterCompleted?.Invoke(data.chapter);
            }
            Save();
        }

        public bool AdvanceChapter()
        {
            if (data.defeatedWraiths < DefeatsRequired) return false;
            data.chapter++;
            data.defeatedWraiths = 0;
            Save();
            return true;
        }

        public bool SpendEssence(int amount)
        {
            if (amount <= 0 || data.essence < amount) return false;
            data.essence -= amount;
            Save();
            return true;
        }

        public void AddEssence(int amount)
        {
            if (amount <= 0) return;
            data.essence = Mathf.Min(int.MaxValue - amount, data.essence) + amount;
            Save();
        }

        private void Save()
        {
            PlayerPrefs.SetString(Key, JsonUtility.ToJson(data));
            PlayerPrefs.Save();
        }
    }
}