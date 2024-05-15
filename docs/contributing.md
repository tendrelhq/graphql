# Getting started

## Prerequisites

1. install [bun]

## Install

```sh
bun install
bun generate
```

## Running the development server

There's a few ways:

1. via [bun]

```sh
bun start
```

2. via Docker

This way mimics production, as it builds the Docker image from the same spec
that is used in production. In fact, it even uses NODE_ENV=production.

```
docker build -t tendrel-graphql-dev .
```

3. via docker-compose

This way bootstraps everything that is necessary to run a local graphql
endpoint, including a Postgres database. Note that the Postgres container uses a
Docker volume, which persists across containers. You can `syncdb` it with any
other Postgres database that you have access to. Note that the Postgres
container exposes the port _5433_ (rather than the default 5432), in case you
have a locally running Postgres instance using the default port. The connection
uri is thus: `postgresql://postgres:password@localhost:5433/postgres` (see [the
Dockerfile](../Dockerfile) for reference).

```
docker compose up --detach
docker compose logs -f
```

[bun]: https://github.com/oven-sh/bun
