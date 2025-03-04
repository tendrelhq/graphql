deploy_env := "dev"
image_name := "tendrel-graphql-dev"

default: build

build:
    bun compile

deploy:
    copilot env deploy --name {{deploy_env}}
    copilot deploy --env {{deploy_env}}

package:
    docker build --file copilot/graphql/Dockerfile -t {{image_name}} .

tap:
    pg_prove ./test/*.test.sql
