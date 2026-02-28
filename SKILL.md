---
name: defold-poki-build-test
description: Use when a Defold HTML5 game for Poki needs reproducible CLI build and browser smoke testing with Playwright before sharing, release, or CI hardening.
---

# Defold Poki Build Test

## Overview

Use this skill to run a deterministic Defold build and a Playwright smoke test through bundled shell scripts. Keep build/test logic in scripts for reuse in local runs and CI.

## Install (External Users)

Replace `<owner>/<repo>` with your published repository, then run:

```bash
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}" \
python "$CODEX_HOME/skills/.system/skill-installer/scripts/install-skill-from-github.py" \
  --url "https://github.com/<owner>/<repo>/tree/main/skills/defold-poki-build-test"
```

After installation, restart Codex to load the new skill.

## Preconditions

- Require a Defold installation at `/Applications/Defold.app`.
- Require a project root containing `game.project`.
- Require `npx` and internet access for the first `@playwright/cli` run.

## Workflow

1. Build Defold web bundle with `scripts/build_defold.sh`.
2. Smoke-test bundle with `scripts/test_playwright.sh`.
3. Use `scripts/run_all.sh` to execute both in one command.

## Commands

```bash
# Build only (default: wasm-web + archive)
./skills/defold-poki-build-test/scripts/build_defold.sh --root .

# Test only (serve dist/<title>/index.html and capture artifacts)
./skills/defold-poki-build-test/scripts/test_playwright.sh --root .

# Full pipeline
./skills/defold-poki-build-test/scripts/run_all.sh --root .
```

## Outputs

- Defold build output: `build/default/`
- Defold bundle output: `dist/<project-title>/`
- Playwright artifacts: `output/playwright/<timestamp>/`

## Reference

Read `references/troubleshooting.md` only when build or test fails.
