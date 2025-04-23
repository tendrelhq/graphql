import { setCurrentIdentity } from "@/auth";
import { sql } from "@/datasources/postgres";
import { assertNonNull } from "@/util";
import { createEmptyCustomer, createTestContext } from "../prelude";

export async function setup() {
  const ctx = await createTestContext();
  return await sql.begin(async sql => {
    await setCurrentIdentity(sql, ctx);
    const customer = await createEmptyCustomer(
      { name: "Frozen Tendy Factory" },
      ctx,
      sql,
    );
    const workerIdentity = assertNonNull(process.env.X_TENDREL_USER);
    const _worker = await customer.addWorker(
      { identityId: workerIdentity },
      ctx,
      sql,
    );

    const factory = await customer.addLocation(
      { name: "Frozen Tendy Factory", type: "Frozen Tendy Factory" },
      ctx,
      sql,
    );
    const mixingLine = await factory.insertChild(
      { name: "Mixing Line", order: 0, type: "Runtime Location" },
      ctx,
      sql,
    );
    const fillLine = await factory.insertChild(
      { name: "Fill Line", order: 1, type: "Runtime Location" },
      ctx,
      sql,
    );
    const assemblyLine = await factory.insertChild(
      { name: "Assembly Line", order: 2, type: "Runtime Location" },
      ctx,
      sql,
    );
    const cartoningLine = await factory.insertChild(
      { name: "Cartoning Line", order: 3, type: "Runtime Location" },
      ctx,
      sql,
    );
    const packagingLine = await factory.insertChild(
      { name: "Packaging Line", order: 4, type: "Runtime Location" },
      ctx,
      sql,
    );

    const batchTemplate = await factory.createTemplate(
      {
        name: "Batch",
        fields: [
          { name: "Customer", order: 0, type: "string" },
          { name: "Product Name", order: 1, type: "string" },
          { name: "SKU", order: 2, type: "string" },
        ],
        types: ["Batch"],
      },
      ctx,
      sql,
    );
    const runTemplate = await factory.createTemplate(
      {
        name: "Run",
        fields: [
          // Note that we still have the primary/order requirement for
          // Overrides (primary + 0 => start, 1 => end).
          // This will be removed in the future.
          {
            name: "Override Start Time",
            type: "timestamp",
            isPrimary: true,
            order: 0,
          },
          {
            name: "Override End Time",
            type: "timestamp",
            isPrimary: true,
            order: 1,
          },
          { name: "Run Output", type: "number", order: 2 },
          { name: "Reject Count", type: "number", order: 3 },
          { name: "Comments", type: "string", order: 99 },
        ],
        types: ["Trackable", "Runtime"],
      },
      ctx,
      sql,
    );
    const downTemplate = await factory.createTemplate(
      {
        name: "Downtime",
        fields: [
          {
            name: "Override Start Time",
            type: "timestamp",
            isPrimary: true,
            order: 0,
          },
          {
            name: "Override End Time",
            type: "timestamp",
            isPrimary: true,
            order: 1,
          },
          { name: "Description", type: "string", order: 99 },
        ],
        types: ["Downtime"],
      },
      ctx,
      sql,
    );
    const idleTemplate = await factory.createTemplate(
      {
        name: "Idle Time",
        fields: [
          {
            name: "Override Start Time",
            type: "timestamp",
            isPrimary: true,
            order: 0,
          },
          {
            name: "Override End Time",
            type: "timestamp",
            isPrimary: true,
            order: 1,
          },
          { name: "Description", type: "string", order: 99 },
        ],
        types: ["Idle Time"],
      },
      ctx,
      sql,
    );

    // Constraints.
    await batchTemplate.ensureInstantiableAt(
      { locations: [factory.id] },
      ctx,
      sql,
    );
    await batchTemplate.ensureInstantiableAt(
      { locations: [factory.id] },
      ctx,
      sql,
    );
    for (const t of [runTemplate, downTemplate, idleTemplate]) {
      await t.ensureInstantiableAt(
        {
          locations: [
            mixingLine.id,
            fillLine.id,
            assemblyLine.id,
            cartoningLine.id,
            packagingLine.id,
          ],
        },
        ctx,
        sql,
      );
    }

    // Rules.
    // When the Batch goes in-progress, prompt the user to choose where it
    // should go next. For the purposes of this test, we will allow for the
    // Batch to start at any Line.
    for (const l of [
      mixingLine,
      fillLine,
      assemblyLine,
      cartoningLine,
      packagingLine,
    ]) {
      await batchTemplate.createTransition(
        {
          whenStatusChangesTo: "InProgress",
          instantiate: {
            template: runTemplate.id,
            atLocation: l.id,
            withType: "On Demand", // Choice.
          },
        },
        ctx,
        sql,
      );
    }

    // Mixing -> Fill
    await runTemplate.createTransition(
      {
        atLocation: mixingLine.id,
        whenStatusChangesTo: "Closed",
        instantiate: {
          template: runTemplate.id,
          atLocation: fillLine.id,
          withType: "Task", // Eager. This is the default.
        },
      },
      ctx,
      sql,
    );

    // Fill -> Assembly
    await runTemplate.createTransition(
      {
        atLocation: fillLine.id,
        whenStatusChangesTo: "Closed",
        instantiate: {
          template: runTemplate.id,
          atLocation: assemblyLine.id,
        },
      },
      ctx,
      sql,
    );

    // Assembly -> Cartoning
    await runTemplate.createTransition(
      {
        atLocation: assemblyLine.id,
        whenStatusChangesTo: "Closed",
        instantiate: {
          template: runTemplate.id,
          atLocation: cartoningLine.id,
        },
      },
      ctx,
      sql,
    );

    // Cartoning -> Packaging
    await runTemplate.createTransition(
      {
        atLocation: cartoningLine.id,
        whenStatusChangesTo: "Closed",
        instantiate: {
          template: runTemplate.id,
          atLocation: packagingLine.id,
        },
      },
      ctx,
      sql,
    );

    return {
      customer,
      worker: workerIdentity,
      factory,
      mixingLine,
      fillLine,
      assemblyLine,
      cartoningLine,
      packagingLine,
      batchTemplate,
      runTemplate,
      downTemplate,
      idleTemplate,
    };
  });
}
