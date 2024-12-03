import { config as scalarsConfig } from "@/schema/system/scalars";
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
      resolverGeneration: {
        interface: "", // disabled
        mutation: "*",
        object: [
          "!*.*Edge", // all Edge implementations
          "!*.Active",
          "!*.AssignmentPayload",
          "!*.UnassignmentPayload",
          "!*.ChecklistChain",
          "!*.ChecklistOpen",
          "!*.ChecklistInProgress",
          "!*.ChecklistClosed*",
          "!*Payload",
          "!*Geofence",
        ],
        query: "*",
        scalar: "*",
        subscription: "*",
        union: "", // disabled
      },
      scalarsModule: "@/schema/system/scalars",
      typesPluginsConfig: {
        contextType: "@/schema#Context",
        inputMaybeValue: "T | undefined",
        maybeValue: "T | undefined",
        useTypeImports: true,
      },
    }),
    "./schema.graphql": {
      plugins: ["schema-ast"],
      config: {
        includeDirectives: true,
        sort: true,
      },
    },
    ".": {
      preset: "near-operation-file",
      plugins: ["typescript-operations", "typed-document-node"],
      presetConfig: {
        baseTypesPath: "~@/schema",
      },
      config: {
        addTypenameToSelectionSets: true,
        scalars: scalarsConfig,
        useTypeImports: true,
      },
    },
  },
  verbose: true,
};

await generate(config);

await $`biome format --vcs-enabled=false --write ./schema/__generated__/*.ts`;
await $`biome check --write ./schema/*/resolvers/**/*.ts`;
await $`prettier --write **/*.graphql`;
