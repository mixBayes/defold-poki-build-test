# defold-poki-build-test

Codex skill for reproducible Defold + Poki HTML5 build and Playwright smoke testing.

## Recommended Usage (Codex-First)

Use this as a **Codex skill**, not as a manual script collection.

After installation, invoke it in Codex with prompts like:

- `Use $defold-poki-build-test to build and smoke-test this Defold Poki project.`
- `Use $defold-poki-build-test and fail on console errors after the smoke test.`

The skill is designed to orchestrate the workflow safely and consistently.

## Install in Codex

Replace `<owner>/<repo>` with your published repository:

```bash
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}" \
python "$CODEX_HOME/skills/.system/skill-installer/scripts/install-skill-from-github.py" \
  --url "https://github.com/<owner>/<repo>/tree/main"
```

Restart Codex after installation.

## What It Does

- Standardizes Defold web build parameters (default `wasm-web`)
- Produces a testable HTML5 bundle
- Runs Playwright CLI smoke checks (open, snapshot, screenshot, console)
- Collects structured artifacts for debugging and CI

## Requirements

- Defold installed (default path: `/Applications/Defold.app`)
- `java`, `python3`, and `npx` available
- Network access for first Playwright package download (`registry.npmjs.org`)
- Network access for Defold/Poki dependencies (e.g. GitHub, `build.defold.com`)

## Outputs

- Build output: `build/default/`
- Bundle output: `dist/<project-title>/`
- Playwright artifacts: `output/playwright/<timestamp>/`

## Repository Layout

```text
.
├── SKILL.md
├── agents/openai.yaml
├── scripts/
│   ├── build_defold.sh
│   ├── test_playwright.sh
│   └── run_all.sh
└── references/troubleshooting.md
```

## Direct Script Usage (Advanced / Non-Codex)

If you are running outside Codex, you can execute scripts directly:

```bash
# Build only
./scripts/build_defold.sh --root .

# Test only (requires dist/<title>/index.html)
./scripts/test_playwright.sh --root .

# Build + test
./scripts/run_all.sh --root .
```

## CI Notes

- Start with non-strict console mode to establish a baseline
- Enable strict mode only after known noise (for example favicon 404) is handled

## Troubleshooting

See [references/troubleshooting.md](./references/troubleshooting.md).
