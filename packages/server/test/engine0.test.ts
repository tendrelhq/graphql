import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { sql } from "@/datasources/postgres";
import { decodeGlobalId } from "@/schema/system";
import { Task } from "@/schema/system/component/task";
import { map } from "@/util";
import {
  assertTaskIsNamed,
  cleanup,
  createTestContext,
  findAndEncode,
  getFieldByName,
  setup,
} from "./prelude";

const ctx = await createTestContext();

describe("engine0", () => {
  let CUSTOMER: string;
  let INSTANCE: Task;
  let TEMPLATE: Task;
  let NEXT_TEMPLATE: Task;

  test("build", async () => {
    const result = await sql`
      select node, target, target_type, row_to_json(t.*) as condition
      from
          engine0.build_instantiation_plan_v2(${INSTANCE._id}) as p,
          unnest(p.ops) as t
    `;
    // IMPORTANT! This is the build phase and so what we get back is the
    // *entire* plan. The check phase actually evaluates the conditions.
    expect(result).toBeArrayOfSize(3);
    // expect(result).toMatchSnapshot();
  });

  test("build + check", async () => {
    const r0 = await sql`
      select p1.*
      from
          engine0.build_instantiation_plan_v2(${INSTANCE._id}) as p0,
          engine0.evaluate_instantiation_plan(
              target := p0.node,
              target_type := p0.target_type,
              conditions := p0.ops
          ) as p1
    `;
    // The instance in question is currently Open. The default rules created as
    // part of the MFT demo consist of only InProgress state conditions.
    expect(r0).toHaveLength(0);

    // Set the instance to InProgress.
    await sql`
      update public.workinstance
      set workinstancestatusid = 707
      where id = ${INSTANCE._id}
    `;
    //
    const r1 = await sql`
      select p1.*
      from
          engine0.build_instantiation_plan_v2(${INSTANCE._id}) as p0,
          engine0.evaluate_instantiation_plan(
              target := p0.node,
              target_type := p0.target_type,
              conditions := p0.ops
          ) as p1
    `;
    // Now that the instance is InProgress, we expect our plan to include the
    // two default rules included in the MFT demo (Idle, Downtime) as well as
    // the canonical respawn rule.
    expect(r1).toMatchObject([
      {
        result: true,
        system: "engine0.eval_state_condition",
      },
      {
        result: true,
        system: "engine0.eval_state_condition",
      },
      {
        result: true,
        system: "engine0.eval_state_condition",
      },
    ]);
  });

  test("build + check + execute", async () => {
    await sql.begin(async tx => {
      const result =
        await tx`select * from engine0.execute(${INSTANCE._id}, 895)`;
      // We expect only the respawn rule to result in instantiation.
      expect(result).toHaveLength(1);
      expect(result.some(row => !row.instance)).toBeFalse();
    });
  });

  test("with field-level rules", async () => {
    // Let's create an instantiation rule that will trigger on Close and only
    // when the 'Run Output' field is greater than 0.
    const [{ prev, next }] = await sql`
      select *
      from legacy0.create_instantiation_rule(
          prev_template_id := ${TEMPLATE._id},
          next_template_id := ${NEXT_TEMPLATE._id},
          state_condition := 'Complete',
          type_tag := 'Audit',
          modified_by := 895
      );
    `;
    // Although currently we don't have a way to specify result-level
    // conditions, so we must manually fixup the new rule.
    const f = await getFieldByName(TEMPLATE, "Run Output");
    await sql`
      update public.worktemplatenexttemplate
      set worktemplatenexttemplateviaworkresultid = (
              select workresultid
              from public.workresult
              where id = ${decodeGlobalId(f.id).id}
          ),
          worktemplatenexttemplateviaworkresultvalue = '0',
          worktemplatenexttemplateviaworkresultcontstraintid = (
              select systagid
              from public.systag
              where systagparentid = 749 and systagtype = '>'
          )
      where
          worktemplatenexttemplatenexttemplateid = (
              select worktemplateid
              from public.worktemplate
              where id = ${next}
          )
          and worktemplatenexttemplateprevioustemplateid = (
              select worktemplateid
              from public.worktemplate
              where id = ${prev}
          )
          and worktemplatenexttemplateviastatuschangeid = (
              select systagid
              from public.systag
              where systagparentid = 705 and systagtype = 'Complete'
          )
    `;

    {
      const r = await sql`
        select pc.*
        from
            engine0.build_instantiation_plan(${INSTANCE._id}) as pb,
            engine0.evaluate_instantiation_plan(
                target := pb.target,
                target_type := pb.target_type,
                conditions := pb.ops
            ) as pc
        order by pc.system
      `;
      // Same as the previous test. We expect no difference.
      expect(r).toMatchObject([
        {
          result: true,
          system: "engine0.eval_state_condition",
        },
        {
          result: true,
          system: "engine0.eval_state_condition",
        },
        {
          result: true,
          system: "engine0.eval_state_condition",
        },
      ]);
    }

    // Close the instance which brings it into the correct state.
    await sql`
      update public.workinstance
      set workinstancestatusid = 710
      where id = ${INSTANCE._id}
    `;

    {
      const r = await sql`
        select pc.*
        from
            engine0.build_instantiation_plan(${INSTANCE._id}) as pb,
            engine0.evaluate_instantiation_plan(
                target := pb.target,
                target_type := pb.target_type,
                conditions := pb.ops
            ) as pc
        order by pc.system
      `;
      // but we have yet to set the field's value and therefore the rule will
      // not be evaluated:
      expect(r).toHaveLength(0);
    }

    // Let's set the field's value to 0.
    {
      const r0 = await sql`
        update public.workresultinstance
        set workresultinstancevalue = '0'
        where
            workresultinstanceworkinstanceid = (
                select workinstanceid
                from public.workinstance
                where id = ${INSTANCE._id}
            )
            and workresultinstanceworkresultid = (
                select workresultid
                from public.workresult
                where id = ${decodeGlobalId(f.id).id}
            )
      `;
      expect(r0.count).toBe(1);

      // Still not evaluated since the result condition doesn't hold.
      const r1 = await sql`
        select pc.*
        from
            engine0.build_instantiation_plan(${INSTANCE._id}) as pb,
            engine0.evaluate_instantiation_plan(
                target := pb.target,
                target_type := pb.target_type,
                conditions := pb.ops
            ) as pc
        order by pc.system
      `;
      expect(r1).toHaveLength(0);
    }

    // Finally let's set our field such that our rule should trigger
    // instantiation.
    {
      const r0 = await sql`
        update public.workresultinstance
        set workresultinstancevalue = '1' -- rule: >0
        where
            workresultinstanceworkinstanceid = (
                select workinstanceid
                from public.workinstance
                where id = ${INSTANCE._id}
            )
            and workresultinstanceworkresultid = (
                select workresultid
                from public.workresult
                where id = ${decodeGlobalId(f.id).id}
            )
      `;
      expect(r0.count).toBe(1);

      // Same as the last test: evaluates to false.
      const r1 = await sql`
        select pc.*
        from
            engine0.build_instantiation_plan(${INSTANCE._id}) as pb,
            engine0.evaluate_instantiation_plan(
                target := pb.target,
                target_type := pb.target_type,
                conditions := pb.ops
            ) as pc
        order by pc.system
      `;
      expect(r1).toMatchObject([
        {
          result: true,
          system: "engine0.eval_field_and_state_condition",
        },
      ]);
    }

    await sql.begin(async sql => {
      const result =
        await sql`select * from engine0.execute(${INSTANCE._id}, 895)`;
      // To confirm, we should get a single instantiation back from the engine:
      expect(result).toHaveLength(1);
      const t = Task.fromTypeId("workinstance", result[0].instance);
      // and of course it should be the *right* instantiation:
      assertTaskIsNamed(t, "Idle Time", ctx);
      const [{ systagtype }] = await sql`
        select systagtype
        from public.workinstance
        inner join public.systag on workinstancetypeid = systagid
        where id = ${t._id}
      `;
      // and to be extra certain there is no fuckery afoot:
      expect(systagtype).toBe("Audit");
    });
  });

  beforeAll(async () => {
    const logs = await setup(ctx);
    CUSTOMER = findAndEncode("customer", "organization", logs);
    TEMPLATE = map(
      findAndEncode("task", "worktemplate", logs),
      id => new Task({ id }),
    );
    INSTANCE = map(
      findAndEncode("instance", "workinstance", logs),
      id => new Task({ id }),
    );
    NEXT_TEMPLATE = map(
      findAndEncode("next", "worktemplate", logs),
      id => new Task({ id }),
    );
  });

  afterAll(async () => {
    await cleanup(CUSTOMER);
  });
});
