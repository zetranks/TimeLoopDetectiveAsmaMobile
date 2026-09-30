using System;
using UnityEngine;

namespace RebornEternalLoop.Combat
{
    public enum AbilityKind { ArcaneBolt, SlimeBurst, VerdantGuard, ChronoPulse }

    [Serializable]
    public sealed class AbilityDefinition
    {
        public AbilityKind kind;
        public string displayName;
        [Min(0)] public int power = 20;
        [Min(0f)] public float cooldown = 3f;
        [TextArea] public string description;
    }

    /// <summary>Data-driven ability cooldown and damage rules for local combat prototypes.</summary>
    public sealed class AbilityBook : MonoBehaviour
    {
        [SerializeField] private AbilityDefinition[] abilities =
        {
            new AbilityDefinition { kind = AbilityKind.ArcaneBolt, displayName = "Arcane Bolt", power = 20, cooldown = 2f, description = "A focused magical projectile." },
            new AbilityDefinition { kind = AbilityKind.SlimeBurst, displayName = "Slime Burst", power = 35, cooldown = 5f, description = "A close-range burst of slime magic." },
            new AbilityDefinition { kind = AbilityKind.VerdantGuard, displayName = "Verdant Guard", power = 0, cooldown = 12f, description = "A defensive blessing." },
            new AbilityDefinition { kind = AbilityKind.ChronoPulse, displayName = "Chrono Pulse", power = 45, cooldown = 15f, description = "A strike empowered by a time loop." }
        };
        private readonly System.Collections.Generic.Dictionary<AbilityKind, float> readyAt = new System.Collections.Generic.Dictionary<AbilityKind, float>();
        public AbilityDefinition Find(AbilityKind kind)
        {
            foreach (var ability in abilities) if (ability != null && ability.kind == kind) return ability;
            return null;
        }
        public bool TryUse(AbilityKind kind, out AbilityDefinition ability)
        {
            ability = Find(kind);
            if (ability == null || Time.time < (readyAt.TryGetValue(kind, out var t) ? t : 0f)) return false;
            readyAt[kind] = Time.time + ability.cooldown;
            return true;
        }
        public float CooldownRemaining(AbilityKind kind)
        {
            return Mathf.Max(0f, (readyAt.TryGetValue(kind, out var t) ? t : 0f) - Time.time);
        }
    }
}