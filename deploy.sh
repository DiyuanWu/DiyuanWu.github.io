#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

REMOTE="${DEPLOY_REMOTE:-origin}"
EXPECTED_BRANCH="${DEPLOY_BRANCH:-main}"
AUTO_CONFIRM=false
DRY_RUN=false
MESSAGE_PARTS=()

usage() {
    cat <<'EOF'
Usage: ./deploy.sh [options] [commit message]

Build, validate, commit, and push the website to GitHub.

Options:
  -y, --yes      Skip the final confirmation prompt.
  -n, --dry-run  Build and validate without committing or pushing.
  -h, --help     Show this help message.

Examples:
  ./deploy.sh "Update homepage"
  ./deploy.sh --yes "Add teaching page"
  ./deploy.sh --dry-run
EOF
}

while (($#)); do
    case "$1" in
        -y|--yes)
            AUTO_CONFIRM=true
            ;;
        -n|--dry-run)
            DRY_RUN=true
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --)
            shift
            MESSAGE_PARTS+=("$@")
            break
            ;;
        -*)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 2
            ;;
        *)
            MESSAGE_PARTS+=("$1")
            ;;
    esac
    shift
done

if ((${#MESSAGE_PARTS[@]})); then
    COMMIT_MESSAGE="${MESSAGE_PARTS[*]}"
else
    COMMIT_MESSAGE="Update website $(date '+%Y-%m-%d %H:%M')"
fi

command -v git >/dev/null 2>&1 || {
    echo "Error: git is not installed or is not on PATH." >&2
    exit 1
}

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    echo "Error: deploy.sh must be run inside a Git repository." >&2
    exit 1
}

CURRENT_BRANCH="$(git branch --show-current)"
if [[ -z "$CURRENT_BRANCH" ]]; then
    echo "Error: cannot deploy from a detached HEAD." >&2
    exit 1
fi
if [[ "$CURRENT_BRANCH" != "$EXPECTED_BRANCH" ]]; then
    echo "Error: current branch is '$CURRENT_BRANCH'; expected '$EXPECTED_BRANCH'." >&2
    echo "Switch branches or set DEPLOY_BRANCH explicitly." >&2
    exit 1
fi
if ! git remote get-url "$REMOTE" >/dev/null 2>&1; then
    echo "Error: Git remote '$REMOTE' does not exist." >&2
    exit 1
fi

if [[ -x "$PROJECT_DIR/.venv/Scripts/python.exe" ]]; then
    PYTHON_BIN="$PROJECT_DIR/.venv/Scripts/python.exe"
elif [[ -x "$PROJECT_DIR/.venv/bin/python" ]]; then
    PYTHON_BIN="$PROJECT_DIR/.venv/bin/python"
elif command -v python3 >/dev/null 2>&1; then
    PYTHON_BIN="$(command -v python3)"
elif command -v python >/dev/null 2>&1; then
    PYTHON_BIN="$(command -v python)"
else
    echo "Error: Python was not found. Create .venv or install Python 3." >&2
    exit 1
fi

echo "Checking GitHub for remote updates..."
git fetch "$REMOTE" "$EXPECTED_BRANCH"

REMOTE_REF="$REMOTE/$EXPECTED_BRANCH"
if git show-ref --verify --quiet "refs/remotes/$REMOTE_REF"; then
    read -r BEHIND AHEAD < <(
        git rev-list --left-right --count "$REMOTE_REF...HEAD"
    )
    if ((BEHIND > 0)); then
        echo "Error: $REMOTE_REF has $BEHIND commit(s) not present locally." >&2
        echo "Sync those changes before deploying; no commit or push was made." >&2
        exit 1
    fi
else
    AHEAD=0
fi

echo "Generating English and Chinese pages..."
"$PYTHON_BIN" "$PROJECT_DIR/src/md2html.py"

echo "Validating generated changes..."
git diff --check

CHANGES="$(git status --porcelain)"
if [[ -n "$CHANGES" ]]; then
    echo
    echo "Files that will be committed:"
    git status --short
    echo
    echo "Tracked-file summary:"
    git diff --stat || true
else
    echo "No uncommitted website changes were found."
fi

if [[ "$DRY_RUN" == true ]]; then
    echo "Dry run complete; nothing was committed or pushed."
    exit 0
fi

if [[ -z "$CHANGES" && "$AHEAD" -eq 0 ]]; then
    echo "Everything is already up to date."
    exit 0
fi

if [[ "$AUTO_CONFIRM" != true ]]; then
    echo
    if [[ -n "$CHANGES" ]]; then
        echo "Commit message: $COMMIT_MESSAGE"
    fi
    printf "Commit the listed files and push to %s/%s? [y/N] " "$REMOTE" "$EXPECTED_BRANCH"
    if ! read -r REPLY; then
        echo
        echo "Cancelled: confirmation input was unavailable." >&2
        exit 1
    fi
    case "$REPLY" in
        y|Y|yes|YES|Yes)
            ;;
        *)
            echo "Cancelled; deploy.sh made no staging, commit, or push changes."
            exit 0
            ;;
    esac
fi

if [[ -n "$CHANGES" ]]; then
    git add -A -- .
    git diff --cached --check

    if git diff --cached --quiet; then
        echo "No staged changes remain after generation."
    else
        echo
        echo "Staged summary:"
        git diff --cached --stat
        git commit -m "$COMMIT_MESSAGE"
    fi
fi

git push "$REMOTE" "$EXPECTED_BRANCH"

LOCAL_SHA="$(git rev-parse HEAD)"
REMOTE_SHA="$(git rev-parse "$REMOTE_REF")"
if [[ "$LOCAL_SHA" != "$REMOTE_SHA" ]]; then
    echo "Error: push completed but local and remote commit IDs differ." >&2
    exit 1
fi

echo "Deployment pushed successfully: $(git rev-parse --short HEAD)"
