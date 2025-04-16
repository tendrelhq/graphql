image_name := "tendrel-graphql-dev"
node_env   := "development"
target     := "dev"

default: start

dump:
    pg_dump --verbose --format=c --no-acl --no-owner --exclude-schema=datawarehouse --exclude-schema=upload --clean --if-exists --file db.dump

restore:
    createdb $PGDATABASE
    pg_restore --verbose --exit-on-error --no-acl --no-owner --clean --if-exists --dbname=$PGDATABASE db.dump

install:
    bun install --frozen-lockfile

migrate:
    sqitch deploy --target {{target}}

package:
    docker build --build-arg=NODE_ENV={{node_env}} --file=config/graphql.dockerfile -t {{image_name}} .

start:
    docker compose up

tap:
    pg_prove ./test/*.test.sql

test: tap
    bun test
