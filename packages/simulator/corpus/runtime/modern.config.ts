import { setCurrentIdentity } from "@/auth";
import { sql } from "@/datasources/postgres";
import type { Context } from "@/schema";
import type { Location } from "@/schema/platform/archetype/location";
import { type Customer, createEmptyCustomer } from "@/test/prelude";
import { assertNonNull } from "@/util";
import {
  DEFAULT_RUNTIME_CHILD_LOCATIONS,
  DEFAULT_RUNTIME_LOCATION_TYPE,
  createDefaultDowntimeTemplate,
  createDefaultIdleTimeTemplate,
  createDefaultRuntimeTemplate,
} from "./lib";

/**
 * Create a so-called "modern" Runtime customer. The only tangible difference
 * here is that our Run tasks are truly on-demand, i.e. they support lazy
 * instantiation, i.e. we do NOT pre-create instances nor do we "respawn"
 * instance when the Runs go in-progress.
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

    // Same as the legacy setup.
    const site = await customer.addLocation({ name, type: name }, ctx, sql);

    // Same as the legacy setup.
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

    return customer;
  });
}
