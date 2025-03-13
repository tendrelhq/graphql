import { decodeGlobalId } from "@/schema/system";
import type { Component } from "@/schema/system/component";
import type { DynamicString } from "@/schema/system/i18n";
import type { Refetchable } from "@/schema/system/node";
import type { Context } from "@/schema/types";
import type { ID } from "grats";

/** @gqlInput */
export type UpdateNameInput = {
  id: ID;
  activatedAt?: string | null;
  deactivatedAt?: string | null;
  languageId: ID;
  value: string;
};

/** @gqlType */
export class DisplayName implements Component, Refetchable {
  readonly __typename = "DisplayName" as const;
  readonly _type: string;
  readonly _id: string;

  constructor(public id: ID) {
    const { type, ...identifier } = decodeGlobalId(id);
    this._type = type;
    this._id = identifier.id;
  }

  /** @gqlField */
  async locale(ctx: Context): Promise<string> {
    const s = await ctx.orm.dynamicString.load(this.id);
    return s.locale;
  }

  /**
   * @deprecated Use the DisplayName.value and/or DisplayName.locale instead.
   * @gqlField
   */
  name(ctx: Context): Promise<DynamicString> {
    return ctx.orm.dynamicString.load(this.id);
  }

  /** @gqlField */
  async value(ctx: Context): Promise<string> {
    const s = await ctx.orm.dynamicString.load(this.id);
    return s.value;
  }
}
