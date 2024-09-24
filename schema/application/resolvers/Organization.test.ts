import { describe, expect, test } from "bun:test";
import { resolvers, typeDefs } from "@/schema";
import { execute } from "@/test/prelude";
import { makeExecutableSchema } from "@graphql-tools/schema";
import { TestChecklistsForOrganizationDocument } from "./Organization.test.generated";

const schema = makeExecutableSchema({ resolvers, typeDefs });

process.env.X_TENDREL_USER = "user_2iADtxE5UonU4KO5lphsG59bkR9";

describe("Organization", () => {
  test.skipIf(!!process.env.CI)("checklists", async () => {
    const result = await execute(
      schema,
      TestChecklistsForOrganizationDocument,
      {
        nodeId:
          "b3JnYW5pemF0aW9uOmN1c3RvbWVyXzFiMmQ2YzYwLTg2NzgtNDVhZC1iMzBkLWExMDMyM2MyYzQ0MQ==",
        searchOptions: {
          active: true,
          status: ["open"],
        },
      },
    );
    expect(result).toMatchSnapshot();
  });
});
