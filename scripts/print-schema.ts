import path from "node:path";
import { schema } from "@/schema/final";
import { printSchemaWithDirectives } from "@graphql-tools/utils";
import { lexicographicSortSchema } from "graphql";

await Bun.write(
  Bun.file(path.join(__dirname, "../schema.graphql")),
  printSchemaWithDirectives(lexicographicSortSchema(schema)),
);
