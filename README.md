# Boids Raylib Development Container

This repository contains a Docker-based development environment for building and running the `boids-c` Raylib project.

The container provides:

- Ubuntu 24.04
- GCC, G++, Make, CMake and pkg-config
- Git and basic command-line tools
- Raylib 6.0 built from source
- `raygui.h` installed as a single-header library
- X11/OpenGL support for running graphical Raylib programs from inside the container
- Optional NVIDIA GPU access when the host is configured for it

The actual boids source code is kept in a separate repository and can be cloned into the workspace manually.

## Directory layout

The intended layout is:

```text
boid-docker/
├── Dockerfile
├── docker-compose.yml
├── .env
├── .env.example
├── .gitignore
├── build-image.sh
├── up.sh
└── boids-c/
