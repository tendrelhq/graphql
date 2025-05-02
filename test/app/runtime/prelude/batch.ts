import { setCurrentIdentity } from "@/auth";
import { sql } from "@/datasources/postgres";
import type { Context } from "@/schema";
import type { Location } from "@/schema/platform/archetype/location";
import { type Customer, createEmptyCustomer } from "@/test/prelude";
import { assertNonNull } from "@/util";
import {
  DEFAULT_RUNTIME_CHILD_LOCATIONS,
  DEFAULT_RUNTIME_LOCATION_TYPE,
  createDefaultBatchTemplate,
  createDefaultDowntimeTemplate,
  createDefaultIdleTimeTemplate,
  createDefaultRuntimeTemplate,
} from "../prelude";

/**
 * Create a Batch-enabled Runtime customer. This is the latest and greatest
 * configuration, although it may yet be a bit buggy :/
 */
export async function createCustomer(
  name: string,
  ctx: Context,
): Promise<Customer> {
  return await sql.begin(async sql => {
    await setCurrentIdentity(sql, ctx);

    const customer = await createEmptyCustomer({ name }, ctx, sql);

    await customer.addWorker(
      {
        identityId: assertNonNull(
          process.env.X_TENDREL_USER,
          "Set the X_TENDREL_USER environment variable to the workeridentityid of your choosing. This will be the initial Admin. Note that the test is set up for CI and using a non-standard Admin identity may lead to snapshot failures, which is okay. To replicate CI exactly, use the Admin identity from the e2e GitHub workflow.",
        ),
      },
      ctx,
      sql,
    );

    // The initial site has the same name as the customer.
    const site = await customer.addLocation({ name, type: name }, ctx, sql);

    // As with the canonical Runtime configuration, there are five Locations as
    // well as the usual Run, Down and Idle templates. Different from the
    // canonical configuration is that the Run template does NOT have a respawn
    // rule but is configured to support lazy instantiation. This affects the
    // frontend, since you will see Tasks come back that do not have an fsm,
    // parent, state, etc... because they are "on demand" tasks, i.e.
    // worktemplates. Therefore the process of "starting a run" will be slightly
    // different, since you will need to, e.g., `router.replace(...)` in
    // `onComplete` after the first `advance` to start the run.

    const lines: Location[] = [];
    let order = 0;
    for (const name of DEFAULT_RUNTIME_CHILD_LOCATIONS) {
      const line = await site.insertChild(
        {
          name: name,
          order: order++,
          type: DEFAULT_RUNTIME_LOCATION_TYPE,
        },
        ctx,
        sql,
      );
      lines.push(line);
    }

    const batch = await createDefaultBatchTemplate(
      { location: site },
      ctx,
      sql,
    );

    // Note the differences with the canonical setup:
    // 1. the Run template supports lazy instantiation (i.e. you can always do a Run at any location).
    // 2. there is no respawn rule (because^)
    // 3. we create no initial instances
    const run = await createDefaultRuntimeTemplate(
      { location: site },
      ctx,
      sql,
    );
    await run.ensureInstantiableAt(
      { locations: lines.map(l => l.id) },
      ctx,
      sql,
    );

    // For InProgress Batches, allow the user to explicitly instantiate a Run
    // at any of the following Locations. The newly instantiated Run will be
    // part of the Batch chain.
    for (const line of lines) {
      await batch.createTransition(
        {
          whenStatusChangesTo: "InProgress",
          instantiate: {
            template: run.id,
            atLocation: line.id,
          },
          type: "lazy",
        },
        ctx,
        sql,
      );
    }

    // The rest is the same as in the canonical setup.
    const down = await createDefaultDowntimeTemplate(
      { location: site },
      ctx,
      sql,
    );
    await down.ensureInstantiableAt(
      { locations: lines.map(l => l.id) },
      ctx,
      sql,
    );

    const idle = await createDefaultIdleTimeTemplate(
      { location: site },
      ctx,
      sql,
    );
    await idle.ensureInstantiableAt(
      { locations: lines.map(l => l.id) },
      ctx,
      sql,
    );

    // Note that these two transitions use *lazy instantiation*.
    // (This is what `withType: "On Demand"` means)
    //
    // Runtime -> Downtime
    run.createTransition(
      {
        whenStatusChangesTo: "InProgress",
        instantiate: { template: down.id },
        type: "lazy",
      },
      ctx,
      sql,
    );
    // Runtime -> Idle Time
    run.createTransition(
      {
        whenStatusChangesTo: "InProgress",
        instantiate: { template: idle.id },
        type: "lazy",
      },
      ctx,
      sql,
    );

    // TODO: use Keller's API?
    await sql`call entity.import_entity(null)`;

    return customer;
  });
}
