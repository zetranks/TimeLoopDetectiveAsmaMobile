using UnityEngine;

namespace RebornEternalLoop.Combat
{
    /// <summary>Starter combat stats. Production multiplayer combat must be server-authoritative.</summary>
    public sealed class Combatant : MonoBehaviour
    {
        [SerializeField, Min(1)] private int maxHealth = 100;
        [SerializeField, Min(0)] private int attackPower = 10;

        public int MaxHealth => maxHealth;
        public int AttackPower => attackPower;
        public int CurrentHealth { get; private set; }

        private void Awake() => CurrentHealth = maxHealth;

        public void ApplyDamage(int amount)
        {
            if (amount <= 0 || CurrentHealth <= 0) return;
            CurrentHealth = Mathf.Max(0, CurrentHealth - amount);
        }

        public void Restore()
        {
            CurrentHealth = maxHealth;
        }
    }
}
