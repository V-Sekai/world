# V-Sekai Other World Architecture: Overview

The V-Sekai Other World Architecture project aims to create a virtual world using the binary Godot Engine client and server. The development process is divided into several prototypes, each with its own specific goals and objectives.

```mermaid
flowchart TB
    subgraph user [Users]
        desktop[Desktop] -- "2a. Open URL" --> third_party_login_flow
    end

    subgraph third_party [3rd Party OAuth Provider]
        third_party_login_flow -- "2b. 3rd Party Login Flow" --> oauth_provider
        oauth_provider -- "3. Login Flow" --> login_flow_response
        login_flow_response -- "3a. Successful Login" --> godot_engine
        login_flow_response -- "3b. Login Failed" --> godot_engine
    end

    subgraph godot [Godot Engine]
        godot_engine -- "1. Establish Websocket" --> websocket_service
        godot_engine -- "6. Asset Response" --> asset_service
    end

    subgraph websocket_s [Websocket Service]
        websocket_service -- "4. Notify Login Success" --> session_created
        session_created -- "4a. Session Created" --> websocket_service
        websocket_service -- "5. Asset Interaction" --> asset_service
        asset_service -- "5c. Asset Status" --> websocket_service
    end

    subgraph asset [Asset Service]
        asset_service -- "5f. Asset Request" --> cloud_storage
        cloud_storage -- "5g. Signed Session" --> asset_service
        asset_service -- "5d. Asset Data Storage" --> project_database
        project_database -- "5e. Asset Data Retrieval" --> asset_service
        asset_service -- "5a. Process new Asset" --> validation_service
        asset_service -- "5b. Asset Invalid" --> validation_service
        validation_service -- "5c. Asset Valid for Storage" --> asset_service
    end

    subgraph login [Login Service]
        session_created -. "Session Management" .-> login_service
    end
```

> **Note:** Instead of working on a car engine, work on the body. Instead of a bicycle wheel, work on the frame.

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
