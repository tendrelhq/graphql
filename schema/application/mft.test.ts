import { afterAll, describe, expect, test } from "bun:test";
import { sql } from "@/datasources/postgres";
import { schema } from "@/schema/final";
import { encodeGlobalId } from "@/schema/system";
import { execute } from "@/test/prelude";
import dedent from "dedent";
import {
  TestMftEntrypointDocument,
  TestMftRefetchQueryDocument,
  TestMftTransitionMutationDocument,
} from "./mft.test.generated";

describe.skipIf(!!process.env.CI)("MFT", () => {
  test("entrypoint query", async () => {
    const result = await execute(schema, TestMftEntrypointDocument, {
      root: encodeGlobalId({
        type: "organization",
        id: "customer_83f6f643-132c-4255-ad9e-f3c37dc84885",
      }),
    });
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();
  });

  describe("refetch query", () => {
    test("with Location as node", async () => {
      const result = await execute(schema, TestMftRefetchQueryDocument, {
        node: encodeGlobalId({
          type: "location",
          id: "location_a8bcb43b-d11c-4d05-855c-5d6586c2da35",
        }),
      });
      expect(result.errors).toBeFalsy();
      expect(result.data).toMatchSnapshot();
    });

    test("with Task as node", async () => {
      const result = await execute(schema, TestMftRefetchQueryDocument, {
        node: encodeGlobalId({
          type: "worktemplate",
          id: "work-template_1bf31cd5-8fc2-47b1-a28f-e4bc5513e028",
        }),
      });
      expect(result.errors).toBeFalsy();
      expect(result.data).toMatchSnapshot();
    });
  });

  const FSM = encodeGlobalId({
    type: "worktemplate",
    id: "work-template_1bf31cd5-8fc2-47b1-a28f-e4bc5513e028",
  });

  describe("transition mutations", () => {
    test("from idle to active", async () => {
      const result = await execute(schema, TestMftTransitionMutationDocument, {
        fsm: FSM,
        task: encodeGlobalId({
          type: "worktemplate",
          id: "work-template_1bf31cd5-8fc2-47b1-a28f-e4bc5513e028",
        }),
      });
      expect(result.errors).toBeFalsy();
      expect(result.data).toMatchSnapshot();
    });

    test("between active states", async () => {
      const result = await execute(schema, TestMftTransitionMutationDocument, {
        fsm: FSM,
        task: encodeGlobalId({
          type: "worktemplate",
          id: "work-template_c2fddb7a-17f4-4b49-a744-8528d6ee44c4",
        }),
      });
      expect(result.errors).toBeFalsy();
      expect(result.data).toMatchSnapshot();
    });

    test("reverting an intermediate transition", async () => {
      // HACK: grab the "most recently in progress" workinstance.
      const [{ task }] = await sql`
        SELECT encode(('workinstance:' || id)::bytea, 'base64') AS task
        FROM public.workinstance
        WHERE
            workinstancecustomerid = 99
            AND workinstancestatusid = 707
        ORDER BY workinstanceid DESC
        LIMIT 1;
      `;

      const result = await execute(schema, TestMftTransitionMutationDocument, {
        fsm: FSM,
        task: task,
      });
      expect(result.errors).toBeFalsy();
      expect(result.data).toMatchSnapshot();
    });

    test("back to idle", async () => {
      // HACK: grab the "most recently in progress" workinstance.
      const [{ task }] = await sql`
        SELECT encode(('workinstance:' || id)::bytea, 'base64') AS task
        FROM public.workinstance
        WHERE
            workinstancecustomerid = 99
            AND workinstancestatusid = 707
        ORDER BY workinstanceid DESC
        LIMIT 1;
      `;

      const result = await execute(schema, TestMftTransitionMutationDocument, {
        fsm: FSM,
        task: task,
      });
      expect(result.errors).toBeFalsy();
      expect(result.data).toMatchSnapshot();
    });

    // HACK: ensure all open workinstances are closed out.
    afterAll(async () => {
      const rows = await sql`
        UPDATE public.workinstance
        SET workinstancestatusid = 710
        WHERE
            workinstancecustomerid = 99
            AND workinstancestatusid != 710
        RETURNING workinstanceid AS id;
      `;

      if (rows.count) {
        console.warn(
          dedent`
            ==========
            Test suite finished with ${rows.count} open instances lingering.
            This should be considered a BUG!

            Linguine instances:
              ${rows.map(r => `- ${r.id}`).join("\n")}
            ==========
          `,
        );
      }
    });
  });
});
