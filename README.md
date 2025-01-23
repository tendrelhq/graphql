# @tendrelhq/graphql

1. `cp .envrc.template .envrc` and fill in the blanks.
2. `cp .env.local.template .env.local` and fill in the blanks.
3. Run `bun install` per usual, then `bun start` to start the server.

If you have [nix] installed (which I highly recommend you do) you can use the
dev environment via `devenv up`. This will start:

1. the graphql server
2. postgresql
3. a [ruru] graphiql instance
4. a [pgweb] instance

The first time you do this will require `syncdb`ing; I will fix this soon.

Lastly, there are a bunch of sql scripts in [./sql]. I plan on manually keeping
these things up to date in the production database. In development I've been
using [sqitch] as a helpful little migration tool. Once installed, basically the
only command you need is `sqitch rebase -y`. This will revert (if applicable)
and deploy the scripts in [./sql] as per [./sql/sqitch.plan].

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
includes = ["*.graphql", "*.json", "*.ts"]
options = ["check", "--write"]

[formatter.prettier]
command = "prettier"
excludes = []
includes = ["*.md", "*.yaml", "*.yml"]
options = ["--write"]

[formatter.sqlfmt]
command = "sqlfmt"
excludes = []
includes = ["*.sql"]
options = ["-"]

[global]
excludes = ["*.lock", "*.patch", "package-lock.json", "go.mod", "go.sum", ".gitignore", ".gitmodules", ".hgignore", ".svnignore", "*.conf", "*.lockb", "*.plan", "*.snap", "*.toml", ".*", "copilot/.workspace", "Dockerfile", "justfile"]
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

$ sqlfmt **/*.sql
28 files left unchanged.
```

[nix]: https://nixos.org/download/
[ruru]: https://github.com/graphile/crystal/tree/main/grafast/ruru
[pgweb]: https://github.com/sosedoff/pgweb
[sqitch]: https://sqitch.org/
