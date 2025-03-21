import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { sql } from "@/datasources/postgres";
import { decodeGlobalId } from "@/schema/system";
import { Task } from "@/schema/system/component/task";
import { cleanup, findAndEncode } from "@/test/prelude";
import { map } from "@/util";
import { deleteNode } from "./node";

describe("node", () => {
  // See beforeAll for initialization of these variables.
  let CUSTOMER: string;
  let TEMPLATE: Task;

  test("delete", async () => {
    const result = await deleteNode(TEMPLATE.id);
    expect([TEMPLATE.id]).toEqual(result);
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
                  where workerfullname = 'Jerry Garcia'
              ),
              modified_by := 895
          )
      ;
    `;

    CUSTOMER = findAndEncode("customer", "organization", logs);
    TEMPLATE = map(
      findAndEncode("task", "worktemplate", logs),
      id => new Task({ id }),
    );
  });

  afterAll(async () => {
    const { id } = decodeGlobalId(CUSTOMER);
    await cleanup(id);
  });
});
