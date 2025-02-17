import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { sql } from "@/datasources/postgres";
import { schema } from "@/schema/final";
import { decodeGlobalId, encodeGlobalId } from "@/schema/system";
import { Task } from "@/schema/system/component/task";
import {
  createTestContext,
  execute,
  findAndEncode,
  getFieldByName,
} from "@/test/prelude";
import { assertNonNull, map } from "@/util";
import { TestSetValueDocument } from "./setValue.test.generated";

const ctx = await createTestContext();

describe("setValue", () => {
  let CUSTOMER: string;
  let TASK: Task;

  test("set", async () => {
    const field = await getFieldByName(TASK, "Run Output");
    const result = await execute(schema, TestSetValueDocument, {
      parent: TASK.id,
      entity: field,
      input: {
        number: {
          value: 42,
        },
      },
    });

    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();
  });

  test("set: dynamic content", async () => {
    const field = await getFieldByName(TASK, "Comments");
    const result = await execute(schema, TestSetValueDocument, {
      parent: TASK.id,
      entity: field,
      input: {
        string: {
          value: "Hello world",
        },
      },
    });

    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();

    // TODO: move to prelude
    const { id, suffix } = decodeGlobalId(field);
    const [row] = await sql`
      select
          languagemastersource as content,
          languagemastersourcelanguagetypeid as language
      from public.workresultinstance
      inner join
          public.languagemaster
          on workresultinstancevaluelanguagemasterid = languagemasterid
      where
          workresultinstanceworkinstanceid = (
              select workinstanceid
              from public.workinstance
              where id = ${id}
          )
          and workresultinstanceworkresultid = (
              select workresultid
              from public.workresult
              where id = ${assertNonNull(suffix?.at(0))}
          )
    `;
    expect(row).toEqual({
      content: "Hello world",
      language: 20n,
    });
  });

  test("entity is not mutable", async () => {
    const result = await execute(schema, TestSetValueDocument, {
      parent: TASK.id,
      entity: encodeGlobalId({
        type: "foo",
        id: "foo",
      }),
      input: {
        string: {
          value: "hello world",
        },
      },
    });
    expect(result).toMatchSnapshot();
  });

  test("global id invariant", async () => {
    const result = await execute(schema, TestSetValueDocument, {
      parent: TASK.id,
      entity: encodeGlobalId({
        type: "workresultinstance",
        id: "foo",
      }),
      input: {
        string: {
          value: "hello world",
        },
      },
    });
    expect(result).toMatchSnapshot();
  });

  beforeAll(async () => {
    const logs = await sql<{ op: string; id: string }[]>`
      select *
      from
          runtime.create_demo(
              customer_name := 'Frozen Tendy Factory',
              admins := (
                  select array_agg(workeruuid)
                  from public.worker
                  where workeridentityid = ${ctx.auth.userId}
              ),
              modified_by := 895
          )
      ;
    `;
    CUSTOMER = findAndEncode("customer", "organization", logs);
    TASK = map(
      findAndEncode("instance", "workinstance", logs),
      id => new Task({ id }, ctx),
    );
    console.log(TASK._type, TASK._id);
  });

  afterAll(async () => {
    const { id } = decodeGlobalId(CUSTOMER);
    process.stdout.write("Cleaning up... ");
    const [row] = await sql<[{ ok: string }]>`
      select runtime.destroy_demo(${id}) as ok;
    `;
    console.log(row.ok);
  });
});
