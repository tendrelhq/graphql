import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { sql } from "@/datasources/postgres";
import { schema } from "@/schema/final";
import { decodeGlobalId, encodeGlobalId } from "@/schema/system";
import { NOW, execute } from "@/test/prelude";
import dedent from "dedent";
import {
  TestMftDetailDocument,
  TestMftEntrypointDocument,
  TestMftTransitionMutationDocument,
} from "./mft.test.generated";

/*
 * MFT todos.
 *
 * - [x] TaskState
 * - [x] Assignees
 * - [~] Time at Task (punted; can be calculated)
 * - [x] Transition payloads (overrides, notes, etc)
 * - [~] Matrix (first pass)
 * - [~] History (partial; can't filter)
 * - [~] Task detail (first pass)
 * - [x] Location time zone
 * - [ ] Task time zone?
 * - [ ] Better nomenclature re. differentiating template vs instance
 */

describe("MFT", () => {
  let CUSTOMER: string;
  let TEMPLATE: string;
  let IDLE_TIME: string;
  let DOWNTIME: string;

  beforeAll(async () => {
    const logs = await sql<{ op: string; id: string }[]>`
      select *
      from
          mft.create_demo(
              customer_name := 'Frozen Tendy Factory',
              admins := array[
                  'worker_d3ebf472-606c-4d26-9a19-d99f187e9c92',
                  'worker_a5d1d16f-4264-45e7-97c6-1ef534b8875f'
              ]
          )
      ;
    `;

    // we get customer uuid back in the first row
    const row1 = logs.at(0);
    // but we can check the tag to be sure
    if (row1?.op?.trim() !== "+customer") {
      console.warn(logs.join("\n"));
      throw "setup failed to find customer";
    }
    CUSTOMER = encodeGlobalId({
      type: "organization",
      id: row1.id,
    });

    // we get the top-level template in the fifth row
    const row5 = logs.at(4);
    // but we can check the tag to be sure
    if (row5?.op?.trim() !== "+task") {
      console.warn(logs.join("\n"));
      throw "setup failed to find 'run' task";
    }
    TEMPLATE = encodeGlobalId({
      type: "worktemplate",
      id: row5.id,
    });

    // we get 'idle time' in the 13th row
    const row13 = logs.at(12);
    // but we can check the tag to be sure
    if (row13?.op?.trim() !== "+task") {
      console.warn(logs.join("\n"));
      throw "setup failed to find 'idle time' task";
    }
    IDLE_TIME = encodeGlobalId({
      type: "worktemplate",
      id: row13.id,
    });
  });

  afterAll(async () => {
    process.stdout.write("Cleaning up... ");
    const { id } = decodeGlobalId(CUSTOMER);
    const [row] = await sql<[{ ok: string }]>`
      select mft.destroy_demo(${id}) as ok;
    `;
    console.log(row.ok);
  });

  test("entrypoint query", async () => {
    const result = await execute(schema, TestMftEntrypointDocument, {
      root: CUSTOMER,
    });
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();
  });

  describe("state machine", () => {
    test("start run", async () => {
      const result = await execute(schema, TestMftTransitionMutationDocument, {
        opts: {
          fsm: TEMPLATE,
          task: {
            id: TEMPLATE,
            overrides: [
              {
                field: await overrideStartTimeField(TEMPLATE),
                value: {
                  timestamp: NOW.toISOString(),
                },
              },
              {
                field: await getFieldByName(TEMPLATE, "Comments"),
                value: {
                  string:
                    "We got off to a late start, hence this comment and the overridden start time!",
                },
              },
            ],
          },
        },
      });
      expect(result.errors).toBeFalsy();
      expect(result.data).toMatchSnapshot();
    });

    test("production -> idle time", async () => {
      const result = await execute(schema, TestMftTransitionMutationDocument, {
        opts: {
          fsm: TEMPLATE,
          task: {
            id: IDLE_TIME,
          },
        },
      });
      expect(result.errors).toBeFalsy();
      expect(result.data).toMatchSnapshot();
    });

    test("end idle time", async () => {
      const result = await execute(schema, TestMftTransitionMutationDocument, {
        opts: {
          fsm: TEMPLATE,
          task: {
            id: await mostRecentlyInProgress(CUSTOMER),
            overrides: [
              {
                field: await getFieldByName(IDLE_TIME, "Description"),
                value: {
                  string: "We idled for awhile, twas a no wake zone...",
                },
              },
            ],
          },
        },
      });
      expect(result.errors).toBeFalsy();
      expect(result.data).toMatchSnapshot();
    });

    test("detail query", async () => {
      const result = await execute(schema, TestMftDetailDocument, {
        node: await mostRecentlyInProgress(CUSTOMER),
      });
      expect(result.errors).toBeFalsy();
      expect(result.data).toMatchObject({
        node: {
          chainAgg: [
            {
              group: "Idle Time",
              value: expect.stringMatching(/[\d]+.[\d]+/),
              __typename: "Aggregate",
            },
            {
              group: "Runtime",
              value: null,
              __typename: "Aggregate",
            },
          ],
          chain: {
            edges: [
              {
                node: {
                  displayName: {
                    name: {
                      value: "Run",
                      __typename: "DynamicString",
                    },
                    __typename: "DisplayName",
                  },
                  state: {
                    __typename: "InProgress",
                  },
                  __typename: "Task",
                },
                __typename: "TaskEdge",
              },
              {
                node: {
                  displayName: {
                    name: {
                      value: "Idle Time",
                      __typename: "DynamicString",
                    },
                    __typename: "DisplayName",
                  },
                  state: {
                    __typename: "Closed",
                  },
                  __typename: "Task",
                },
                __typename: "TaskEdge",
              },
            ],
            totalCount: 2,
            __typename: "TaskConnection",
          },
          __typename: "Task",
        },
      });
    });

    test("end run", async () => {
      const result = await execute(schema, TestMftTransitionMutationDocument, {
        opts: {
          fsm: TEMPLATE,
          task: {
            id: await mostRecentlyInProgress(CUSTOMER),
          },
        },
      });
      expect(result.errors).toBeFalsy();
      expect(result.data).toMatchSnapshot();
    });

    // HACK: ensure all open workinstances are closed out.
    afterAll(async () => {
      const rows = await sql`
        update public.workinstance
        set workinstancestatusid = 710
        where
            workinstancecustomerid in (
                select customerid
                from public.customer
                where customeruuid = ${decodeGlobalId(CUSTOMER).id}
            )
            and workinstancestatusid != 710
        returning workinstanceid as id;
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

//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//

describe.skipIf(true)("MFT", () => {
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

  test("history query", async () => {
    const result = await execute(schema, TestMftEntrypointDocument, {
      count: 10,
      root: encodeGlobalId({
        type: "organization",
        id: "customer_83f6f643-132c-4255-ad9e-f3c37dc84885",
      }),
      impl: "Task",
    });
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();
  });

  test("detail query", async () => {
    const result = await execute(schema, TestMftDetailDocument, {
      node: encodeGlobalId({
        type: "workinstance",
        id: "work-instance_2c4b1022-b46d-4c08-98ea-7167a2f2159e",
      }),
    });
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();
  });

  const FSM = encodeGlobalId({
    type: "worktemplate",
    id: "work-template_1bf31cd5-8fc2-47b1-a28f-e4bc5513e028",
  });

  describe("transition mutations", () => {
    test("start production", async () => {
      const result = await execute(schema, TestMftTransitionMutationDocument, {
        opts: {
          fsm: FSM,
          task: {
            id: encodeGlobalId({
              type: "worktemplate",
              id: "work-template_1bf31cd5-8fc2-47b1-a28f-e4bc5513e028",
            }),
          },
        },
      });
      expect(result.errors).toBeFalsy();
      expect(result.data).toMatchSnapshot();
    });

    test("production -> planned downtime", async () => {
      const result = await execute(schema, TestMftTransitionMutationDocument, {
        opts: {
          fsm: FSM,
          task: {
            id: encodeGlobalId({
              type: "worktemplate",
              id: "work-template_c2fddb7a-17f4-4b49-a744-8528d6ee44c4",
            }),
          },
        },
      });
      expect(result.errors).toBeFalsy();
      expect(result.data).toMatchSnapshot();
    });

    test("end planned downtime -> in production", async () => {
      const result = await execute(schema, TestMftTransitionMutationDocument, {
        opts: {
          fsm: FSM,
          task: {
            id: await mostRecentlyInProgress(""),
          },
        },
      });
      expect(result.errors).toBeFalsy();
      expect(result.data).toMatchSnapshot();
    });

    test("start unplanned downtime", async () => {
      const result = await execute(schema, TestMftTransitionMutationDocument, {
        opts: {
          fsm: FSM,
          task: {
            id: encodeGlobalId({
              type: "worktemplate",
              id: "work-template_0bd74deb-edcb-4c86-bfd7-404bce5013b6",
            }),
            overrides: [
              {
                // 'Override Start Time'
                field: encodeGlobalId({
                  type: "workresult",
                  id: "work-result_2c316d44-74ea-457d-af07-f0863e552b1a",
                }),
                value: {
                  // '5 minutes ago'
                  timestamp: new Date(Date.now() - 5 * 60 * 1000).toISOString(),
                },
              },
              {
                // 'Comments'
                field: encodeGlobalId({
                  type: "workresult",
                  id: "work-result_8b5c1f2d-5553-4809-8c9c-66bd2b111def",
                }),
                value: {
                  string:
                    "The unplanned nature of this downtime event took us by surprise!",
                },
              },
            ],
          },
        },
      });
      expect(result.errors).toBeFalsy();
      expect(result.data).toMatchSnapshot();
    });

    test("(invalid) start planned downtime", async () => {
      const result = await execute(schema, TestMftTransitionMutationDocument, {
        opts: {
          fsm: FSM,
          task: {
            id: encodeGlobalId({
              type: "worktemplate",
              id: "work-template_c2fddb7a-17f4-4b49-a744-8528d6ee44c4",
            }),
          },
        },
      });
      expect(result.data?.advance).toBeNull();
      expect(result.errors).toMatchSnapshot();
    });

    test("end unplanned downtime -> in production", async () => {
      const result = await execute(schema, TestMftTransitionMutationDocument, {
        opts: {
          fsm: FSM,
          task: {
            id: await mostRecentlyInProgress(""),
            overrides: [
              {
                // 'Override End Time'
                field: encodeGlobalId({
                  type: "workresult",
                  id: "work-result_76e8c5e0-0de5-4ea7-9c28-f480daed4825",
                }),
                value: {
                  // '2 minutes ago'
                  timestamp: new Date(Date.now() - 2 * 60 * 1000).toISOString(),
                },
              },
            ],
          },
        },
      });
      expect(result.errors).toBeFalsy();
      expect(result.data).toMatchSnapshot();
    });

    // test("stop production -> idle", async () => {
    //   const result = await execute(schema, TestMftTransitionMutationDocument, {
    //     opts: {
    //       fsm: FSM,
    //       task: {
    //         id: await mostRecentlyInProgress(),
    //       },
    //     },
    //   });
    //   expect(result.errors).toBeFalsy();
    //   expect(result.data).toMatchSnapshot();
    // });

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

/**
 * HACK! Grabs the "most recently in progress" workinstance for this test suite.
 * Temporary utility function while we are in the implementation phase of MFT.
 */
async function mostRecentlyInProgress(customerId: string): Promise<string> {
  const [{ id }] = await sql`
    select encode(('workinstance:' || id)::bytea, 'base64') as id
    from public.workinstance
    where
        workinstancecustomerid in (
            select customerid
            from public.customer
            where customeruuid = ${decodeGlobalId(customerId).id}
        )
        and workinstancestatusid = 707
    order by workinstanceid DESC
    limit 1;
  `;
  return id;
}

/**
 * HACK! Grabs the "Override State Time" field (i.e. workresult) for the given
 * work template.
 */
async function overrideStartTimeField(templateId: string): Promise<string> {
  const [{ id }] = await sql`
    select encode(('workresult:' || wr.id)::bytea, 'base64') as id
    from public.workresult as wr
    where
        wr.workresultorder = 0
        and wr.workresultisprimary = true
        and wr.workresulttypeid in (
            select s.systagid
            from public.systag as s
            where s.systagparentid = 699 and s.systagtype = 'Date'
        )
        and wr.workresultworktemplateid in (
            select wt.worktemplateid
            from public.worktemplate as wt
            where wt.id = ${decodeGlobalId(templateId).id}
        )
  `;

  return id;
}

async function getFieldByName(
  templateId: string,
  name: string,
): Promise<string> {
  const [{ id }] = await sql`
    select encode(('workresult:' || wr.id)::bytea, 'base64') as id
    from public.workresult as wr
    inner join public.languagemaster as lm
        on wr.workresultlanguagemasterid = lm.languagemasterid
    where
        lm.languagemastersource = ${name}
        and wr.workresultisprimary = false
        and wr.workresultworktemplateid in (
            select wt.worktemplateid
            from public.worktemplate as wt
            where wt.id = ${decodeGlobalId(templateId).id}
        )
  `;

  return id;
}

async function getTemplateByTypeTag(
  customerId: string,
  typeTag: string,
): Promise<string> {
  const [{ id }] = await sql`
    select encode(('worktemplate:' || wt.id)::bytea, 'base64') as id
    from public.worktemplate as wt
    inner join public.worktemplatetype as wtt
        on wt.worktemplateid = wtt.worktemplatetypeworktemplateid
    where
        wt.worktemplatecustomerid in (
            select customerid
            from public.customer
            where customeruuid = ${customerId}
        )
        and wtt.worktemplatetypesystagid in (
            select systagid
            from public.systag
            where systagtype = ${typeTag}
        )
  `;

  return id;
}
