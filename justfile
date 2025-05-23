image_name := "tendrel-graphql-dev"
node_env   := "development"

default: generate

dump:
    pg_dump --verbose --format=c --no-acl --no-owner --exclude-schema=datawarehouse --exclude-schema=upload --file db.dump

restore:
    createdb $PGDATABASE
    pg_restore --jobs=$(nproc) --verbose --exit-on-error --no-acl --no-owner --dbname=$PGDATABASE db.dump

install:
    bun clean && bun install --frozen-lockfile

generate: install
    bun --filter=./packages/* generate
    bun format

migrate:
    sqitch deploy

package:
    docker build --build-arg=NODE_ENV={{node_env}} --file=config/graphql.dockerfile -t {{image_name}} .

test:
    bun test
