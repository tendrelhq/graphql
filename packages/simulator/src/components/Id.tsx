import { normalizeBase64 } from "@/util";
import { Text } from "ink";

export interface IdProps {
  id: string;
  slice?: number;
}

export function Id({ id, slice = 8 }: IdProps) {
  return <Text color="gray">{normalizeBase64(id).slice(-slice)}</Text>;
}
