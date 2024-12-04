import { config as scalarsConfig } from "@/schema/system/scalars";
import { defineConfig } from "@eddeee888/gcg-typescript-resolver-files";
import { generate } from "@graphql-codegen/cli";
import type { CodegenConfig } from "@graphql-codegen/cli";
import graphqlConfig from "../graphql.config.json";

const config: CodegenConfig = {
  schema: graphqlConfig.schema,
  documents: "./schema/**/*.test.graphql",
  generates: {
    "./schema/__generated__": defineConfig({
      resolverGeneration: {
        interface: "", // disabled
        mutation: [
          // New schema mutations
          "!schema.Mutation.*",
        ],
        object: [
          // New schema objects
          "!schema.*",
          // Legacy schema objects
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
        query: [
          // New schema queries
          "!schema.Query.*",
        ],
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
