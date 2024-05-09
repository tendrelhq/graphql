deploy_env := "dev"
image_name := "tendrel-graphql-dev"
port       := "4000"

default: build

build: clean generate
    bun build.ts

clean:
    bun rimraf ./out

deploy:
    copilot deploy --env {{deploy_env}}

docker:
    docker build --build-arg NODE_ENV=development --pull -t {{image_name}} .

generate:
    bun graphql-codegen

start: docker
    docker kill tendrel-graphql-dev 2>/dev/null || true
    docker run --name tendrel-graphql-dev --rm -d -p {{port}}:{{port}} {{image_name}}
