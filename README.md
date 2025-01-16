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

(the first time you do this will require `syncdb`ing, I will fix this soon)

[nix]: https://nixos.org/download/
[ruru]: https://github.com/graphile/crystal/tree/main/grafast/ruru
[pgweb]: https://github.com/sosedoff/pgweb
