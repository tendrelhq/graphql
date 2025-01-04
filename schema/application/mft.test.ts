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

  test("end run", async () => {
    const result = await execute(schema, TestMftTransitionMutationDocument, {
      opts: {
        fsm: FSM,
        task: {
          id: FSM,
        },
      },
    });
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();
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
    const row1 = logs.at(1 - 1);
    // but we can check the tag to be sure
    if (row1?.op?.trim() !== "+customer") {
      debugLogs();
      throw "setup failed to find customer";
    }
    CUSTOMER = encodeGlobalId({
      type: "organization",
      id: row1.id,
    });

    // grab the first instance from the 20th row
    const row20 = logs.at(20 - 1);
    // but we can check the tag to be sure
    if (row20?.op?.trim() !== "+instance") {
      debugLogs();
      throw "setup failed to find 'run' task";
    }
    FSM = encodeGlobalId({
      type: "workinstance",
      id: row20.id,
    });

    // we get 'Idle Time' in the 13th row
    const row13 = logs.at(13 - 1);
    // but we can check the tag to be sure
    if (row13?.op?.trim() !== "+task") {
      debugLogs();
      throw "setup failed to find 'idle time' task";
    }
    IDLE_TIME = encodeGlobalId({
      type: "worktemplate",
      id: row13.id,
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

    process.stdout.write("Cleaning up... ");
    const { id } = decodeGlobalId(CUSTOMER);
    const [row] = await sql<[{ ok: string }]>`
      select mft.destroy_demo(${id}) as ok;
    `;
    console.log(row.ok);
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

// describe.skipIf(true)("MFT", () => {
//   test("entrypoint query", async () => {
//     const result = await execute(schema, TestMftEntrypointDocument, {
//       root: encodeGlobalId({
//         type: "organization",
//         id: "customer_83f6f643-132c-4255-ad9e-f3c37dc84885",
//       }),
//     });
//     expect(result.errors).toBeFalsy();
//     expect(result.data).toMatchSnapshot();
//   });
//
//   test("history query", async () => {
//     const result = await execute(schema, TestMftEntrypointDocument, {
//       count: 10,
//       root: encodeGlobalId({
//         type: "organization",
//         id: "customer_83f6f643-132c-4255-ad9e-f3c37dc84885",
//       }),
//       impl: "Task",
//     });
//     expect(result.errors).toBeFalsy();
//     expect(result.data).toMatchSnapshot();
//   });
//
//   test("detail query", async () => {
//     const result = await execute(schema, TestMftDetailDocument, {
//       node: encodeGlobalId({
//         type: "workinstance",
//         id: "work-instance_2c4b1022-b46d-4c08-98ea-7167a2f2159e",
//       }),
//     });
//     expect(result.errors).toBeFalsy();
//     expect(result.data).toMatchSnapshot();
//   });
//
//   const FSM = encodeGlobalId({
//     type: "worktemplate",
//     id: "work-template_1bf31cd5-8fc2-47b1-a28f-e4bc5513e028",
//   });
//
//   describe("transition mutations", () => {
//     test("start production", async () => {
//       const result = await execute(schema, TestMftTransitionMutationDocument, {
//         opts: {
//           fsm: FSM,
//           task: {
//             id: encodeGlobalId({
//               type: "worktemplate",
//               id: "work-template_1bf31cd5-8fc2-47b1-a28f-e4bc5513e028",
//             }),
//           },
//         },
//       });
//       expect(result.errors).toBeFalsy();
//       expect(result.data).toMatchSnapshot();
//     });
//
//     test("production -> planned downtime", async () => {
//       const result = await execute(schema, TestMftTransitionMutationDocument, {
//         opts: {
//           fsm: FSM,
//           task: {
//             id: encodeGlobalId({
//               type: "worktemplate",
//               id: "work-template_c2fddb7a-17f4-4b49-a744-8528d6ee44c4",
//             }),
//           },
//         },
//       });
//       expect(result.errors).toBeFalsy();
//       expect(result.data).toMatchSnapshot();
//     });
//
//     test("end planned downtime -> in production", async () => {
//       const result = await execute(schema, TestMftTransitionMutationDocument, {
//         opts: {
//           fsm: FSM,
//           task: {
//             id: await mostRecentlyInProgress(""),
//           },
//         },
//       });
//       expect(result.errors).toBeFalsy();
//       expect(result.data).toMatchSnapshot();
//     });
//
//     test("start unplanned downtime", async () => {
//       const result = await execute(schema, TestMftTransitionMutationDocument, {
//         opts: {
//           fsm: FSM,
//           task: {
//             id: encodeGlobalId({
//               type: "worktemplate",
//               id: "work-template_0bd74deb-edcb-4c86-bfd7-404bce5013b6",
//             }),
//             overrides: [
//               {
//                 // 'Override Start Time'
//                 field: encodeGlobalId({
//                   type: "workresult",
//                   id: "work-result_2c316d44-74ea-457d-af07-f0863e552b1a",
//                 }),
//                 value: {
//                   // '5 minutes ago'
//                   timestamp: new Date(Date.now() - 5 * 60 * 1000).toISOString(),
//                 },
//               },
//               {
//                 // 'Comments'
//                 field: encodeGlobalId({
//                   type: "workresult",
//                   id: "work-result_8b5c1f2d-5553-4809-8c9c-66bd2b111def",
//                 }),
//                 value: {
//                   string:
//                     "The unplanned nature of this downtime event took us by surprise!",
//                 },
//               },
//             ],
//           },
//         },
//       });
//       expect(result.errors).toBeFalsy();
//       expect(result.data).toMatchSnapshot();
//     });
//
//     test("(invalid) start planned downtime", async () => {
//       const result = await execute(schema, TestMftTransitionMutationDocument, {
//         opts: {
//           fsm: FSM,
//           task: {
//             id: encodeGlobalId({
//               type: "worktemplate",
//               id: "work-template_c2fddb7a-17f4-4b49-a744-8528d6ee44c4",
//             }),
//           },
//         },
//       });
//       expect(result.data?.advance).toBeNull();
//       expect(result.errors).toMatchSnapshot();
//     });
//
//     test("end unplanned downtime -> in production", async () => {
//       const result = await execute(schema, TestMftTransitionMutationDocument, {
//         opts: {
//           fsm: FSM,
//           task: {
//             id: await mostRecentlyInProgress(""),
//             overrides: [
//               {
//                 // 'Override End Time'
//                 field: encodeGlobalId({
//                   type: "workresult",
//                   id: "work-result_76e8c5e0-0de5-4ea7-9c28-f480daed4825",
//                 }),
//                 value: {
//                   // '2 minutes ago'
//                   timestamp: new Date(Date.now() - 2 * 60 * 1000).toISOString(),
//                 },
//               },
//             ],
//           },
//         },
//       });
//       expect(result.errors).toBeFalsy();
//       expect(result.data).toMatchSnapshot();
//     });
//
//     // test("stop production -> idle", async () => {
//     //   const result = await execute(schema, TestMftTransitionMutationDocument, {
//     //     opts: {
//     //       fsm: FSM,
//     //       task: {
//     //         id: await mostRecentlyInProgress(),
//     //       },
//     //     },
//     //   });
//     //   expect(result.errors).toBeFalsy();
//     //   expect(result.data).toMatchSnapshot();
//     // });
//
//     // HACK: ensure all open workinstances are closed out.
//   //   afterAll(async () => {
//   //     const rows = await sql`
//   //       UPDATE public.workinstance
//   //       SET workinstancestatusid = 710
//   //       WHERE
//   //           workinstancecustomerid = 99
//   //           AND workinstancestatusid = 707
//   //       RETURNING workinstanceid AS id
//   //     `;
//   //
//   //     if (rows.count) {
//   //       console.warn(
//   //         dedent`
//   //           ==========
//   //           Test suite finished with ${rows.count} in progress instances lingering.
//   //           This should be considered a BUG!
//   //
//   //           Linguine instances:
//   //             ${rows.map(r => `- ${r.id}`).join("\n")}
//   //           ==========
//   //         `,
//   //       );
//   //     }
//   //   });
//   // });
// });

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
