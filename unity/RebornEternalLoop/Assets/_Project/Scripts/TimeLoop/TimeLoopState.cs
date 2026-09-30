using System;
using UnityEngine;

namespace RebornEternalLoop.TimeLoop
{
    /// <summary>Prototype rewind state. Production state should be saved and validated by the backend.</summary>
    [Serializable]
    public sealed class TimeLoopState
    {
        [SerializeField, Min(0)] private int loopCount;
        [SerializeField, Min(0)] private int chronoEssence;
        [SerializeField, Min(0)] private int permanentResearch;

        public int LoopCount => loopCount;
        public int ChronoEssence => chronoEssence;
        public int PermanentResearch => permanentResearch;

        public void GrantEssence(int amount) => chronoEssence = Mathf.Max(0, chronoEssence + amount);

        public bool Rewind(int essenceCost)
        {
            if (essenceCost < 0 || chronoEssence < essenceCost) return false;
            chronoEssence -= essenceCost;
            loopCount++;
            return true;
        }

        public void UpgradeResearch(int cost)
        {
            if (cost <= 0 || chronoEssence < cost) return;
            chronoEssence -= cost;
            permanentResearch++;
        }
    }
}
