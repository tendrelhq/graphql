deploy_env := "dev"
image_name := "tendrel-graphql-dev"
port       := "4000"

default: build

build:
    bun compile

deploy:
    copilot env deploy --name {{deploy_env}}
    copilot deploy --env {{deploy_env}}

start:
    docker compose up --detach --watch
