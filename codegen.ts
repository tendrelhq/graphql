import { defineConfig } from "@eddeee888/gcg-typescript-resolver-files";
import type { CodegenConfig } from "@graphql-codegen/cli";

const config: CodegenConfig = {
  schema: "./lib/schema/schema.gql",
  generates: {
    "lib/schema/__generated__": defineConfig({
      typesPluginsConfig: {
        contextType: "@/schema#Context",
        useTypeImports: true,
      },
    }),
  },
};

export default config;
