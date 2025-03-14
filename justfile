deploy_env := "dev"
image_name := "tendrel-graphql-dev"

default: build

build:
    bun compile

deploy:
    copilot env deploy --name {{deploy_env}}
    copilot deploy --env {{deploy_env}}

package:
    docker build --file config/graphql.dockerfile -t {{image_name}} .

start: package
    docker run --env-file .env.local --network=host --rm {{image_name}}

tap:
    pg_prove ./test/*.test.sql
