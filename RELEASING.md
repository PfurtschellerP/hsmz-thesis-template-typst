# Releasing a new version

This document describes how to publish a new version of `hsmz-thesis-unofficial` on
[Typst Universe](https://typst.app/universe/package/hsmz-thesis-unofficial). Typst Universe is fed from the
[typst/packages](https://github.com/typst/packages) repository: every version is a folder
`packages/preview/hsmz-thesis-unofficial/<version>/` that is added with a pull request and reviewed by the Typst team.

> [!IMPORTANT]
> Published versions can never be changed or removed. If you find a mistake after a version has been published, release
> a new (patch) version.

## Overview

| Step | What | Where |
| --- | --- | --- |
| 1 | Bump the version, regenerate the thumbnail | Pull request in this repository |
| 2 | Tag the merged commit (`vX.Y.Z`) | Your machine |
| 3 | GitHub release with sample PDF and package archive | Automatic ([`release.yml`](.github/workflows/release.yml)) |
| 4 | Pull request `hsmz-thesis-unofficial:X.Y.Z` on typst/packages | Automatic (if configured) or manual |
| 5 | Review and merge by the Typst team, package appears on Universe (up to 30 minutes after merge) | typst/packages |

## Versioning

The package follows [Semantic Versioning](https://semver.org/). While the version is below 1.0.0:

- **Patch** (`0.4.0` → `0.4.1`): bug fixes and text corrections that do not change the layout of existing documents.
- **Minor** (`0.4.0` → `0.5.0`): new features and any change that changes the layout or the parameters of existing
  documents (e.g. new guideline requirements, renamed parameters, changed defaults).

## One-time setup

### Fork of typst/packages

A fork of [typst/packages](https://github.com/typst/packages) is required for both the automatic and the manual
submission. It already exists at [PfurtschellerP/packages](https://github.com/PfurtschellerP/packages). If it is ever
deleted, fork typst/packages again.

### Automatic submission (optional)

The `typst-universe` job of the release workflow pushes the package to your fork and, depending on the token, opens
the pull request on typst/packages. It needs a token, because the default `GITHUB_TOKEN` of a workflow can't access
other repositories. Choose one of the two token types:

| | Fine-grained token (recommended) | Classic token |
| --- | --- | --- |
| Access | Only your fork | All your repositories, **including private ones** (the `workflow` scope can't be combined with `public_repo` only) |
| Pull request on typst/packages | You open it with one click on a prefilled link in the job summary | Opened automatically |

GitHub doesn't allow fine-grained tokens to write to repositories of other users, and opening a pull request on
typst/packages counts as such. Everything else (updating the fork and pushing the package) only needs the fork.

1. Create the token:
   - **Fine-grained:** <https://github.com/settings/personal-access-tokens/new>. Resource owner: your account. Repository
     access: **Only select repositories** → your fork (`PfurtschellerP/packages`). Repository permissions:
     **Contents: Read and write** (push the package) and **Workflows: Read and write** (update the fork when
     typst/packages changed its own workflows); **Metadata: Read-only** is added automatically. No account permissions.
   - **Classic:** <https://github.com/settings/tokens> with the scopes `public_repo` and `workflow`.

   Set an expiration date (e.g. one year) and renew the token when it expires.
2. In this repository, go to **Settings → Environments**, create an environment called `typst-universe` and add the
   token as the environment secret `TYPST_PACKAGES_TOKEN`.
3. Recommended: enable **Required reviewers** for the environment and add yourself. The workflow then waits for your
   approval before anything is pushed to your fork or submitted to typst/packages.
4. Only if your fork is not called `<owner>/packages`: add the repository variable `TYPST_PACKAGES_FORK`
   (e.g. `PfurtschellerP/typst-packages`) under **Settings → Secrets and variables → Actions → Variables**.

Without the secret, the job is skipped with a notice and you submit the package manually (see below).

The pull request is created by the owner of the token (or by you, if you open it from the link). The Typst team expects
updates to come from the same person who submitted the previous versions; otherwise they will ask that person before
merging.

## Release process

### 1. Prepare the release (pull request)

1. Create a branch, e.g. `release/0.5.0`.
2. Bump the version. This updates `typst.toml`, the import in `template/main.typ` and the versioned references in
   `README.md`, and then checks them:

   ```bash
   scripts/bump-version.sh 0.5.0
   ```

3. If the title page changed, regenerate the thumbnail (the title page is page 2, after the restriction notice). The
   longer edge must be at least 1080 px and the file at most 3 MiB:

   ```bash
   scripts/compile-template.sh thumbnail.png --format png --pages 2 --ppi 250
   oxipng -o 4 --strip safe thumbnail.png   # optional, reduces the file size
   ```

4. Test the template locally (see [Testing locally](#testing-locally)).
5. Open a pull request. CI checks the formatting and the version references, compiles the template with the minimum
   and the latest Typst version, and runs [typst/package-check](https://github.com/typst/package-check), the linter
   that also runs on typst/packages. The compiled sample thesis can be downloaded from the workflow run
   (artifact `thesis-preview`).
6. Merge the pull request.

### 2. Tag the release

```bash
git switch main
git pull
git tag v0.5.0
git push origin v0.5.0
```

The tag must be `v` followed by the version in `typst.toml`. Otherwise the release workflow fails before it creates
anything.

### 3. GitHub release (automatic)

Pushing the tag starts [`release.yml`](.github/workflows/release.yml). It

1. checks that the tag matches `typst.toml`, `template/main.typ` and `README.md`,
2. compiles the sample thesis,
3. assembles the package with [`scripts/package.sh`](scripts/package.sh). Only the files that users need are copied:
   `typst.toml`, `README.md`, `LICENSE`, `thumbnail.png`, the logo, the `.typ` files of the library and the
   `template/` folder. `.github/`, `.vscode/`, `scripts/`, `.gitignore`, `RELEASING.md` and `renovate.json` are never
   submitted. Both lists are defined in [`scripts/common.sh`](scripts/common.sh); if you add a file that matches
   neither, packaging (and therefore CI) fails until you add it to one of them,
4. creates the GitHub release with automatically generated release notes (see [Release notes](#release-notes)) and
   attaches `sample-thesis-X.Y.Z.pdf` and `hsmz-thesis-unofficial-X.Y.Z.zip`.

### 4. Submit to Typst Universe

#### Automatic

If the token is configured, the `typst-universe` job runs after the release (after your approval, if you configured
required reviewers). It

1. syncs your fork with typst/packages,
2. creates the branch `hsmz-thesis-unofficial-X.Y.Z` with the folder `packages/preview/hsmz-thesis-unofficial/X.Y.Z/`
   and pushes it to your fork,
3. opens the pull request `hsmz-thesis-unofficial:X.Y.Z` on typst/packages (classic token), or, with a fine-grained
   token, ends with a warning and a link **Open pull request hsmz-thesis-unofficial:X.Y.Z** in the job summary. Open
   the link, check the prefilled title and description and click **Create pull request**.

Check the pull request, and continue with [step 5](#5-review-and-publication).

#### Manual

1. Assemble the package:

   ```bash
   scripts/package.sh dist
   ```

   (or download and unpack `hsmz-thesis-unofficial-X.Y.Z.zip` from the GitHub release).

2. Clone your fork with a sparse checkout (the full repository contains every version of every package and is large):

   ```bash
   git clone --depth 1 --no-checkout --filter="tree:0" git@github.com:PfurtschellerP/packages
   cd packages
   git sparse-checkout init
   git sparse-checkout set packages/preview/hsmz-thesis-unofficial
   git remote add upstream git@github.com:typst/packages
   git config remote.upstream.partialclonefilter tree:0
   git checkout main
   ```

   If you already have a clone, update it instead:

   ```bash
   git switch main
   git pull upstream main
   git push origin main
   ```

3. Copy the package into a new version folder and commit it on a new branch:

   ```bash
   git switch -c hsmz-thesis-unofficial-0.5.0
   cp -r ../hsmz-thesis-template-typst/dist/hsmz-thesis-unofficial/0.5.0 packages/preview/hsmz-thesis-unofficial/
   git add packages/preview/hsmz-thesis-unofficial/0.5.0
   git commit -m "hsmz-thesis-unofficial:0.5.0"
   git push origin hsmz-thesis-unofficial-0.5.0
   ```

   Note that `packages/` is a directory inside the `packages` repository, so the full path contains `packages` twice.
   Don't copy the `.git` folder and don't use submodules.

4. Open a pull request against `typst/packages:main`, for example with

   ```bash
   gh pr create -R typst/packages --base main --head PfurtschellerP:hsmz-thesis-unofficial-0.5.0 \
     --title "hsmz-thesis-unofficial:0.5.0"
   ```

   The title must be `name:version`. In the pull request template, tick "an update for a package" and describe the
   changes (copy them from the GitHub release). The checklist for new submissions can be deleted for updates.

### 5. Review and publication

- An automated check (typst/package-check) comments on the pull request if it finds problems. Fix them in this
  repository, then update the files in the typst/packages branch. As long as the pull request is open, you can push to
  that branch again; the version doesn't have to change.
- A maintainer of typst/packages reviews the pull request. Answer questions and requested changes in the pull request.
- After the merge, it can take up to 30 minutes until the new version is visible on
  [Typst Universe](https://typst.app/universe/package/hsmz-thesis-unofficial) and available via
  `typst init @preview/hsmz-thesis-unofficial`.

If the review requires changes to the package, commit them to this repository as well, and move the tag to the final
commit (`git tag -f v0.5.0 && git push -f origin v0.5.0`) so that the GitHub release matches the published version.
Delete the old GitHub release first, because the workflow can't create a release that already exists.

## Release notes

There is no changelog file. The release notes are generated by GitHub
([automatically generated release notes](https://docs.github.com/en/repositories/releasing-projects-on-github/automatically-generated-release-notes))
from the **pull requests** merged since the previous release, plus a link to the full list of commits. The automatic
submission uses them as the description of the typst/packages pull request as well. Therefore:

- Make every change through a pull request, also your own. Commits pushed directly to `main` only show up in the
  "Full Changelog" comparison, not as entries of the notes.
- Give pull requests meaningful titles in the [Conventional Commits](https://www.conventionalcommits.org/) style
  (`feat: ...`, `fix: ...`, `docs: ...`, `ci: ...`), because the title is what appears in the notes. Mark breaking
  changes with `!` (e.g. `feat!: ...`).
- Keep the individual commits of a pull request meaningful as well. They are listed in the "Full Changelog" comparison.
- You can edit the notes on the GitHub release page after the release has been created.

## Dependency updates

[Renovate](https://docs.renovatebot.com/) ([`renovate.json`](renovate.json)) opens pull requests when a new version of a
Typst package imported by the template (e.g. `@preview/acrostiche`) or of a GitHub Action is available. The PR titles
follow Conventional Commits (`chore(deps): ...`). The template's own import in `template/main.typ` is excluded, because
`scripts/bump-version.sh` manages it.

CI compiles every update with the minimum Typst version. If an update needs a newer compiler, either raise `compiler` in
`typst.toml` (and the minimum version in CI) or close the pull request. Updates reach users only with the next release
(usually a patch version).

## Testing locally

Compile the template against your checkout, without installing or publishing anything:

```bash
scripts/compile-template.sh                    # writes template/main.pdf
TYPST=/path/to/typst-0.15.0 scripts/compile-template.sh   # test with the minimum compiler version
```

While a version is not published yet, `@preview/hsmz-thesis-unofficial:X.Y.Z` can't be downloaded, so your editor
(Tinymist) shows "package not found" in `template/main.typ`. Link the checkout as a local package; local packages take
precedence over downloaded ones, also in the `@preview` namespace:

```bash
scripts/link-local-package.sh            # links the version in typst.toml to this checkout
scripts/link-local-package.sh --remove   # use the published versions again
```

Only the current version is linked, and `scripts/bump-version.sh` moves the link to the new version. The link is
global for your user (in `~/.local/share/typst/packages` on Linux, `~/Library/Application Support/typst/packages` on
macOS), so other projects that import exactly this version use the checkout as well. On Windows, Git Bash creates a
copy instead of a link unless symbolic links are enabled.

With the link in place, you can also test `typst init` exactly as users will run it:

```bash
version=$(sed -n 's/^version = "\(.*\)"/\1/p' typst.toml)
cd "$(mktemp -d)"
typst init "@preview/hsmz-thesis-unofficial:$version" test
cd test && typst compile main.typ
```

CI and `scripts/compile-template.sh` don't need the link: they use a temporary package directory
(`typst --package-path`).

Before committing, format all Typst files with [typstyle](https://github.com/typstyle-rs/typstyle) (the same check runs
in CI):

```bash
typstyle -i --line-width 120 .
```

## Checklist

- [ ] `scripts/bump-version.sh X.Y.Z` ran, `scripts/check-version.sh` passes
- [ ] Thumbnail regenerated (if the title page changed)
- [ ] README documents new or changed parameters
- [ ] CI is green on `main`
- [ ] Tag `vX.Y.Z` pushed, GitHub release created
- [ ] Pull request `hsmz-thesis-unofficial:X.Y.Z` on typst/packages opened and merged
