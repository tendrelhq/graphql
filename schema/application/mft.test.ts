import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { sql } from "@/datasources/postgres";
import { schema } from "@/schema/final";
import { decodeGlobalId, encodeGlobalId } from "@/schema/system";
import { NOW, execute } from "@/test/prelude";
import { assert, nullish } from "@/util";
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
  // See beforeAll for initialization of these variables.
  let CUSTOMER: string;
  let FSM: string; // instance
  let IDLE_TIME: string; // template
  let DOWNTIME: string; // template

  test("entrypoint query", async () => {
    const result = await execute(schema, TestMftEntrypointDocument, {
      root: CUSTOMER,
    });
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();
  });

  test("start run", async () => {
    const result = await execute(schema, TestMftTransitionMutationDocument, {
      includeChain: false,
      opts: {
        fsm: FSM,
        task: {
          id: FSM,
          overrides: [
            {
              field: await overrideStartTimeField(FSM),
              value: {
                timestamp: NOW.toISOString(),
              },
            },
            {
              field: await getFieldByName(FSM, "Comments"),
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
      includeChain: false,
      opts: {
        fsm: FSM,
        task: {
          id: IDLE_TIME,
        },
      },
    });
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();
  });

  test("end idle time", async () => {
    const t = await mostRecentlyInProgress(FSM);
    const result = await execute(schema, TestMftTransitionMutationDocument, {
      includeChain: false,
      opts: {
        fsm: FSM,
        task: {
          id: t,
          overrides: [
            {
              field: await getFieldByName(t, "Description"),
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
      node: await mostRecentlyInProgress(FSM),
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

  test("production -> downtime", async () => {
    const result = await execute(schema, TestMftTransitionMutationDocument, {
      includeChain: false,
      opts: {
        fsm: FSM,
        task: {
          id: DOWNTIME,
        },
      },
    });
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();
  });

  test("end downtime", async () => {
    const t = await mostRecentlyInProgress(FSM);
    const result = await execute(schema, TestMftTransitionMutationDocument, {
      includeChain: false,
      opts: {
        fsm: FSM,
        task: {
          id: t,
        },
      },
    });
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();
  });

  test("another idle run", async () => {
    const start = await execute(schema, TestMftTransitionMutationDocument, {
      includeChain: false,
      opts: {
        fsm: FSM,
        task: {
          id: IDLE_TIME,
        },
      },
    });
    expect(start.errors).toBeFalsy();

    const end = await execute(schema, TestMftTransitionMutationDocument, {
      includeChain: false,
      opts: {
        fsm: FSM,
        task: {
          id: await mostRecentlyInProgress(FSM),
        },
      },
    });
    expect(end.errors).toBeFalsy();

    const result = await execute(schema, TestMftDetailDocument, {
      node: await mostRecentlyInProgress(FSM),
    });
    expect(result.errors).toBeFalsy();
  });

  test("end run", async () => {
    const result = await execute(schema, TestMftTransitionMutationDocument, {
      includeChain: true,
      opts: {
        fsm: FSM,
        task: {
          id: FSM,
        },
      },
    });
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();

    // const result2 = await execute(schema, TestMftDetailDocument, {
    //   node: FSM,
    // });
    // expect(result2.errors).toBeFalsy();
    // expect(result2.data).toMatchSnapshot();
  });

  beforeAll(async () => {
    process.env.X_TENDREL_USER = "user_2iADtxE5UonU4KO5lphsG59bkR9";

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

    function debugLogs() {
      let i = 0;
      for (const l of logs) {
        console.log(`${i++}: ${JSON.stringify(l)}`);
      }
    }

    // we get customer uuid back in the first row
    const row1 = logs.at(0);
    // but we can check the tag to be sure
    if (row1?.op?.trim() !== "+customer") {
      debugLogs();
      throw "setup failed to find customer";
    }
    CUSTOMER = encodeGlobalId({
      type: "organization",
      id: row1.id,
    });

    // grab the first instance from the 26th row
    const row25 = logs.at(25);
    // but we can check the tag to be sure
    if (row25?.op?.trim() !== "+instance") {
      debugLogs();
      throw "setup failed to find 'Run' task instance";
    }
    FSM = encodeGlobalId({
      type: "workinstance",
      id: row25.id,
    });

    // we get 'Idle Time' in the 14th row
    const row13 = logs.at(13);
    // but we can check the tag to be sure
    if (row13?.op?.trim() !== "+task") {
      debugLogs();
      throw "setup failed to find 'Idle Time' task template";
    }
    IDLE_TIME = encodeGlobalId({
      type: "worktemplate",
      id: row13.id,
    });

    // we get 'Downtime' in the 19th row
    const row18 = logs.at(18);
    // but we can check the tag to be sure
    if (row18?.op?.trim() !== "+task") {
      debugLogs();
      throw "setup failed to find 'Downtime' task template";
    }
    DOWNTIME = encodeGlobalId({
      type: "worktemplate",
      id: row18.id,
    });
  });

  afterAll(async () => {
    process.env.X_TENDREL_USER = undefined;

    const rows = await sql`
      update public.workinstance
      set workinstancestatusid = 710
      where
          workinstancecustomerid in (
              select customerid
              from public.customer
              where customeruuid = ${decodeGlobalId(CUSTOMER).id}
          )
          and workinstancestatusid = 707
      returning id
      ;
    `;

    if (rows.count) {
      console.warn(
        `
==========
Test suite finished with ${rows.count} in progress instances lingering.
This should be considered a BUG!

Linguine instances:
${rows.map(r => ` - ${r.id}`).join("\n")}
==========
        `,
      );
    }

    const { id } = decodeGlobalId(CUSTOMER);
    // useful for debugging tests:
    if (process.env.SKIP_MFT_CLEANUP) {
      console.log(
        "Skipping clean up... don't forget to cleanup after yourself!",
      );
      console.debug(`select mft.destroy_demo(${id})`);
      return;
    }

    process.stdout.write("Cleaning up... ");
    const [row] = await sql<[{ ok: string }]>`
      select mft.destroy_demo(${id}) as ok;
    `;
    console.log(row.ok);
  });
});

/**
 * HACK! Grabs the "most recently in progress" workinstance for this test suite.
 * Temporary utility function while we are in the implementation phase of MFT.
 */
async function mostRecentlyInProgress(instanceId: string): Promise<string> {
  const [row] = await sql`
    select encode(('workinstance:' || id)::bytea, 'base64') as id
    from public.workinstance
    where
        workinstanceoriginatorworkinstanceid in (
            select og.workinstanceid
            from public.workinstance as og
            where og.id = ${decodeGlobalId(instanceId).id}
        )
        and workinstancestatusid = 707
    order by workinstanceid DESC
    limit 1;
  `;
  assert(nullish(row) === false, "no in progress instance");
  return row.id;
}

/**
 * HACK! Grabs the "Override State Time" field (i.e. workresult) for the given
 * work instance.
 */
async function overrideStartTimeField(instanceId: string): Promise<string> {
  const [row] = await sql`
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
            select wi.workinstanceworktemplateid
            from public.workinstance as wi
            where wi.id = ${decodeGlobalId(instanceId).id}
        )
  `;
  assert(nullish(row) === false, "no override start time field");
  return row.id;
}

async function getFieldByName(
  instanceId: string,
  name: string,
): Promise<string> {
  const [row] = await sql`
    select encode(('workresult:' || wr.id)::bytea, 'base64') as id
    from public.workresult as wr
    inner join public.languagemaster as lm
        on wr.workresultlanguagemasterid = lm.languagemasterid
    where
        lm.languagemastersource = ${name}
        and wr.workresultisprimary = false
        and wr.workresultworktemplateid in (
            select wi.workinstanceworktemplateid
            from public.workinstance as wi
            where wi.id = ${decodeGlobalId(instanceId).id}
        )
  `;
  assert(nullish(row) === false, `no named field '${name}'`);
  return row.id;
}

// async function getTemplateByTypeTag(
//   customerId: string,
//   typeTag: string,
// ): Promise<string> {
//   const [{ id }] = await sql`
//     select encode(('worktemplate:' || wt.id)::bytea, 'base64') as id
//     from public.worktemplate as wt
//     inner join public.worktemplatetype as wtt
//         on wt.worktemplateid = wtt.worktemplatetypeworktemplateid
//     where
//         wt.worktemplatecustomerid in (
//             select customerid
//             from public.customer
//             where customeruuid = ${customerId}
//         )
//         and wtt.worktemplatetypesystagid in (
//             select systagid
//             from public.systag
//             where systagtype = ${typeTag}
//         )
//   `;
//
//   return id;
// }
