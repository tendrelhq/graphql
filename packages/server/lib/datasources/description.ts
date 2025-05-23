import { decodeGlobalId } from "@/schema/system";
import { Description } from "@/schema/system/component/description";
import { assertNonNull, normalizeBase64 } from "@/util";
import DataLoader from "dataloader";
import type { Request } from "express";
import type { ID } from "grats";
import { sql, unionAll } from "./postgres";

type SourceLocations = {
  workinstance: string[];
  workresult: string[];
  worktemplate: string[];
  workresultinstance: [string, string][];
};

export function makeDescriptionLoader(_req: Request) {
  return new DataLoader<ID, Description | null>(async keys => {
    const sources: SourceLocations = {
      workinstance: [],
      workresult: [],
      worktemplate: [],
      workresultinstance: [],
    };

    for (const key of keys) {
      const { type, id, suffix } = decodeGlobalId(key);
      switch (type) {
        case "workinstance":
        case "workresult":
        case "worktemplate": {
          sources[type].push(id);
          break;
        }
        case "workresultinstance": {
          // workresultinstance:<workinstanceid>:<workresultid>
          sources[type].push([id, assertNonNull(suffix?.at(0))]);
          break;
        }
        default: {
          console.warn(`Unknown underlying type for Description: ${type}`);
          break;
        }
      }
    }

    const queries = [];
    if (sources.workinstance.length) {
      queries.push(
        sql<{ key: string; id: ID[] }[]>`
          select
              encode(('workinstance:' || wi.id)::bytea, 'base64') as key,
              array_agg(
                  encode(('workdescription:' || wd.id)::bytea, 'base64') order by wd.workdescriptionid desc
              ) as id
          from public.workinstance as wi
          inner join public.workdescription as wd
              on wi.workinstanceworktemplateid = wd.workdescriptionworktemplateid
              and wd.workdescriptionworkresultid is null
              and wd.workdescriptiondeleted = false
              and wd.workdescriptiondraft = false
              and (
                  wd.workdescriptionenddate is null
                  or wd.workdescriptionenddate > now()
              )
          where wi.id in ${sql(sources.workinstance)}
          group by key
        `,
      );
    }
    if (sources.workresult.length) {
      queries.push(
        sql<{ key: string; id: ID[] }[]>`
          select
              encode(('workresult:' || wr.id)::bytea, 'base64') as key,
              array_agg(
                  encode(('workdescription:' || wd.id)::bytea, 'base64') order by wd.workdescriptionid desc
              ) as id
          from public.workresult as wr
          inner join public.workdescription as wd
              on wr.workresultworktemplateid = wd.workdescriptionworktemplateid
              and wr.workresultid = wd.workdescriptionworkresultid
              and wd.workdescriptiondeleted = false
              and wd.workdescriptiondraft = false
              and (
                  wd.workdescriptionenddate is null
                  or wd.workdescriptionenddate > now()
              )
          where wr.id in ${sql(sources.workresult)}
          group by key
        `,
      );
    }
    if (sources.worktemplate.length) {
      queries.push(
        sql<{ key: string; id: ID[] }[]>`
          select
              encode(('worktemplate:' || wt.id)::bytea, 'base64') as key,
              array_agg(
                  encode(('workdescription:' || wd.id)::bytea, 'base64') order by wd.workdescriptionid desc
              ) as id
          from public.worktemplate as wt
          inner join public.workdescription as wd
              on wt.worktemplateid = wd.workdescriptionworktemplateid
              and wd.workdescriptionworkresultid is null
              and wd.workdescriptiondeleted = false
              and wd.workdescriptiondraft = false
              and (
                  wd.workdescriptionenddate is null
                  or wd.workdescriptionenddate > now()
              )
          where wt.id in ${sql(sources.worktemplate)}
          group by key
        `,
      );
    }
    if (sources.workresultinstance.length) {
      queries.push(
        sql<{ key: string; id: ID[] }[]>`
          select
              encode(('workresultinstance:' || wi.id || ':' || wr.id)::bytea, 'base64') as key,
              array_agg(
                  encode(('workdescription:' || wd.id)::bytea, 'base64') order by wd.workdescriptionid desc
              ) as id
          from public.workresultinstance as wri
          inner join public.workinstance as wi
              on wri.workresultinstanceworkinstanceid = wi.workinstanceid
          inner join public.workresult as wr
              on wri.workresultinstanceworkresultid = wr.workresultid
          inner join public.workdescription as wd
              on wr.workresultworktemplateid = wd.workdescriptionworktemplateid
              and wr.workresultid = wd.workdescriptionworkresultid
              and wd.workdescriptiondeleted = false
              and wd.workdescriptiondraft = false
              and (
                  wd.workdescriptionenddate is null
                  or wd.workdescriptionenddate > now()
              )
          where (wi.id, wr.id) in (${sql(sources.workresultinstance)})
          group by key
        `,
      );
    }

    if (!queries.length) return keys.map(() => null);

    const rows = await sql<{ key: string; id: ID[] }[]>`${unionAll(queries)}`;
    return keys.map(key => {
      const id = rows
        .find(row => normalizeBase64(row.key) === normalizeBase64(key))
        ?.id.at(0);
      return id ? new Description({ id }) : null;
    });
  });
}
