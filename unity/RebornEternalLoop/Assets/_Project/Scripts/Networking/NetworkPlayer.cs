using Unity.Netcode;
using UnityEngine;

namespace RebornEternalLoop.Networking
{
    /// <summary>Minimal network-owned player movement for the first shared-world prototype.</summary>
    [RequireComponent(typeof(NetworkObject))]
    public sealed class NetworkPlayer : NetworkBehaviour
    {
        [SerializeField, Min(0.1f)] private float moveSpeed = 4f;
        [SerializeField] private Transform visualRoot;

        private void Update()
        {
            if (!IsOwner) return;

            float x = Input.GetAxisRaw("Horizontal");
            float z = Input.GetAxisRaw("Vertical");
            Vector3 direction = new Vector3(x, 0f, z).normalized;
            transform.position += direction * (moveSpeed * Time.deltaTime);

            if (direction.sqrMagnitude > 0.001f && visualRoot != null)
                visualRoot.rotation = Quaternion.Slerp(visualRoot.rotation,
                    Quaternion.LookRotation(direction), 12f * Time.deltaTime);
        }
    }
}
