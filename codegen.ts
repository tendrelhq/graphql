import type { CodegenConfig } from "@graphql-codegen/cli";
import { defineConfig } from "@eddeee888/gcg-typescript-resolver-files";

const config: CodegenConfig = {
  schema: "./lib/schema/schema.gql",
  generates: {
    "lib/schema/__generated__": defineConfig({
      typesPluginsConfig: {
        contextType: "@/schema#Context",
      },
    }),
  },
};

export default config;
