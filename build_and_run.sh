#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="${IMAGE_NAME:-garlicwizard/lab1-api}"
TAG="${TAG:-latest}"
CONTAINER_NAME="${CONTAINER_NAME:-lab1-api}"
PORT="${PORT:-8000}"

build_image() {
  echo "[build] building $IMAGE_NAME:$TAG ..."
  docker build -t "$IMAGE_NAME:$TAG" .
}

run_container() {
  echo "[run] stopping any existing container named $CONTAINER_NAME ..."
  docker rm -f "$CONTAINER_NAME" 2>/dev/null || true
  echo "[run] starting container $CONTAINER_NAME ..."
  docker run -d --name "$CONTAINER_NAME" -p "$PORT:8000" "$IMAGE_NAME:$TAG"
}

build_and_run() {
  build_image
  run_container
}

# initial build/run
build_and_run

# Detect changes and rebuild
if command -v inotifywait >/dev/null 2>&1; then
  echo "[watch] using inotifywait to watch for changes"
  while inotifywait -q -e modify,create,delete -r app requirements.txt Dockerfile; do
    echo "[watch] change detected: rebuilding..."
    build_and_run
  done
else
  echo "[watch] inotifywait not found; falling back to checksum polling (every 5s)"
  oldsum=$(find app requirements.txt Dockerfile -type f -exec md5sum {} \; | md5sum)
  while true; do
    sleep 5
    newsum=$(find app requirements.txt Dockerfile -type f -exec md5sum {} \; | md5sum)
    if [ "$newsum" != "$oldsum" ]; then
      echo "[watch] change detected: rebuilding..."
      build_and_run
      oldsum=$newsum
    fi
  done
fi

