import { defineConfig } from "@eddeee888/gcg-typescript-resolver-files";
import { generate } from "@graphql-codegen/cli";
import type { CodegenConfig } from "@graphql-codegen/cli";
import { $ } from "bun";
import graphqlConfig from "./graphql.config.json";

const config: CodegenConfig = {
  schema: graphqlConfig.schema,
  documents: "./schema/**/*.test.graphql",
  generates: {
    "./schema/__generated__": defineConfig({
      typesPluginsConfig: {
        contextType: "@/schema#Context",
        inputMaybeValue: "T | undefined",
        maybeValue: "T | undefined",
        useTypeImports: true,
      },
    }),
    "./schema.graphql": {
      plugins: ["schema-ast"],
    },
    ".": {
      preset: "near-operation-file",
      plugins: ["typescript-operations", "typed-document-node"],
      presetConfig: {
        baseTypesPath: "~@/schema",
      },
    },
  },
};

await generate(config);

await $`biome format --write ./schema/__generated__/*.ts`;
await $`biome check --write ./schema/*/resolvers/**/*.ts`;