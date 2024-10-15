import { afterAll, describe, expect, test } from "bun:test";
import { resolvers, typeDefs } from "@/schema";
import { execute } from "@/test/prelude";
import { makeExecutableSchema } from "@graphql-tools/schema";
import { TestAfterDiscardChecklistDocument } from "./discardChecklist.after.test.generated";
import { TestDiscardChecklistDocument } from "./discardChecklist.test.generated";

process.env.X_TENDREL_USER = "user_2iADtxE5UonU4KO5lphsG59bkR9";

const schema = makeExecutableSchema({ resolvers, typeDefs });

const INSTANCE =
  "d29ya2luc3RhbmNlOndvcmstaW5zdGFuY2VfZmJhMGQyNTgtODBhZi00YmRjLWEwZjYtYTNmNGE2NGM1NTZj";
// const TEMPLATE =
//   "d29ya3RlbXBsYXRlOjQ5MzgzMDJiLTdkYWEtNDUyYy05YzM3LThlMGMxYTZiZGNjOA==";

describe.skipIf(!!process.env.CI)("discardChecklist", () => {
  test("discards in progress checklist", async () => {
    const result = await execute(schema, TestDiscardChecklistDocument, {
      id: INSTANCE,
    });

    expect(result.errors).toBeFalsy();
    expect(result.data?.discardChecklist.discardedChecklistIds).toContain(
      INSTANCE,
    );
    expect(result.data?.discardChecklist.edge).toMatchSnapshot();
  });

  afterAll(async () => {
    await execute(schema, TestAfterDiscardChecklistDocument, {
      id: INSTANCE,
      at: {
        instant: Date.now().toString(),
      },
    });
  });
});
