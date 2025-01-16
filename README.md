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

[nix]: https://nixos.org/download/
[ruru]: https://github.com/graphile/crystal/tree/main/grafast/ruru
[pgweb]: https://github.com/sosedoff/pgweb
[sqitch]: https://sqitch.org/
