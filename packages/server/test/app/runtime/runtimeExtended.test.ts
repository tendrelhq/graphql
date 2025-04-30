import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { schema } from "@/schema/final";
import { Location } from "@/schema/platform/archetype/location";
import { Task } from "@/schema/system/component/task";
import { TestCreateTemplateConstraintDocument } from "@/schema/system/engine0/createTemplateConstraint.test.generated";
import {
  cleanup,
  createTestContext,
  execute,
  findAndEncode,
  setup,
  testGlobalId,
} from "@/test/prelude";
import { assertNonNull, map } from "@/util";
import { TestRuntimeEntrypointDocument } from "./runtime.test.generated";
import { TestRuntimeExtendedCreateLocationDocument } from "./runtimeExtended.test.generated";

const ctx = await createTestContext();

describe("extended runtime demo", () => {
  // See beforeAll for initialization of these variables.
  let CUSTOMER: string;
  let SITE: Location;
  let TEMPLATE: Task; // fsm
  let LOCATION: Location; // created in the first test

  test("create a new location", async () => {
    const result = await execute(
      schema,
      TestRuntimeExtendedCreateLocationDocument,
      {
        input: {
          category: "Runtime Location", // TODO: provide a mechanism to look this up
          name: "Super Fast Assembly Line",
          parent: SITE.id,
          timeZone: "America/Denver",
        },
      },
    );
    expect(result.errors).toBeFalsy();

    LOCATION = new Location({
      id: assertNonNull(result.data?.createLocation?.id),
    });
  });

  test.skip("should be okay without a constraint/instance", async () => {
    const result = await execute(schema, TestRuntimeEntrypointDocument, {
      parent: CUSTOMER,
    });
    expect(result.errors).toBeFalsy();
    const t = result.data?.trackables?.edges?.find(
      e =>
        e.node?.__typename === "Location" &&
        e.node.name.value === "Super Fast Assembly Line",
    );
    expect(t?.node?.tracking?.edges).toHaveLength(0);
  });

  test.skip("create a template constraint and instantiate", async () => {
    const result = await execute(schema, TestCreateTemplateConstraintDocument, {
      template: TEMPLATE.id,
      location: LOCATION.id,
      options: {
        instantiate: {},
      },
    });
    expect(result.errors).toBeFalsy();
  });

  test(
    "it should show up in the app",
    async () => {
      const result = await execute(schema, TestRuntimeEntrypointDocument, {
        parent: CUSTOMER,
      });
      expect(result.errors).toBeFalsy();
      const t = result.data?.trackables?.edges?.find(
        e =>
          e.node?.__typename === "Location" &&
          e.node.name.value === "Super Fast Assembly Line",
      );
      expect(t).toMatchSnapshot();
    },
    {
      timeout: 10_000,
    },
  );

  describe.skip("diagnostics", () => {
    test("invalid_type -> template", async () => {
      const result = await execute(
        schema,
        TestCreateTemplateConstraintDocument,
        {
          template: testGlobalId(),
          location: SITE.id,
        },
      );
      expect(result).toMatchSnapshot();
    });

    test("invalid_type -> entity", async () => {
      const result = await execute(
        schema,
        TestCreateTemplateConstraintDocument,
        {
          template: TEMPLATE.id,
          location: testGlobalId(),
        },
      );
      expect(result).toMatchSnapshot();
    });
  });

  beforeAll(async () => {
    const logs = await setup(ctx);
    CUSTOMER = findAndEncode("customer", "organization", logs);
    SITE = map(
      findAndEncode("site", "location", logs),
      id => new Location({ id }),
    );
    TEMPLATE = map(
      findAndEncode("task", "worktemplate", logs),
      id => new Task({ id }),
    );
  });

  afterAll(async () => {
    await cleanup(CUSTOMER);
  });
});
