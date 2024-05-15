# Infrastructure

The infrastructure for this package is managed by [copilot].

## CI/CD

There is a CodePipeline that is responsible for deploying changes to this
package. It runs on every commit to the "main" branch. The resulting service
can be accessed at https://test.graphql.tendrel.io.

## Deploying to a personal account

1. install [copilot]
2. setup environment variables (see [the dev env manifest](../copilot/environments/dev/manifest.yml) for details).

```sh
# Fill these in from your personal account, either by deploying a
# DevTendrelServiceStack or using the default vpc.
# You can put them in .envrc (if you are using direnv).
export VPC_ID=
export PUBLIC_SUBNET_1=
export PRIVATE_SUBNET_1=
```

3. `copilot app init`, and then follow the prompts...

[copilot]: https://github.com/aws/copilot-cli
