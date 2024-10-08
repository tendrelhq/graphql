import { describe, expect, test } from "bun:test";
import { resolvers, typeDefs } from "@/schema";
import { execute } from "@/test/prelude";
import { makeExecutableSchema } from "@graphql-tools/schema";
import { TestSetStatusDocument } from "./setStatus.test.generated";

const schema = makeExecutableSchema({ resolvers, typeDefs });

describe.skipIf(!!process.env.CI)("setStatus", () => {
  test("set open", async () => {
    const result = await execute(schema, TestSetStatusDocument, {
      entity:
        "d29ya2luc3RhbmNlOndvcmstaW5zdGFuY2VfMDA4NWE3Y2YtMmI5ZC00MDU2LTlhYzUtYTBiNTgxYTliNmZh",
      input: {
        open: {
          at: {
            instant: Date.now().toString(),
          },
        },
      },
    });
    expect(result).toMatchSnapshot();
  });

  test("invalid state change", async () => {
    const result = await execute(schema, TestSetStatusDocument, {
      entity:
        "d29ya3Jlc3VsdDp3b3JrLXJlc3VsdF9hYjE3N2IwMS0yNjA4LTQxOTgtYmI4Zi0yZjMzYTRhM2QzNTg=",
      input: {
        open: {
          at: {
            instant: Date.now().toString(),
          },
        },
      },
    });
    expect(result).toMatchSnapshot();
  });
});
