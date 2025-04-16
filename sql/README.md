## Notice

Until a better solution comes along, this is my best effort at maintaining a
semblance of version control to the wild west that is our Postgresql database.

In this directory you will find several things:

1. The "source code" for all of the SQL routines (and some schemas) that
   comprise the Tendrel "platform": [./src](./src)
2. A script that "pulls" the "source code": [pull-schemas.sh](./scripts/pull-schemas.sh)
3. Various CI patches/scripts that attempt to replicate the permissions of the
   production database as closely as possible: [./deploy](./deploy)

To pull the latest SQL source code:

```sh
nix develop -c ./scripts/pull-schemas.sh
```

Note that the above script expects:

- libpq environment variables, e.g. PGUSER and PGPASSWORD
- [pgddl]
- python3

[pgddl]: https://github.com/lacanoid/pgddl
