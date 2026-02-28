# Troubleshooting

## Build fails with `UnknownHostException` or dependency download errors

- Cause: network is blocked for GitHub or Defold build services.
- Action: allow outbound access to:
  - `https://github.com/defold/extension-poki-sdk/...`
  - `https://build.defold.com/...`

## Build fails with `Folder .../build ... can't be used for bundling`

- Cause: Defold reserves `<project>/build` for internal build state.
- Action: keep `--bundle-output` outside `build` (default is `dist`).

## Bundle fails only for `wasm_pthread-web`

- Cause: extension/toolchain differences between architectures.
- Action: lock architecture to `wasm-web` for Poki HTML5 baseline testing.

## Playwright command hangs or cannot resolve package

- Cause: first run needs npm registry access.
- Action:
  - verify `npx` is available
  - allow access to `https://registry.npmjs.org/`

## Smoke test reports console errors

- Open the copied `console-*.log` under `output/playwright/<timestamp>/`.
- Fix the first real runtime error, rebuild, then rerun smoke test.
- Use `--strict-console` in CI to fail on any remaining console errors.

## Local smoke test reports COOP errors from IMA SDK

- Cause: third-party ad scripts can emit COOP-related console errors in local HTTP smoke tests.
- Action:
  - keep `--strict-console` disabled for local ad-SDK smoke loops
  - enable `--strict-console` only after deciding your allowed error baseline

## Local smoke test reports `favicon.ico` 404

- Cause: bundle does not include a favicon file by default.
- Action:
  - add a favicon file under your served bundle root
  - or keep `--strict-console` disabled until favicon is added
