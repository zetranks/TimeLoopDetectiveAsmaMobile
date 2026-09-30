using System;
using System.Collections.Generic;
using UnityEngine;

namespace RebornEternalLoop.Quests
{
    public enum QuestObjectiveType { DefeatEnemies, CollectMoonCoins, Rebirth, ReachLevel }

    [Serializable]
    public sealed class QuestDefinition
    {
        public string id = "first_hunt";
        public string title = "First Hunt";
        [TextArea] public string description = "Defeat three wandering wraiths.";
        public QuestObjectiveType objective;
        [Min(1)] public int target = 3;
        [Min(0)] public int coinReward = 25;
        [Min(0)] public int experienceReward = 50;
    }

    [Serializable]
    public sealed class QuestProgress
    {
        public string id;
        public int count;
        public bool claimed;
    }

    /// <summary>Local quest tracking. Rewards must be server-validated in multiplayer.</summary>
    public sealed class QuestLog : MonoBehaviour
    {
        [SerializeField] private QuestDefinition[] quests =
        {
            new QuestDefinition { id="first_hunt", title="First Hunt", description="Defeat three wandering wraiths.", objective=QuestObjectiveType.DefeatEnemies, target=3, coinReward=25, experienceReward=50 },
            new QuestDefinition { id="time_touched", title="Time Touched", description="Complete one Chrono Rebirth.", objective=QuestObjectiveType.Rebirth, target=1, coinReward=50, experienceReward=75 },
            new QuestDefinition { id="apprentice", title="A Slime Awakens", description="Reach level five.", objective=QuestObjectiveType.ReachLevel, target=5, coinReward=100, experienceReward=150 }
        };
        private readonly Dictionary<string, QuestProgress> progress = new Dictionary<string, QuestProgress>();
        public event Action<QuestDefinition> QuestCompleted;
        private void Awake()
        {
            foreach (var q in quests) if (q != null && !progress.ContainsKey(q.id)) progress[q.id] = new QuestProgress { id=q.id };
        }
        public IReadOnlyList<QuestDefinition> Definitions => quests;
        public int ProgressFor(string id) => progress.TryGetValue(id, out var p) ? p.count : 0;
        public bool IsComplete(QuestDefinition q) => q != null && progress.TryGetValue(q.id, out var p) && p.count >= q.target;
        public bool IsClaimed(string id) => progress.TryGetValue(id, out var p) && p.claimed;
        public void Report(QuestObjectiveType type, int amount = 1)
        {
            if (amount <= 0) return;
            foreach (var q in quests)
            {
                if (q == null || q.objective != type || !progress.TryGetValue(q.id, out var p) || p.claimed) continue;
                int before = p.count;
                p.count = Mathf.Min(q.target, p.count + amount);
                if (before < q.target && p.count >= q.target) QuestCompleted?.Invoke(q);
            }
        }
        public bool TryClaim(string id, out int coins, out int experience)
        {
            coins = 0; experience = 0;
            foreach (var q in quests)
            {
                if (q == null || q.id != id || !IsComplete(q) || IsClaimed(id)) continue;
                progress[id].claimed = true; coins = q.coinReward; experience = q.experienceReward; return true;
            }
            return false;
        }
    }
}