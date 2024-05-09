deploy_env := "test"
dev_image  := "tendrel-graphql-dev"
prod_image := "tendrel-grahpql"
port       := "4000"

default: build

build: clean generate
    bun build.ts

clean:
    bun rimraf ./out

deploy:
    copilot deploy --env {{deploy_env}}

docker:
    docker build --build-arg NODE_ENV=development --pull -t {{dev_image}} .

generate:
    bun graphql-codegen

release:
    docker build --build-arg NODE_ENV=production --pull -t {{prod_image}} .

start: docker
    docker kill tendrel-graphql-dev 2>/dev/null || true
    docker run --name tendrel-graphql-dev --rm -d -p {{port}}:{{port}} {{dev_image}}
