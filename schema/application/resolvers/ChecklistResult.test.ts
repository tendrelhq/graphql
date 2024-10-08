import { expect, test } from "bun:test";
import { resolvers, typeDefs } from "@/schema";
import { execute } from "@/test/prelude";
import { makeExecutableSchema } from "@graphql-tools/schema";
import { TestChecklistResultDocument } from "./ChecklistResult.test.generated";

const schema = makeExecutableSchema({ resolvers, typeDefs });

test.skipIf(!!process.env.CI)("ChecklistResult", async () => {
  const result = await execute(schema, TestChecklistResultDocument);
  if (result.errors?.length) {
    for (const e of result.errors) {
      console.error(e);
    }
  }
  expect(result).toMatchSnapshot();
});
