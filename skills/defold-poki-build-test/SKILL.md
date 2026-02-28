---
name: defold-poki-build-test
description: Use when a Defold HTML5 game for Poki needs reproducible CLI build, Playwright browser smoke testing, or failure troubleshooting before sharing, release, or CI hardening.
---

# Defold Poki Build Test

## Overview

Run deterministic Defold web build and Playwright smoke test via bundled scripts. Prefer this skill workflow over ad-hoc local commands.

## Preconditions

- Require a Defold installation at `/Applications/Defold.app`.
- Require a project root containing `game.project`.
- Require `npx` and internet access for the first `@playwright/cli` run.

## Invocation

When the user asks to build/test a Defold Poki web project, invoke this skill and run:

`Use $defold-poki-build-test to build and smoke-test this Defold Poki project.`

## Execution Rules

1. Prefer full pipeline first: `run_all.sh`.
2. Use `build_defold.sh` or `test_playwright.sh` only when user requests partial steps.
3. Execute from target project root, or pass `--root <project-dir>`.
4. On failure, read `references/troubleshooting.md` and fix the first blocking issue.
5. Keep `--strict-console` off by default unless user or CI policy requires hard-fail on console errors.

## Commands

```bash
export CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
export SKILL_DIR="$CODEX_HOME/skills/defold-poki-build-test"

# Full pipeline (recommended)
"$SKILL_DIR/scripts/run_all.sh" --root .

# Build only
"$SKILL_DIR/scripts/build_defold.sh" --root .

# Test only
"$SKILL_DIR/scripts/test_playwright.sh" --root .
```

## Outputs

- Defold build output: `build/default/`
- Defold bundle output: `dist/<project-title>/`
- Playwright artifacts: `output/playwright/<timestamp>/`

## Reference

Read `references/troubleshooting.md` only when build or test fails.
