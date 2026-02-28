# Install defold-poki-build-test in Codex

Run:

```bash
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}" \
python3 "$CODEX_HOME/skills/.system/skill-installer/scripts/install-skill-from-github.py" \
  --repo "mixBayes/defold-poki-build-test" \
  --path "skills/defold-poki-build-test" \
  --method git
```

Why `--method git`: installer default is `auto`, which may use zip download first.
Python zip extraction can drop executable bits for shell scripts and cause `Permission denied`.

Verify script permissions after install:

```bash
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}" \
stat -f '%N %Sp %OLp' "$CODEX_HOME/skills/defold-poki-build-test/scripts/"*.sh
```

If already installed and scripts are not executable, run one-time fix:

```bash
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}" \
chmod 755 "$CODEX_HOME/skills/defold-poki-build-test/scripts/"*.sh
```

Restart Codex after installation.
