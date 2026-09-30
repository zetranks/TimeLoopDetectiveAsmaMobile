#if UNITY_EDITOR
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace RebornEternalLoop.Editor
{
    public static class PrototypeSceneBuilder
    {
        [MenuItem("Reborn Eternal Loop/Build Prototype Scene")]
        public static void Build()
        {
            var scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);
            RenderSettings.ambientLight = new Color(0.55f, 0.58f, 0.68f);
            var light = new GameObject("Moonlight", typeof(Light)).GetComponent<Light>();
            light.type = LightType.Directional;
            light.intensity = 1.25f;
            light.transform.rotation = Quaternion.Euler(48f, -32f, 0f);

            var floor = GameObject.CreatePrimitive(PrimitiveType.Plane);
            floor.name = "Arena";
            floor.transform.localScale = new Vector3(2f, 1f, 2f);
            floor.GetComponent<Renderer>().sharedMaterial = Material(new Color(0.15f, 0.22f, 0.28f));

            var player = GameObject.CreatePrimitive(PrimitiveType.Sphere);
            player.name = "PlayerSlime";
            player.transform.position = new Vector3(0f, 0.65f, 0f);
            player.transform.localScale = new Vector3(1.1f, 0.9f, 1.1f);
            player.GetComponent<Renderer>().sharedMaterial = Material(new Color(0.18f, 0.85f, 0.72f));

            var enemy = GameObject.CreatePrimitive(PrimitiveType.Capsule);
            enemy.name = "LoopWraith";
            enemy.transform.position = new Vector3(3f, 0.6f, 5f);
            enemy.transform.localScale = new Vector3(0.85f, 1.2f, 0.85f);
            enemy.GetComponent<Renderer>().sharedMaterial = Material(new Color(0.62f, 0.25f, 0.85f));

            var cameraObject = new GameObject("PrototypeCamera", typeof(Camera), typeof(AudioListener));
            var camera = cameraObject.GetComponent<Camera>();
            camera.transform.position = new Vector3(0f, 10f, -9f);
            camera.transform.rotation = Quaternion.Euler(48f, 0f, 0f);
            camera.orthographic = false;
            camera.fieldOfView = 55f;
            camera.clearFlags = CameraClearFlags.SolidColor;
            camera.backgroundColor = new Color(0.07f, 0.1f, 0.17f);

            var controller = new GameObject("GamePrototypeController");
            controller.AddComponent<RebornEternalLoop.GamePrototypeController>();

            EditorSceneManager.SaveScene(scene, "Assets/_Project/Scenes/Bootstrap.unity");
            AssetDatabase.SaveAssets();
            EditorUtility.DisplayDialog("Reborn: Eternal Loop", "Prototype scene created. Press Play to test movement, attacks, XP, levels, and rewind.", "OK");
        }

        private static Material Material(Color color)
        {
            var shader = Shader.Find("Universal Render Pipeline/Lit");
            if (shader == null) shader = Shader.Find("Standard");
            var material = new Material(shader);
            material.color = color;
            return material;
        }
    }
}
#endif