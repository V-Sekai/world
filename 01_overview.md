# V-Sekai Other World Architecture: Overview

The V-Sekai Other World Architecture project aims to create a virtual world using the binary Godot Engine client and server. The development process is divided into several prototypes, each with its own specific goals and objectives.

## Prototype 1: Element Instantiation and Uploading

In this prototype, we will instantiate elements into our virtual world and make them available for user interaction. These elements include:

1. **Colliders**: Invisible objects that simulate solid matter.
2. **Per Bone Capsules**: Simplified user avatars used for collision detection.

By the end of this prototype, we will have established a basic system for adding and sharing elements in our virtual world.

## Prototype 2: Packaging, Marker3D, and Quad Plane

This prototype involves packaging colliders and per bone capsules for upload/download. We will introduce a Marker3D at coordinates (0, 0, 1) as a reference point in the 3D space. Additionally, we will add a quad plane to our virtual world, which will serve as a basic surface or platform within the environment.

## Prototype 3: Tree Concept Decision and Texture Packaging

During this prototype, we will decide between the GLTF2 concept of a unified node tree or the Godot Engine / Blender concept of armatures. Textures, materials, meshes, and IDs will be packaged at the marker.

## Prototype 4: Object Uploads and Positioning

In this prototype, we will develop the capability to upload objects like a teacup (possibly a collider) and an avatar. Users will be able to drag and scale these objects.

## Prototype 5: Server Management and Scripting

This prototype will focus on server management considerations such as handling server downtime and managing user logouts/logins. We will also incorporate scripting into the system.

## Prototype 6: Physics

This prototype will involve the implementation of physics in our virtual world.

## Prototype 7: Server Capacity and Bandwidth Limit

In this final prototype, we will ensure that the server can handle up to 100 people per instance. We will also calculate the bandwidth and object/mesh complexity limit.

The estimated timeline for this project is between 2 to 4 weeks.

## Additional Prototypes

The following prototypes are under consideration:

1. **VOIP Integration**: This prototype will focus on integrating Voice over IP (VoIP) into the virtual world for real-time voice communication.
2. **VR Interaction Menus**: This prototype will develop interaction menus for Virtual Reality (VR) users.
3. **Social Interactions**: This prototype will implement social interactions such as friend requests, private messaging, and public chat rooms.
4. **Avatar Customization**: This prototype will allow users to customize their avatars with different outfits, accessories, and animations.
5. **Gameplay Mechanics**: This prototype will introduce gameplay mechanics like quests, combat systems, and item collection.

## Asset Management Prototypes

1. **Inventory Synchronization**: This prototype will establish a system for synchronizing inventory between the datastore and the Digital Content Creation (DCC) tools.
2. **Asset Validation**: This prototype will create a process for validating assets before they are uploaded to the server.
3. **Asset Optimization**: This prototype will develop methods for optimizing assets to ensure efficient use of resources.
4. **Asset Moderation**: This prototype will implement a system for moderating user-generated content to maintain a safe and enjoyable environment for all users.
