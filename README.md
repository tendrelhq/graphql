# @tendrelhq/graphql

To get started:

0. Set up PostgreSQL. If you use [nix], you can use the devenv via `devenv up`.
   - If this is your first time, run the [./sql/deploy](./sql/deploy) scripts in the order specified by [./sql/sqitch.plan](./sql/sqitch.plan).
   - e.g. `psql -f ./sql/deploy/graphql-service-role.sql`
   - You can use [sqitch] if you feel like it. I use it during development.
1. `cp .env.local.template .env.local` and fill in the blanks.
2. `cp .envrc.template .envrc` and fill in the blanks.
3. `docker compose up`

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

[nix]: https://nixos.org/download/
[sqitch]: https://sqitch.org/
