import { describe, expect, test } from "bun:test";
import { resolvers, typeDefs } from "@/schema";
import { execute } from "@/test/prelude";
import { makeExecutableSchema } from "@graphql-tools/schema";
import { TestSetValueDocument } from "./setValue.test.generated";

const schema = makeExecutableSchema({ resolvers, typeDefs });

describe.skipIf(!!process.env.CI)("setValue", () => {
  test("lazy instantiation", async () => {
    const result = await execute(schema, TestSetValueDocument, {
      parent:
        "d29ya2luc3RhbmNlOndvcmstaW5zdGFuY2VfZDZjNTljM2EtOWQ1MS00MDc0LTllNjItZTkzZTgxOWIxZWFh",
      entity:
        "d29ya3Jlc3VsdDp3b3JrLXJlc3VsdF9mODc1OWM3Ny01OGMwLTRlY2YtYjNjMC02Y2Y3NmM0ZTIyYjQ=",
      input: {
        number: {
          value: 42,
        },
      },
    });
    expect(result).toMatchSnapshot();
  });

  test("invalid type", async () => {
    const result = await execute(schema, TestSetValueDocument, {
      parent:
        "d29ya3RlbXBsYXRlOndvcmstdGVtcGxhdGVfNzdhNTU1NjctNmIyYi00NTA2LTlkMmItZjM3NWUwYzI5ZTNm",
      entity:
        "d29ya3Jlc3VsdDp3b3JrLXJlc3VsdF9hYjE3N2IwMS0yNjA4LTQxOTgtYmI4Zi0yZjMzYTRhM2QzNTg=",
      input: {
        string: {
          value: "hello world",
        },
      },
    });
    expect(result).toMatchSnapshot();
  });
});
