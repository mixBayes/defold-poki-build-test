# defold-poki-build-test

Codex skill for reproducible Defold + Poki HTML5 build and Playwright smoke testing.

## Recommended Usage (Codex-First)

Use this as a **Codex skill**, not as a manual script collection.

After installation, invoke it in Codex with prompts like:

- `Use $defold-poki-build-test to build and smoke-test this Defold Poki project.`
- `Use $defold-poki-build-test and fail on console errors after the smoke test.`
- `在项目 X 对 390x844, 768x1024, 1920x1080 做缩放测试，检查 UI 是否重叠/裁切，输出每个分辨率截图和结论。`

The skill is designed to orchestrate the workflow safely and consistently.

## Direct Agent Command (Viewport Regression)

You can directly send this instruction to the agent:

```text
在项目 X 对 390x844, 768x1024, 1920x1080 做缩放测试，检查 UI 是否重叠/裁切，输出每个分辨率截图和结论。
```

Recommended output expectation:

- Screenshot for each viewport (`390x844`, `768x1024`, `1920x1080`)
- A pass/fail conclusion for each viewport
- File/element evidence when overlap, clipping, or deformation is detected

## Triggering Post-Feature Validation

Current setup does not provide an event hook like "auto-run when coding is done".
Use a fixed completion phrase in your prompt so the agent reliably triggers validation:

```text
Defold 功能已实现完成，请自动调用 $defold-poki-build-test 测试刚实现的功能；如果涉及 UI，自带 390x844, 768x1024, 1920x1080 缩放检查并输出截图和结论。
```

This phrase makes the validation intent explicit and keeps runs deterministic/reproducible in CI and local workflows.

## Install in Codex

### Codex

Tell Codex:

```text
Fetch and follow instructions from https://raw.githubusercontent.com/mixBayes/defold-poki-build-test/refs/heads/main/.codex/INSTALL.md
```

The install instructions explicitly force `--method git` to preserve executable bits on shell scripts.

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
├── README.md
├── LICENSE
└── skills/
    └── defold-poki-build-test/
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
SKILL_REPO="/path/to/this-repo"
GAME_ROOT="/path/to/defold-game-project" # contains game.project

# Build only
"$SKILL_REPO/skills/defold-poki-build-test/scripts/build_defold.sh" --root "$GAME_ROOT"

# Test only (requires dist/<title>/index.html)
"$SKILL_REPO/skills/defold-poki-build-test/scripts/test_playwright.sh" --root "$GAME_ROOT"

# Build + test
"$SKILL_REPO/skills/defold-poki-build-test/scripts/run_all.sh" --root "$GAME_ROOT"
```

## CI Notes

- Start with non-strict console mode to establish a baseline
- Enable strict mode only after known noise (for example favicon 404) is handled

## Troubleshooting

See [skills/defold-poki-build-test/references/troubleshooting.md](./skills/defold-poki-build-test/references/troubleshooting.md).
