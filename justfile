deploy_env := "dev"
image_name := "tendrel-graphql-dev"

default: build

build:
    bun compile

deploy:
    copilot env deploy --name {{deploy_env}}
    copilot deploy --env {{deploy_env}}

package:
    docker build -t {{image_name}} .
