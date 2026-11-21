#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

OUT_DIR="$REPO_ROOT/_site/roadmap"
FILTER_PATH="$REPO_ROOT/.tinytau/scripts/tinytau.lua"

if [ ! -e roadmap ]; then
  rm -rf "$OUT_DIR"
  mkdir -p "$OUT_DIR"
  cat > "$OUT_DIR/index.html" <<'EOF'
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Roadmap</title>
</head>
<body>
  <h1>Roadmap</h1>
  <p>The roadmap will appear after the first sync.</p>
  <p><a href="../">Back to project home</a></p>
</body>
</html>
EOF
  echo "Wrote a placeholder to $OUT_DIR because roadmap/ is missing."
  exit 0
fi

WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/tinytau-roadmap.XXXXXX")"
trap 'rm -rf "$WORK_DIR"' EXIT

mkdir -p "$WORK_DIR/roadmap"
cp -r roadmap/. "$WORK_DIR/roadmap/"

# Ensure a root _quarto.yml exists so --output-dir is always respected by Quarto
if [ ! -f "$WORK_DIR/roadmap/_quarto.yml" ] && [ ! -f "$WORK_DIR/roadmap/_quarto.yaml" ]; then
  cat << 'EOF' > "$WORK_DIR/roadmap/_quarto.yml"
project:
  type: default

format:
  html: default
EOF
fi

cat << EOF > "$WORK_DIR/tinytau-filter.yml"
filters:
  - at: pre-ast
    path: "$FILTER_PATH"
EOF

rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"

QUARTO_PROFILE=""
if [ -f .tinytau/config.yml ]; then
  if command -v yq >/dev/null 2>&1; then
    QUARTO_PROFILE="$(yq '."quarto-profile" // ""' .tinytau/config.yml)"
  else
    QUARTO_PROFILE="$(awk -F': *' '/^quarto-profile:/ {print $2}' .tinytau/config.yml | sed "s/#.*//; s/[[:space:]\"'\r]//g")"
  fi
  if [ "$QUARTO_PROFILE" = "null" ] || [ "$QUARTO_PROFILE" = "~" ]; then
    QUARTO_PROFILE=""
  fi
fi

QUARTO_ARGS=(
  --to html
  --output-dir "$OUT_DIR"
  --metadata-file "$WORK_DIR/tinytau-filter.yml"
)
if [ -n "$QUARTO_PROFILE" ]; then
  QUARTO_ARGS+=(--profile "$QUARTO_PROFILE")
fi

quarto render "$WORK_DIR/roadmap" "${QUARTO_ARGS[@]}"

echo "Rendered roadmap into $OUT_DIR"
