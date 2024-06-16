# Proposed: Template

## The Context

We are currently working with a large number of 3D meshes, which vary in complexity. The challenge is to manage these meshes efficiently while maintaining their quality and usability.

## The Problem Statement

The main issue we face is determining the optimal number of triangles for each mesh. Too few might result in a low-quality mesh, while too many could increase the computational load unnecessarily.

## Proposed Solution

Here's a snippet of the proposed configuration:

```python
minTriangles = 100
maxTriangles = 2000
num_threads = 6
maxDownloadedMeshes = float('inf') # Download all.
```

We propose to download generic meshes in the 100 to 2,000 triangle range. This approach allows us to maintain a balance between the complexity and performance of the meshes. It also provides flexibility in terms of the number of meshes we can download and process.

## Generic Meshes vs Avatar Meshes

In this context, "generic meshes" refer to 3D models that have a relatively simple structure and fewer details. They are less complex and require fewer resources to process. On the other hand, "avatar meshes" are more detailed and complex, often designed to represent specific characters or objects with unique features. These meshes typically have a higher number of triangles, making them more resource-intensive to process.

## The Benefits

This approach will help us manage our computer training budget by using generic meshes rather than avatar meshes. Generic meshes, due to their simplicity, are easier and less costly to process.

## The Downsides

There might be some meshes with unique characteristics that fall outside our defined range. These would be excluded from our processing, potentially leading to missed opportunities.

## The Road Not Taken

An alternative approach could have been to download and process all meshes without any restrictions on the number of triangles. However, this could lead to performance issues and inefficient use of resources.

## The Infrequent Use Case

In cases where a specific mesh with a high number of triangles is required, our current setup might not be able to accommodate it.

## In Core and Done by Us

The proposed solution is integral to our mesh processing system and will be implemented by our development team.

## Status

Status: Proposed <!-- Draft | Proposed | Rejected | Accepted | Deprecated | Superseded by -->

## Decision Makers

- V-Sekai development team

## Tags

- V-Sekai

## Further Reading

1. [V-Sekai · GitHub](https://github.com/v-sekai) - Official GitHub account for the V-Sekai development community focusing on social VR functionality for the Godot Engine.
2. [V-Sekai/v-sekai-game](https://github.com/v-sekai/v-sekai-game) is the GitHub page for the V-Sekai open-source project, which brings social VR/VRSNS/metaverse components to the Godot Engine.

AI assistant Aria assisted with this article.
