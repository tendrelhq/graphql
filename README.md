# @tendrelhq/graphql

To get started:

0. Set up PostgreSQL
   - Run the scripts in [./sql/deploy/](./sql/deploy),
     e.g. `psql -f ./sql/deploy/01-permissions.sql`
   - You can use [sqitch] if you feel like it. I use it during development.[^1]
   - If you get errors about things already existing, run the corresponding
     revert script and then re-run the deploy script.
1. `cp .env.local.template .env.local` and fill in the blanks, everything is required.
2. `docker compose up --build --wait` (n.b. `--wait` implies `--detach`)

### formatting

If you don't have [nix] and want to format, the generated configuration looks
like this:

```toml
[formatter.alejandra]
command = "alejandra"
excludes = []
includes = ["*.nix"]
options = []

[formatter.biome]
command = "biome"
excludes = []
includes = ["*.graphql", "*.json", "*.md", "*.ts"]
options = ["check", "--write"]

[formatter.prettier]
command = "prettier"
excludes = []
includes = ["*.yaml", "*.yml"]
options = ["--write"]

[formatter.shfmt]
command = "shfmt"
excludes = []
includes = ["*.sh", "*.bash", "*.envrc", "*.envrc.*"]
options = ["-s", "-w", "-i", "2"]
```

You can derive the correct commands from there, e.g.

```
$ biome check --write **/*.{graphql,json,ts}
Checked 198 files in 107ms. No fixes applied.

$ prettier --write **/*.{yaml,yml}
copilot/environments/beta/manifest.yml 16ms (unchanged)
copilot/environments/dev/manifest.yml 2ms (unchanged)
copilot/environments/test/manifest.yml 2ms (unchanged)
copilot/graphql/manifest.yml 6ms (unchanged)
copilot/pipelines/graphql-workloads/buildspec.yml 4ms (unchanged)
copilot/pipelines/graphql-workloads/manifest.yml 1ms (unchanged)
```

[^1]: `sqitch deploy`, `sqitch revert -y`, `sqitch rebase -y`

[nix]: https://nixos.org/download/
[sqitch]: https://sqitch.org/
