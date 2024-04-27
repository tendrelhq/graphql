import type { CodegenConfig } from "@graphql-codegen/cli";

const config: CodegenConfig = {
  schema: "./lib/schema/schema.graphql",
  generates: {
    "lib/schema/schema.ts": {
      plugins: ["typescript", "typescript-resolvers"],
      config: {
        contextType: "@/schema#Context",
        useIndexSignature: true,
      },
    },
  },
};

export default config;
