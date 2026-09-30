using UnityEngine;

namespace RebornEternalLoop
{
    /// <summary>Offline vertical-slice gameplay loop. Multiplayer authority is added separately.</summary>
    public sealed class GamePrototypeController : MonoBehaviour
    {
        [Header("Prototype")]
        [SerializeField] private float moveSpeed = 5f;
        [SerializeField] private float attackRange = 2.4f;
        [SerializeField] private float attackCooldown = 0.45f;
        [SerializeField] private int startingHealth = 100;
        [SerializeField] private int enemyHealth = 30;

        private Transform player;
        private Transform enemy;
        private int health;
        private int level = 1;
        private int xp;
        private int enemyHp;
        private int loops;
        private float nextAttack;
        private Vector3 spawnPoint;
        private string notice = "WASD / arrows: move   Space: attack   R: rewind";

        private void Start()
        {
            health = startingHealth;
            spawnPoint = new Vector3(0f, 0.65f, 0f);
            player = GameObject.Find("PlayerSlime").transform;
            enemy = GameObject.Find("LoopWraith").transform;
            enemyHp = enemyHealth;
        }

        private void Update()
        {
            if (player == null || enemy == null) return;
            float x = Input.GetAxisRaw("Horizontal");
            float z = Input.GetAxisRaw("Vertical");
            Vector3 direction = new Vector3(x, 0f, z).normalized;
            player.position += direction * moveSpeed * Time.deltaTime;
            if (direction.sqrMagnitude > 0.01f) player.forward = direction;

            if (Input.GetKeyDown(KeyCode.Space) && Time.time >= nextAttack) Attack();
            if (Input.GetKeyDown(KeyCode.R)) Rewind();
            if (health <= 0) Rewind();
        }

        private void Attack()
        {
            nextAttack = Time.time + attackCooldown;
            if (Vector3.Distance(player.position, enemy.position) > attackRange)
            {
                notice = "Too far away. Move closer to attack.";
                return;
            }

            enemyHp -= 10 + level * 2;
            notice = "Arcane strike! The wraith loses health.";
            if (enemyHp <= 0)
            {
                xp += 25;
                enemy.position = new Vector3(Random.Range(-5f, 5f), 0.6f, Random.Range(3f, 8f));
                enemyHp = enemyHealth + loops * 5;
                notice = "Wraith defeated! +25 XP";
                while (xp >= level * 50)
                {
                    xp -= level * 50;
                    level++;
                    health = Mathf.Min(startingHealth + (level - 1) * 15, health + 25);
                    notice = "Level up! You are now level " + level + ".";
                }
            }
        }

        private void Rewind()
        {
            loops++;
            health = startingHealth + (level - 1) * 15;
            player.position = spawnPoint;
            enemy.position = new Vector3(3f, 0.6f, 5f);
            enemyHp = enemyHealth + loops * 5;
            notice = "Time rewound. Loop " + loops + " — the wraith grows stronger.";
        }

        private void OnGUI()
        {
            GUI.Box(new Rect(16, 16, 300, 128), "REBORN: ETERNAL LOOP");
            GUI.Label(new Rect(30, 45, 270, 22), "Level " + level + "     XP " + xp + " / " + (level * 50));
            GUI.Label(new Rect(30, 68, 270, 22), "HP " + health + " / " + (startingHealth + (level - 1) * 15));
            GUI.Label(new Rect(30, 91, 270, 22), "Time loops: " + loops);
            GUI.Label(new Rect(30, 114, 270, 22), "Enemy HP: " + Mathf.Max(0, enemyHp));
            GUI.Box(new Rect(16, Screen.height - 56, Mathf.Min(Screen.width - 32, 620), 40), notice);
            GUI.Label(new Rect(28, Screen.height - 47, 600, 24), "Move: WASD / arrows   Attack: SPACE   Rewind: R");
        }
    }
}