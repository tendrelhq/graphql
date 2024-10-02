import { sql } from "@/datasources/postgres";
import type { MutationResolvers } from "@/schema";
import { decodeGlobalId } from "@/schema/system";
import { match } from "ts-pattern";

export const setStatus: NonNullable<MutationResolvers["setStatus"]> = async (
  _,
  args,
) => {
  const { type, id } = decodeGlobalId(args.id);

  const targetStatus = (() => {
    switch (true) {
      case "open" in args.input:
        return "Open";
      case "inProgress" in args.input:
        return "In Progress";
      case "closed" in args.input:
        return "Complete";
      default: {
        const _: never = args.input;
        throw "invariant violated";
      }
    }
  })();

  await match(type)
    .with(
      "workinstance",
      () => sql`
          WITH inputs AS (
              SELECT systagid AS status
              FROM public.systag
              WHERE
                  systagparentid = 705
                  AND
                  systagtype = ${targetStatus}
          )

          UPDATE public.workinstance
          SET
              workinstancestatusid = inputs.status,
              workinstancemodifieddate = now()
          FROM inputs
          WHERE
              id = ${id}
              AND
              workinstancestatusid != inputs.status
      `,
    )
    .otherwise(() => {
      throw "invariant violated";
    });

  return {
    __typename: "Checklist",
    id: args.id,
    // biome-ignore lint/suspicious/noExplicitAny:
  } as any;
};
