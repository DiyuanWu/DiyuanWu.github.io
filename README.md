# [diyuanwu.github.io](DiyuanWu.github.io)

## Content workflow

- English pages live in `src/md/` and define the site's page list.
- Optional Chinese translations use the same filenames in `src/md_zh/`.
- Run `.venv/Scripts/python.exe src/md2html.py` to regenerate the English root
  pages and their Chinese counterparts under `zh/` on Windows.
- If a Chinese translation is missing, the generator still creates the page
  with the English content as a temporary fallback.

## Deploy

Run the deployment script from Git Bash. It rebuilds both languages, checks
the remote branch, shows the files to be committed, asks for confirmation, and
then commits and pushes to GitHub:

```bash
./deploy.sh "Update homepage"
```

Use `./deploy.sh --dry-run` to build and validate without uploading, or
`./deploy.sh --yes "Update homepage"` for a non-interactive deployment. The
script commits every non-ignored change in this repository, so review the
displayed file list before confirming.

From PowerShell on Windows, invoke the same script through Git Bash:

```powershell
& 'C:\Program Files\Git\bin\bash.exe' ./deploy.sh "Update homepage"
```
