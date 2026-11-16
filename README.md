# [diyuanwu.github.io](DiyuanWu.github.io)

## Content workflow

- English pages live in `src/md/` and define the site's page list.
- Optional Chinese translations use the same filenames in `src/md_zh/`.
- Run `python src/md2html.py` to regenerate the English root pages and their
  Chinese counterparts under `zh/`.
- If a Chinese translation is missing, the generator still creates the page
  with the English content as a temporary fallback.
