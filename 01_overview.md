# V-Sekai Other World Architecture: Overview

The V-Sekai Other World Architecture project aims to create a virtual world using the binary Godot Engine client and server. The development process is divided into several prototypes, each with its own specific goals and objectives.

> **Note:** Instead of working on a car engine, work on the body. Instead of a bicycle wheel, work on the frame.

## Prototype 0: Push an asset to a service

> **Note:** In Elixir, we can directly call functions using the Interactive Elixir (IEX) shell.

Work on the function calls for sanitization and validation service.

### Input

1. Input gltf.
2. Input godot text scene.

### Data Structures

- An Elixir struct representing glTF2.
- An Elixir struct representing VRM0.
- An Elixir struct representing VRM1.
- An Elixir struct representing Godot Text Scene.
- An Elixir struct represents the list of validations for 3D modeling and animation.

#### Mesh Vertex Attributes

1. Validate Mesh Vertices Have Edges
2. Validate Mesh Has Overlapping UVs
3. Validate Mesh Single UV Set
4. Validate Mesh Has UVs
5. Validate Mesh No Co-Planar Faces
6. Validate Mesh Ngons
7. Validate Mesh Non-Manifold
8. Validate Mesh No Negative Scale
9. Validate Mesh Edge Length Non Zero
10. Validate Mesh Normals Unlocked
11. Validate Mesh UV Set Map 1
12. Validate if Mesh is Triangulated

#### Material

13. Validate Color Sets
14. Validate Model's default uv set exists.

#### Images

15. Validate Alembic Visible Node

#### General

16. Validate Model Name
17. Validate Model Content
18. Validate Transform Naming Suffix
19. Validate No Namespace
20. Validate No Null Transforms
21. Validate No Unknown Nodes
22. Validate Node No Ghosting
23. Validate Shape Default Names
24. Validate Shape Render Stats
25. Validate Shape Zero
26. Validate Transform Zero
27. Validate Unique Names

#### Animations

28. Validate No Animation
29. Ensure no keyframes on nodes in the Instance.

### Output

1. Output Godot Scene

Before the game client/server architecture is sound, we need to be able to push an asset to a service with sanitization and validation. This service will separate the colliders and other elements. Then, the game server pulls those colliders in.

## Prototype 1: Element Instantiation and Uploading

In this prototype, we will instantiate elements into our virtual world and pull them for user interaction. These elements include:

1. **Colliders**: Invisible objects that simulate solid matter.
2. **Per Bone Capsules**: Simplified user avatars used for collision detection.

## Prototype 2: Packaging, Marker3D, and Quad Plane

This prototype involves packaging colliders and per bone capsules for upload/download. We will introduce a Marker3D at coordinates (0, 0, 1) as a reference point in the 3D space. Additionally, we will add a quad plane to our virtual world, which will serve as a basic surface or platform within the environment.

## Prototype 3: Tree Concept Decision and Texture Packaging

During this prototype, we will decide between the GLTF2 concept of a unified node tree or the Godot Engine / Blender concept of armatures. Textures, materials, meshes, and IDs will be packaged at the marker.

## Prototype 4: Object Uploads and Positioning

In this prototype, we will develop the capability to upload objects like a teacup (possibly a collider) and an avatar. Users will be able to drag and scale these objects.

- name
- user_uid
- attachments
  - avatar (materials, meshes, animations)
  - colliders
- scale
- skeleton

## Prototype 5: Server Management and Scripting

This prototype will focus on server management considerations such as handling server downtime and managing user logouts/logins. We will also incorporate scripting into the system.

## Prototype 6: Physics

This prototype will involve the implementation of physics in our virtual world.

## Prototype 7: Server Capacity and Bandwidth Limit

In this final prototype, we will ensure that the server can handle up to 100 people per instance. We will also calculate the bandwidth and object/mesh complexity limit.

The estimated timeline for this project is between 2 to 4 weeks.
