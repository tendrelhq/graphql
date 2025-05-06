import { setCurrentIdentity } from "@/auth";
import { sql } from "@/datasources/postgres";
import type { Context } from "@/schema";
import type { Location } from "@/schema/platform/archetype/location";
import { type Customer, createEmptyCustomer } from "@/test/prelude";
import { assertNonNull } from "@/util";
import type { Faker } from "@faker-js/faker";
import {
  DEFAULT_RUNTIME_CHILD_LOCATIONS,
  DEFAULT_RUNTIME_LOCATION_TYPE,
  createDefaultDowntimeTemplate,
  createDefaultIdleTimeTemplate,
  createDefaultRuntimeTemplate,
} from "../prelude";

/**
 * Create the canonical Runtime customer, i.e. before Batch and Reason Codes
 * when there was just Run, Down and Idle. This test is intended to be a sort of
 * backwards compatibility test, e.g. it passes Task ids into `advance` where
 * the newer model expects Transition ids instead (to enable cross-location
 * instantiation). In practice this configuration will soon be defunct (as soon
 * as folks upgrade to the latest app build).
 */
export async function createCustomer(
  args: {
    faker: Faker;
    seed: number;
  },
  ctx: Context,
): Promise<Customer> {
  return await sql.begin(async sql => {
    await setCurrentIdentity(sql, ctx);

    const customerName = args.seed.toString();
    const customer = await createEmptyCustomer(
      { name: customerName },
      ctx,
      sql,
    );

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
    const site = await customer.addLocation(
      { name: customerName, type: customerName },
      ctx,
      sql,
    );

    // The canonical Runtime setup involves five Locations and just the basic
    // Run, Idle, and Down templates. The user can transition from Run into Idle
    // or Down, and then back to Run. The Run template is "on demand" (in the
    // legacy sense) which is to say that we should both create the initial
    // instances as well as an eager instantiation rule that fulfills the legacy
    // "respawn on-demand on in-progress" rule.

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
      {
        location: site,
        // The canonical configuration did this by default (it was the only way
        // at the time) and so we maintain that behavior here for the sake of
        // testing. Nowadays we *default* to supporting lazy instantiation.
        supportsLazyInstantiation: false,
      },
      ctx,
      sql,
    );

    // In alignment with the above configuration, we create the legacy respawn
    // rule as well as the initial instances at each Location.
    await run.createTransition(
      {
        whenStatusChangesTo: "InProgress",
        instantiate: { template: run.id },
      },
      ctx,
      sql,
    );
    await run.ensureInstantiableAt(
      { locations: lines.map(l => l.id) },
      ctx,
      sql,
    );
    for (const line of lines) {
      await run.instantiate({ location: line.id }, ctx, sql);
    }

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

    return customer;
  });
}
