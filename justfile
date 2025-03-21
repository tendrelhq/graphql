dbname     := "dev"
image_name := "tendrel-graphql-dev"
node_env   := "development"
target     := "dev"

default: start

dump:
    pg_dump --verbose --format=c --disable-triggers --no-acl --no-owner --schema=public --schema=entity --clean --if-exists --file db.dump

restore:
    createdb {{dbname}}
    pg_restore --verbose --exit-on-error --no-acl --no-owner --clean --if-exists --dbname={{dbname}} db.dump

install:
    bun install --frozen-lockfile

migrate:
    sqitch deploy --target {{target}}

package:
    docker build --build-arg=NODE_ENV={{node_env}} --file=config/graphql.dockerfile -t {{image_name}} .

start: package
    docker run --env-file=.env.local --network=host --rm {{image_name}}

tap:
    pg_prove ./test/*.test.sql

test: tap
    bun test
