---
name: add-skill
description: Publish a skill to the chaodoze/claude-skills repo with one line and zero fuss. Trigger when the user says "add this as a skill", "publish this skill", "release this skill", "new skill from <path>", "/add-skill <path>", or provides a .skill bundle / folder containing SKILL.md and asks to add or release it. Handles both first-time publishes and version bumps of existing skills. Performs the full pipeline end-to-end: source placement, README update, packaging, GitHub release, commit, push — and reports the download URL.
---

# add-skill

Adds a skill to chaodoze/claude-skills (or ships a new version of an existing one) with zero fuss. The user should be able to say `/add-skill ~/Downloads/foo.skill` and get back a release URL, no further prompting unless something is ambiguous.

## When to use

Trigger when the user provides any of:

- Path to a `.skill` file (zip bundle) anywhere on disk
- Path to a folder containing `SKILL.md`
- Name of an existing `<skill>/` folder in this repo that needs a new release

…and asks to publish, release, add, or ship it.

## The pipeline

Run these steps in order. If any step surfaces unexpected state, pause and ask the user before continuing.

### 1. Resolve source → extract name + description

- If input is a `.skill` zip: unzip to a temp dir, locate the inner folder's `SKILL.md`.
- If input is a folder: read its `SKILL.md` directly.
- If input is just a name: look for `<name>/SKILL.md` in the repo.
- Parse the YAML frontmatter. The `name:` field is canonical — it overrides the folder/zip filename if they disagree.
- Grab the `description:` field for the release notes and README row. If absent, fall back to the first paragraph of the body; if still nothing, ask the user for a one-line blurb.

### 2. Place source in the repo

- Destination: `<repo-root>/<name>/SKILL.md`.
- **New skill** (folder doesn't exist): `mkdir -p <name>/` and copy the SKILL.md in.
- **Update** (folder exists): diff the incoming SKILL.md against the tracked one. If identical, skip this step. If different, show the user the diff and confirm before overwriting.

### 3. Update README.md

The skills table lives under `## Skills` as `| [name](name/) | description |` rows.

- If the row is missing, add one. Use a short one-sentence hook derived from the frontmatter description (trim to roughly the length of the existing rows).
- If the row exists and the description has materially changed, update it.
- Otherwise leave it alone.

### 4. Build the bundle

```bash
./scripts/package.sh <name>
```

Produces `dist/<name>.skill`. `dist/` is gitignored — only the release asset ships the bundle.

### 5. Publish the GitHub release

Pick the tag:

- **New skill**: `<name>-v1.0`.
- **Update**: check `gh release list --repo chaodoze/claude-skills`. Bump the highest `<name>-vX.Y` tag by 0.1 by default. If the user specified a version, use theirs.

Create the release:

```bash
gh release create <name>-v<version> dist/<name>.skill \
  --repo chaodoze/claude-skills \
  --title "<name> v<version>" \
  --notes "<description-first-sentence>"
```

If the tag already exists from a previous partial run, use `gh release upload <tag> dist/<name>.skill --repo chaodoze/claude-skills --clobber` instead.

### 6. Commit and push

Stage only the files this pipeline touched:

```bash
git add <name>/SKILL.md README.md
git commit -m "Add <name> skill"          # new skill
# or
git commit -m "Bump <name> to v<version>" # update
git push origin main
```

Follow the repo's existing commit style (see `git log`). Keep the message short; no trailing summaries.

### 7. Report the URL

End with the direct download link so the user can test install:

```
https://github.com/chaodoze/claude-skills/releases/download/<name>-v<version>/<name>.skill
```

## Edge cases

- **Frontmatter `name` disagrees with the folder/zip filename** — trust the frontmatter. Use that as the destination folder name and release tag prefix.
- **Uncommitted changes in the working tree before you start** — warn the user; the commit in step 6 would sweep them in. Ask whether to proceed, stash, or abort.
- **`gh` not authenticated** — tell the user to run `gh auth login` and stop.
- **Release tag already exists and already has the asset** — ask the user: bump the version, or overwrite with `--clobber`?
- **No `scripts/package.sh`** — you're not in the claude-skills repo root. Stop and tell the user.

## What "one line, zero fuss" means

If the user types `/add-skill ~/Downloads/foo.skill` (or equivalent natural-language invocation with a path), run the whole pipeline without asking further questions. Only pause when ambiguity forces it — update vs. new, version bump, diff confirmation, uncommitted changes. Everything else (name, description, tag, commit message) is inferable from the source.
