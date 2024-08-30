import { describe, expect, test } from "bun:test";
import { resolvers, typeDefs } from "@/schema";
import { execute } from "@/test/prelude";
import { makeExecutableSchema } from "@graphql-tools/schema";
import { TestLanguagesQueryDocument } from "./languages.test.generated";

const schema = makeExecutableSchema({ resolvers, typeDefs });

describe("languages", () => {
  test("works", async () => {
    const result = await execute(schema, TestLanguagesQueryDocument);
    expect(result).toMatchSnapshot();
  });
});
