#!/usr/bin/env bash
set -euo pipefail

REMOTE=${REMOTE:-origin}
BRANCH=${BRANCH:-main}
INTERVAL=${INTERVAL:-30}  # seconds between checks

while true; do
  echo "[git-monitor] fetching $REMOTE..."
  git fetch "$REMOTE" --quiet

  LOCAL=$(git rev-parse @)
  REMOTE_HASH=$(git rev-parse "$REMOTE/$BRANCH")

  if [ "$LOCAL" != "$REMOTE_HASH" ]; then
    echo "[git-monitor] new commits detected on $REMOTE/$BRANCH. Pulling and rebuilding..."
    git pull "$REMOTE" "$BRANCH"
    ./build_and_run.sh
  else
    echo "[git-monitor] no change (HEAD == $LOCAL)."
  fi

  sleep "$INTERVAL"
done

