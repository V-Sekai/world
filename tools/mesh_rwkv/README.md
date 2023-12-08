# VSEKAI_mesh_geometric_embedding GLTF 2.0 Extension Specification

## Contributors

- K. S. Ernest (iFire) Lee, V-Sekai & Godot Engine, [@fire](https://github.com/fire)

## Status

Draft

## Dependencies

Written against the glTF 2.0 specification and the EXT_structural_metadata extension.

## Overview

The `VSEKAI_mesh_geometric_embedding` extension is an extension for the GLTF 2.0 specification. This extension provides additional geometric metadata for meshes, including face area, edge definition, edge area, and edge angles in radians.

## Extension Schema

```json
{
  "asset": {
    "version": "2.0"
  },
  "extensionsUsed": [
    "VSEKAI_mesh_geometric_embedding",
    "EXT_structural_metadata"
  ],
  "extensions": {
    "EXT_structural_metadata": {
      "schema": {
        "classes": {
          "vertex": {
            "name": "Vertex",
            "description": "A vertex in a mesh.",
            "properties": {
              "POSITION_X": { "type": "SCALAR", "componentType": "FLOAT32" },
              "POSITION_Y": { "type": "SCALAR", "componentType": "FLOAT32" },
              "POSITION_Z": { "type": "SCALAR", "componentType": "FLOAT32" },
              "NORMAL_X": { "type": "SCALAR", "componentType": "FLOAT32" },
              "NORMAL_Y": { "type": "SCALAR", "componentType": "FLOAT32" },
              "NORMAL_Z": { "type": "SCALAR", "componentType": "FLOAT32" },
              "TANGENT_X": { "type": "SCALAR", "componentType": "FLOAT32" },
              "TANGENT_Y": { "type": "SCALAR", "componentType": "FLOAT32" },
              "TANGENT_Z": { "type": "SCALAR", "componentType": "FLOAT32" },
              "TANGENT_W": { "type": "SCALAR", "componentType": "FLOAT32" },
              "JOINT_INDEX": { "type": "SCALAR", "componentType": "UINT32" },
              "JOINT_WEIGHT": { "type": "SCALAR", "componentType": "FLOAT32" },
              "FACE_AREA": { "type": "SCALAR", "componentType": "FLOAT32" },
              "ANGLE": { "type": "SCALAR", "componentType": "FLOAT32" },
              "MESH_ID": { "type": "SCALAR", "componentType": "UINT32" },
              "VERTEX_INDEX": { "type": "SCALAR", "componentType": "UINT32" },
              "PRIMITIVE_ID": { "type": "SCALAR", "componentType": "UINT32" },
              "TEXCOORD_U": { "type": "SCALAR", "componentType": "FLOAT32" },
              "TEXCOORD_V": { "type": "SCALAR", "componentType": "FLOAT32" }
            }
          },
          "distance": {
            "name": "Node Distance",
            "description": "Distance between nodes.",
            "properties": {
              "NODE0_ID": { "type": "SCALAR", "componentType": "UINT32" },
              "NODE1_ID": { "type": "SCALAR", "componentType": "UINT32" },
              "WEIGHT": { "type": "SCALAR", "componentType": "FLOAT32" },
              "MESH_ID": { "type": "SCALAR", "componentType": "UINT32" },
              "PRIMITIVE_ID": { "type": "SCALAR", "componentType": "UINT32" }
            }
          }
        }
      },
      "propertyTables": [
        {
          "name": "face_vertex_attributes",
          "class": "vertex",
          "count": 14,
          "properties": {
            "POSITION_X": { "values": 0 },
            "POSITION_Y": { "values": 1 },
            "POSITION_Z": { "values": 2 },
            "NORMAL_X": { "values": 3 },
            "NORMAL_Y": { "values": 4 },
            "NORMAL_Z": { "values": 5 },
            "TANGENT_X": { "values": 6 },
            "TANGENT_Y": { "values": 7 },
            "TANGENT_Z": { "values": 8 },
            "TANGENT_W": { "values": 9 },
            "JOINT_INDEX": { "values": 10 },
            "JOINT_WEIGHT": { "values": 11 },
            "FACE_AREA": { "values": 12 },
            "ANGLE": { "values": 13 },
            "MESH_ID": { "values": 14 },
            "VERTEX_INDEX": { "values": 15 },
            "PRIMITIVE_ID": { "values": 16 },
            "TEXCOORD_U": { "values": 17 },
            "TEXCOORD_V": { "values": 18 }
          }
        },
        {
          "name": "node_distances",
          "class": "distance",
          "count": 2,
          "properties": {
            "NODE0_ID": { "values": 0 },
            "NODE1_ID": { "values": 1 },
            "WEIGHT": { "values": 2 },
            "MESH_ID": { "values": 3 },
            "PRIMITIVE_ID": { "values": 4 }
          }
        }
      ]
    }
  },
  "nodes": [
    {
      "mesh": 0,
      "skin": 0
    }
  ],
  "meshes": [
    {
      "primitives": [
        {
          "attributes": {
            "POSITION": 0,
            "NORMAL": 1,
            "TANGENT": 2,
            "TEXCOORD_0": 3,
            "JOINTS_0": 4,
            "WEIGHTS_0": 5
          },
          "indices": 6
        }
      ]
    }
  ],
  "skins": [
    {
      "inverseBindMatrices": 6,
      "joints": [0]
    }
  ],
  "buffers": [
    {
      "byteLength": 12288,
      "uri": "external_file.bin"
    }
  ],
  "bufferViews": [
    {
      "buffer": 0,
      "byteOffset": 0,
      "byteLength": 12288
    }
  ],
  "accessors": [
    {
      "bufferView": 0,
      "byteOffset": 0,
      "componentType": 5126,
      "count": 4,
      "type": "VEC3",
      "max": [1.0, 1.0, 1.0],
      "min": [-1.0, -1.0, -1.0]
    },
    {
      "bufferView": 0,
      "byteOffset": 48,
      "componentType": 5126,
      "count": 4,
      "type": "VEC3"
    },
    {
      "bufferView": 0,
      "byteOffset": 96,
      "componentType": 5123,
      "count": 12,
      "type": "SCALAR"
    }
  ]
}
```

## Usage

This extension can be used to provide additional geometric information about a mesh, such as the embedding vector for each face index. The embedding vectors are particularly useful for large language models to parse the GLTF more efficiently.

## Indexed Mesh Requirement

The mesh must be indexed.

## Normals Requirement

The mesh must have normals.

## Vertex and Face Sorting Scheme

Vertices within each face are sorted first. The comparison function `compare_vertices` is used to sort an array of vertices. This function compares two vertices based on their z-coordinate first. If the z-coordinates are equal, it then compares the y-coordinates. If the y-coordinates are also equal, it finally compares the x-coordinates.

After the vertices have been sorted, faces are sorted based on their index ID. The comparison function `compare_faces` is used to sort an array of faces. This function compares two faces based on their index ID.

```gdscript
# Sorting scheme based on:
# [43] Charlie Nash, Yaroslav Ganin, SM Ali Eslami, and Peter Battaglia.
# Polygen: An autoregressive generative model of 3d meshes.
# In International conference on machine learning, pages 7220–7229. PMLR, 2020
func compare_vertices(vertex_a, vertex_b):
    # Compare vertex positions
    if vertex_a.position.z < vertex_b.position.z:
        return -1
    elif vertex_a.position.z > vertex_b.position.z:
        return 1
    elif vertex_a.position.y < vertex_b.position.y:
        return -1
    elif vertex_a.position.y > vertex_b.position.y:
        return 1
    elif vertex_a.position.x < vertex_b.position.x:
        return -1
    elif vertex_a.position.x > vertex_b.position.x:
        return 1

    # If all vertex positions are equal, the vertices are equal.
    return 0

func compare_faces(face_a, face_b):
    # Compare vertices first
    vertex_comparison = compare_vertices(face_a.vertices, face_b.vertices)
    if vertex_comparison != 0:
        return vertex_comparison

    # If vertices are equal, compare face IDs
    if face_a.id < face_b.id:
        return -1
    elif face_a.id > face_b.id:
        return 1

    return 0
```

## Face Vertex Attributes

We want to teach large language models to use a language of face vertices as its language vocabulary.

As we input face vertex tokens, the large language model auto completes more face vertices until we have a full mesh.

We need to be able to encode and decode vocabulary into face vertices. `Vector3, Vector3, Vector3, [vertex node 0, vertex node 1, weight, ... up to 3 connections per face vertex]`

| INDEX | EMBEDDING TYPE | DESCRIPTION                                                                       |
| ----- | -------------- | --------------------------------------------------------------------------------- |
| 0     | `VERTEX_INDEX` | The index of the vertex within its mesh                                           |
| 1     | `MESH_ID`      | The ID of the mesh that the vertex belongs to                                     |
| 2     | `PRIMITIVE_ID` | The ID of the primitive that the vertex belongs to                                |
| 3     | `POSITION_X`   | The x-coordinate of the position vector (part of a Vector3)                       |
| 4     | `POSITION_Y`   | The y-coordinate of the position vector (part of a Vector3)                       |
| 5     | `POSITION_Z`   | The z-coordinate of the position vector (part of a Vector3)                       |
| 6     | `NORMAL_X`     | The X component of the normal vector associated with a vertex (part of a Vector3) |
| 7     | `NORMAL_Y`     | The Y component of the normal vector associated with a vertex (part of a Vector3) |
| 8     | `NORMAL_Z`     | The Z component of the normal vector associated with a vertex (part of a Vector3) |
| 9     | `TANGENT_X`    | The X component of the tangent vector at a vertex (part of a Vector4)             |
| 10    | `TANGENT_Y`    | The Y component of the tangent vector at a vertex (part of a Vector4)             |
| 11    | `TANGENT_Z`    | The Z component of the tangent vector at a vertex (part of a Vector4)             |
| 12    | `TANGENT_W`    | The W component of the tangent vector at a vertex (part of a Vector4)             |
| 13    | `JOINT_INDEX`  | The index of a joint for a vertex                                                 |
| 14    | `JOINT_WEIGHT` | The weight of influence a joint has on a vertex                                   |
| 15    | `FACE_AREA`    | The area of the face defined by the vertices                                      |
| 16    | `ANGLE`        | The angle at the vertex in radians                                                |
| 17    | `TEXCOORD_U`   | The U component of the texture coordinate associated with a vertex                 |
| 18    | `TEXCOORD_V`   | The V component of the texture coordinate associated with a vertex                 |

## Node Distance

The node distance table represents the distances between different nodes in the mesh. Each row in the table corresponds to a pair of nodes and the weight of their connection.

| INDEX | EMBEDDING TYPE | DESCRIPTION                                        |
| ----- | -------------- | -------------------------------------------------- |
| 0     | `NODE0_ID`     | The ID of the first node in the pair               |
| 1     | `NODE1_ID`     | The ID of the second node in the pair              |
| 2     | `WEIGHT`       | The weight of the connection between the two nodes |
| 3     | `MESH_ID`      | The ID of the mesh that the nodes belong to        |
| 4     | `PRIMITIVE_ID` | The ID of the primitive that the nodes belong to   |

This approach allows us to represent the structure of the mesh in a compact and efficient way, which is crucial for large-scale applications such as 3D modeling and computer graphics.

## Approach

This approach is based on the MeshGPT method in [MeshGPT: Generating Triangle Meshes with Decoder-Only Transformers](https://nihalsid.github.io/mesh-gpt/).

```bibtex
@article{siddiqui2023meshgpt,
  title={MeshGPT: Generating Triangle Meshes with Decoder-Only Transformers},
  author={Siddiqui, Yawar and Alliegro, Antonio and Artemov, Alexey and Tommasi, Tatiana and Sirigatti, Daniele and Rosov, Vladislav and Dai, Angela and Nie{\ss}ner, Matthias},
  journal={arXiv preprint arXiv:2311.15475},
  year={2023}
}
```
