FROM ubuntu:24.04

ARG BOIDS_UID=1000
ARG BOIDS_GID=1000
ARG BOIDS_USER=jerry

ENV DEBIAN_FRONTEND=noninteractive

# Basic C development tools, GitHub CLI, and raylib build dependencies.
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    g++ \
    make \
    cmake \
    pkg-config \
    git \
    gh \
    ca-certificates \
    bash \
    nano \
    less \
    procps \
    xauth \
    libgl1 \
    libglvnd0 \
    libglx0 \
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
    libgl-dev \
    libegl-dev \
    libgles-dev \
    libglu1-mesa-dev \
    libasound2-dev \
    libopenal-dev \
    wget \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Build and install raylib statically.
# This lets the boids executable run on the host without needing libraylib.so.600.
RUN git clone --depth 1 --branch 6.0 https://github.com/raysan5/raylib.git /tmp/raylib \
    && cmake -S /tmp/raylib -B /tmp/raylib/build \
        -DBUILD_SHARED_LIBS=OFF \
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
