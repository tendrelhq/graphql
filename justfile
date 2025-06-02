image_name := "tendrel-graphql-dev"
node_env   := "development"

default: generate

check:
    bun --filter=./packages/* check

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

publish:
    mkdir -p ./dist/graphql
    jq '{name,version,files}' packages/server/package.json > ./dist/graphql/package.json
    cp packages/server/schema.graphql ./dist/graphql/schema.graphql
    cd ./dist/graphql && bun publish

pull-schemas:
    ./sql/scripts/pull-schemas.sh

test:
    bun test

alias c := check
alias ci := install
alias g := generate
