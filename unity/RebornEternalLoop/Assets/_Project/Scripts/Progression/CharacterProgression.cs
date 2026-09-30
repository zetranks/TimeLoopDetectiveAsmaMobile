using UnityEngine;

namespace RebornEternalLoop.Progression
{
    /// <summary>Local prototype progression. Persist and validate progression on the server before release.</summary>
    public sealed class CharacterProgression : MonoBehaviour
    {
        [SerializeField, Min(1)] private int level = 1;
        [SerializeField, Min(1)] private int maxLevel = 500;
        [SerializeField, Min(1)] private int experienceToNextLevel = 100;

        public int Level => level;
        public int Experience { get; private set; }
        public int ExperienceToNextLevel => experienceToNextLevel;

        public void AddExperience(int amount)
        {
            if (amount <= 0) return;
            Experience += amount;
            while (level < maxLevel && Experience >= experienceToNextLevel)
            {
                Experience -= experienceToNextLevel;
                level++;
                experienceToNextLevel = Mathf.CeilToInt(experienceToNextLevel * 1.15f);
            }
            if (level >= maxLevel) Experience = 0;
        }
    }
}
