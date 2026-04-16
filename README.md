# claude-skills

A collection of Claude skills I've made. Each skill is a folder with a `SKILL.md`; `.skill` bundles (zip archives) are published as release assets for one-click install.

## Install a skill

1. Go to [Releases](https://github.com/chaodoze/claude-skills/releases).
2. Download the `.skill` file for the skill you want.
3. Double-click it — Claude Desktop will offer to install.

> Safari tip: if the download auto-unzips, right-click the release link and choose "Download Linked File", or disable *Safari → Settings → General → Open "safe" files after downloading*.

## Skills

| Skill | What it does |
|-------|--------------|
| [hunch](hunch/) | A curious thinking partner for small personal experiments. |

## Package a skill locally

```bash
./scripts/package.sh hunch    # → dist/hunch.skill
```

## Publish a new version

```bash
./scripts/package.sh hunch
gh release create hunch-v1.0 dist/hunch.skill \
  --title "hunch v1.0" \
  --notes "Release notes here."
```
