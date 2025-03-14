image_name := "tendrel-graphql-dev"
node_env   := "development"

default: start

package:
    docker build --build-arg=NODE_ENV={{node_env}} --file=config/graphql.dockerfile -t {{image_name}} .

start: package
    docker run --env-file=.env.local --network=host --rm {{image_name}}

tap:
    pg_prove ./test/*.test.sql
