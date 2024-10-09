import { describe, expect, test } from "bun:test";
import { resolvers, typeDefs } from "@/schema";
import { execute } from "@/test/prelude";
import { makeExecutableSchema } from "@graphql-tools/schema";
import { TestCopyFromDocument } from "./copyFrom.test.generated";

const schema = makeExecutableSchema({ resolvers, typeDefs });

const TEMPLATE =
  "d29ya3RlbXBsYXRlOndvcmstdGVtcGxhdGVfNzdhNTU1NjctNmIyYi00NTA2LTlkMmItZjM3NWUwYzI5ZTNm";

describe.skipIf(!!process.env.CI)("copyFrom", () => {
  test("copyFrom(:template, :withStatus[Open])", async () => {
    const result = await execute(schema, TestCopyFromDocument, {
      entity: TEMPLATE,
      options: {
        withStatus: "open",
      },
    });

    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();
  });
});
