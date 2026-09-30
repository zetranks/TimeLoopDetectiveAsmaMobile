using System;
using UnityEngine;

namespace RebornEternalLoop.Kingdom
{
    [Serializable]
    public sealed class KingdomBuilding
    {
        public string id;
        public string title;
        [Min(0)] public int level;
        [Min(1)] public int baseCost = 50;
        [Min(1)] public int maxLevel = 10;
    }

    /// <summary>Offline kingdom-building economy. Online purchases require server validation.</summary>
    public sealed class KingdomProgress : MonoBehaviour
    {
        [SerializeField] private int moonCoins = 100;
        [SerializeField] private KingdomBuilding[] buildings =
        {
            new KingdomBuilding { id="hall", title="Village Hall", baseCost=50, maxLevel=10 },
            new KingdomBuilding { id="farm", title="Moonlit Farm", baseCost=30, maxLevel=10 },
            new KingdomBuilding { id="sanctum", title="Arcane Sanctum", baseCost=100, maxLevel=5 }
        };
        public int MoonCoins => moonCoins;
        public KingdomBuilding[] Buildings => buildings;
        public event Action<KingdomBuilding> BuildingUpgraded;
        public bool TryUpgrade(string id)
        {
            foreach (var b in buildings)
            {
                if (b == null || b.id != id || b.level >= b.maxLevel) continue;
                int cost = b.baseCost * (b.level + 1) * (b.level + 1);
                if (moonCoins < cost) return false;
                moonCoins -= cost; b.level++; BuildingUpgraded?.Invoke(b); return true;
            }
            return false;
        }
        public void AddCoins(int amount) { if (amount > 0) moonCoins = Mathf.Min(int.MaxValue - amount, moonCoins) + amount; }
    }
}