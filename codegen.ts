import type { CodegenConfig } from "@graphql-codegen/cli";

const config: CodegenConfig = {
  schema: "./lib/schema/schema.gql",
  generates: {
    "lib/schema/types.ts": {
      plugins: ["typescript", "typescript-resolvers"],
      config: {
        contextType: "@/schema#Context",
        useIndexSignature: true,
      },
    },
  },
};

export default config;
