#!/usr/bin/env bash
set -e

export DISPLAY="${DISPLAY:-:0}"

xhost +SI:localuser:"$USER"

cleanup() {
    xhost -SI:localuser:"$USER" >/dev/null 2>&1 || true
}

trap cleanup EXIT

docker compose up
