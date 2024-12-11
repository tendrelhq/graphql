import { sql } from "@/datasources/postgres";
import { GraphQLError } from "graphql";
import type { ID } from "grats";
import { decodeGlobalId, encodeGlobalId } from ".";
import { Location } from "../platform/archetype/location";
import type { Query } from "../root";
import type { Context } from "../types";
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
 * @gqlField
 * @killsParentOnException
 */
export async function node(
  _: Query,
  args: { id: ID },
  ctx: Context,
): Promise<Refetchable> {
  const { type, id } = decodeGlobalId(args.id);
  switch (type) {
    case "location":
      return new Location(args, ctx);
    case "name":
      return {
        __typename: "Name",
        ...(await ctx.orm.name.load(id)),
        // biome-ignore lint/suspicious/noExplicitAny:
      } as any;
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
          // FIXME: We don't know the parent here!
          return new Task({ id: args.id }, ctx);
      }
    }
    case "workresult":
    case "workresultinstance":
      return {
        __typename: "ChecklistResult",
        id: args.id,
        // biome-ignore lint/suspicious/noExplicitAny:
      } as any;
    case "workpictureinstance":
      // biome-ignore lint/suspicious/noExplicitAny:
      return ctx.orm.attachment.byId.load(args.id) as any;
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
