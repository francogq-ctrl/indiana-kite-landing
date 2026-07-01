#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO="francogq-ctrl/indiana-kite-landing"
REPO_URL="https://github.com/${REPO}.git"
PUBLISH="$SCRIPT_DIR/.publish"

if ! gh repo view "$REPO" &>/dev/null; then
  gh repo create "$REPO" --public --description "Indiana Kite House — kite trips landing (GitHub Pages)"
fi

rm -rf "$PUBLISH"
mkdir -p "$PUBLISH"

rsync -a \
  --exclude '.publish' \
  --exclude '.DS_Store' \
  --exclude 'theme-lab.html' \
  --exclude 'theme-lab-themes.css' \
  --exclude 'COPY.md' \
  --exclude 'dist' \
  --exclude 'assets/03s.jpg' \
  --exclude 'assets/04s.jpg' \
  --exclude 'assets/052.jpg' \
  "$SCRIPT_DIR/" "$PUBLISH/"

cd "$PUBLISH"
git init -b main
git remote add origin "$REPO_URL"
git add -A
git commit -m "Publish landing ($(date +%Y-%m-%d))"
GIT_HTTP_LOW_SPEED_LIMIT=1000 GIT_HTTP_LOW_SPEED_TIME=600 git push -f origin main

if ! gh api "repos/${REPO}/pages" &>/dev/null; then
  gh api -X POST "repos/${REPO}/pages" \
    -f build_type=legacy \
    -f 'source[branch]=main' \
    -f 'source[path]=/'
fi

echo ""
echo "Live: https://francogq-ctrl.github.io/indiana-kite-landing/"
