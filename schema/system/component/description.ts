import type { Context } from "@/schema/types";
import { assertUnderlyingType, normalizeBase64 } from "@/util";
import type { ID } from "grats";
import { decodeGlobalId } from "..";
import type { Component } from "../component";
import type { DynamicString, DynamicStringInput } from "../i18n";
import type { Refetchable } from "../node";

export type ConstructorArgs = {
  id: ID;
};

/**
 * @gqlType
 */
export class Description implements Component, Refetchable {
  readonly __typename = "Description" as const;
  readonly _type: string;
  readonly _id: string;
  readonly id: ID;

  constructor(args: ConstructorArgs) {
    this.id = normalizeBase64(args.id);
    const { type, id } = decodeGlobalId(this.id);
    this._type = assertUnderlyingType("workdescription", type);
    this._id = id;
  }

  /**
   * @gqlField
   * @deprecated Use Description.locale and/or Description.value.
   */
  async description(ctx: Context): Promise<DynamicString> {
    return await ctx.orm.dynamicString.load(this.id);
  }

  /**
   * @gqlField
   */
  async locale(ctx: Context): Promise<string> {
    const s = await ctx.orm.dynamicString.load(this.id);
    return s.locale;
  }

  /**
   * @gqlField
   */
  async value(ctx: Context): Promise<string> {
    const s = await ctx.orm.dynamicString.load(this.id);
    return s.value;
  }
}

/**
 * @gqlInput
 */
export type DescriptionInput = {
  id?: ID | null;
  value: DynamicStringInput;
};
