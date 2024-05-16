deploy_env := "dev"
image_name := "tendrel-graphql-dev"
port       := "4000"

default: build

build:
    bun compile

deploy:
    copilot env deploy --name {{deploy_env}}
    copilot deploy --env {{deploy_env}}

package:
    docker build -t {{image_name}} .

start:
    docker compose up --detach && docker compose logs -f
