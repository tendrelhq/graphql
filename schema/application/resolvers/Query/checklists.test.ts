import { expect, test } from "bun:test";
import { resolvers, typeDefs } from "@/schema";
import { execute } from "@/test/prelude";
import { mergeResolvers, mergeTypeDefs } from "@graphql-tools/merge";
import { makeExecutableSchema } from "@graphql-tools/schema";
import { ChecklistsDocument } from "./checklists.test.generated";

const schema = makeExecutableSchema({
  resolvers: mergeResolvers([resolvers]),
  typeDefs: mergeTypeDefs([ChecklistsDocument, typeDefs]),
});

test.skip("checklists", async () => {
  const result = await execute(schema, ChecklistsDocument);
  expect(result).toMatchSnapshot();
});
