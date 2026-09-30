using UnityEngine;

namespace RebornEternalLoop
{
    /// <summary>Offline mobile-first vertical slice. Online authority is not yet implemented.</summary>
    public sealed class GamePrototypeController : MonoBehaviour
    {
        [Header("Movement and combat")]
        [SerializeField] private float moveSpeed = 5f;
        [SerializeField] private float attackRange = 2.4f;
        [SerializeField] private float attackCooldown = 0.45f;
        [SerializeField] private int startingHealth = 100;
        [SerializeField] private int enemyHealth = 30;
        [SerializeField] private int attackBaseDamage = 10;

        private Transform player;
        private Transform enemy;
        private int health, level = 1, xp, enemyHp, loops, coins;
        private float nextAttack;
        private Vector3 spawnPoint;
        private string notice = "Use the movement pad, ATTACK and REWIND.";
        private Vector2 mobileMove;
        private bool attackPressed, rewindPressed;
        private const string SaveKey = "REL_SAVE_V1";

        [System.Serializable]
        private class SaveData { public int level = 1; public int xp; public int loops; public int coins; }

        private void Start()
        {
            health = startingHealth;
            spawnPoint = new Vector3(0f, 0.65f, 0f);
            var p = GameObject.Find("PlayerSlime");
            var e = GameObject.Find("LoopWraith");
            if (p == null || e == null) { notice = "Build the prototype scene from the Reborn menu."; return; }
            player = p.transform;
            enemy = e.transform;
            Load();
            enemyHp = enemyHealth + loops * 5;
        }

        private void Update()
        {
            if (player == null || enemy == null) return;
            float x = Input.GetAxisRaw("Horizontal") + mobileMove.x;
            float z = Input.GetAxisRaw("Vertical") + mobileMove.y;
            Vector3 direction = new Vector3(Mathf.Clamp(x, -1, 1), 0f, Mathf.Clamp(z, -1, 1)).normalized;
            player.position += direction * moveSpeed * Time.deltaTime;
            if (direction.sqrMagnitude > 0.01f) player.forward = direction;
            if ((Input.GetKeyDown(KeyCode.Space) || attackPressed) && Time.time >= nextAttack) Attack();
            if (Input.GetKeyDown(KeyCode.R) || rewindPressed) Rewind();
            attackPressed = false; rewindPressed = false;
            if (health <= 0) Rewind();
        }

        private void Attack()
        {
            nextAttack = Time.time + attackCooldown;
            if (Vector3.Distance(player.position, enemy.position) > attackRange)
            { notice = "Move closer to the Wraith to attack."; return; }
            enemyHp -= attackBaseDamage + level * 2;
            notice = "Arcane strike!";
            if (enemyHp <= 0)
            {
                xp += 25; coins += 5;
                enemy.position = new Vector3(Random.Range(-5f, 5f), 0.6f, Random.Range(3f, 8f));
                enemyHp = enemyHealth + loops * 5;
                notice = "Wraith defeated! +25 XP, +5 moon coins.";
                while (xp >= level * 50)
                {
                    xp -= level * 50; level++;
                    health = Mathf.Min(MaxHealth, health + 25);
                    notice = "Evolution! You reached level " + level + ".";
                }
                Save();
            }
        }

        private int MaxHealth { get { return startingHealth + (level - 1) * 15; } }

        private void Rewind()
        {
            loops++;
            health = MaxHealth;
            if (player != null) player.position = spawnPoint;
            if (enemy != null) enemy.position = new Vector3(3f, 0.6f, 5f);
            enemyHp = enemyHealth + loops * 5;
            notice = "Chrono Rebirth: Loop " + loops + ". The Wraith grows stronger.";
            Save();
        }

        private void Save()
        {
            var data = new SaveData { level = level, xp = xp, loops = loops, coins = coins };
            PlayerPrefs.SetString(SaveKey, JsonUtility.ToJson(data));
            PlayerPrefs.Save();
        }

        private void Load()
        {
            if (!PlayerPrefs.HasKey(SaveKey)) return;
            var data = JsonUtility.FromJson<SaveData>(PlayerPrefs.GetString(SaveKey));
            if (data == null) return;
            level = Mathf.Max(1, data.level); xp = Mathf.Max(0, data.xp);
            loops = Mathf.Max(0, data.loops); coins = Mathf.Max(0, data.coins);
            health = MaxHealth;
        }

        private void OnGUI()
        {
            float scale = Mathf.Clamp(Screen.width / 900f, 0.75f, 1.5f);
            GUI.matrix = Matrix4x4.TRS(Vector3.zero, Quaternion.identity, new Vector3(scale, scale, 1));
            float w = Screen.width / scale, h = Screen.height / scale;
            GUI.Box(new Rect(12, 12, 310, 142), "REBORN: ETERNAL LOOP");
            GUI.Label(new Rect(25, 42, 285, 22), "Level " + level + "   XP " + xp + "/" + (level * 50));
            GUI.Label(new Rect(25, 65, 285, 22), "HP " + health + "/" + MaxHealth);
            GUI.Label(new Rect(25, 88, 285, 22), "Loops " + loops + "   Moon coins " + coins);
            GUI.Label(new Rect(25, 111, 285, 22), "Wraith HP " + Mathf.Max(0, enemyHp));
            GUI.Box(new Rect(12, h - 48, Mathf.Min(w - 24, 640), 36), notice);

            // On-screen controls work with mouse in the Editor and touch on Android.
            float bx = 28, by = h - 190, s = 58;
            mobileMove = Vector2.zero;
            if (GUI.RepeatButton(new Rect(bx + s, by, s, s), "▲")) mobileMove.y = 1;
            if (GUI.RepeatButton(new Rect(bx + s, by + s * 2, s, s), "▼")) mobileMove.y = -1;
            if (GUI.RepeatButton(new Rect(bx, by + s, s, s), "◀")) mobileMove.x = -1;
            if (GUI.RepeatButton(new Rect(bx + s * 2, by + s, s, s), "▶")) mobileMove.x = 1;
            if (GUI.Button(new Rect(w - 166, h - 150, 140, 62), "ATTACK")) attackPressed = true;
            if (GUI.Button(new Rect(w - 166, h - 78, 140, 52), "REWIND")) rewindPressed = true;
        }
    }
}