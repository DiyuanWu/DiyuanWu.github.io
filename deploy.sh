#!/usr/bin/env bash

set -euo pipefail

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

# md2html.py updates both locales in src/html and the GitHub Pages files atomically.
python ./src/md2html.py

echo "Deployment files generated successfully."
