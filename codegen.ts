import { defineConfig } from "@eddeee888/gcg-typescript-resolver-files";
import type { CodegenConfig } from "@graphql-codegen/cli";

const config: CodegenConfig = {
  schema: "./schema/**/*.schema.graphql",
  generates: {
    "./lib/schema/__generated__": defineConfig({
      typesPluginsConfig: {
        contextType: "@/schema#Context",
        inputMaybeValue: "T | undefined",
        useTypeImports: true,
      },
    }),
    "./schema.graphql": {
      plugins: ["schema-ast"],
    },
  },
};

export default config;
