# V-Sekai Other World Architecture: Overview

The V-Sekai Other World Architecture project aims to create a virtual world using the binary Godot Engine client and server. The development process is divided into several prototypes, each with its own specific goals and objectives.

> **Note:** Instead of working on a car engine, work on the body. Instead of a bicycle wheel, work on the frame.

## Prototype 0: Push an asset to a service

> **Note:** In Elixir, we can directly call functions using the Interactive Elixir (IEX) shell.

Work on the function calls for sanitization and validation service.

### Input

2. Input godot text scene.

### Data Structures

- An Elixir struct representing Godot Text Scene.
- An Elixir struct represents the list of validations for 3D modeling and animation.

#### Mesh Vertex Attributes

1. **Validate Mesh Vertices Have Edges**: Ensure that each vertex in the mesh is connected to at least one edge.
2. **Validate Mesh Has Overlapping UVs**: Check if any UV coordinates in the mesh overlap.
3. **Validate Mesh Single UV Set**: Confirm that the mesh only has one set of UV coordinates.
4. **Validate Mesh Has UVs**: Verify that the mesh has UV coordinates.
5. **Validate Mesh No Co-Planar Faces**: Ensure that there are no faces in the mesh that lie on the same plane.
6. **Validate Mesh Ngons**: Check for the presence of polygons with more than four sides in the mesh.
7. **Validate Mesh Non-Manifold**: Confirm that the mesh does not have any non-manifold geometry.
8. **Validate Mesh No Negative Scale**: Ensure that the scale of the mesh is not negative.
9. **Validate Mesh Edge Length Non Zero**: Verify that all edges in the mesh have a length greater than zero.
10. **Validate Mesh Normals Unlocked**: Check that the normals of the mesh are not locked and can be modified.
11. **Validate Mesh UV Set Map 1**: Confirm that the first UV set map of the mesh is correctly configured.
12. **Validate if Mesh is Triangulated**: Ensure that the mesh is composed entirely of triangular faces.

#### Material

13. **Validate Color Sets**: Check that the color sets used in the material are valid.
14. **Validate Model's default uv set exists**: Confirm that the model has a default UV set.

#### Images

15. **Validate Alembic Visible Node**: Verify that the Alembic node is visible in the rendered image.

#### General

16. **Validate Model Name**: Ensure that the model has a valid name.
17. **Validate Model Content**: Check that the content of the model is valid.
18. **Validate Transform Naming Suffix**: Confirm that the naming suffix for transforms is correct.
19. **Validate No Namespace**: Ensure that there are no namespaces in the model.
20. **Validate No Null Transforms**: Check that there are no null or empty transforms in the model.
21. **Validate No Unknown Nodes**: Confirm that there are no unknown nodes in the model.
22. **Validate Node No Ghosting**: Verify that there is no ghosting effect on any node.
23. **Validate Shape Default Names**: Ensure that the default names for shapes are valid.
24. **Validate Shape Render Stats**: Check the render statistics for each shape.
25. **Validate Shape Zero**: Confirm that the zero position for each shape is correctly set.
26. **Validate Transform Zero**: Ensure that the zero position for each transform is correctly set.
27. **Validate Unique Names**: Verify that all names in the model are unique.

#### Animations

28. **Validate No Animation**: Check that there are no animations in the model.
29. **Ensure no keyframes on nodes in the Instance**: Confirm that there are no keyframes on any nodes in the instance.

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
