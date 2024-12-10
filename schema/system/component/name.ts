import { decodeGlobalId } from "@/schema/system";
import type { Component } from "@/schema/system/component";
import type { DynamicString } from "@/schema/system/i18n";
import type { Refetchable } from "@/schema/system/node";
import type { Context } from "@/schema/types";
import type { ID } from "grats";

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
  name(ctx: Context): Promise<DynamicString> {
    return ctx.orm.dynamicString.load(this.id);
  }
}

export interface Named {
  displayName(): Promise<DisplayName>;
}
