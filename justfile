deploy_env := "dev"
image_name := "tendrel-graphql-dev"
port       := "4000"

default: build

build:
    bun compile

database:
    docker compose up -d postgresql

deploy:
    copilot env deploy --name {{deploy_env}}
    copilot deploy --env {{deploy_env}}

jaeger:
    docker compose up -d jaeger

package:
    docker build -t {{image_name}} .

sidecars: database jaeger
    docker compose logs -f

start:
    docker compose up --detach && docker compose logs -f graphql
