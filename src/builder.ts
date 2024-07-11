import SchemaBuilder from "@pothos/core";
import RelayPlugin from "@pothos/plugin-relay";
import type { Context } from "./types";

export const builder = new SchemaBuilder<{ Context: Context }>({
  plugins: [RelayPlugin],
  relay: {
    //
  },
});

export const Query = builder.queryType();
