import { defineConfig } from "@eddeee888/gcg-typescript-resolver-files";
import type { CodegenConfig } from "@graphql-codegen/cli";

const config: CodegenConfig = {
  schema: "./*.schema.graphql",
  generates: {
    "./__generated__": defineConfig({
      typesPluginsConfig: {
        // contextType: "@/schema#Context",
        useTypeImports: true,
        inputMaybeValue: "T | undefined",
      },
    }),
  },
};

export default config;
