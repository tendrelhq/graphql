import { sql } from "@/datasources/postgres";
import type { MutationResolvers } from "@/schema";

export const createUser: NonNullable<MutationResolvers['createUser']> = async (
  _,
  { input },
  ctx,
) => {
  const [user] = await sql<[{ id: string }?]>`
      INSERT INTO public.worker (
          workerfullname,
          workeridentityid,
          workeridentitysystemid,
          workerlanguageid,
          workerstartdate,
          workerenddate
      ) VALUES (
          ${input.name},
          ${null},
          (
            SELECT systagid
            FROM public.systag
            WHERE systaguuid = ${input.authentication_provider_id ?? null}
          ),
          (
              SELECT systagid
              FROM public.systag
              WHERE systaguuid = ${input.language_id}
          ),
          ${new Date()},
          ${input.active ? null : new Date()}
      )
      ON CONFLICT DO NOTHING
      RETURNING workeruuid AS id;
  `;

  if (!user) {
    // This implies ON CONFLICT DO NOTHING hit.
    // i.e. the user already exists, so we just need to find it.
    const [user] = await sql<[{ id: string }?]>`
        SELECT workeruuid AS id
        FROM public.worker
        WHERE
            workeridentityid IS NOT NULL
            AND workeridentityid = ${input.authentication_provider_id ?? null}
    `;
    if (!user) throw "must've messed up the unique constraints";
    return ctx.orm.user.byId.load(user.id);
  }

  return ctx.orm.user.byId.load(user.id);
};
