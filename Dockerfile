FROM ubuntu:24.04

ARG BOIDS_UID=1000
ARG BOIDS_GID=1000
ARG BOIDS_USER=jerry

ENV DEBIAN_FRONTEND=noninteractive

# Basic development tools, X11/OpenGL tools, CMake, Git,
# and Raylib build/runtime dependencies.
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    g++ \
    make \
    cmake \
    pkg-config \
    git \
    ca-certificates \
    bash \
    nano \
    less \
    procps \
    xauth \
    x11-apps \
    mesa-utils \
    libgl1 \
    libglx-mesa0 \
    libglu1-mesa \
    libx11-6 \
    libx11-dev \
    libxcursor-dev \
    libxrandr-dev \
    libxinerama-dev \
    libxi-dev \
    libxext-dev \
    libxfixes-dev \
    libxrender-dev \
    libxxf86vm-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libasound2-dev \
    libopenal-dev \
    wget \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Build and install raylib from source.
# This gives pkg-config support for your CMakeLists.txt.
RUN git clone --depth 1 --branch 6.0 https://github.com/raysan5/raylib.git /tmp/raylib \
    && cmake -S /tmp/raylib -B /tmp/raylib/build \
        -DBUILD_SHARED_LIBS=ON \
        -DBUILD_EXAMPLES=OFF \
    && cmake --build /tmp/raylib/build --parallel \
    && cmake --install /tmp/raylib/build \
    && ldconfig \
    && rm -rf /tmp/raylib

# Install raygui single-header library.
RUN git clone --depth 1 https://github.com/raysan5/raygui.git /tmp/raygui \
    && cp /tmp/raygui/src/raygui.h /usr/local/include/raygui.h \
    && rm -rf /tmp/raygui

# Create or reuse a normal user matching the host UID/GID.
# This avoids failing if UID/GID 1000 already exists in the base image.
RUN set -eux; \
    if getent group "${BOIDS_GID}" >/dev/null; then \
        GROUP_NAME="$(getent group "${BOIDS_GID}" | cut -d: -f1)"; \
        echo "Reusing existing group ${GROUP_NAME} with GID ${BOIDS_GID}"; \
    else \
        groupadd --gid "${BOIDS_GID}" "${BOIDS_USER}"; \
        GROUP_NAME="${BOIDS_USER}"; \
    fi; \
    if getent passwd "${BOIDS_UID}" >/dev/null; then \
        EXISTING_USER="$(getent passwd "${BOIDS_UID}" | cut -d: -f1)"; \
        echo "Reusing existing user ${EXISTING_USER} with UID ${BOIDS_UID}"; \
        usermod --login "${BOIDS_USER}" \
                --home "/home/${BOIDS_USER}" \
                --move-home "${EXISTING_USER}" || true; \
    else \
        useradd --uid "${BOIDS_UID}" \
                --gid "${BOIDS_GID}" \
                --create-home \
                --shell /bin/bash \
                "${BOIDS_USER}"; \
    fi; \
    mkdir -p "/home/${BOIDS_USER}" /workspace; \
    chown -R "${BOIDS_UID}:${BOIDS_GID}" "/home/${BOIDS_USER}" /workspace

USER ${BOIDS_USER}
WORKDIR /workspace

CMD ["bash"]
