using UnityEngine;

namespace RebornEternalLoop
{
    /// <summary>Simple local enemy pursuit for the offline prototype.</summary>
    public sealed class WraithEnemyAI : MonoBehaviour
    {
        [SerializeField] private float pursuitSpeed = 1.6f;
        [SerializeField] private float stoppingDistance = 1.45f;
        [SerializeField] private float turnSpeed = 8f;
        private Transform target;

        private void Start()
        {
            var player = GameObject.Find("PlayerSlime");
            if (player != null) target = player.transform;
        }

        private void Update()
        {
            if (target == null) return;
            Vector3 offset = target.position - transform.position;
            offset.y = 0f;
            if (offset.sqrMagnitude <= stoppingDistance * stoppingDistance) return;
            Vector3 direction = offset.normalized;
            transform.position += direction * pursuitSpeed * Time.deltaTime;
            if (direction.sqrMagnitude > 0.001f)
            {
                var desired = Quaternion.LookRotation(direction);
                transform.rotation = Quaternion.Slerp(transform.rotation, desired, turnSpeed * Time.deltaTime);
            }
        }
    }
}