import type { Key } from "ink";

export function anyModifier(key: Key) {
  return key.ctrl || key.shift || key.meta;
}
