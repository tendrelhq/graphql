import {
  ClerkExpressRequireAuth,
  type StrictAuthProp,
} from "@clerk/clerk-sdk-node";
import { sql } from "./datasources/postgres";

declare global {
  namespace Express {
    interface Request extends StrictAuthProp {}
  }
}

export type Auth = StrictAuthProp["auth"];

export default {
  clerk() {
    return ClerkExpressRequireAuth({
      //
    });
  },
};

export async function protect(
  { orgId, userId }: { orgId: string; userId: string },
  allowed: string[],
) {
  const rows = await sql<{ type: string }[]>`
      SELECT s.systagtype
      FROM public.workerinstance AS w
      INNER JOIN public.systag AS s
          ON w.workerinstanceuserroleid = s.systagid
      WHERE
          w.workerinstancecustomerid = (
              SELECT customerid
              FROM public.customer
              WHERE customeruuid = ${orgId}
          )
          AND w.workerinstanceworkerid = (
              SELECT workerid
              FROM public.worker
              WHERE workeridentityid = ${userId}
          );
  `;

  return rows.some(r => allowed.includes(r.type));
}
