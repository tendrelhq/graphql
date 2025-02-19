import { sql } from "@/datasources/postgres";
import {
  assert,
  assertNonNull,
  assertUnderlyingType,
  normalizeBase64,
} from "@/util";
import { GraphQLError } from "graphql";
import type { ID } from "grats";
import type { Fragment } from "postgres";
import { match } from "ts-pattern";
import type { Mutation } from "../root";
import { decodeGlobalId } from "../system";
import type { Component } from "../system/component";
import type { Refetchable } from "../system/node";
import type { Edge } from "../system/pagination";
import type { GqlUrl } from "../system/scalars/url";
import type { Context } from "../types";

/**
 * @gqlInterface
 */
export interface Identity extends Component {
  /**
   * @gqlField
   * @killsParentOnException
   */
  readonly id: ID;
}

export type ConstructorArgs = {
  id: ID;
  url: string | URL;
};

/** @gqlType */
export class Attachment implements Component, Refetchable {
  readonly __typename = "Attachment" as const;
  readonly _type: string;
  readonly _id: string;
  readonly id: ID;

  #url: URL;

  constructor(
    args: ConstructorArgs,
    private ctx: Context,
  ) {
    this.id = normalizeBase64(args.id);
    const { type, id } = decodeGlobalId(this.id);
    this._type = assertUnderlyingType("workpictureinstance", type);
    this._id = id;
    this.#url = args.url instanceof URL ? args.url : new URL(args.url);
  }

  /**
   * If you are using [Relay](https://relay.dev), make sure you annotate this
   * field with `@catch(to: RESULT)` to avoid intermittent S3 errors from
   * crashing the entire fragment.
   *
   * @gqlField
   */
  async attachment(): Promise<GqlUrl> {
    return await this.ctx.orm.s3.load(this.#url);
  }

  /** @gqlField */
  async attachedBy(): Promise<Identity | null> {
    const [row] = await sql<[{ _key: string }?]>`
    select wi.workerinstanceuuid as _key
    from public.workpictureinstance as wpi
    inner join
        public.workerinstance as wi
        on wpi.workpictureinstancemodifiedby = wi.workerinstanceid
    where wpi.workpictureinstanceuuid = ${this._id}
  `;

    if (row) {
      const worker = await this.ctx.orm.worker.load(row._key);
      return {
        __typename: "Worker",
        ...worker,
      } as Identity;
    }

    return null;
  }
}

/** @gqlField */
export async function attach(
  _: Mutation,
  entity: ID,
  attachments: GqlUrl[],
  ctx: Context,
): Promise<Edge<Attachment>[]> {
  const { type, id, suffix } = decodeGlobalId(entity);
  if (type !== "workinstance" && type !== "workresultinstance") {
    throw new GraphQLError("Entity cannot be attached to", {
      extensions: {
        code: "E_NOT_ATTACHABLE",
      },
    });
  }

  const frag: Fragment = match(type)
    .with(
      "workinstance",
      () => sql`
        select
            workinstancecustomerid as _owner,
            workinstanceid as _entity,
            null::bigint as _field
        from public.workinstance
        where id = ${id}
      `,
    )
    .with(
      "workresultinstance",
      () => sql`
        select
            workresultinstancecustomerid as _owner,
            workresultinstanceworkinstanceid as _entity,
            workresultinstanceid as _field
        from public.workresultinstance
        where
            workresultinstanceworkinstanceid = (
                select workinstanceid
                from public.workinstance
                where id = ${id}
            )
            and workresultinstanceworkresultid = (
                select workresultid
                from public.workresult
                where id = ${assertNonNull(suffix?.at(0), "invariant violated")}
            )
      `,
    )
    .exhaustive();

  const values = attachments.map(a => [a.toString()]);
  const rows = await sql<ConstructorArgs[]>`
    with
        entity as (${frag}),

        inputs (url) as (
          values ${sql(values)}
        )

    insert into public.workpictureinstance (
        workpictureinstancecustomerid,
        workpictureinstanceworkinstanceid,
        workpictureinstanceworkresultinstanceid,
        workpictureinstancestoragelocation,
        workpictureinstancemodifiedby
    )
    select
        e._owner,
        e._entity,
        e._field,
        a.url,
        auth.current_identity(e._owner, ${ctx.auth.userId})
    from
        entity as e,
        inputs as a
    returning
        encode(('workpictureinstance:' || workpictureinstanceuuid)::bytea, 'base64') as id,
        workpictureinstancestoragelocation as url
    ;
  `;

  return rows.map(row => ({
    cursor: id,
    node: new Attachment(row, ctx),
  }));
}
