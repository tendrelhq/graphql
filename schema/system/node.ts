import { sql } from "@/datasources/postgres";
import { assertUnderlyingType } from "@/util";
import { GraphQLError } from "graphql";
import type { ID } from "grats";
import { match } from "ts-pattern";
import { decodeGlobalId, encodeGlobalId } from ".";
import { Location } from "../platform/archetype/location";
import {
  Attachment,
  type ConstructorArgs as AttachmentConstructorArgs,
} from "../platform/attachment";
import type { Context } from "../types";
import { DisplayName } from "./component/name";
import { Task } from "./component/task";

/**
 * Indicates an object that is "refetchable".
 *
 * @gqlInterface Node
 */
export interface Refetchable {
  /** GraphQL typename. */
  readonly __typename: string;

  /**
   * Internal type, which typically maps to the underlying database table name.
   */
  readonly _type: string;

  /**
   * Internal identifier, which typically maps to the underlying database
   * primary key.
   */
  readonly _id: string;
}

/**
 * A globally unique opaque identifier for a node.
 *
 * @see https://graphql.org/learn/global-object-identification/
 *
 * @gqlField
 * @killsParentOnException
 */
export function id(node: Refetchable): ID {
  return encodeGlobalId({
    type: node._type,
    id: node._id,
  });
}

/**
 * Delete a Node.
 * This operation is a no-op if the node has already been deleted.
 *
 * @gqlMutationField
 */
export async function deleteNode(node: ID, ctx: Context): Promise<ID[]> {
  const { id, ...g } = decodeGlobalId(node);
  // Nodes map to tables.
  const type = assertUnderlyingType(
    [
      // These are the ones we have standardized on in the legacy model:
      "workresult",
      "workresultinstance",
      "workinstance",
      "worktemplate",
      // These are new under the entity model:
      "entity_instance",
    ],
    g.type,
  );

  const rows = await match(type)
    .with("entity_instance", async () => {
      const [{ owner }] = await sql`
        select entityinstanceownerentityuuid as owner
        from entity.entityinstance
        where entityinstanceuuid = ${id};
      `;
      const res = await ctx.pgrst.rpc("delete_entity_instance", { owner, id });
      if (res.error) {
        throw new GraphQLError("Failed to delete Node", {
          originalError: res.error,
        });
      }
      return res.data;
    })
    .otherwise(
      () => sql`
        select exe.*
        from engine1.delete_node(${type}, ${id}) as ops,
             engine1.execute(ops.*) as exe
        ;
      `,
    );

  console.debug(`engine1.execution.result:\n${JSON.stringify(rows, null, 2)}`);

  if (rows.length) {
    return [node];
  }

  throw new GraphQLError("Failed to delete Node");
}

/**
 * @gqlQueryField
 * @killsParentOnException
 */
export async function node(
  args: { id: ID },
  ctx: Context,
): Promise<Refetchable> {
  const { type, id } = decodeGlobalId(args.id);
  switch (type) {
    case "location":
      return new Location(args);
    case "name":
      return new DisplayName(args.id);
    case "organization":
      return {
        __typename: "Organization",
        ...(await ctx.orm.organization.load(id)),
        // biome-ignore lint/suspicious/noExplicitAny:
      } as any;
    case "user":
      return {
        __typename: "User",
        ...(await ctx.orm.user.byId.load(id)),
        // biome-ignore lint/suspicious/noExplicitAny:
      } as any;
    case "workinstance":
    case "worktemplate": {
      const [row] = await sql<[{ type: string }?]>`
        SELECT systagtype AS type
        FROM public.worktemplatetype
        INNER JOIN public.systag
            ON worktemplatetypesystagid = systagid
        WHERE worktemplatetypeworktemplateid IN (
          ${
            type === "workinstance"
              ? sql`SELECT workinstanceworktemplateid FROM public.workinstance WHERE id = ${id}`
              : sql`SELECT worktemplateid FROM public.worktemplate WHERE id = ${id}`
          }
        )
      `;
      switch (row?.type) {
        case "Checklist":
          return {
            __typename: "Checklist",
            id: args.id,
            // biome-ignore lint/suspicious/noExplicitAny:
          } as any;
        default:
          return new Task({ id: args.id });
      }
    }
    case "workresult":
    case "workresultinstance":
      return {
        __typename: "ChecklistResult",
        id: args.id,
        // biome-ignore lint/suspicious/noExplicitAny:
      } as any;
    case "workpictureinstance": {
      const [row] = await sql<[AttachmentConstructorArgs]>`
        select
            encode(('workpictureinstance:' || workpictureinstanceuuid)::bytea, 'base64') as id,
            workpictureinstancestoragelocation as url
        from public.workpictureinstance
        where workpictureinstanceuuid = ${id}
      `;
      return new Attachment(row, ctx);
    }
    default: {
      console.warn(`Unknown node type: '${type}'`);
      throw new GraphQLError("Unknown node type", {
        extensions: {
          code: "BAD_REQUEST",
        },
      });
    }
  }
}
