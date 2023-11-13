# v-sekai-other-world-architecture: Overview

This project aims to develop a virtual world using binary Godot Engine client & server. The development is divided into several prototypes.

## Prototype 1: Element Instantiation and Uploading

We'll instantiate elements into our virtual world and upload them for user interaction.

1. **Colliders**: Invisible objects simulating solid matter.
2. **Avatar Pill Characters**: Simplified user avatars for collision detection.

By prototype end, we'll have a basic system for adding and sharing elements in our virtual world.

## Prototype 2: Packaging, Marker3D, and Quad Plane

In this stage, we'll package colliders and avatar pill characters for upload/download. A Marker3D at coordinates 0, 0, 1 will be introduced as a reference point in the 3D space.

Additionally, we'll also introduce a quad plane to our virtual world. This will serve as a basic surface or platform within the environment.

## Prototype 3: Tree Concept Decision and Texture Packaging

We'll decide between GLTF2 conceptof a unified node tree or the Godot Engine / Blender concept of armatures. Textures, materials, meshes, and IDs will be packaged at the marker.

## Prototype 4: Object Uploads and Positioning

We'll add the capability to upload objects like a teacup (possibly a collider) and an avatar. Users can drag and scale these objects.

## Prototype 5: Server Management and Scripting

Considerations for server downtime, logging out/in will be introduced. Scripting will also be incorporated.

## Prototype 6: Physics

Physics implementation will be done at this stage.

## Prototype 7: Server Capacity and Bandwidth Limit

We'll ensure the server can handle 100 people per instance. Bandwidth and object/mesh complexity limit will be calculated.

The project timeline is estimated at 2-4 weeks.
