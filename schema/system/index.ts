import z, { type Infer } from "myzod";

const GlobalId = z.object({
  type: z.string(),
  id: z.string(),
});

/**
 * Global Identifier. Externally it just an opaque string. Internally it may
 * have some meaning. Right now this is just the base64 encoding of the
 * object's underlying type (e.g. workinstance) and its uuid (i.e. primary
 * key).
 */
type GlobalId = Infer<typeof GlobalId>;

export function decodeGlobalId(id: string): GlobalId {
  return GlobalId.parse(JSON.parse(Buffer.from(id, "base64").toString()));
}

export function encodeGlobalId(id: GlobalId) {
  return Buffer.from(JSON.stringify(id)).toString("base64");
}

// biome-ignore lint/suspicious/noExplicitAny:
export function isGlobalId(value: any): value is GlobalId {
  if (typeof value?.type === "string" && typeof value?.id === "string") {
    return true;
  }

  return false;
}
