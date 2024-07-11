import { lexicographicSortSchema, printSchema } from "graphql";
import { schema } from "../src/schema";

await Bun.write(
  "./schema.graphql",
  printSchema(lexicographicSortSchema(schema)),
);
