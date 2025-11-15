using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HardEdgeOutline : MonoBehaviour
{
    [SerializeField] private Material _outlineMat;
    [SerializeField] private MeshFilter _meshFilter;

    private void Awake()
    {
        GameObject outlineObject;

        outlineObject = new GameObject("Outline");
        outlineObject.transform.parent = transform;

        outlineObject.AddComponent<MeshFilter>();
        outlineObject.AddComponent<MeshRenderer>();
        Mesh tmpMesh = Instantiate(_meshFilter.sharedMesh);
        CreateMeshNormalAverage(tmpMesh);
        outlineObject.GetComponent<MeshFilter>().sharedMesh = tmpMesh;
        outlineObject.GetComponent<MeshRenderer>().material = _outlineMat;

        outlineObject.transform.localPosition = Vector3.zero;
        outlineObject.transform.localRotation = Quaternion.identity;
        outlineObject.transform.localScale = Vector3.one;
    }


    //Merge Vertex normal : which has same Vertex ID (= AvgNormal)


    private static void CreateMeshNormalAverage(Mesh mesh)
    {
        Dictionary<Vector3, List<int>> map = new Dictionary<Vector3, List<int>>();

        for (int v = 0; v < mesh.vertexCount; ++v)
        {
            if (!map.ContainsKey(mesh.vertices[v]))
            {
                map.Add(mesh.vertices[v], new List<int>());
            }

            map[mesh.vertices[v]].Add(v);
        }

        Vector3[] normals = mesh.normals;
        Vector3 normal;

        foreach (var p in map)
        {
            normal = Vector3.zero;

            foreach (var n in p.Value)
            {
                normal += mesh.normals[n];
            }

            normal /= p.Value.Count;

            foreach (var n in p.Value)
            {
                normals[n] = normal;
            }
        }

        mesh.normals = normals;
    }
}
