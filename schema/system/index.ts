import z from "myzod";

const GlobalId = z.string().map(id => {
  const parts = id.split(":");
  if (parts.length < 2) {
    throw "invariant violated: invalid global identifier";
  }
  return {
    type: parts[0],
    id: parts[1],
    suffix: parts.slice(2),
  };
});

/**
 * Global Identifier. Externally it just an opaque string. Internally it may
 * have some meaning. Right now this is just the base64 encoding of the
 * object's underlying type (e.g. workinstance) and its uuid (i.e. primary
 * key).
 */
type GlobalId = {
  type: string;
  id: string;
  suffix?: string | string[];
};

export function decodeGlobalId(id: unknown): GlobalId {
  return GlobalId.parse(decodeGlobalIdRaw(id));
}

export function decodeGlobalIdRaw(id: unknown): string {
  if (typeof id !== "string") {
    throw `invariant violated: global ids should be string but got ${typeof id}`;
  }
  return Buffer.from(decodeURIComponent(id), "base64").toString();
}

export function encodeGlobalId({ type, id, ...rest }: GlobalId) {
  const suffix = rest.suffix
    ? typeof rest.suffix === "string"
      ? rest.suffix
      : rest.suffix.join(":")
    : "";
  return Buffer.from(
    `${type}:${id}${suffix.length ? `:${suffix}` : ""}`,
  ).toString("base64");
}

// biome-ignore lint/suspicious/noExplicitAny:
export function isGlobalId(value: any): value is GlobalId {
  if (typeof value?.type === "string" && typeof value?.id === "string") {
    return true;
  }

  return false;
}
