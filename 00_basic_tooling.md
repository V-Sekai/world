# v-sekai-other-world-architecture: Basic Tooling: Bill of Materials

This section outlines the essential tools we use in our VR world architecture.

## VR Software

The creation of virtual worlds necessitates specific software. We utilize:

1. **Godot Engine**: An open-source game engine renowned for its power and versatility, supporting both 2D and 3D games as well as interactive experiences.
2. **Blender**: A comprehensive, free, and open-source 3D creation suite that caters to all aspects of the 3D pipeline—modeling, rigging, animation, simulation, rendering, compositing, and motion tracking.

## File Formats

We adhere to the following standards for 3D models:

- **glTF (GL Transmission Format)**: This is a standard file format for three-dimensional scenes and models. It's designed for efficient transmission and loading of 3D content.
- **VRM**: This is a 3D avatar file format for VR applications. It's based on glTF 2.0 and allows for the use of humanoid animations and interactions in VR.
- **Godot Scene (.tscn)**: This is Godot's native scene format. It's text-based, making it friendly for version control systems.

In addition to these, we'll also introduce video, audio and music files at a later point.

## Software Languages

Software languages are indispensable for infusing interactivity into our VR worlds:

- **C++**: This versatile language empowers developers to script intricate behavior.
- **GDScript**: As the native scripting language for Godot Engine, GDScript is game-specific and boasts a simple syntax akin to Python.
- **Elixir**: A dynamic, functional language engineered for crafting scalable and maintainable applications.

## Infrastructure Automation Tools

To manage and automate our infrastructure, we use:

- **Terraform**: An open-source infrastructure as code software tool that provides a consistent CLI workflow to manage hundreds of cloud services.
- **Ansible**: An open-source software provisioning, configuration management, and application-deployment tool enabling infrastructure as code.

## Local and Cloud Storage with SeaweedFS and S3

For local storage, we use:

- **SeaweedFS**: A simple and highly scalable distributed file system. It provides an S3-compatible API and can handle billions of files with ease. This makes it a perfect choice for environments where scalability and compatibility are key requirements.

For cloud storage, we use:

- **Cloud's S3 Compatible Storage**: Many cloud service providers offer storage solutions that are compatible with the S3 API. These services provide the scalability and reliability of cloud storage while maintaining compatibility with the widely used S3 API.

## Database

Our choice for database management is **CockroachDB**, an open-source, distributed SQL database designed for building, scaling, and managing modern, data-intensive applications.

## Hardware

To test and experience our virtual worlds, VR hardware is essential:

- **VR Headsets**: Devices such as the Meta Quest, Beyond HMD, or Valve Index offer the means to view and interact with our virtual worlds.
- **Controllers**: These devices facilitate user interaction with the virtual environment, providing a more intuitive interface than traditional input devices.
- **Windows PCVR**: Placeholder for Windows PCVR.
- **VR GPUs**: Graphics processing units for rendering VR content. They provide the computational power necessary to create immersive, realistic virtual environments.
